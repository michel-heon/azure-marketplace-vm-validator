#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Minimum tool versions required at runtime
readonly CTT_MIN_AZ_VERSION="2.50.0"
readonly CTT_MIN_JQ_VERSION="1.6"

usage() {
  printf 'Usage:\n'
  printf '  %s [--severity-warn-is-fail] validate\n' "$0"
  printf '  %s [--severity-warn-is-fail] tests\n' "$0"
  printf '  %s list\n' "$0"
  printf '  %s test <name>\n' "$0"
  printf '\nOptions:\n'
  printf '  --severity-warn-is-fail   Treat WARN results as FAIL (sets CTT_SEVERITY_WARN_IS_FAIL=1)\n'
}

discover_tests() {
  find "$ROOT_DIR/tests" -maxdepth 1 -type f -name 'test_*.sh' | sort
}

run_test_file() {
  local test_file="$1"
  ctt_info "Running $(basename "$test_file")"
  if "$test_file"; then
    return 0
  fi
  return 1
}

_version_gte() {
  # Returns 0 if $1 >= $2 (both dotted version strings)
  local actual="$1" required="$2"
  printf '%s\n%s\n' "$required" "$actual" | sort -V | head -n1 | grep -qF "$required"
}

cmd_validate() {
  local rc=0

  # P1.5 — check az presence and minimum version
  if command -v az >/dev/null 2>&1; then
    local az_ver
    az_ver="$(az version --query '"azure-cli"' -o tsv 2>/dev/null || echo "0.0.0")"
    if _version_gte "$az_ver" "$CTT_MIN_AZ_VERSION"; then
      ctt_pass "Azure CLI (az) present — version ${az_ver} >= ${CTT_MIN_AZ_VERSION}"
    else
      ctt_fail "Azure CLI (az) version ${az_ver} is below minimum ${CTT_MIN_AZ_VERSION}"
      rc=1
    fi
  else
    ctt_fail 'Azure CLI (az) is required but not found'
    rc=1
  fi

  # P1.5 — check jq presence and minimum version
  if command -v jq >/dev/null 2>&1; then
    local jq_ver
    jq_ver="$(jq --version 2>/dev/null | sed 's/jq-//' || echo "0.0")"
    if _version_gte "$jq_ver" "$CTT_MIN_JQ_VERSION"; then
      ctt_pass "jq present — version ${jq_ver} >= ${CTT_MIN_JQ_VERSION}"
    else
      ctt_fail "jq version ${jq_ver} is below minimum ${CTT_MIN_JQ_VERSION}"
      rc=1
    fi
  else
    ctt_fail 'jq is required but not found'
    rc=1
  fi

  ctt_require_azure_context || rc=1

  if [[ "$rc" -eq 0 ]]; then
    ctt_pass 'Runtime prerequisites are present'
  fi
  ctt_summary
  return "$rc"
}

cmd_list() {
  discover_tests | xargs -n1 basename | sed 's/\.sh$//'
}

cmd_test() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    ctt_fail 'Missing test name'
    usage
    return 1
  fi
  local file="$ROOT_DIR/tests/${name}.sh"
  if [[ ! -f "$file" ]]; then
    ctt_fail "Unknown test: $name"
    return 1
  fi
  run_test_file "$file"
}

cmd_tests() {
  local failures=0
  while IFS= read -r test_file; do
    if ! run_test_file "$test_file"; then
      failures=$((failures + 1))
    fi
  done < <(discover_tests)

  # P1.4 — promote accumulated WARN count to failures when flag is set
  if [[ "${CTT_SEVERITY_WARN_IS_FAIL:-0}" == "1" ]] && (( CTT_WARN > 0 )); then
    ctt_fail "WARN promoted to FAIL (CTT_SEVERITY_WARN_IS_FAIL=1): ${CTT_WARN} warning(s)"
    failures=$((failures + CTT_WARN))
  fi

  if (( failures > 0 )); then
    ctt_fail "Test failures: $failures"
  else
    ctt_pass 'All tests passed or warned'
  fi
  ctt_summary
  (( failures == 0 ))
}

main() {
  # P1.4 — global flag parsing (before the subcommand)
  while [[ "${1:-}" == --* ]]; do
    case "$1" in
      --severity-warn-is-fail)
        CTT_SEVERITY_WARN_IS_FAIL=1
        export CTT_SEVERITY_WARN_IS_FAIL
        shift
        ;;
      *)
        ctt_fail "Unknown option: $1"
        usage
        return 1
        ;;
    esac
  done

  local cmd="${1:-}"
  case "$cmd" in
    validate)
      shift
      cmd_validate "$@"
      ;;
    tests)
      shift
      cmd_tests "$@"
      ;;
    list)
      shift
      cmd_list "$@"
      ;;
    test)
      shift
      cmd_test "$@"
      ;;
    *)
      usage
      return 1
      ;;
  esac
}

main "$@"
