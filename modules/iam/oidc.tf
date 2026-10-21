# OIDC provider cho GitHub Actions + role Deploy (W7).
# Cho phép GitHub Actions assume role tạm thời qua sts:AssumeRoleWithWebIdentity,
# KHÔNG cần lưu AWS access key tĩnh trong GitHub Secrets.

locals {
  oidc_enabled = var.create_github_oidc && var.github_owner != "" && var.github_repo != ""
  # Điều kiện sub: nếu truyền github_sub_claims thì dùng trực tiếp (pattern StringLike,
  # cho phép wildcard); nếu không thì sinh từ owner/repo + allowed_refs.
  #
  # LƯU Ý (xác định bằng CloudTrail): một số repo GitHub gửi sub có nhúng ID số, vd
  #   repo:bengimixDoo@96771380/project3-devsecopsAWS@1428064514:ref:refs/heads/main
  # Khi đó phải truyền github_sub_claims với wildcard quanh @<id>, vd:
  #   ["repo:bengimixDoo*/project3-devsecopsAWS*:*"]
  oidc_subs = length(var.github_sub_claims) > 0 ? var.github_sub_claims : [for r in var.github_allowed_refs : "repo:${var.github_owner}/${var.github_repo}:${r}"]
}

resource "aws_iam_openid_connect_provider" "github" {
  count = local.oidc_enabled ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # Thumbprint của GitHub OIDC. AWS hiện bỏ qua thumbprint cho các IdP đã biết,
  # nhưng field vẫn bắt buộc về mặt API.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name = "${var.project_name}-github-oidc"
  }
}

data "aws_iam_policy_document" "github_deploy_assume" {
  count = local.oidc_enabled ? 1 : 0

  statement {
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
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.oidc_subs
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  count              = local.oidc_enabled ? 1 : 0
  name               = "${var.project_name}-github-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_deploy_assume[0].json

  tags = {
    Name = "${var.project_name}-github-deploy"
    Role = "deploy"
  }
}

resource "aws_iam_role_policy_attachment" "github_deploy" {
  for_each   = local.oidc_enabled ? toset(var.deploy_role_managed_policy_arns) : toset([])
  role       = aws_iam_role.github_deploy[0].name
  policy_arn = each.value
}
