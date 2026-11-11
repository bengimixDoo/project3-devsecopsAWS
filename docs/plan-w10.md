# W10 — Tổng hợp và lưu kết quả quét

## Lưu trữ tập trung

Bucket `project3-reports-<account>` (`modules/s3/reports.tf`): mã hóa SSE-S3, versioning, chặn public, chỉ cho truy cập qua HTTPS, tự xóa báo cáo sau 90 ngày (`report_retention_days`).

```
checkov/<YYYY-MM-DD>/<sha7>-<run_id>/results_json.json
checkov/latest/results_json.json
prowler/<YYYY-MM-DD>/<sha7>-<run_id>/{prowler.ocsf.json, prowler.html, prowler.csv, summary.json}
latest/summary.json        <- bản tóm tắt mới nhất, là mốc so sánh cho lần quét sau
```

- **Checkov:** job `checkov-report` trong `ci-terraform.yml` lưu kết quả mỗi lần push lên `main`.
- **Prowler:** `cspm-prowler.yml` lưu báo cáo sau mỗi lần quét, rồi mới thay `latest/summary.json`.

Cả hai dùng role CSPM. Quyền ghi duy nhất của role này là `s3:GetObject`/`s3:PutObject`/`s3:ListBucket` trên bucket reports (`modules/iam/main.tf`). Role Deploy không được dùng cho việc này.

## Chuẩn hóa dữ liệu

`scripts/aggregate_findings.py` gộp Checkov + Prowler thành `summary.json`:

| Phần | Nội dung |
|---|---|
| `checkov` | pass/fail, số lỗi chặn build, số lỗi theo severity (cùng bảng severity với gate W8) |
| `prowler` | PASS/FAIL, lỗi theo severity, control CIS đạt/tổng và %, danh sách control trượt, danh sách finding FAIL |
| `diff` | so với `latest/summary.json` lần trước: finding **mới** và finding **đã sửa** |

Một control CIS được tính là đạt khi không có finding FAIL nào thuộc control đó. Prowler gắn mọi phiên bản CIS vào mỗi finding, nên script chỉ lấy framework đang quét (`--framework`, mặc định `CIS-7.0`). Finding bị mute (`Suppressed`) không được tính là FAIL.

Lần quét đầu không có bản trước, nên `diff.baseline = true` và không có finding nào được coi là mới.

## Xem lịch sử

```bash
aws s3 ls s3://project3-reports-434481793703/prowler/ --recursive --profile sonplt
```

```bash
aws s3 cp s3://project3-reports-434481793703/latest/summary.json - --profile sonplt
```

## Giới hạn

- Tài khoản AWS dùng chung với project khác, nên số liệu CIS có cả lỗi cấp account và resource không thuộc project3.
- Severity của Checkov là do project tự gán (xem `docs/plan-w8.md`).
