#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/_common.sh
source "$ROOT_DIR/lib/_common.sh"
ctt_load_distro_adapter

# Policy 200.3.1 — drivers Hyper-V réseau + stockage doivent être disponibles.
# Sur Ubuntu Azure (Gen2), ces drivers peuvent être soit chargés dynamiquement
# (lsmod), soit compilés in-kernel (visibles sous /sys/module/). On accepte
# les deux formes pour éviter les faux négatifs sur kernels Azure-tuned.
ctt_remote_check_true "Hyper-V drivers hv_netvsc + hv_storvsc are present" \
  'h1=0; h2=0; \
   { lsmod 2>/dev/null | grep -q "^hv_netvsc"  || [ -d /sys/module/hv_netvsc ]; }  && h1=1; \
   { lsmod 2>/dev/null | grep -q "^hv_storvsc" || [ -d /sys/module/hv_storvsc ]; } && h2=1; \
   if [ "$h1" -eq 1 ] && [ "$h2" -eq 1 ]; then echo true; else echo false; fi'
