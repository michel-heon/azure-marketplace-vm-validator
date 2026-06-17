#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.3.3 — No account in /etc/shadow must have an empty password field
# (second field empty means passwordless login is possible).
ctt_remote_check_false "No accounts with empty passwords in /etc/shadow" \
  "awk -F: '(\$2 == \"\" || \$2 == \"!\") { found=1 } END { if (found) print \"true\"; else print \"false\" }' /etc/shadow 2>/dev/null | tail -n 1"
