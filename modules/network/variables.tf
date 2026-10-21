variable "project_name" {
  description = "Tiền tố đặt tên tài nguyên"
  type        = string
}

variable "vpc_cidr" {
  description = "Dải CIDR cho VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_count" {
  description = "Số public subnet tạo ra (trải trên các AZ)"
  type        = number
  default     = 2
}
