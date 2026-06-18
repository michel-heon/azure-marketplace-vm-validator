#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.4 — pas d'utilisateur LISA/résiduel UID>=1000.
# Implémentation : on passe l'exclude-list dans la variable d'environnement
# remote (PT_CTT_EXCLUDE) plutôt qu'en arg AWK -v, ce qui évite le conflit
# entre `set -u` côté script CTT et $3 dans l'AWK distant.
_excl="${CTT_LISA_EXCLUDE_USERS:-ubuntu,nobody,azureuser}"
ctt_remote_check_false "No residual LISA users with UID >= 1000" \
  "PT_EXCL='${_excl}' bash -c '
    found=0
    while IFS=: read -r u _ uid _; do
      [ \"\$uid\" -ge 1000 ] 2>/dev/null || continue
      case \",\$PT_EXCL,\" in *\",\$u,\"*) continue;; esac
      found=1
    done < /etc/passwd
    if [ \$found -eq 1 ]; then echo true; else echo false; fi
  '"
