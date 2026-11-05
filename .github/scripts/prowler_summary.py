"""Tóm tắt kết quả Prowler cho CI (W9).

Đọc file OCSF JSON của Prowler, rồi:
  - in finding CRITICAL/HIGH thành annotation ::warning,
  - ghi bảng số lượng theo severity và danh sách lỗi nặng vào GITHUB_STEP_SUMMARY,
  - thoát mã 1 chỉ khi không đọc được kết quả hoặc không có finding nào (quét hỏng).
    Có lỗi cấu hình KHÔNG làm job đỏ: đó là kết quả để báo cáo, không phải lỗi pipeline.
"""
import json
import os
import sys
from collections import Counter

SEVERITY_ORDER = ["CRITICAL", "HIGH", "MEDIUM", "LOW", "INFORMATIONAL"]
SERIOUS = {"CRITICAL", "HIGH"}


def severity_of(finding):
    return (finding.get("severity") or "UNKNOWN").upper()


def is_failed(finding):
    # Finding bị mute qua mutelist có status = "Suppressed": đã chấp nhận rủi ro.
    return finding.get("status_code") == "FAIL" and finding.get("status") != "Suppressed"


def resource_of(finding):
    resources = finding.get("resources") or [{}]
    return resources[0].get("uid") or resources[0].get("name") or "-"


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "reports/prowler.ocsf.json"
    if not os.path.exists(path):
        print(f"::error::Không tìm thấy kết quả Prowler: {path}")
        return 1

    with open(path, encoding="utf-8") as f:
        findings = json.load(f)
    if not findings:
        print("::error::Prowler không trả về finding nào, quét có thể đã hỏng")
        return 1

    failed = [f for f in findings if is_failed(f)]
    passed = sum(1 for f in findings if f.get("status_code") == "PASS")
    by_severity = Counter(severity_of(f) for f in failed)
    serious = [f for f in failed if severity_of(f) in SERIOUS]
    serious.sort(key=lambda f: SEVERITY_ORDER.index(severity_of(f)))

    for f in serious:
        title = f.get("finding_info", {}).get("title", "")
        print(f"::warning title=Prowler {severity_of(f)}::{title} ({resource_of(f)})")

    lines = [
        "## Prowler CSPM (CIS AWS Foundations)",
        "",
        f"PASS: **{passed}** | FAIL: **{len(failed)}** | Tổng finding: **{len(findings)}**",
        "",
        "| Severity | FAIL |",
        "|---|---|",
    ]
    lines += [f"| {s} | {by_severity[s]} |" for s in SEVERITY_ORDER if by_severity[s]]
    if serious:
        lines += ["", "### Lỗi CRITICAL/HIGH", "", "| Severity | Lỗi | Resource |", "|---|---|---|"]
        for f in serious:
            title = f.get("finding_info", {}).get("title", "")
            lines.append(f"| {severity_of(f)} | {title} | {resource_of(f)} |")
    summary_file = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_file:
        with open(summary_file, "a", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")

    print(f"Prowler: pass={passed} fail={len(failed)} serious={len(serious)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
