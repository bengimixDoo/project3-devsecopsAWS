variable "aws_region" {
  description = "AWS region cho môi trường dev"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Tiền tố đặt tên tài nguyên"
  type        = string
  default     = "project3"
}

variable "vpc_cidr" {
  description = "Dải CIDR cho VPC dev"
  type        = string
  default     = "10.20.0.0/16"
}
