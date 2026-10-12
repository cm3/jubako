# Attempt once per tty1 login; failures leave a recovery console.
case $- in *i*) ;; *) return ;; esac
[ "$(id -un)" = user ] || return
[ "$(tty 2>/dev/null)" = /dev/tty1 ] || return
[ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] || return
[ "${JA_LIVE_DESKTOP_ATTEMPTED:-}" != yes ] || return
export JA_LIVE_DESKTOP_ATTEMPTED=yes
/usr/local/bin/start-desktop || :
