#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.3.3 — No account in /etc/shadow must have an empty password field
# (second field empty means passwordless login is possible).
# NOTE : "!" et "*" sont des verrous valides (compte désactivé), pas des vides.
# Seul un champ littéralement vide pose problème de sécurité.
ctt_remote_check_false "No accounts with empty passwords in /etc/shadow" \
  'n=$(sudo cut -d: -f2 /etc/shadow | grep -c "^$" 2>/dev/null || echo 0); if [ "$n" -gt 0 ]; then echo true; else echo false; fi'
