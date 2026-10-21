# W5 — Chốt thiết kế & môi trường

Mục tiêu tuần: dựng khung repo, chốt công cụ, chuẩn bị môi trường và cơ chế kiểm soát chi phí. **Chưa apply lên AWS.**

## Checklist

- [x] Khung repo: `modules/{network,s3,iam,ecr}`, `envs/dev/`, `.github/workflows/`, `scripts/`, `docs/`
- [x] Module `network` nền tảng (VPC + public subnet + IGW, **không NAT GW**)
- [x] Pin phiên bản: Terraform >= 1.10, provider aws ~> 5.60
- [x] Cấu hình backend S3 (viết sẵn, comment chờ bootstrap) + S3 native locking
- [x] Tài liệu bootstrap backend state (`docs/backend-bootstrap.md`)
- [x] Workflow CI placeholder (`fmt` / `validate` / `plan`)
- [ ] Cấu hình AWS credentials ở máy (`aws configure` / `aws sso login`)
- [ ] Bootstrap bucket state theo `docs/backend-bootstrap.md`
- [ ] Tạo AWS Budgets alert ngưỡng ~5 USD (Console hoặc CLI)
- [ ] Tạo repo trên GitHub + `git remote add origin` + push

## Công cụ đã chốt

| Lớp | Công cụ | Ghi chú |
|-----|---------|---------|
| IaC | Terraform >= 1.10 | S3 native state lock |
| Shift-left (IaC scan) | Checkov | xuất SARIF |
| CSPM runtime | Prowler v4 | đối chiếu CIS AWS Benchmark |
| CI/CD | GitHub Actions | xác thực OIDC, không access key |
| Registry | Amazon ECR | scan-on-push |

## Việc cần bạn làm thủ công (cần quyền AWS / GitHub)

1. `aws configure` hoặc `aws sso login` để có credentials.
2. Chạy phần bootstrap trong `docs/backend-bootstrap.md`.
3. Tạo repo rỗng trên GitHub, rồi link remote.

Các bước này cần tài khoản AWS/GitHub của bạn nên tôi không tự chạy được.
