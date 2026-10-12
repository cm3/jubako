#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
[[ $# == 0 || ( $# == 1 && $1 == --dependencies ) ]] || exit 2
while IFS= read -r -d '' file; do
    first=$(head -n 1 "$file")
    case "$first" in '#!/bin/bash'*) bash -n "$file" ;; '#!/bin/sh'*) sh -n "$file" ;; esac
done < <(find "$root/scripts" "$root/recipe" -type f -print0)
command -v python3 >/dev/null || { echo 'Install python3 on the build host before running check.' >&2; exit 1; }
python3 "$root/scripts/check-files.py"
if [[ ${1:-} == --dependencies ]]; then
    [[ $(dpkg --print-architecture) == amd64 ]] || exit 1
    apt_root="$root/build/checks/apt"
    mkdir -p "$apt_root/lists/partial" "$apt_root/archives/partial" "$apt_root/empty"
    cat > "$apt_root/sources.list" <<'SOURCES'
deb https://deb.debian.org/debian trixie main non-free-firmware
deb https://deb.debian.org/debian trixie-updates main non-free-firmware
deb https://security.debian.org/debian-security trixie-security main non-free-firmware
SOURCES
    apt_options=(
        -o "Dir::Etc::sourcelist=$apt_root/sources.list"
        -o "Dir::Etc::sourceparts=$apt_root/empty"
        -o "Dir::Etc::preferences=$apt_root/preferences"
        -o "Dir::Etc::preferencesparts=$apt_root/empty"
        -o "Dir::State::lists=$apt_root/lists"
        -o "Dir::Cache::archives=$apt_root/archives"
        -o "Dir::Cache::pkgcache=$apt_root/pkgcache.bin"
        -o "Dir::Cache::srcpkgcache=$apt_root/srcpkgcache.bin"
        -o Dir::State::status=/dev/null
        -o APT::Get::List-Cleanup=false
        -o APT::Update::Error-Mode=any
    )
    : > "$apt_root/preferences"
    # Independent target index: host sources often lack non-free-firmware.
    apt-get "${apt_options[@]}" update > "$root/build/checks/index.log" 2>&1
    mapfile -t packages < <(sed '/^#/d;/^$/d' "$root/recipe/config/package-lists/desktop.list.chroot")
    apt-get -s --no-install-recommends "${apt_options[@]}" install "${packages[@]}" > "$root/build/checks/dependencies.log"
    echo 'Independent Debian 13 target index dependency simulation: PASS.'
fi
echo 'Source checks passed; no package installation, mounts, ISO or disk writes.'
