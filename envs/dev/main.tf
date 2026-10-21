# Môi trường dev — chỉ nối module nền tảng ở W5/W6.
# Giữ tối giản để tránh phí (không NAT Gateway, không RDS).

module "network" {
  source = "../../modules/network"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

# Các module dưới đây là placeholder, sẽ nối ở W6:
# module "s3"  { source = "../../modules/s3"  ... }
# module "iam" { source = "../../modules/iam" ... }
# module "ecr" { source = "../../modules/ecr" ... }
