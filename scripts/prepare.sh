#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
[[ $# == 0 ]] || { echo 'Usage: scripts/prepare.sh'; exit 2; }
(( EUID != 0 )) || { echo 'Prepare as an ordinary user.' >&2; exit 1; }
command -v lb >/dev/null
[[ $(dpkg --print-architecture) == amd64 ]] || { echo 'This example requires an amd64 host.' >&2; exit 1; }
mkdir -p "$root/build/runs"
run=$(mktemp -d "$root/build/runs/desktop-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")
cp -R "$root/recipe/auto" "$root/recipe/config" "$run/"
mkdir "$run/logs"
(cd "$run"; lb config --cache-packages true --cache-indices true --cache-stages bootstrap) > "$run/logs/config.log" 2>&1
printf '%s\n' "$run" > "$root/build/latest-run.txt"
printf 'Prepared: %s\nBuild: sudo bash scripts/build.sh\n' "$run"
