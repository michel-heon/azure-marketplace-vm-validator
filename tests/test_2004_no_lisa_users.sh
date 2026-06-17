#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

ctt_remote_check_false "No residual LISA users with UID >= 1000" "exclude=\"${CTT_LISA_EXCLUDE_USERS:-ubuntu,nobody}\"; awk -F: -v ex=\"\$exclude\" 'BEGIN{split(ex,a,/,/); for(i in a) skip[a[i]]=1} $3>=1000 && $1!="nobody" && !skip[$1] {found=1} END{if(found) print "true"; else print "false"}' /etc/passwd"
