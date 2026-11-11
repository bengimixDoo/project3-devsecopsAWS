"""Gộp kết quả Checkov + Prowler thành một JSON chung (W10).

Đầu ra gồm:
  - checkov: số check pass/fail theo severity của project (.github/checkov-severity.json),
  - prowler: PASS/FAIL theo severity, theo control CIS và % control CIS đạt,
  - diff: so với bản tóm tắt lần trước, finding Prowler nào MỚI và nào ĐÃ SỬA.
    W11 dựa vào diff này để chỉ cảnh báo lỗi mới, không gửi trùng.

Ví dụ:
  python scripts/aggregate_findings.py --prowler reports/prowler.ocsf.json \
      --checkov checkov.json --previous previous.json --output reports/summary.json
"""
import argparse
import json
import os
import sys
from collections import Counter, defaultdict
from datetime import datetime, timezone

# Dùng chung bảng severity với gate Checkov của W8.
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".github", "scripts"))
from checkov_gate import load_reports, load_severity_config  # noqa: E402

SEVERITY_ORDER = ["CRITICAL", "HIGH", "MEDIUM", "LOW", "INFORMATIONAL"]


def summarize_checkov(path):
    severity_by_check, default_severity, blocking = load_severity_config()
    passed, failed = 0, []
    for report in load_reports(path):
        passed += report.get("summary", {}).get("passed", 0)
        failed.extend(report.get("results", {}).get("failed_checks", []))

    by_severity = Counter(severity_by_check.get(c.get("check_id"), default_severity) for c in failed)
    return {
        "passed": passed,
        "failed": len(failed),
        "blocking": sum(n for s, n in by_severity.items() if s in blocking),
        "by_severity": {s: by_severity[s] for s in SEVERITY_ORDER if by_severity[s]},
    }


def is_failed(finding):
    # Finding bị mute qua mutelist có status = "Suppressed": đã chấp nhận rủi ro.
    return finding.get("status_code") == "FAIL" and finding.get("status") != "Suppressed"


def summarize_prowler(path, framework):
    with open(path, encoding="utf-8") as f:
        findings = json.load(f)

    failed, passed = [], 0
    controls = defaultdict(lambda: {"pass": 0, "fail": 0})
    for finding in findings:
        severity = (finding.get("severity") or "UNKNOWN").upper()
        failing = is_failed(finding)
        if failing:
            resources = finding.get("resources") or [{}]
            failed.append({
                "uid": finding.get("finding_info", {}).get("uid"),
                "check": finding.get("metadata", {}).get("event_code"),
                "severity": severity,
                "title": finding.get("finding_info", {}).get("title"),
                "resource": resources[0].get("uid") or resources[0].get("name"),
            })
        elif finding.get("status_code") == "PASS":
            passed += 1

        # Prowler gắn mọi phiên bản CIS vào finding, chỉ lấy framework đang quét.
        compliance = (finding.get("unmapped") or {}).get("compliance") or {}
        for control in compliance.get(framework, []):
            controls[control]["fail" if failing else "pass"] += 1

    failed.sort(key=lambda f: (SEVERITY_ORDER.index(f["severity"]) if f["severity"] in SEVERITY_ORDER else 99, f["check"] or ""))
    controls_passed = sum(1 for c in controls.values() if c["fail"] == 0)
    by_severity = Counter(f["severity"] for f in failed)
    return {
        "framework": framework,
        "passed": passed,
        "failed": len(failed),
        "by_severity": {s: by_severity[s] for s in SEVERITY_ORDER if by_severity[s]},
        "cis_controls": {
            "total": len(controls),
            "passed": controls_passed,
            "percent_passed": round(100 * controls_passed / len(controls), 1) if controls else None,
            "failed_ids": sorted((c for c, v in controls.items() if v["fail"]), key=control_sort_key),
        },
        "failed_findings": failed,
    }


def control_sort_key(control_id):
    return [int(p) if p.isdigit() else p for p in control_id.split(".")]


def diff_with_previous(prowler, previous):
    """Finding mới/đã sửa so với lần trước. Không có lần trước thì đây là mốc đầu."""
    if previous is None or not previous.get("prowler"):
        return {"baseline": True, "new": [], "resolved": []}

    previous_by_uid = {f["uid"]: f for f in previous["prowler"]["failed_findings"]}
    current_by_uid = {f["uid"]: f for f in prowler["failed_findings"]}
    return {
        "baseline": False,
        "previous_generated_at": previous.get("generated_at"),
        "new": [f for uid, f in current_by_uid.items() if uid not in previous_by_uid],
        "resolved": [f for uid, f in previous_by_uid.items() if uid not in current_by_uid],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--prowler", help="File OCSF JSON của Prowler")
    parser.add_argument("--checkov", help="File JSON kết quả Checkov")
    parser.add_argument("--previous", help="summary.json của lần quét trước")
    parser.add_argument("--framework", default="CIS-7.0", help="Khóa compliance trong OCSF")
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    if not args.prowler and not args.checkov:
        parser.error("cần ít nhất --prowler hoặc --checkov")

    summary = {
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "commit": os.environ.get("GITHUB_SHA"),
        "run_url": run_url(),
    }
    if args.checkov:
        summary["checkov"] = summarize_checkov(args.checkov)
    if args.prowler:
        summary["prowler"] = summarize_prowler(args.prowler, args.framework)
        previous = None
        if args.previous and os.path.exists(args.previous):
            with open(args.previous, encoding="utf-8") as f:
                previous = json.load(f)
        summary["diff"] = diff_with_previous(summary["prowler"], previous)

    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(summary, f, ensure_ascii=False, indent=2)

    prowler = summary.get("prowler")
    if prowler:
        diff = summary["diff"]
        print(
            f"Prowler: fail={prowler['failed']} CIS đạt {prowler['cis_controls']['passed']}/"
            f"{prowler['cis_controls']['total']} | mới={len(diff['new'])} đã sửa={len(diff['resolved'])}"
            + (" (mốc đầu)" if diff["baseline"] else "")
        )
    if "checkov" in summary:
        print(f"Checkov: pass={summary['checkov']['passed']} fail={summary['checkov']['failed']}")
    return 0


def run_url():
    server, repo, run_id = (os.environ.get(k) for k in ("GITHUB_SERVER_URL", "GITHUB_REPOSITORY", "GITHUB_RUN_ID"))
    return f"{server}/{repo}/actions/runs/{run_id}" if server and repo and run_id else None


if __name__ == "__main__":
    sys.exit(main())
