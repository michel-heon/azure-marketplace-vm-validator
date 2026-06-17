#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

usage() {
  printf 'Usage:\n'
  printf '  %s validate\n' "$0"
  printf '  %s tests\n' "$0"
  printf '  %s list\n' "$0"
  printf '  %s test <name>\n' "$0"
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

cmd_validate() {
  local rc=0
  command -v az >/dev/null 2>&1 || { ctt_fail 'Azure CLI (az) is required'; rc=1; }
  command -v jq >/dev/null 2>&1 || { ctt_fail 'jq is required'; rc=1; }
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

  if (( failures > 0 )); then
    ctt_fail "Test failures: $failures"
  else
    ctt_pass 'All tests passed or warned'
  fi
  ctt_summary
  (( failures == 0 ))
}

main() {
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
