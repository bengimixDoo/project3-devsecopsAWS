# Backend S3 cho Terraform state.
#
# CHƯA bật ở W5: bucket state phải được tạo TRƯỚC (xem docs/backend-bootstrap.md).
# Sau khi bucket tồn tại, bỏ comment khối dưới và chạy: terraform init -migrate-state
#
# Dùng S3 native locking (use_lockfile) của Terraform >= 1.10 -> không cần DynamoDB.
#
# terraform {
#   backend "s3" {
#     bucket       = "project3-tfstate-<ACCOUNT_ID>"   # tên bucket toàn cục, thay <ACCOUNT_ID>
#     key          = "envs/dev/terraform.tfstate"
#     region       = "ap-southeast-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
