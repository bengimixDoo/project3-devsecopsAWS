output "cspm_readonly_role_arn" {
  description = "ARN role read-only cho Prowler (null nếu không tạo)"
  value       = try(aws_iam_role.cspm_readonly[0].arn, null)
}
