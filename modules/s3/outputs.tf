output "app_bucket_name" {
  description = "Tên bucket ứng dụng (an toàn)"
  value       = aws_s3_bucket.app.id
}

output "app_bucket_arn" {
  description = "ARN bucket ứng dụng"
  value       = aws_s3_bucket.app.arn
}

output "reports_bucket_name" {
  description = "Tên bucket lưu báo cáo quét"
  value       = aws_s3_bucket.reports.id
}

output "reports_bucket_arn" {
  description = "ARN bucket lưu báo cáo quét"
  value       = aws_s3_bucket.reports.arn
}
