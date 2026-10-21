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

# ---------- OIDC + role Deploy cho GitHub Actions (W7) ----------
variable "create_github_oidc" {
  description = "Tạo GitHub OIDC provider + IAM Role Deploy để GitHub Actions assume (không dùng access key tĩnh)."
  type        = bool
  default     = false
}

variable "github_owner" {
  description = "Chủ sở hữu repo GitHub (user/org), vd 'bengimixDoo'."
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "Tên repo GitHub, vd 'project3-devsecopsAWS'."
  type        = string
  default     = ""
}

variable "github_allowed_refs" {
  description = "Danh sách điều kiện sub được phép assume role Deploy. Mặc định: nhánh main (apply) + mọi PR của repo (plan)."
  type        = list(string)
  default     = ["ref:refs/heads/main", "pull_request"]
}

variable "github_sub_claims" {
  description = "Ghi đè trực tiếp danh sách pattern sub (StringLike, cho phép '*'). Để trống thì sinh tự động từ owner/repo + allowed_refs."
  type        = list(string)
  default     = []
}

variable "deploy_role_managed_policy_arns" {
  description = "Managed policy gắn cho role Deploy. Mặc định PowerUserAccess + IAMFullAccess cho demo; siết lại ở W13."
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/PowerUserAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
  ]
}
