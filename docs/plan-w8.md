# W8 — Checkov security gate (shift-left)

## Thiết kế

- Job `checkov` trong `.github/workflows/ci-terraform.yml` chạy trên **mọi PR và push**, không cần AWS credentials (chỉ quét code).
- `plan` và `apply` có `needs: checkov` → Checkov đỏ thì **không plan, không apply được**.
- `.checkov.yaml` chạy toàn bộ check Terraform mặc định + check tự viết, trừ các waiver đã ghi lý do.
- `.github/scripts/checkov_gate.py` đọc kết quả JSON và quyết định pass/fail, tạo annotation đúng file/dòng trên PR và bảng tóm tắt trong Job Summary.
- SARIF được upload **trước** gate, nên finding vẫn lên tab *Security → Code scanning* khi build bị chặn.

## Ngưỡng chặn

| Severity | Hành vi |
|---|---|
| CRITICAL, HIGH | `::error`, job đỏ, chặn merge |
| MEDIUM, LOW | `::warning`, job vẫn xanh |

Checkov bản không có API key trả về `severity = None` (đã kiểm chứng), nên project tự gán severity trong `.github/checkov-severity.json`. Check chưa có trong bảng được tính là MEDIUM: check mới của Checkov chỉ cảnh báo, không tự chặn build; muốn chặn thì thêm vào bảng.

Gate cũng đỏ nếu kết quả quét không đáng tin: có file lỗi parse, hoặc không có check nào chạy.

## Check tự viết

`.github/checkov-policies/s3_sse_required.yaml` (`CKV2_P3_1`) bắt S3 bucket không khai báo khối mã hóa. Lý do cần viết riêng: bucket không khai báo gì vẫn đạt `CKV_AWS_19` vì AWS mặc định mã hóa bucket mới, còn `CKV_AWS_145` đòi KMS CMK và đã được waive vì chi phí.

## Finding còn lại trên main (chỉ cảnh báo)

| Check | Severity | Xử lý dự kiến |
|---|---|---|
| `CKV2_AWS_11` VPC flow logs | MEDIUM | W13 |
| `CKV2_AWS_12` default security group | MEDIUM | W13 |
| `CKV_AWS_130` subnet tự cấp public IP | MEDIUM | W13 |
| `CKV_AWS_18` S3 access logging | LOW | W13 |
| `CKV2_AWS_61` S3 lifecycle | LOW | W13 |
| `CKV_AWS_394` pin availability zone | LOW | W13 |

## Vì sao tài nguyên insecure không nằm trên main

Checkov quét tĩnh mọi khối `resource`, **kể cả khi `count = 0`** (đã kiểm chứng: run đầu tiên đỏ vì `aws_s3_bucket.insecure_demo` dù mặc định tắt). Vì vậy tài nguyên insecure chỉ nằm trên nhánh demo `w8-demo-insecure`. **Không merge và không apply nhánh này.**

## Kịch bản demo

1. Mở PR `w8-demo-insecure` → `main`. Nhánh này thêm `modules/network/insecure_demo.tf` (Security Group mở cổng 22 cho `0.0.0.0/0`) và `modules/s3/insecure_demo.tf` (bucket không mã hóa, không chặn public).
2. Job `checkov (security gate)` **đỏ**, annotation hiện trong tab *Files changed*:
   - `CKV_AWS_24` (CRITICAL): mở cổng 22 cho `0.0.0.0/0`
   - `CKV2_AWS_6` (HIGH): thiếu Public Access Block
   - `CKV2_P3_1` (HIGH): không khai báo mã hóa
3. `CKV_AWS_21` (thiếu versioning, MEDIUM) chỉ là cảnh báo, chứng minh ngưỡng chặn hoạt động.
4. Job `validate + plan` bị **skipped** → cấu hình sai không đi tới AWS. Nút Merge bị khóa.
5. Mở tab *Security → Code scanning* để xem finding.
6. Xóa hai file insecure, push lại → Checkov **xanh**, plan chạy.

## Chặn merge

Ruleset `Block merge` của `main` yêu cầu status check `checkov (security gate)`. Workflow không lọc `paths` trên PR, vì nếu không chạy thì PR chỉ sửa docs sẽ kẹt ở trạng thái chờ check.

## Giới hạn đã biết

- Checkov không chặn role Deploy dù role có `PowerUserAccess` + `IAMFullAccess`: quyền đến từ managed policy, không nằm trong code. Xử lý ở W13.
- Severity là do project tự gán, không phải điểm chính thức của Checkov.
