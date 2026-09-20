---
name: release
description: Take a completed milestone through release-check, build, package, report and human-gated publish. Use when a milestone's issues are all closed.
---

# Release

## 1. Release check

```
[ ] All milestone issues closed, no open blocking issue
[ ] Working tree clean, on main, up to date
[ ] Version and build number correct and incremented
[ ] CHANGELOG updated
[ ] Every tier PASS on the release commit
[ ] Security matrix scenarios executed on a PHYSICAL device
[ ] No secret material in any shipped log path
[ ] Signing identity and profile match manifest.project.team_id
```

## 2. Build and package

```bash
./scripts/ai/flow verify release
./.ai/adapter/package <version>
```

Artifacts land in `build/<version>/`. Preserve them; they are the release record.

## 3. Report

Write `build/<version>/release-report.md`: commit, milestone, per-tier results, device
verification with the actual device and iOS version, known issues, artifact path, and
`READY FOR HUMAN APPROVAL`.

## 4. Gate

A human adds `gate:release-approved` and types the version at the prompt:

```bash
./.ai/adapter/publish <version>
```

Never publish without both. Never decide on your own that a release is acceptable.

## 5. Rollback

If a shipped build is bad: expire the TestFlight build, open a `fix/` issue against the
release milestone, and write a postmortem to `.ai/ledger/`. The question a postmortem must
answer is not "what broke" but **"why did the system let this reach production?"**
