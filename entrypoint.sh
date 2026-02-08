#!/usr/bin/env bash
set -euo pipefail

APP_HOME="/opt/ohdsi"
WR_JAR="${APP_HOME}/WhiteRabbit.jar"

: "${WR_JAVA_OPTS:=}"
: "${DISPLAY:=:99}"
: "${XVFB_SCREEN:=1280x800x24}"
: "${ENABLE_VNC:=0}"
: "${VNC_PASSWORD:=}"

start_xvfb() {
  if ! pgrep -x Xvfb >/dev/null 2>&1; then
    Xvfb "${DISPLAY}" -screen 0 "${XVFB_SCREEN}" >/tmp/xvfb.log 2>&1 &
  fi
  export DISPLAY="${DISPLAY}"
}

start_vnc() {
  if [[ "${ENABLE_VNC}" == "1" ]]; then
    if [[ -n "${VNC_PASSWORD}" ]]; then
      x11vnc -display "${DISPLAY}" -rfbport 5900 -passwd "${VNC_PASSWORD}" -forever -shared -bg
    else
      x11vnc -display "${DISPLAY}" -rfbport 5900 -nopw -forever -shared -bg
    fi
  fi
}

run_wr_cli() {
  exec java ${WR_JAVA_OPTS} -jar "${WR_JAR}" "$@"
}

run_wr_gui() {
  start_xvfb
  fluxbox >/tmp/fluxbox.log 2>&1 &
  start_vnc
  exec java ${WR_JAVA_OPTS} -jar "${WR_JAR}"
}

cmd="${1:-}"
case "${cmd}" in
  gui)
    shift
    run_wr_gui
    ;;
  *)
    # Default: WhiteRabbit CLI with passthrough args
    run_wr_cli "$@"
    ;;
esac
