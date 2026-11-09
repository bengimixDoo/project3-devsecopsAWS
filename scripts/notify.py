"""Gửi cảnh báo Slack (W11).

Hai loại tin:
  findings <summary.json>  -> chỉ gửi khi có finding Prowler CRITICAL/HIGH MỚI so với lần quét
                              trước (diff trong summary.json), để không gửi trùng mỗi tuần.
  pipeline-failed          -> báo pipeline trên main bị lỗi.

Webhook đọc từ biến môi trường SLACK_WEBHOOK_URL (GitHub Secret). Không có webhook thì
chỉ in notice và thoát 0, để repo fork hay môi trường test không bị đỏ.
"""
import argparse
import json
import os
import sys
import urllib.request

SERIOUS = {"CRITICAL", "HIGH"}
MAX_ITEMS = 10


def findings_message(summary):
    diff = summary.get("diff") or {}
    if diff.get("baseline"):
        print("Lần quét đầu (mốc so sánh): không gửi cảnh báo.")
        return None

    new_serious = [f for f in diff.get("new", []) if f["severity"] in SERIOUS]
    if not new_serious:
        print(f"Không có lỗi CRITICAL/HIGH mới (mới: {len(diff.get('new', []))}, đã sửa: {len(diff.get('resolved', []))}).")
        return None

    prowler = summary["prowler"]
    cis = prowler["cis_controls"]
    lines = [
        f":rotating_light: *Prowler phát hiện {len(new_serious)} lỗi CRITICAL/HIGH mới* trên AWS",
        f"CIS ({prowler['framework']}) đạt {cis['passed']}/{cis['total']} control"
        + (f" ({cis['percent_passed']}%)" if cis["percent_passed"] is not None else ""),
        "",
    ]
    for f in new_serious[:MAX_ITEMS]:
        lines.append(f"• `{f['severity']}` {f['title']} — `{f['resource']}`")
    if len(new_serious) > MAX_ITEMS:
        lines.append(f"• … và {len(new_serious) - MAX_ITEMS} lỗi khác")
    if summary.get("run_url"):
        lines += ["", f"<{summary['run_url']}|Xem báo cáo>"]
    return "\n".join(lines)


def pipeline_failed_message(workflow, run_url):
    text = f":x: *Pipeline `{workflow}` trên main bị lỗi*"
    if run_url:
        text += f"\n<{run_url}|Xem run>"
    return text


def send(text):
    webhook = os.environ.get("SLACK_WEBHOOK_URL")
    if not webhook:
        print("::notice::Chưa cấu hình SLACK_WEBHOOK_URL, bỏ qua gửi cảnh báo.")
        print(text)
        return 0

    request = urllib.request.Request(
        webhook,
        data=json.dumps({"text": text}).encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            print(f"Đã gửi cảnh báo Slack (HTTP {response.status}).")
            return 0
    except Exception as error:
        # Đường cảnh báo hỏng là lỗi thật: để job đỏ thay vì im lặng.
        print(f"::error::Gửi cảnh báo Slack thất bại: {error}")
        return 1


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = parser.add_subparsers(dest="kind", required=True)
    findings = sub.add_parser("findings")
    findings.add_argument("summary")
    failed = sub.add_parser("pipeline-failed")
    failed.add_argument("--workflow", default=os.environ.get("GITHUB_WORKFLOW", "?"))
    args = parser.parse_args()

    if args.kind == "findings":
        with open(args.summary, encoding="utf-8") as f:
            text = findings_message(json.load(f))
    else:
        server, repo, run_id = (os.environ.get(k) for k in ("GITHUB_SERVER_URL", "GITHUB_REPOSITORY", "GITHUB_RUN_ID"))
        run_url = f"{server}/{repo}/actions/runs/{run_id}" if server and repo and run_id else None
        text = pipeline_failed_message(args.workflow, run_url)

    return send(text) if text else 0


if __name__ == "__main__":
    sys.exit(main())
