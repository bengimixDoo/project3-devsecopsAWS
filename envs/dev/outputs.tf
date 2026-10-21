output "vpc_id" {
  description = "ID của VPC dev"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Danh sách public subnet"
  value       = module.network.public_subnet_ids
}
