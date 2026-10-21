# Module: iam

Placeholder — sẽ hiện thực ở **W6–W7**.

Dự kiến:
- OIDC provider cho GitHub + IAM Role `deploy` (assume qua `sts:AssumeRoleWithWebIdentity`, scope theo repo/branch bằng `sub`).
- IAM Role `cspm-readonly` riêng cho Prowler (`SecurityAudit` + `ViewOnlyAccess`).
