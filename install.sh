#!/bin/sh
# Install Xperia 10 V camera HAL provider workaround (user systemd units).
#
# Jolla disables vendor.camera-provider-2-5 at boot; this starts the binary
# after the user session so jolla-camera can use Camera2 / CamX.
#
# Also installs a lens guard: rear 1.0 (OIS) and 0.6/tele (actuator I2C) black
# the viewfinder and stick deviceId — guard snaps back to working ultrawide (3).
set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
FIX="${HOME}/camera-fix"
UNIT_DIR="${HOME}/.config/systemd/user"
BIN=/vendor/bin/hw/android.hardware.camera.provider@2.5-service_64

echo "==> sfos-xperia10v-camera-fix v1.1"
echo "==> Install dir: ${FIX}"

if [ ! -x "${BIN}" ]; then
  echo "ERROR: ${BIN} not found (wrong device / incomplete vendor image?)."
  exit 1
fi

mkdir -p "${FIX}" "${UNIT_DIR}" "${HOME}/bin"

cp "${REPO_DIR}/files/camxoverridesettings.txt" "${FIX}/camxoverridesettings.txt"
cp "${REPO_DIR}/scripts/start-camera-provider.sh" "${FIX}/start-camera-provider.sh"
cp "${REPO_DIR}/scripts/camera-lens-guard.sh" "${HOME}/bin/camera-lens-guard.sh"
chmod +x "${FIX}/start-camera-provider.sh" "${HOME}/bin/camera-lens-guard.sh"
cp "${FIX}/start-camera-provider.sh" "${HOME}/bin/start-camera-provider.sh"
chmod +x "${HOME}/bin/start-camera-provider.sh"

cat > "${UNIT_DIR}/camera-provider.service" << EOF
[Unit]
Description=Xperia 10 V camera HAL provider (Jolla disables this at boot)
Documentation=file://${REPO_DIR}/README.md
After=pre-user-session.target

[Service]
Type=simple
WorkingDirectory=${FIX}
ExecStart=${FIX}/start-camera-provider.sh
Restart=on-failure
RestartSec=3
StartLimitIntervalSec=60
StartLimitBurst=5

[Install]
WantedBy=user-session.target
EOF

cat > "${UNIT_DIR}/camera-lens-guard.service" << EOF
[Unit]
Description=Xperia 10 V camera: avoid stuck black screen on broken rear lenses
Documentation=file://${REPO_DIR}/README.md
After=camera-provider.service
Wants=camera-provider.service

[Service]
Type=simple
ExecStart=${HOME}/bin/camera-lens-guard.sh
Restart=on-failure
RestartSec=2

[Install]
WantedBy=user-session.target
EOF

# Prefer working ultrawide (deviceId 3). Empty labels hide broken 1.0 / 0.6 buttons
# (CameraDeviceToggle only shows non-empty labels; order = backFacingCameras = 0,2,3).
dconf write /apps/jolla-camera/deviceId 3
dconf write /apps/jolla-camera/position 1
dconf write /apps/jolla-camera/previousBackFacingDeviceId 3
dconf write /apps/jolla-camera/backCameraLabels "['', '', 'UW']"

systemctl --user daemon-reload
systemctl --user enable camera-provider.service camera-lens-guard.service
systemctl --user restart camera-provider.service
systemctl --user restart camera-lens-guard.service

sleep 1
if systemctl --user is-active --quiet camera-provider.service; then
  echo "OK: camera-provider.service is active."
else
  echo "WARN: camera-provider not active — systemctl --user status camera-provider.service"
fi
if systemctl --user is-active --quiet camera-lens-guard.service; then
  echo "OK: camera-lens-guard.service is active."
else
  echo "WARN: lens-guard not active — systemctl --user status camera-lens-guard.service"
fi

echo
echo "Done."
echo "  - Working: front + rear UW (UI button UW / was mislabeled 2.0)."
echo "  - Not optical yet: 1.0 (OIS/cam_vaf) and tele/0.6 (actuator I2C) — kernel/blob issue."
echo "  - Guard auto-recovers if you land on a broken rear id."
echo "Uninstall: ${REPO_DIR}/uninstall.sh"
