# Device Matrix

## Simulator (routine verification)
- iPhone 18 Pro / iOS 27.1 — the default in `.ai/adapter/manifest.yml`

## Physical (required before release)
- Primary development iPhone — fill in `manifest.yml: device.name`
- Oldest supported device — fill in `manifest.yml: device.min_supported`

Keep the minimum-supported device around. Biometric, Keychain and performance behavior on
the oldest supported hardware is where authenticators actually break.

## Recording

Every runtime claim in `evidence.yml` must carry the real device string:

```yaml
runtime:
  target: device
  device: "iPhone 17 Pro / iOS 27.1"
```
