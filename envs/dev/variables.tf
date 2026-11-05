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
  description = "Tạo GitHub OIDC provider + role Deploy (W7). Mặc định bật để CI không plan xóa chính role nó đang dùng."
  type        = bool
  default     = true
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
  description = "Danh sách sub OIDC được assume role Deploy. Khóa theo ID số của owner/repo: chỉ nhánh main (plan, apply) và PR (plan). Không dùng wildcard ở owner/repo."
  type        = list(string)
  default = [
    "repo:bengimixDoo@96771380/project3-devsecopsAWS@1428064514:ref:refs/heads/main",
    "repo:bengimixDoo@96771380/project3-devsecopsAWS@1428064514:pull_request",
  ]
}

variable "cspm_sub_claims" {
  description = "Danh sách sub OIDC được assume role CSPM read-only. Chỉ nhánh main: code của PR không được dùng quyền đọc toàn account."
  type        = list(string)
  default = [
    "repo:bengimixDoo@96771380/project3-devsecopsAWS@1428064514:ref:refs/heads/main",
  ]
}
