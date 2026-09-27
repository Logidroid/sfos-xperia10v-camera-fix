#!/bin/sh
# Remove sfos-xperia10v-camera-fix user services and files.
set -eu

FIX="${HOME}/camera-fix"
UNIT_DIR="${HOME}/.config/systemd/user"

systemctl --user disable --now camera-lens-guard.service 2>/dev/null || true
systemctl --user disable --now camera-provider.service 2>/dev/null || true

rm -f "${UNIT_DIR}/camera-provider.service"
rm -f "${UNIT_DIR}/camera-lens-guard.service"
rm -f "${UNIT_DIR}/user-session.target.wants/camera-provider.service"
rm -f "${UNIT_DIR}/user-session.target.wants/camera-lens-guard.service"
rm -f "${HOME}/bin/start-camera-provider.sh"
rm -f "${HOME}/bin/camera-lens-guard.sh"
rm -rf "${FIX}"

# restore default rear labels (do not force a deviceId)
dconf write /apps/jolla-camera/backCameraLabels "['1.0', '0.6', '2.0']" 2>/dev/null || true

systemctl --user daemon-reload

echo "Removed camera-provider + camera-lens-guard and ~/camera-fix."
echo "Camera HAL stays disabled until you start the vendor binary again."
