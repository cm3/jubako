# Third-party components

This repository's original scripts, configuration and documentation use the MIT license.
That license does not relicense Debian packages, applications, fonts or firmware.

- Debian / live-build: packages are fetched from Debian by the person building. Their own copyright and license files apply; see `/usr/share/doc/<package>/copyright` in the built system.
- labwc, Firefox ESR, Xfce Terminal, Fcitx5/Mozc, PipeWire and Noto fonts: installed as Debian packages, not stored in this Git repository.
- Non-free firmware: explicitly requested through Debian's `non-free-firmware` archive area. Its package-specific terms still apply.
- The labwc XML, input profile, helper scripts and HTML/CSS here are newly written examples. No third-party theme or icon files have been copied into the repository.

No Zed/Codex/Claude binaries, npm dependencies, machine-specific kernel modules,
MOK keys, credentials or generated ISO files are included.
If you distribute an ISO you build, separately check the licenses, notices and
source obligations of all included packages. This repository does not publish ISOs.
