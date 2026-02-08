#!/usr/bin/env bash
set -euo pipefail

APP_HOME=/opt/ohdsi
JAR_PATH="${APP_HOME}/WhiteRabbit.jar"
LIB_DIR="${APP_HOME}/lib"
MAIN_CLASS="org.ohdsi.whiterabbit.WhiteRabbitMain"
JAVA_OPTS="${WR_JAVA_OPTS:-}"

if [ ! -f "${JAR_PATH}" ]; then
  echo "ERROR: JAR not found at ${JAR_PATH}" >&2
  exit 1
fi

CLASSPATH="${JAR_PATH}:${LIB_DIR}/*"

if [ "${1:-}" = "gui" ]; then
  shift
  export DISPLAY=${DISPLAY:-:1}

  if [ "${ENABLE_VNC:-0}" = "1" ]; then
    Xvfb "${DISPLAY}" -screen 0 1280x800x24 &
    fluxbox &
    if [ -n "${VNC_PASSWORD:-}" ]; then
      x11vnc -storepasswd "${VNC_PASSWORD}" /tmp/vncpass
      x11vnc -display "${DISPLAY}" -forever -shared -rfbauth /tmp/vncpass &
    else
      x11vnc -display "${DISPLAY}" -forever -shared &
    fi
  else
    Xvfb "${DISPLAY}" -screen 0 1280x800x24 &
    fluxbox &
  fi

  exec java ${JAVA_OPTS} -cp "${CLASSPATH}" "${MAIN_CLASS}" "$@"
else
  exec java ${JAVA_OPTS} -cp "${CLASSPATH}" "${MAIN_CLASS}" "$@"
fi