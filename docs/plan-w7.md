# W7 — Xác thực OIDC + CI

Mục tiêu: GitHub Actions xác thực vào AWS bằng **OIDC + IAM Role tạm thời**, không
dùng access key tĩnh. CI: `plan` khi mở PR hoặc push `main`, `apply` chỉ chạy thủ công.

## 1. Tạo OIDC provider + role Deploy (chạy local một lần)

`create_github_oidc` mặc định bật trong `envs/dev/variables.tf`, nên local và CI cho
cùng một plan:

```powershell
cd envs\dev
# export credentials sonplt ra env (xem dev.auto.tfvars) rồi:
terraform apply
```

Lấy ARN role Deploy:

```powershell
terraform output -raw deploy_role_arn
# vd: arn:aws:iam::434481793703:role/project3-github-deploy
```

Trust policy đã khóa:
- `aud = sts.amazonaws.com`
- `sub` khớp đúng ID số của owner/repo (default của `github_sub_claims`), chỉ cho:
  - `repo:bengimixDoo@96771380/project3-devsecopsAWS@1428064514:ref:refs/heads/main`
  - `repo:bengimixDoo@96771380/project3-devsecopsAWS@1428064514:pull_request`

Không dùng wildcard ở owner/repo: `bengimixDoo*` khớp cả account khác có cùng tiền tố
tên. Muốn cho phép thêm nhánh thì thêm một dòng vào `github_sub_claims`.

## 2. Khai báo ARN cho GitHub Actions

Trên GitHub: **Settings → Secrets and variables → Actions → Variables** → tạo
biến `AWS_DEPLOY_ROLE_ARN` = ARN ở trên. Workflow đọc qua
`vars.AWS_DEPLOY_ROLE_ARN`.

> Lưu ý: chạy `apply` thủ công từ nhánh khác `main` sẽ fail ở bước assume role, vì
> trust policy chỉ cho `main` và PR. Đây là hành vi mong muốn.

## 3. Pipeline

- **PR hoặc push vào main** → job `plan`: fmt + validate + plan (không apply).
- **Actions → Run workflow trên main, gõ `apply`** → job `apply`.

Checkov (gate HIGH/CRITICAL, SARIF) thêm ở **W8**.
