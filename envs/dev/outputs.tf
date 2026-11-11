output "vpc_id" {
  description = "ID của VPC dev"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Danh sách public subnet"
  value       = module.network.public_subnet_ids
}

output "app_bucket_name" {
  description = "Tên bucket ứng dụng (an toàn)"
  value       = module.s3.app_bucket_name
}

output "reports_bucket_name" {
  description = "Bucket lưu báo cáo Checkov + Prowler (W10)"
  value       = module.s3.reports_bucket_name
}

output "cspm_readonly_role_arn" {
  description = "ARN role read-only cho Prowler"
  value       = module.iam.cspm_readonly_role_arn
}

output "deploy_role_arn" {
  description = "ARN role Deploy cho GitHub Actions (điền vào workflow khi dùng OIDC)"
  value       = module.iam.deploy_role_arn
}
