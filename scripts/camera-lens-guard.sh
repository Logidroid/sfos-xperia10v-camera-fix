#!/bin/sh
# Keep jolla-camera off broken rear lenses on Xperia 10 V.
# deviceId 0 (main/1.0) fails OIS; deviceId 2 (tele/0.6) fails actuator I2C.
# Working rear lens: deviceId 3 (ultrawide, UI often labeled 2.0).
set -eu

export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/dbus/user_bus_socket}"
GOOD=3

while true; do
  id=$(dconf read /apps/jolla-camera/deviceId 2>/dev/null | tr -d "'") || id=
  case "$id" in
    0|2)
      dconf write /apps/jolla-camera/deviceId "$GOOD"
      dconf write /apps/jolla-camera/position 1
      dconf write /apps/jolla-camera/previousBackFacingDeviceId "$GOOD"
      if pidof jolla-camera >/dev/null 2>&1; then
        killall jolla-camera 2>/dev/null || true
        sleep 0.5
        invoker --type=silica-media,silica-qt5 -A -- /usr/bin/jolla-camera >/dev/null 2>&1 &
      fi
      ;;
  esac
  sleep 1
done
