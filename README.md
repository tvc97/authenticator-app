# Authenticator (iOS · native SwiftUI)

A TOTP/HOTP authenticator for iOS, built natively with SwiftUI.

This repository is operated as an **AI-native development system**: Claude executes the
engineering loop, GitHub holds the state, and this Mac is the verification authority.

## How work happens here

```text
intent -> intake -> preflight -> plan -> [human approves] -> implement
       -> verify -> review -> [checks + approval] -> integrate -> learn
```

One command drives it:

```bash
./scripts/ai/flow status      # where is this issue?
./scripts/ai/flow next 12     # what is the one legal next action?
```

Read these in order:

| File | What it answers |
|---|---|
| `CLAUDE.md` | The rules Claude must follow |
| `.ai/adapter/manifest.yml` | Project facts (scheme, simulator, frozen paths) |
| `docs/testing/security-matrix.md` | What an authenticator must prove before shipping |
| `docs/release/checklist.md` | How a release is gated |
| `.ai/ledger/` | What this project has already learned |

## First-run setup

```bash
./.ai/adapter/env
```

It reports exactly what is missing and how to fix it. Nothing else runs until it passes.
