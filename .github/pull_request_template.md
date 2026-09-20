# Summary

<!-- What changed, in one paragraph. -->

# Related issue

Closes #

# Changes

-

# Verification

Paste the tier results from `.ai/run/<issue>/evidence.yml`. Do not hand-write them.

- [ ] static
- [ ] unit
- [ ] integration
- [ ] security
- [ ] runtime — target: `simulator` / `device` (circle one; they are not equivalent)

Evidence commit: `` (must equal this PR's head commit)

# Security impact

- [ ] No new path where a seed, derived code or `otpauth://` URI can be logged, copied, or persisted outside the Keychain
- [ ] Keychain accessibility class unchanged, or changed with an ADR
- [ ] No new third-party dependency, or added with an ADR
- [ ] Entitlements and Info.plist unchanged
- [ ] Pasteboard writes (if any) expire and do not sync

# Runtime verification

<!-- What you actually did in the running app, on what device, and what you saw. -->

# Risks

-

# Known limitations / unverified

<!-- Anything from evidence.yml `unverified:`. If this is empty and a tier says SKIP, that is a contradiction. -->
