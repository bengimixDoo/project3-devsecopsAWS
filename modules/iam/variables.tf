variable "project_name" {
  description = "Tiền tố đặt tên tài nguyên"
  type        = string
}

variable "create_cspm_readonly_role" {
  description = "Tạo IAM Role read-only cho Prowler (CSPM). Bật ở W9."
  type        = bool
  default     = true
}

variable "cspm_trusted_principal_arns" {
  description = "Danh sách ARN được phép assume role CSPM read-only (vd user/role chạy Prowler). Mặc định chính account hiện tại."
  type        = list(string)
  default     = []
}
