# W8 — Checkov security gate (shift-left)

## Thiết kế

- Job `checkov` trong `.github/workflows/ci-terraform.yml` chạy trên **mọi push và PR**, không cần AWS credentials (chỉ quét code).
- `plan` và `apply` có `needs: checkov` → Checkov đỏ thì **không plan, không apply được**.
- Bộ check thi hành nằm trong `.checkov.yaml` (baseline có chủ đích, 9 check S3/ECR). Các check ngoài phạm vi MVP (KMS CMK, VPC flow logs, S3 access logging...) để dành cho W13.
- `.github/scripts/checkov_gate.py` đọc kết quả JSON, tạo annotation `::error` đúng file/dòng trên PR, ghi bảng tóm tắt vào Job Summary và quyết định pass/fail.

## Vì sao bucket insecure không còn nằm trong module s3

Checkov quét tĩnh mọi khối `resource`, **kể cả khi `count = 0`** (đã kiểm chứng: run đầu tiên đỏ vì `aws_s3_bucket.insecure_demo` dù mặc định tắt). Vì vậy bucket insecure được tách sang nhánh demo `w8-demo-insecure` (file `modules/s3/insecure_demo.tf`), không nằm trên `main`.

## Kịch bản demo

1. Trên GitHub mở PR `w8-demo-insecure` → `main`.
2. Job `checkov (security gate)` **đỏ**, annotation hiện ngay trong tab *Files changed* tại `modules/s3/insecure_demo.tf`:
   - `CKV2_AWS_6` thiếu Public Access Block
   - `CKV_AWS_21` thiếu versioning
3. Job `validate + plan` bị **skipped** → cấu hình sai không đi tới AWS.
4. Đóng PR (hoặc xóa file insecure, push lại) → Checkov **xanh**, plan chạy.

## Bật chặn merge (làm một lần trên GitHub)

Settings → Branches → Add branch ruleset / protection cho `main` → **Require status checks to pass** → chọn `checkov (security gate)`.
Không bật thì PR vẫn đỏ nhưng nút Merge chưa bị khóa.
