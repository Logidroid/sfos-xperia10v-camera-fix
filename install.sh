#!/bin/sh
# Install Xperia 10 V camera HAL provider workaround (user systemd unit).
#
# Jolla disables vendor.camera-provider-2-5 at boot; this starts the binary
# after the user session so jolla-camera can use Camera2 / CamX.
set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
FIX="${HOME}/camera-fix"
UNIT_DIR="${HOME}/.config/systemd/user"
UNIT="${UNIT_DIR}/camera-provider.service"
BIN=/vendor/bin/hw/android.hardware.camera.provider@2.5-service_64

echo "==> sfos-xperia10v-camera-fix v1.0"
echo "==> Install dir: ${FIX}"

if [ ! -x "${BIN}" ]; then
  echo "ERROR: ${BIN} not found (wrong device / incomplete vendor image?)."
  exit 1
fi

mkdir -p "${FIX}" "${UNIT_DIR}" "${HOME}/bin"

cp "${REPO_DIR}/files/camxoverridesettings.txt" "${FIX}/camxoverridesettings.txt"
cp "${REPO_DIR}/scripts/start-camera-provider.sh" "${FIX}/start-camera-provider.sh"
chmod +x "${FIX}/start-camera-provider.sh"

# Convenience wrapper for manual start / debug
cp "${FIX}/start-camera-provider.sh" "${HOME}/bin/start-camera-provider.sh"
chmod +x "${HOME}/bin/start-camera-provider.sh"

cat > "${UNIT}" << EOF
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

systemctl --user daemon-reload
systemctl --user enable camera-provider.service
systemctl --user restart camera-provider.service

sleep 1
if systemctl --user is-active --quiet camera-provider.service; then
  echo "OK: camera-provider.service is active."
else
  echo "WARN: service not active yet — check: systemctl --user status camera-provider.service"
fi

echo
echo "Done."
echo "  - Open jolla-camera; front camera should show a live viewfinder."
echo "  - Rear 1.0x may still fail (OIS) on many 10 V blobs."
echo "Uninstall: ${REPO_DIR}/uninstall.sh"
