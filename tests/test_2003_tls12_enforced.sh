#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

ctt_remote_check_true "TLS 1.2+ is enforced in OpenSSL defaults" "cfg=/etc/ssl/openssl.cnf; [ -f \"\$cfg\" ] && grep -Eq "^\s*MinProtocol\s*=\s*TLSv1\\.2" \"\$cfg\" && echo true || echo false"
