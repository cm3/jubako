#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
[[ $# == 0 ]] || { echo 'Usage: sudo bash scripts/build.sh'; exit 2; }
(( EUID == 0 )) || { echo 'sudo is required for debootstrap, chroot and temporary mounts.' >&2; exit 1; }
run=$(realpath -e -- "$(cat "$root/build/latest-run.txt")")
[[ $run == "$root"/build/runs/desktop-* && -f "$run/config/common" && -f "$run/auto/config" ]] || exit 1
[[ ! -e "$run/logs/build.started" ]] || { echo 'Run already attempted; prepare a fresh run.' >&2; exit 1; }
cd "$run"
[[ -z $(findmnt -rn -o TARGET | awk -v r="$run" '$0 == r || index($0,r"/")==1') ]] || { echo 'A mount remains inside this run.' >&2; exit 1; }
grep -qx 'LB_UEFI_SECURE_BOOT="enable"' config/binary
printf 'started\n' > logs/build.started
exec > >(tee logs/build.log) 2>&1
lb build
test -s live-image-amd64.hybrid.iso
sha256sum live-image-amd64.hybrid.iso > SHA256SUMS
sha256sum -c SHA256SUMS
touch logs/build.succeeded
printf '%s\n' "$run" > "$root/build/latest-successful-run.txt"
echo "ISO: $run/live-image-amd64.hybrid.iso"
echo 'Construction succeeded. Actual boot and device compatibility are still untested.'
