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
