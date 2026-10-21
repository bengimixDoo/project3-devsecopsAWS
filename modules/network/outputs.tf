output "vpc_id" {
  description = "ID của VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Danh sách ID public subnet"
  value       = aws_subnet.public[*].id
}
