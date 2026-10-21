output "cspm_readonly_role_arn" {
  description = "ARN role read-only cho Prowler (null nếu không tạo)"
  value       = try(aws_iam_role.cspm_readonly[0].arn, null)
}

output "deploy_role_arn" {
  description = "ARN role Deploy mà GitHub Actions assume qua OIDC (null nếu không tạo)"
  value       = try(aws_iam_role.github_deploy[0].arn, null)
}

output "github_oidc_provider_arn" {
  description = "ARN GitHub OIDC provider (null nếu không tạo)"
  value       = try(aws_iam_openid_connect_provider.github[0].arn, null)
}
