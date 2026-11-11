# scripts/

- `aggregate_findings.py` (W10) — gộp kết quả Checkov + Prowler về một `summary.json`: số lỗi theo severity, % control CIS đạt, finding mới/đã sửa so với lần trước. Xem `docs/plan-w10.md`.
- `notify.py` (W11) — gửi Slack khi Prowler có lỗi CRITICAL/HIGH mới hoặc pipeline trên `main` lỗi. Xem `docs/plan-w11.md`.

Chỉ dùng thư viện chuẩn của Python, chạy được ngay trên runner GitHub.
