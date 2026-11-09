variable "project_name" {
  description = "Tiền tố đặt tên tài nguyên"
  type        = string
}

variable "report_retention_days" {
  description = "Số ngày giữ báo cáo quét trong bucket reports (W10)."
  type        = number
  default     = 90
}
