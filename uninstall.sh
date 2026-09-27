#!/bin/sh
# Remove sfos-xperia10v-camera-fix user service and files.
set -eu

FIX="${HOME}/camera-fix"
UNIT_DIR="${HOME}/.config/systemd/user"

systemctl --user disable --now camera-provider.service 2>/dev/null || true

rm -f "${UNIT_DIR}/camera-provider.service"
rm -f "${UNIT_DIR}/user-session.target.wants/camera-provider.service"
rm -f "${HOME}/bin/start-camera-provider.sh"
rm -rf "${FIX}"

systemctl --user daemon-reload

echo "Removed camera-provider.service and ~/camera-fix."
echo "Camera HAL stays disabled until you start the vendor binary again."
