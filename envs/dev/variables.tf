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

variable "create_cspm_readonly_role" {
  description = "Tạo IAM Role read-only cho Prowler (CSPM)."
  type        = bool
  default     = true
}

variable "create_github_oidc" {
  description = "Tạo GitHub OIDC provider + role Deploy (W7)."
  type        = bool
  default     = false
}

variable "github_owner" {
  description = "Chủ sở hữu repo GitHub."
  type        = string
  default     = "bengimixDoo"
}

variable "github_repo" {
  description = "Tên repo GitHub."
  type        = string
  default     = "project3-devsecopsAWS"
}

variable "github_sub_claims" {
  description = "Ghi đè pattern sub OIDC (StringLike, cho phép '*'). Để trống thì sinh tự động từ owner/repo."
  type        = list(string)
  default     = []
}
