output "repository_url" {
  description = "URL ECR repository (dùng để push image)"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN ECR repository"
  value       = aws_ecr_repository.this.arn
}
