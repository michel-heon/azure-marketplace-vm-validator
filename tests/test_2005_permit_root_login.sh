#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.5.x — PermitRootLogin must be 'no' or 'prohibit-password'.
# 'sshd -T' outputs the effective configuration including values from Match blocks.
ctt_remote_check_false "PermitRootLogin is no or prohibit-password" \
  "val=\$(sshd -T 2>/dev/null | awk '/^permitrootlogin / {print \$2}'); case \"\$val\" in no|prohibit-password) echo false ;; *) echo true ;; esac"
