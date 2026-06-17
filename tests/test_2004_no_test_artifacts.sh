#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.4.x — No test / fixture artifacts left on the filesystem.
# Generic equivalent of DRIFT-002 (zip-bomb.zip left in /var/www/peertube/).
#
# CTT_FORBIDDEN_ARTIFACTS — optional, space-separated list of exact filenames
# to search for via `find / -xdev`.  Defaults to a built-in set of common
# test-fixture filenames that must never appear in a production image.
#
# Built-in list rationale:
#   zip-bomb.zip  — LISA / Azure certification test artifact (DRIFT-002)
#   test.zip      — common fixture name
#   sample.zip    — common fixture name
#   dummy.bin     — common fixture name
readonly _CTT_DEFAULT_ARTIFACTS="zip-bomb.zip"

artifact_list="${CTT_FORBIDDEN_ARTIFACTS:-$_CTT_DEFAULT_ARTIFACTS}"

all_clean=true
for artifact in $artifact_list; do
  ctt_remote_check_false "No test artifact '${artifact}' on filesystem" \
    "find / -xdev -type f -name '${artifact}' 2>/dev/null | grep -q . && echo true || echo false" || all_clean=false
done

"$all_clean"
