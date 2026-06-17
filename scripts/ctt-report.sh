#!/usr/bin/env bash
# ctt-report.sh — Report generator for azure-marketplace-vm-validator
#
# Wraps ctt.sh tests, captures structured output, and writes:
#   - JSON report  (always, to stdout or CTT_REPORT_DIR)
#   - JUnit XML    (--format junit, or always when CTT_REPORT_DIR is set)
#
# Usage:
#   ./scripts/ctt-report.sh [--format json|junit|all] [--output-dir <dir>]
#   CTT_REPORT_DIR=/tmp/reports ./scripts/ctt-report.sh
#
# P5.1 — JSON report
# P5.2 — JUnit XML report
# P5.3 — CTT_REPORT_DIR archiving

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# ── Defaults ────────────────────────────────────────────────────────────────
FORMAT="${CTT_OUTPUT_FORMAT:-all}"   # json | junit | all
REPORT_DIR="${CTT_REPORT_DIR:-}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
VM_NAME="${CTT_VM_NAME:-unknown}"
DISTRO="${CTT_DISTRO:-ubuntu}"

# ── Argument parsing ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --format)
      FORMAT="$2"; shift 2 ;;
    --output-dir)
      REPORT_DIR="$2"; shift 2 ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

# ── Run tests and capture output ─────────────────────────────────────────────
TMPLOG="$(mktemp)"
trap 'rm -f "$TMPLOG"' EXIT

set +e
"$ROOT_DIR/scripts/ctt.sh" tests 2>&1 | tee "$TMPLOG"
CTT_EXIT=$?
set -e

# ── Parse ctt.sh human output into structured records ────────────────────────
# Line format:  [PASS] message
#               [FAIL] message
#               [WARN] message
#               [INFO] Running test_<name>

declare -a RECORDS=()
current_test="unknown"
start_ms="$(date -u +%s%3N)"

while IFS= read -r line; do
  # Detect test start → track current test name
  if [[ "$line" =~ \[INFO\]\ Running\ (test_[a-z0-9_]+) ]]; then
    current_test="${BASH_REMATCH[1]}"
    start_ms="$(date -u +%s%3N)"
    continue
  fi

  status=""
  message=""
  if [[ "$line" =~ ^\[PASS\]\ (.*) ]]; then
    status="PASS"; message="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^\[FAIL\]\ (.*) ]]; then
    status="FAIL"; message="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^\[WARN\]\ (.*) ]]; then
    status="WARN"; message="${BASH_REMATCH[1]}"
  else
    continue
  fi

  end_ms="$(date -u +%s%3N)"
  duration_ms=$(( end_ms - start_ms ))

  # Extract section from test name (test_2003_foo → 200.3.x)
  section="unknown"
  if [[ "$current_test" =~ ^test_([0-9]{4}) ]]; then
    raw="${BASH_REMATCH[1]}"
    section="${raw:0:3}.${raw:3}"
  fi

  # Escape message for JSON
  msg_escaped="${message//\\/\\\\}"
  msg_escaped="${msg_escaped//\"/\\\"}"

  RECORDS+=("{\"test_id\":\"${current_test}\",\"section\":\"${section}\",\"status\":\"${status}\",\"message\":\"${msg_escaped}\",\"duration_ms\":${duration_ms}}")
done < "$TMPLOG"

# ── Build overall summary ─────────────────────────────────────────────────────
pass_count=0; fail_count=0; warn_count=0
for rec in "${RECORDS[@]:-}"; do
  [[ "$rec" == *'"status":"PASS"'* ]] && pass_count=$((pass_count+1))
  [[ "$rec" == *'"status":"FAIL"'* ]] && fail_count=$((fail_count+1))
  [[ "$rec" == *'"status":"WARN"'* ]] && warn_count=$((warn_count+1))
done
total_count=$(( pass_count + fail_count + warn_count ))
overall="PASS"
(( fail_count > 0 )) && overall="FAIL"
(( fail_count == 0 && warn_count > 0 )) && overall="WARN"

# ── JSON builder ──────────────────────────────────────────────────────────────
build_json() {
  local sep=""
  printf '{\n'
  printf '  "generated_at": "%s",\n' "$TIMESTAMP"
  printf '  "vm_name": "%s",\n' "$VM_NAME"
  printf '  "distro": "%s",\n' "$DISTRO"
  printf '  "overall": "%s",\n' "$overall"
  printf '  "summary": {"pass": %d, "warn": %d, "fail": %d, "total": %d},\n' \
    "$pass_count" "$warn_count" "$fail_count" "$total_count"
  printf '  "results": [\n'
  for rec in "${RECORDS[@]:-}"; do
    printf '%s    %s\n' "$sep" "$rec"
    sep=","
  done
  printf '  ]\n'
  printf '}\n'
}

# ── JUnit XML builder ─────────────────────────────────────────────────────────
build_junit() {
  local total_time=0
  for rec in "${RECORDS[@]:-}"; do
    local ms
    ms="$(printf '%s' "$rec" | grep -oE '"duration_ms":[0-9]+' | grep -oE '[0-9]+$' || echo 0)"
    total_time=$(( total_time + ms ))
  done
  local total_sec
  total_sec="$(awk "BEGIN{printf \"%.3f\", $total_time/1000}")"

  printf '<?xml version="1.0" encoding="UTF-8"?>\n'
  printf '<testsuites name="azure-marketplace-vm-validator" tests="%d" failures="%d" errors="0" time="%s">\n' \
    "$total_count" "$fail_count" "$total_sec"
  printf '  <testsuite name="ctt" tests="%d" failures="%d" errors="0" skipped="%d" timestamp="%s" hostname="%s">\n' \
    "$total_count" "$fail_count" "$warn_count" "$TIMESTAMP" "$VM_NAME"

  for rec in "${RECORDS[@]:-}"; do
    local tid sec msg stat dur_ms dur_sec
    tid="$(printf '%s' "$rec"  | grep -oE '"test_id":"[^"]+"' | cut -d'"' -f4)"
    sec="$(printf '%s' "$rec"  | grep -oE '"section":"[^"]+"'  | cut -d'"' -f4)"
    msg="$(printf '%s' "$rec"  | grep -oE '"message":"[^"]+"'  | cut -d'"' -f4)"
    stat="$(printf '%s' "$rec" | grep -oE '"status":"[^"]+"'   | cut -d'"' -f4)"
    dur_ms="$(printf '%s' "$rec" | grep -oE '"duration_ms":[0-9]+' | grep -oE '[0-9]+$' || echo 0)"
    dur_sec="$(awk "BEGIN{printf \"%.3f\", $dur_ms/1000}")"

    printf '    <testcase classname="%s" name="%s" time="%s">\n' "$sec" "$tid" "$dur_sec"
    case "$stat" in
      FAIL) printf '      <failure message="%s" type="ConformanceFailure"/>\n' "$msg" ;;
      WARN) printf '      <skipped message="%s"/>\n' "$msg" ;;
    esac
    printf '    </testcase>\n'
  done

  printf '  </testsuite>\n'
  printf '</testsuites>\n'
}

# ── Output routing ────────────────────────────────────────────────────────────
if [[ -n "$REPORT_DIR" ]]; then
  mkdir -p "$REPORT_DIR"
  JSON_FILE="${REPORT_DIR}/ctt-report-${TIMESTAMP}.json"
  JUNIT_FILE="${REPORT_DIR}/ctt-junit-${TIMESTAMP}.xml"
  build_json  > "$JSON_FILE"
  build_junit > "$JUNIT_FILE"
  ctt_info "JSON  report: ${JSON_FILE}"
  ctt_info "JUnit report: ${JUNIT_FILE}"
else
  case "$FORMAT" in
    junit) build_junit ;;
    json)  build_json  ;;
    all|*) build_json; printf '\n'; build_junit ;;
  esac
fi

exit "$CTT_EXIT"
