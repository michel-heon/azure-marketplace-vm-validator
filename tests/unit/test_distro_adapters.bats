#!/usr/bin/env bats
# Unit tests for distro adapters — ADR-100 contract compliance
# Run with: bats tests/unit/test_distro_adapters.bats

ROOT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"

_load_adapter() {
  local distro="$1"
  source "$ROOT_DIR/lib/_distro_${distro}.sh"
}

# ── Helper: verify mandatory contract function exists and returns non-empty ───

_check_mandatory_fn() {
  local fn="$1"; shift
  declare -f "$fn" >/dev/null 2>&1 || { echo "MISSING: $fn"; return 1; }
  local result
  result="$("$fn" "$@")"
  [[ -n "$result" ]] || { echo "EMPTY: $fn returned nothing"; return 1; }
}

# ── Ubuntu adapter ────────────────────────────────────────────────────────────

@test "ubuntu: ctt_pkg_update_security_check_cmd is defined and non-empty" {
  _load_adapter ubuntu
  _check_mandatory_fn ctt_pkg_update_security_check_cmd
}

@test "ubuntu: ctt_cloud_init_present_cmd is defined and non-empty" {
  _load_adapter ubuntu
  _check_mandatory_fn ctt_cloud_init_present_cmd
}

@test "ubuntu: ctt_pkg_installed_cmd is defined and non-empty for curl" {
  _load_adapter ubuntu
  _check_mandatory_fn ctt_pkg_installed_cmd "curl"
}

@test "ubuntu: ctt_pkg_update_security_check_cmd output contains apt-get" {
  _load_adapter ubuntu
  result="$(ctt_pkg_update_security_check_cmd)"
  [[ "$result" == *"apt-get"* ]]
}

@test "ubuntu: ctt_pkg_installed_cmd output contains dpkg" {
  _load_adapter ubuntu
  result="$(ctt_pkg_installed_cmd "curl")"
  [[ "$result" == *"dpkg"* ]]
}

# ── RHEL adapter ──────────────────────────────────────────────────────────────

@test "rhel: ctt_pkg_update_security_check_cmd is defined and non-empty" {
  _load_adapter rhel
  _check_mandatory_fn ctt_pkg_update_security_check_cmd
}

@test "rhel: ctt_cloud_init_present_cmd is defined and non-empty" {
  _load_adapter rhel
  _check_mandatory_fn ctt_cloud_init_present_cmd
}

@test "rhel: ctt_pkg_installed_cmd is defined and non-empty for curl" {
  _load_adapter rhel
  _check_mandatory_fn ctt_pkg_installed_cmd "curl"
}

@test "rhel: ctt_pkg_update_security_check_cmd output contains dnf" {
  _load_adapter rhel
  result="$(ctt_pkg_update_security_check_cmd)"
  [[ "$result" == *"dnf"* ]]
}

@test "rhel: ctt_pkg_installed_cmd output contains rpm" {
  _load_adapter rhel
  result="$(ctt_pkg_installed_cmd "curl")"
  [[ "$result" == *"rpm"* ]]
}

# ── Debian adapter ────────────────────────────────────────────────────────────

@test "debian: ctt_pkg_update_security_check_cmd is defined and non-empty" {
  _load_adapter debian
  _check_mandatory_fn ctt_pkg_update_security_check_cmd
}

@test "debian: ctt_cloud_init_present_cmd is defined and non-empty" {
  _load_adapter debian
  _check_mandatory_fn ctt_cloud_init_present_cmd
}

@test "debian: ctt_pkg_installed_cmd is defined and non-empty for curl" {
  _load_adapter debian
  _check_mandatory_fn ctt_pkg_installed_cmd "curl"
}

@test "debian: ctt_pkg_update_security_check_cmd output contains apt-get" {
  _load_adapter debian
  result="$(ctt_pkg_update_security_check_cmd)"
  [[ "$result" == *"apt-get"* ]]
}
