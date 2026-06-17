#!/usr/bin/env bash
set -euo pipefail

: "${CTT_PASS:=0}"
: "${CTT_FAIL:=0}"
: "${CTT_WARN:=0}"

ctt_color_green='\033[32m'
ctt_color_red='\033[31m'
ctt_color_yellow='\033[33m'
ctt_color_blue='\033[34m'
ctt_color_reset='\033[0m'

ctt_info() {
  printf '%b[INFO]%b %s\n' "$ctt_color_blue" "$ctt_color_reset" "$*"
}

ctt_pass() {
  CTT_PASS=$((CTT_PASS + 1))
  printf '%b[PASS]%b %s\n' "$ctt_color_green" "$ctt_color_reset" "$*"
}

ctt_warn() {
  CTT_WARN=$((CTT_WARN + 1))
  printf '%b[WARN]%b %s\n' "$ctt_color_yellow" "$ctt_color_reset" "$*"
}

ctt_fail() {
  CTT_FAIL=$((CTT_FAIL + 1))
  printf '%b[FAIL]%b %s\n' "$ctt_color_red" "$ctt_color_reset" "$*"
}

ctt_summary() {
  printf 'Summary: PASS=%s WARN=%s FAIL=%s\n' "$CTT_PASS" "$CTT_WARN" "$CTT_FAIL"
}

ctt_require_azure_context() {
  : "${CTT_VM_NAME:?CTT_VM_NAME is required}"
  : "${CTT_RESOURCE_GROUP:?CTT_RESOURCE_GROUP is required}"
  : "${CTT_SUBSCRIPTION:?CTT_SUBSCRIPTION is required}"
}

ctt_az() {
  az "$@"
}

ctt_remote_exec() {
  local command="$1"
  ctt_require_azure_context
  if [[ "${CTT_DRY_RUN:-0}" == "1" ]]; then
    printf '{"value":[{"code":"ComponentStatus/StdOut/succeeded","message":"true"}]}'
    return 0
  fi
  ctt_az vm run-command invoke \
    --subscription "$CTT_SUBSCRIPTION" \
    --resource-group "$CTT_RESOURCE_GROUP" \
    --name "$CTT_VM_NAME" \
    --command-id RunShellScript \
    --scripts "$command" \
    --output json
}

ctt_remote_stdout() {
  local payload
  payload="$(ctt_remote_exec "$1")"
  printf '%s' "$payload" | jq -r '.value[] | select(.code | test("StdOut")) | .message' | sed '/^null$/d'
}

ctt_remote_check_true() {
  local label="$1"
  local command="$2"
  local output
  output="$(ctt_remote_stdout "$command" | tr -d '\r' | tail -n 1)"
  if [[ "$output" == "true" ]]; then
    ctt_pass "$label"
    return 0
  fi
  ctt_fail "$label (output: ${output:-<empty>})"
  return 1
}

ctt_remote_check_false() {
  local label="$1"
  local command="$2"
  local output
  output="$(ctt_remote_stdout "$command" | tr -d '\r' | tail -n 1)"
  if [[ "$output" == "false" ]]; then
    ctt_pass "$label"
    return 0
  fi
  ctt_fail "$label (output: ${output:-<empty>})"
  return 1
}

ctt_remote_check_numeric_lte() {
  local label="$1"
  local command="$2"
  local max="$3"
  local output
  output="$(ctt_remote_stdout "$command" | tr -d '\r' | tail -n 1)"
  if [[ "$output" =~ ^[0-9]+$ ]] && (( output <= max )); then
    ctt_pass "$label"
    return 0
  fi
  ctt_fail "$label (output: ${output:-<empty>}, max: $max)"
  return 1
}

ctt_load_distro_adapter() {
  local adapter="$(dirname "${BASH_SOURCE[0]}")/_distro_ubuntu.sh"
  # shellcheck source=lib/_distro_ubuntu.sh
  source "$adapter"
}
