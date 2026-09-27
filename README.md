# sfos-xperia10v-camera-fix

Workaround for the camera on official **Sailfish OS** for **Sony Xperia 10 V**
(`pdx235` / XQ-DC54).

## Cause

Jolla ships the device with the main Camera HAL provider **disabled at boot**
(`vendor.camera-provider-2-5` → `…service_64_HYBRIS_DISABLED`) so a broken
provider cannot hang suspend / drain the battery. Without that process,
`jolla-camera` opens with a black viewfinder.

## What this does

1. Starts `/vendor/bin/hw/android.hardware.camera.provider@2.5-service_64` as a
   **user** systemd service after the session is up.
2. Optional CamX overrides from `~/camera-fix/`.
3. **Lens guard** + UI labels: rear **1.0** (OIS) and **0.6/tele** (actuator I2C)
   black the viewfinder and can stick `deviceId`. Install hides those buttons and
   snaps back to the working ultrawide (`deviceId` 3) if you hit a broken id.

## Known limits (10 V) — verified on device + community

| `deviceId` | Physical lens | Stock UI label | Status |
|------------|---------------|----------------|--------|
| 1 | Front 8 MP | (front) | Works |
| 3 | Ultrawide 16 mm | often shown as **2.0** | Works |
| 0 | Main 48 MP IMX582 | **1.0** | Fails: OIS / `cam_vaf` |
| 2 | Tele 54 mm | **0.6** | Fails: actuator I2C NACK |

True **three optical FOVs** need a kernel/blob fix for OIS + tele actuator.
Nobody has published that for the Jolla 10 V port yet (forum thread still open).
Use pinch **digital zoom** on the ultrawide for approximate FOV for now.

Video may still crash the app. Blobs (`v4b` vs Jolla A14) change reliability.

## Install (on the phone)

Developer Mode + SSH or Terminal:

```sh
cd sfos-xperia10v-camera-fix
chmod +x install.sh uninstall.sh
./install.sh
```

Then open **Camera** and switch to the front camera if needed.

## Uninstall

```sh
./uninstall.sh
```

## Licence

MIT — see [LICENSE](LICENSE).
