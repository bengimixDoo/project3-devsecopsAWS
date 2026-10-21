output "app_bucket_name" {
  description = "Tên bucket ứng dụng (an toàn)"
  value       = aws_s3_bucket.app.id
}

output "app_bucket_arn" {
  description = "ARN bucket ứng dụng"
  value       = aws_s3_bucket.app.arn
}

output "insecure_demo_bucket_name" {
  description = "Tên bucket demo chưa an toàn (null nếu không bật)"
  value       = try(aws_s3_bucket.insecure_demo[0].id, null)
}
