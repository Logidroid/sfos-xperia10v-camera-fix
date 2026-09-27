# sfos-xperia10v-camera-fix

Workaround for the camera on official **Sailfish OS** for **Sony Xperia 10 V**
(`pdx235` / XQ-DC54).

## Cause

Jolla ships the device with the main Camera HAL provider **disabled at boot**
(`vendor.camera-provider-2-5` → `…service_64_HYBRIS_DISABLED`) so a broken
provider cannot hang suspend / drain the battery. Without that process,
`jolla-camera` opens with a black viewfinder.

## What this does

Starts `/vendor/bin/hw/android.hardware.camera.provider@2.5-service_64` as a
**user** systemd service after the session is up (same idea as the community
workaround), plus optional CamX overrides loaded from `~/camera-fix/`.

## Known limits (10 V)

| Lens (UI) | Status |
|-----------|--------|
| Front (selfie) | Works with this fix |
| Rear 1.0× (main / IMX582) | Often fails (OIS / `cam_vaf`) |
| Rear “0.6” / tele | Often fails (I2C) |
| Rear “2.0” / ultrawide | May work depending on blobs |

Video may still crash the app. Stock Android OEM blobs (`v4b` vs Jolla A14)
affect which lenses work.

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
