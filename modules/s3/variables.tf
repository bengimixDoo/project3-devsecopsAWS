variable "project_name" {
  description = "Tiền tố đặt tên tài nguyên"
  type        = string
}

variable "enable_insecure_demo_bucket" {
  description = "Tạo thêm 1 bucket CỐ Ý chưa an toàn làm mục tiêu demo cho Checkov/Prowler (W8-W9). Mặc định tắt."
  type        = bool
  default     = false
}
