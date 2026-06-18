#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.3 — TLS 1.2+ doit être imposé par /etc/ssl/openssl.cnf.
# On évite les imbrications de quotes (cassées par az vm run-command --scripts)
# en utilisant single-quote pour le script remote.
ctt_remote_check_true "TLS 1.2+ is enforced in OpenSSL defaults" \
  'cfg=/etc/ssl/openssl.cnf; if [ -f "$cfg" ] && grep -Eq "^[[:space:]]*MinProtocol[[:space:]]*=[[:space:]]*TLSv1\.[2-9]" "$cfg"; then echo true; else echo false; fi'
