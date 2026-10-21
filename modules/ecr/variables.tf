variable "project_name" {
  description = "Tiền tố đặt tên tài nguyên"
  type        = string
}

variable "repo_name" {
  description = "Tên ECR repository (không gồm tiền tố project)"
  type        = string
  default     = "app"
}

variable "max_image_count" {
  description = "Số image tối đa giữ lại; image cũ hơn bị lifecycle policy dọn"
  type        = number
  default     = 10
}
