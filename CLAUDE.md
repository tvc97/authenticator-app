# Authenticator — Project Rules

Native SwiftUI iOS authenticator (TOTP/HOTP). This file is short on purpose.
Procedures live in `.claude/skills/`. Project facts live in `.ai/adapter/manifest.yml`.

## The rule that overrides the others

Anything a gate depends on must be **observable data**, not a sentence you wrote.
State is derived from GitHub, never stored. Completion is evidence, never a claim.

## Platform

- iOS only. Native SwiftUI. Swift 6 strict concurrency.
- Xcode is the build authority. Never hand-edit `project.pbxproj` to fix a build.
- Read `.ai/adapter/manifest.yml` for scheme, simulator, bundle id, minimum iOS.
  **Never invent these values.** If the manifest says `pending-discovery`, run
  `./.ai/adapter/setup` or stop and ask.

## Commands

Never invent build or test commands. Call the adapter:

```
./.ai/adapter/env          ./.ai/adapter/build <debug|release>
./.ai/adapter/static       ./.ai/adapter/run <sim|device>
./.ai/adapter/unit         ./.ai/adapter/package <version>
./.ai/adapter/integration  ./.ai/adapter/publish <version>
./.ai/adapter/security
```

## Security — this is an authenticator

Treat every TOTP seed as a credential that must never leave the Secure Enclave-backed
Keychain. These are not style preferences; they are correctness requirements.

- Secrets live in Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` unless an
  ADR says otherwise. Never `UserDefaults`, never a plist, never a log line, never analytics.
- Never log, print, or include a seed, a derived code, or a raw `otpauth://` URI — including
  in error messages, crash reports and debug builds.
- Pasteboard writes of a code must set an expiry and must not sync to other devices.
- Biometric/passcode gate is a security boundary, not a UI state. Changing it requires an ADR.
- Crypto is HMAC/base32 from a reviewed implementation. Do not hand-roll, do not "optimize".
- Any change touching a path in `manifest.yml: frozen_paths` stops for human review.

## Architecture

- Read existing code before modifying it. Reuse existing abstractions first.
- No new dependency without an ADR. An authenticator's dependency surface is its attack surface.
- No unrelated refactors while implementing an issue.
- Keep views dumb; keep crypto, Keychain and time logic in testable non-UI types.

## Git and GitHub

- Never commit to `main`. One issue = one branch = one PR.
- Branch: `<type>/<issue>-<slug>` — `feature/12-qr-import`.
- Conventional commits. Small, reviewable.
- Every non-trivial change has an issue; every PR closes one.
- Work in a dedicated worktree: `git worktree add ../wt-<issue> <branch>`.

## Verification

Tiers run in order and stop at the first failure:

1. `static` — swift-format lint + build warnings as errors
2. `unit` — logic, crypto, time, Keychain wrapper
3. `integration` — UI tests on simulator
4. `security` — secret-leak scan, entitlement check, pasteboard/log audit
5. `runtime` — the app actually launched and the flow actually worked

`SKIP` and `PASS` are different values. Never write `PASS` for a tier that did not run.
Simulator-verified and device-verified are different claims. Never collapse them.

## Time

TOTP correctness depends on the clock. The simulator clock is not the device clock.
Any change to code generation, drift handling, or counter math requires a device run
with a deliberately skewed clock. See `docs/testing/security-matrix.md`.

## Completion

You may write `DONE` only when `.ai/run/<issue>/evidence.yml` exists, its `commit`
equals `HEAD`, and every tier the issue requires is `PASS`.

Otherwise write:

```
BLOCKED
Reason:
Verified:
Not verified:
```

Never report an unverified item as passing. Never turn uncertainty into a completion message.
