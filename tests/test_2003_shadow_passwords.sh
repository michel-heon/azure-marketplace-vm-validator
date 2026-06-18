#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.3.3 — aucune entrée /etc/shadow avec champ password vide.
# Implémentation : on évite l'AWK quoté (problèmes d'échappement avec
# az vm run-command --scripts) en utilisant cut + grep -c.
# Sortie attendue : "false" si aucun compte vide, "true" sinon.
ctt_remote_check_false "No empty shadow passwords" \
  'n=$(sudo cut -d: -f2 /etc/shadow | grep -c "^$" 2>/dev/null || echo 0); if [ "$n" -gt 0 ]; then echo true; else echo false; fi'
