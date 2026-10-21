provider "aws" {
  region = var.aws_region

  # Local: điền profile (vd "sonplt"). CI (OIDC): để trống chuỗi "".
  profile = var.aws_profile != "" ? var.aws_profile : null

  default_tags {
    tags = {
      Project     = "project3-devsecops-cspm"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}
