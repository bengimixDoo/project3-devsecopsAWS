"""Gate Checkov cho CI (W8).

Đọc file JSON kết quả của Checkov, rồi:
  - in mỗi vi phạm thành annotation ::error (hiện ngay trên PR, đúng file/dòng),
  - ghi bảng tóm tắt vào GITHUB_STEP_SUMMARY,
  - thoát mã 1 nếu có vi phạm -> job đỏ -> chặn merge (khi bật branch protection).
"""
import json
import os
import sys


def load_reports(path):
    with open(path, encoding="utf-8-sig") as f:
        data = json.load(f)
    # Checkov trả về dict (1 framework) hoặc list (nhiều framework).
    return data if isinstance(data, list) else [data]


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "results_json.json"
    if not os.path.exists(path):
        print(f"::error::Không tìm thấy kết quả Checkov: {path}")
        return 1

    passed, failed = 0, []
    for report in load_reports(path):
        summary = report.get("summary", {})
        passed += summary.get("passed", 0)
        failed.extend(report.get("results", {}).get("failed_checks", []))

    for c in failed:
        file_path = (c.get("file_path") or "").lstrip("/")
        line = (c.get("file_line_range") or [1])[0]
        msg = f"{c.get('check_id')}: {c.get('check_name')} ({c.get('resource')})"
        print(f"::error file={file_path},line={line},title=Checkov {c.get('check_id')}::{msg}")

    lines = [
        "## Checkov security gate",
        "",
        f"Passed: **{passed}** | Failed: **{len(failed)}**",
        "",
    ]
    if failed:
        lines += ["| Check | Resource | File |", "|---|---|---|"]
        for c in failed:
            lines.append(
                f"| {c.get('check_id')} {c.get('check_name')} | {c.get('resource')} "
                f"| {(c.get('file_path') or '').lstrip('/')}:{(c.get('file_line_range') or [1])[0]} |"
            )
    summary_file = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_file:
        with open(summary_file, "a", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")

    print(f"Checkov: passed={passed} failed={len(failed)}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
