# DEMO W8 — CỐ Ý CHƯA AN TOÀN. KHÔNG MERGE VÀO MAIN.
# Bucket này không có Public Access Block và không bật versioning,
# để chứng minh Checkov chặn cấu hình sai ngay từ PR (CKV2_AWS_6, CKV_AWS_21).
resource "aws_s3_bucket" "insecure_demo" {
  bucket        = "${var.project_name}-insecure-demo-${local.account_id}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-insecure-demo"
    Tier = "insecure-demo"
  }
}
