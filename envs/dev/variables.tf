variable "aws_region" {
  description = "AWS region cho môi trường dev"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile dùng khi chạy local (vd 'sonplt'). Để trống khi chạy trên CI bằng OIDC."
  type        = string
  default     = ""
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

variable "enable_insecure_demo_bucket" {
  description = "Bật bucket S3 cố ý chưa an toàn để demo gate Checkov/Prowler (W8). Mặc định tắt."
  type        = bool
  default     = false
}

variable "create_cspm_readonly_role" {
  description = "Tạo IAM Role read-only cho Prowler (CSPM)."
  type        = bool
  default     = true
}
