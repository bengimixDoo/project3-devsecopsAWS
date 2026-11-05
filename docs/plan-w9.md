# W9 — CSPM runtime: Prowler

Checkov (W8) đọc code, nên không thấy những gì xảy ra sau khi deploy. Prowler đọc cấu hình AWS thật và đối chiếu với CIS AWS Foundations Benchmark, nên bắt được cả lỗi cấp account và thay đổi làm tay trên Console (drift).

## Thiết kế

- Workflow `.github/workflows/cspm-prowler.yml`, Prowler 5.47.0, framework `cis_7.0_aws`, region `ap-southeast-1`.
- Chạy theo lịch (03:00 thứ Hai giờ Việt Nam), bấm thủ công, hoặc tự chạy sau mỗi lần `apply` thành công.
- Role `project3-cspm-readonly` (SecurityAudit + ViewOnlyAccess), tách khỏi role Deploy. Trust OIDC khóa đúng nhánh `main`, nên code của PR không dùng được quyền đọc toàn account.
- Báo cáo HTML/OCSF/CSV lưu thành artifact 30 ngày. W10 sẽ chuyển sang bucket S3.
- `.github/scripts/prowler_summary.py` ghi bảng tóm tắt vào Job Summary.

Finding **không** làm job đỏ: lỗi cấu hình là kết quả để báo cáo, không phải lỗi pipeline. Job chỉ đỏ khi quét hỏng hoặc không ra kết quả. Cảnh báo chủ động là việc của W11.

## Cài đặt (làm một lần)

1. Thêm repo variable `AWS_CSPM_ROLE_ARN` = `arn:aws:iam::434481793703:role/project3-cspm-readonly`. Nếu thiếu, job Prowler sau apply sẽ đỏ dù apply vẫn thành công.
2. Merge PR rồi chạy **Actions → ci-terraform → Run workflow** trên `main`, gõ `apply`, để cập nhật trust của role CSPM. Job Prowler tự chạy ngay sau đó.

## Kịch bản demo drift

Mục tiêu: chứng minh Prowler bắt được thứ mà Checkov không thể thấy.

1. Chạy Prowler lần đầu, lưu báo cáo "trước".
2. Sửa tay ngoài Terraform: gỡ Public Access Block của bucket `project3-app-434481793703`.
3. Checkov trên `main` vẫn xanh vì code không đổi.
4. Chạy lại Prowler: `s3_bucket_level_public_access_block` chuyển sang FAIL.
5. `terraform plan` báo sẽ tạo lại Public Access Block. `terraform apply` khôi phục, chạy lại Prowler thấy PASS.

## Việc tiếp theo

- Sau báo cáo đầu tiên, thêm mutelist cho các finding đã chấp nhận rủi ro, mỗi mục ghi rõ lý do (`--mutelist-file`).
- Nhiều control CIS ở cấp account (CloudTrail, Config, root MFA, password policy) chưa có trong Terraform. Cần module baseline để số liệu % CIS ở W13 có thay đổi trước/sau.
