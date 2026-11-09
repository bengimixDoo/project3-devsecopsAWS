# W11 — Cảnh báo Slack

`scripts/notify.py` gửi tin qua Slack Incoming Webhook. Webhook lưu trong GitHub Secret `SLACK_WEBHOOK_URL`, không nằm trong code.

## Khi nào gửi

| Sự kiện | Workflow | Ghi chú |
|---|---|---|
| Prowler có lỗi CRITICAL/HIGH **mới** | `cspm-prowler.yml`, bước `Cảnh báo lỗi mới` | Dựa vào `diff.new` của `summary.json`: lỗi đã báo lần trước không báo lại |
| `cspm-prowler` lỗi | `cspm-prowler.yml`, bước `Báo pipeline lỗi` | Chạy cả khi được gọi sau apply |
| `ci-terraform` lỗi trên `main` | `ci-terraform.yml`, job `notify-failure` | PR đỏ là chuyện bình thường nên không báo |

Không gửi gì ở lần quét đầu (mốc so sánh), hoặc khi chỉ có lỗi mới MEDIUM/LOW.

## Hành vi khi lỗi

- **Chưa có secret:** in notice và bỏ qua, job vẫn xanh.
- **Slack trả lỗi:** job **đỏ**, vì đường cảnh báo hỏng là lỗi thật, không được im lặng.

## Cài đặt

1. Trong Slack, tạo app → bật **Incoming Webhooks** → **Add New Webhook to Workspace**, chọn kênh demo.
2. Trên GitHub: **Settings → Secrets and variables → Actions → Secrets → New repository secret**, tên `SLACK_WEBHOOK_URL`, giá trị là URL vừa tạo.

## Kịch bản demo

1. Chạy `cspm-prowler` lần đầu: không có tin (mốc).
2. Gỡ Public Access Block của bucket `project3-app-<account>` trên Console.
3. Chạy lại `cspm-prowler`: Slack nhận tin về lỗi HIGH mới `s3_bucket_level_public_access_block`.
4. Chạy lại lần nữa mà chưa sửa: **không** có tin mới (chống gửi trùng).
5. Khôi phục bằng `apply`: lần quét sau có `diff.resolved` chứa lỗi này.
