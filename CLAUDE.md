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
- `manifest.yml: human_paths` (entitlements, `Info.plist`) cannot be edited by an agent at
  all. The settings deny list and `pre-tool-safety.sh` both block it. A human changes these
  in Xcode, with an ADR.
- `manifest.yml: review_paths` (Crypto, Keychain, Backup, the adapter, the hooks) may be
  changed, but the change is not done until `/review` records `verdict: APPROVE` against the
  current HEAD in `.ai/run/<issue>/review.yml`. `scope-check` enforces it.

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

There is no CI. Nothing runs on GitHub's compute — `macos-15` runners bill at a 10x minute
multiplier, and the tiers already run here and already write evidence. So the tiers run on
this machine or they do not run at all, and they run **before** the PR exists, not after.

Tiers run in order and stop at the first failure:

1. `static` — swift-format lint + build warnings as errors
2. `unit` — logic, crypto, time, Keychain wrapper
3. `integration` — UI tests on simulator
4. `security` — secret-leak scan, entitlement check, pasteboard/log audit
5. `runtime` — the app actually launched and the flow actually worked

`./scripts/ai/flow verify <issue>` runs 1–4 and then resolves runtime. Tier 5 means
*launched **and** the flow worked*, so a launch alone earns `PASS` only when no app source
changed — tooling work has no user flow to drive. An app-source change with no
`.ai/scenarios/<issue>.sh` is `SKIP`.

A **device** run is never automatic; no agent can plug in a phone. It is required by the
`device-required` label **or** by a `manifest.yml: device_required_markers` hit in the diff,
and it is satisfied only by a recorded `.ai/run/<issue>/device.yml`. The check fails closed:
if the requirement cannot be determined, the answer is "device required".

Before opening a PR: `./scripts/ai/flow precheck <issue>`. It re-checks evidence and runs
`scope-check`, which has no other automatic caller now that CI is gone.

`SKIP` and `PASS` are different values. Never write `PASS` for a tier that did not run.
Simulator-verified and device-verified are different claims. Never collapse them.

## Time

TOTP correctness depends on the clock. The simulator clock is not the device clock.
Any change to code generation, drift handling, or counter math requires a device run
with a deliberately skewed clock. See `docs/testing/security-matrix.md`.

## Gates

Only three things wait on a human, and each waits because an agent physically cannot do it:

1. **`needs:clarification`** — a question addressed to the human.
2. **A device run** — someone has to plug in the iPhone.
3. **`gate:release-approved`** — publishing needs the human's Apple credentials, and is
   outward-facing and irreversible.

Everything else is derived from evidence on disk. Removing an approval gate did not remove a
security requirement: every rule above still binds. See ADR-002.

## Completion

You may write `DONE` only when `.ai/run/<issue>/evidence.yml` exists, its `commit`
equals `HEAD`, and every tier the issue requires is `PASS`. If the diff touched a
`review_path`, `.ai/run/<issue>/review.yml` must also read `verdict: APPROVE` at that
same commit.

Otherwise write:

```
BLOCKED
Reason:
Verified:
Not verified:
```

Never report an unverified item as passing. Never turn uncertainty into a completion message.
