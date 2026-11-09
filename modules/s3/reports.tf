# ---------- Bucket lưu báo cáo quét (W10) ----------
# Lưu kết quả Checkov + Prowler theo tool/ngày/commit để so sánh trước/sau khi sửa.
# Bản mới nhất ở latest/ là mốc để W11 biết finding nào là MỚI.
resource "aws_s3_bucket" "reports" {
  bucket = "${var.project_name}-reports-${local.account_id}"

  tags = {
    Name = "${var.project_name}-reports"
    Tier = "secure"
  }
}

resource "aws_s3_bucket_versioning" "reports" {
  bucket = aws_s3_bucket.reports.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "reports" {
  bucket = aws_s3_bucket.reports.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "reports" {
  bucket                  = aws_s3_bucket.reports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Báo cáo chứa thông tin cấu hình account: giữ có hạn để không phình chi phí.
resource "aws_s3_bucket_lifecycle_configuration" "reports" {
  bucket = aws_s3_bucket.reports.id

  rule {
    id     = "expire-old-reports"
    status = "Enabled"

    filter {}

    expiration {
      days = var.report_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Chỉ cho truy cập qua HTTPS.
data "aws_iam_policy_document" "reports_tls_only" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.reports.arn,
      "${aws_s3_bucket.reports.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "reports" {
  bucket = aws_s3_bucket.reports.id
  policy = data.aws_iam_policy_document.reports_tls_only.json

  # Policy phải đặt sau Public Access Block, nếu không AWS có thể từ chối.
  depends_on = [aws_s3_bucket_public_access_block.reports]
}
