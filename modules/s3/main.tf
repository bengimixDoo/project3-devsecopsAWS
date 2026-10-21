# Module s3 — bucket demo cho project3.
# Bucket chính tuân thủ chuẩn bảo mật. Có tùy chọn thêm bucket "chưa an toàn"
# làm mục tiêu cho Checkov/Prowler bắt lỗi ở W8-W9.

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# ---------- Bucket an toàn (mẫu đúng) ----------
resource "aws_s3_bucket" "app" {
  bucket = "${var.project_name}-app-${local.account_id}"

  tags = {
    Name = "${var.project_name}-app"
    Tier = "secure"
  }
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket                  = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------- Bucket cố ý chưa an toàn (chỉ bật khi cần demo) ----------
# CẢNH BÁO: tài nguyên này cố tình vi phạm CIS để Checkov/Prowler bắt lỗi.
# Không mã hóa, không chặn public, không versioning -> dùng để trình diễn gate ở W8.
resource "aws_s3_bucket" "insecure_demo" {
  count         = var.enable_insecure_demo_bucket ? 1 : 0
  bucket        = "${var.project_name}-insecure-demo-${local.account_id}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-insecure-demo"
    Tier = "insecure-demo"
  }
}
