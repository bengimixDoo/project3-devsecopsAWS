# Backend S3 cho Terraform state.
#
# Bucket state: project3-tfstate-434481793703 (đã bootstrap: versioning + SSE + block public).
# S3 native locking (use_lockfile) của Terraform >= 1.10 -> không cần DynamoDB.
#
# Migrate state: terraform init -migrate-state

terraform {
  backend "s3" {
    bucket       = "project3-tfstate-434481793703"
    key          = "envs/dev/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
