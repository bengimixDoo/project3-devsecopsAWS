# Môi trường dev — nối các module nền tảng (W6).
# Giữ tối giản để tránh phí (không NAT Gateway, không RDS).

module "network" {
  source = "../../modules/network"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "s3" {
  source = "../../modules/s3"

  project_name                = var.project_name
  enable_insecure_demo_bucket = var.enable_insecure_demo_bucket
}

module "iam" {
  source = "../../modules/iam"

  project_name              = var.project_name
  create_cspm_readonly_role = var.create_cspm_readonly_role
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
}
