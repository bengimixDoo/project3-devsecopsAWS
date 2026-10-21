provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "project3-devsecops-cspm"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}
