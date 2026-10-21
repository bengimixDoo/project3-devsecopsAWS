# Project 3 — DevSecOps tích hợp CSPM cho hạ tầng AWS bằng IaC

Workflow: Terraform → GitHub Actions (CI) → Checkov (quét IaC) → terraform apply → Prowler (CSPM, CIS AWS Benchmark) → Báo cáo / Cảnh báo.

## Cấu trúc thư mục (dự kiến)

```
modules/             # Terraform modules: network, s3, iam, ecr
envs/dev/            # Cấu hình môi trường dev + backend S3
.github/workflows/   # Pipeline CI/CD (plan, checkov, apply, prowler)
scripts/             # Script tổng hợp báo cáo, cảnh báo
docs/                # Tài liệu kiến trúc, báo cáo tuần
```
