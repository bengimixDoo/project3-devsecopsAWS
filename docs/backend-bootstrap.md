# Bootstrap backend S3 cho Terraform state

State chứa thông tin nhạy cảm nên phải để trên S3 có mã hóa, không để local.
Bucket state phải được tạo **trước** khi dùng backend (vấn đề con-gà-quả-trứng).

## Cách 1 — tạo nhanh bằng AWS CLI (khuyến nghị cho dev)

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=ap-southeast-1
BUCKET="project3-tfstate-${ACCOUNT_ID}"

aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

# Bật versioning (phục hồi state khi lỡ hỏng)
aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

# Mã hóa mặc định
aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Chặn public hoàn toàn
aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

## Sau khi có bucket

1. Mở `envs/dev/backend.tf`, bỏ comment khối `backend "s3"`, thay `<ACCOUNT_ID>`.
2. Chạy:

```bash
cd envs/dev
terraform init -migrate-state
```

## Locking

Terraform >= 1.10 có **S3 native lock** (`use_lockfile = true`) — không cần tạo
bảng DynamoDB nữa. Khối backend đã bật sẵn tùy chọn này.

## Dọn tài nguyên

Sau khi demo xong: `terraform destroy` trong `envs/dev`, rồi mới xóa bucket state
(xóa bucket trước sẽ mất state và không destroy được hạ tầng còn lại).
