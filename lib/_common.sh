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

# P3.4 — Detect distro from /etc/os-release on the remote VM.
# Reads the ID field and maps it to a supported adapter name.
# Returns the adapter name (e.g. "ubuntu", "rhel", "debian").
ctt_remote_detect_distro() {
  local raw_id
  raw_id="$(ctt_remote_stdout 'source /etc/os-release 2>/dev/null && echo "${ID:-unknown}"' | tr -d '\r' | tail -n 1)"
  case "$raw_id" in
    ubuntu)              printf '%s' "ubuntu" ;;
    debian)              printf '%s' "debian" ;;
    rhel|centos|rocky|almalinux|ol) printf '%s' "rhel" ;;
    *)                   printf '%s' "ubuntu" ; ctt_warn "Unknown distro '${raw_id}' — falling back to ubuntu adapter" ;;
  esac
}

ctt_load_distro_adapter() {
  local distro="${CTT_DISTRO:-}"
  # P3.4 — auto-detect when CTT_DISTRO is unset
  if [[ -z "$distro" ]]; then
    if [[ "${CTT_DRY_RUN:-0}" == "1" ]]; then
      # In dry-run mode there is no real VM — default to ubuntu
      distro="ubuntu"
    else
      ctt_info "CTT_DISTRO not set — auto-detecting from remote /etc/os-release"
      distro="$(ctt_remote_detect_distro)"
      ctt_info "Detected distro adapter: ${distro}"
    fi
  fi
  local adapter
  adapter="$(dirname "${BASH_SOURCE[0]}")/_distro_${distro}.sh"
  if [[ ! -f "$adapter" ]]; then
    ctt_fail "Unsupported distro adapter: ${distro}"
    return 1
  fi
  # Export so child test scripts inherit the resolved value
  export CTT_DISTRO="$distro"
  source "$adapter"
}
