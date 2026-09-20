# Security & Verification Matrix — Authenticator

An authenticator has three properties that must never regress. Everything below exists to
protect one of them.

1. **A seed never leaves the device in plaintext.**
2. **A seed is unreadable without the user's unlock.**
3. **A generated code is correct, or the app says it cannot be trusted.**

---

## Simulator vs device

| Verifiable on simulator | **Requires a physical device** |
|---|---|
| Code generation math | Keychain accessibility classes (simulator Keychain is not real) |
| Base32 decode, HMAC vectors | Secure Enclave |
| Drift math against an injected clock | Face ID / Touch ID, and failure/lockout paths |
| Layout, navigation, empty states | iCloud Keychain sync behavior |
| Import parsing from a fixture | Camera QR scanning |
| Error copy | AutoFill extension |
| | Background/foreground time drift over hours |
| | Entitlement-gated behavior |
| | Passcode-removed / passcode-changed invalidation |

Recording a simulator run as device verification is a false completion claim. They are
different values in `evidence.yml`.

---

## Required scenarios

### S1 — Secret lifecycle
- Add via QR, via manual entry, via `otpauth://` URI
- Relaunch cold: secret still present, still correct
- Delete: secret is gone from Keychain, not merely hidden in the UI
- App uninstall → reinstall: secrets do **not** reappear

### S2 — Lock boundary
- Biometric gate on cold launch
- Biometric gate after backgrounding beyond the timeout
- Biometric **failure** path: codes are not visible, not in the app switcher snapshot
- Device passcode removed → items become inaccessible, and the app says so rather than crashing
- App-switcher snapshot does not show codes

### S3 — Time correctness
- Device clock +30s, +90s, −90s: code correctness and the drift indicator
- Timezone change mid-session
- Automatic time toggled off, then set manually wrong
- Counter-based (HOTP) increments exactly once per user action, including on rapid taps

### S4 — Leak audit
- `.ai/adapter/run sim` log audit passes (no `otpauth://`, no base32, no `sharedSecret`)
- Crash report contains no secret material
- Pasteboard entry expires; verify it is gone after the expiry
- No secret in a backup that leaves the device unencrypted

### S5 — Data shape
- Empty state
- One account
- 200+ accounts: list performance and code refresh stay smooth
- Duplicate issuer/account names remain distinguishable
- Malformed / hostile `otpauth://` input is rejected without crashing
- Migration from the previous schema version preserves every secret

### S6 — Import / export
- Export requires authentication
- Exported payload is encrypted
- Import rejects a tampered payload
- Round-trip: export then import on a clean install reproduces every account exactly

---

## Release gate

A release may not ship unless **S1, S2, S3 and S4 have been executed on a physical device**
against the exact release build, and the results are recorded in the release report with
the device model and iOS version.
