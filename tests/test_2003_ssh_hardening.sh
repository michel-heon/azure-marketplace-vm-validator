#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

ctt_remote_check_true "SSH hardening: root login disabled + ClientAliveInterval <=235" "cfg=\$(sshd -T 2>/dev/null); printf '%s' \"\$cfg\" | grep -Eq '^permitrootlogin no$' && val=\$(printf '%s' \"\$cfg\" | awk '/^clientaliveinterval / {print \$2}'); [ -n \"\$val\" ] && [ \"\$val\" -ge 0 ] && [ \"\$val\" -le 235 ] && echo true || echo false"
