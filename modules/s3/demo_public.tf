# DEMO kich ban 2: S3 bucket public, khong ma hoa, khong chan public.
resource "aws_s3_bucket" "demo_public" {
  bucket = "${var.project_name}-demo-public-${local.account_id}"
}

resource "aws_s3_bucket_ownership_controls" "demo_public" {
  bucket = aws_s3_bucket.demo_public.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "demo_public" {
  bucket = aws_s3_bucket.demo_public.id
  acl    = "public-read-write"

  depends_on = [aws_s3_bucket_ownership_controls.demo_public]
}
