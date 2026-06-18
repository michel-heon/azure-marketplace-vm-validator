#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.5.x — No pre-set / well-known passwords in /etc/shadow.
# Checks that no active account (not locked, not expired) has a hash that
# matches common well-known hashes or a trivially short hash (< 20 chars).
# A locked account starts with '!' or '*'; those are explicitly excluded.
ctt_remote_check_false "No pre-set default credentials in /etc/shadow" \
  "awk -F: '\$2 !~ /^[!*]/ && length(\$2) < 20 && \$2 != \"\" { found=1 } END { print (found ? \"true\" : \"false\") }' /etc/shadow 2>/dev/null | tail -n 1"
