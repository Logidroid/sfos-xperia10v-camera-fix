#!/bin/sh
# Run Camera HAL provider from ~/camera-fix so CamX picks up local overrides.
set -eu

FIX="${HOME}/camera-fix"
cd "${FIX}" || exit 1

BIN=/vendor/bin/hw/android.hardware.camera.provider@2.5-service_64
if [ ! -x "${BIN}" ]; then
  echo "ERROR: ${BIN} missing" >&2
  exit 1
fi

exec "${BIN}"
