"""Gate Checkov cho CI (W8).

Checkov bản không có API key trả về severity = None, nên severity được gán theo
.github/checkov-severity.json. Script đọc file JSON kết quả của Checkov, rồi:
  - in vi phạm HIGH/CRITICAL thành annotation ::error, MEDIUM/LOW thành ::warning,
  - ghi bảng tóm tắt vào GITHUB_STEP_SUMMARY,
  - thoát mã 1 nếu có vi phạm chặn build, hoặc nếu kết quả quét không đáng tin
    (lỗi parse, không có check nào chạy) -> job đỏ -> chặn merge.
"""
import json
import os
import sys

SEVERITY_FILE = os.path.join(os.path.dirname(__file__), "..", "checkov-severity.json")
SEVERITY_ORDER = ["CRITICAL", "HIGH", "MEDIUM", "LOW"]


def load_reports(path):
    with open(path, encoding="utf-8-sig") as f:
        data = json.load(f)
    # Checkov trả về dict (1 framework) hoặc list (nhiều framework).
    return data if isinstance(data, list) else [data]


def load_severity_config(path=SEVERITY_FILE):
    with open(path, encoding="utf-8") as f:
        config = json.load(f)
    severity_by_check = {
        check_id: severity
        for severity, check_ids in config["checks"].items()
        for check_id in check_ids
    }
    return severity_by_check, config["default"], set(config["blocking"])


def location(check):
    file_path = (check.get("file_path") or "").lstrip("/")
    line = (check.get("file_line_range") or [1])[0]
    return file_path, line


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "results_json.json"
    if not os.path.exists(path):
        print(f"::error::Không tìm thấy kết quả Checkov: {path}")
        return 1

    severity_by_check, default_severity, blocking = load_severity_config()

    passed, parsing_errors, failed = 0, 0, []
    for report in load_reports(path):
        summary = report.get("summary", {})
        passed += summary.get("passed", 0)
        parsing_errors += summary.get("parsing_errors", 0)
        failed.extend(report.get("results", {}).get("failed_checks", []))

    findings = sorted(
        ((severity_by_check.get(c.get("check_id"), default_severity), c) for c in failed),
        key=lambda item: SEVERITY_ORDER.index(item[0]),
    )
    blocked = [c for severity, c in findings if severity in blocking]

    for severity, c in findings:
        level = "error" if severity in blocking else "warning"
        file_path, line = location(c)
        msg = f"[{severity}] {c.get('check_id')}: {c.get('check_name')} ({c.get('resource')})"
        print(f"::{level} file={file_path},line={line},title=Checkov {c.get('check_id')}::{msg}")

    untrusted = []
    if parsing_errors:
        untrusted.append(f"{parsing_errors} file lỗi parse, không được quét")
    if passed + len(failed) == 0:
        untrusted.append("không có check nào chạy")
    for reason in untrusted:
        print(f"::error title=Checkov::Kết quả quét không đáng tin: {reason}")

    lines = [
        "## Checkov security gate",
        "",
        f"Passed: **{passed}** | Chặn build: **{len(blocked)}** | "
        f"Chỉ cảnh báo: **{len(findings) - len(blocked)}**",
        "",
    ]
    lines += [f"- Kết quả quét không đáng tin: {reason}" for reason in untrusted]
    if findings:
        lines += ["| Severity | Check | Resource | File |", "|---|---|---|---|"]
        for severity, c in findings:
            file_path, line = location(c)
            lines.append(
                f"| {severity} | {c.get('check_id')} {c.get('check_name')} "
                f"| {c.get('resource')} | {file_path}:{line} |"
            )
    summary_file = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_file:
        with open(summary_file, "a", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")

    print(f"Checkov: passed={passed} blocked={len(blocked)} warnings={len(findings) - len(blocked)}")
    return 1 if blocked or untrusted else 0


if __name__ == "__main__":
    sys.exit(main())
