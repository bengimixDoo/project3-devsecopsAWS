# Module iam — role read-only cho CSPM (Prowler).
# Role Deploy qua OIDC sẽ thêm ở W7 (cần GitHub OIDC provider trước).

data "aws_caller_identity" "current" {}

locals {
  # Mặc định cho phép chính account hiện tại assume; có thể truyền ARN cụ thể.
  cspm_trusted = length(var.cspm_trusted_principal_arns) > 0 ? var.cspm_trusted_principal_arns : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

# ---------- Role read-only cho Prowler (least-privilege) ----------
data "aws_iam_policy_document" "cspm_assume" {
  count = var.create_cspm_readonly_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = local.cspm_trusted
    }
  }

  # W9: cho workflow Prowler assume qua OIDC, không dùng access key tĩnh.
  dynamic "statement" {
    for_each = local.oidc_enabled && length(var.cspm_sub_claims) > 0 ? [1] : []
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [aws_iam_openid_connect_provider.github[0].arn]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = ["sts.amazonaws.com"]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:sub"
        values   = var.cspm_sub_claims
      }
    }
  }
}

resource "aws_iam_role" "cspm_readonly" {
  count              = var.create_cspm_readonly_role ? 1 : 0
  name               = "${var.project_name}-cspm-readonly"
  assume_role_policy = data.aws_iam_policy_document.cspm_assume[0].json

  tags = {
    Name = "${var.project_name}-cspm-readonly"
    Role = "cspm"
  }
}

# Prowler cần quyền đọc cấu hình để đối chiếu CIS Benchmark.
resource "aws_iam_role_policy_attachment" "cspm_security_audit" {
  count      = var.create_cspm_readonly_role ? 1 : 0
  role       = aws_iam_role.cspm_readonly[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "cspm_view_only" {
  count      = var.create_cspm_readonly_role ? 1 : 0
  role       = aws_iam_role.cspm_readonly[0].name
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

# W10: quyền ghi DUY NHẤT của role CSPM, giới hạn trong bucket báo cáo.
data "aws_iam_policy_document" "cspm_reports_write" {
  count = var.create_cspm_readonly_role && var.cspm_reports_write ? 1 : 0

  statement {
    sid       = "ListReports"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.reports_bucket_arn]
  }

  statement {
    sid       = "ReadWriteReports"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${var.reports_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "cspm_reports_write" {
  count  = var.create_cspm_readonly_role && var.cspm_reports_write ? 1 : 0
  name   = "${var.project_name}-reports-write"
  role   = aws_iam_role.cspm_readonly[0].id
  policy = data.aws_iam_policy_document.cspm_reports_write[0].json
}
