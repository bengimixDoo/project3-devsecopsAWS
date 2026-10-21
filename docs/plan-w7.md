# W7 — Xác thực OIDC + CI

Mục tiêu: GitHub Actions xác thực vào AWS bằng **OIDC + IAM Role tạm thời**, không
dùng access key tĩnh. CI: `plan` khi mở PR, `apply` khi merge vào `main`.

## 1. Tạo OIDC provider + role Deploy (chạy local một lần)

Bật biến `create_github_oidc` khi apply env dev:

```powershell
cd envs\dev
# export credentials sonplt ra env (xem dev.auto.tfvars) rồi:
terraform apply -var="create_github_oidc=true"
```

Lấy ARN role Deploy:

```powershell
terraform output -raw deploy_role_arn
# vd: arn:aws:iam::434481793703:role/project3-github-deploy
```

Trust policy đã khóa:
- `aud = sts.amazonaws.com`
- `sub = repo:bengimixDoo/project3-devsecopsAWS:ref:refs/heads/main`

Muốn cho phép thêm nhánh/PR thì truyền `github_allowed_refs` (vd thêm
`"pull_request"` cho job plan ở PR).

## 2. Khai báo ARN cho GitHub Actions

Trên GitHub: **Settings → Secrets and variables → Actions → Variables** → tạo
biến `AWS_DEPLOY_ROLE_ARN` = ARN ở trên. Workflow đọc qua
`vars.AWS_DEPLOY_ROLE_ARN`.

> Lưu ý: PR cũng cần assume role để chạy `plan`. Nếu trust policy chỉ cho `main`,
> job plan ở PR sẽ fail assume. Thêm ref cho PR bằng `github_allowed_refs`, ví dụ:
> `["ref:refs/heads/main", "pull_request"]`.

## 3. Pipeline

- **PR** → job `plan`: fmt + validate + plan (không apply).
- **Push/merge vào main** → job `apply`: apply tự động.

Checkov (gate HIGH/CRITICAL, SARIF) thêm ở **W8**.
