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

output "ecr_repository_url" {
  description = "URL ECR repository"
  value       = module.ecr.repository_url
}

output "cspm_readonly_role_arn" {
  description = "ARN role read-only cho Prowler"
  value       = module.iam.cspm_readonly_role_arn
}
