# Architecture Overview

> Fill this in as the app takes shape. It exists now so preflight has somewhere to look.

## Layering rule

```
SwiftUI Views        dumb; no crypto, no Keychain, no clock access
ViewModels           observable state, no secrets held longer than needed
Domain               TOTP/HOTP generation, drift, counters   <- pure, fully unit tested
Storage              Keychain wrapper                        <- the only place a seed lives
Platform             biometrics, camera, pasteboard, time
```

A seed crosses exactly one boundary: Storage → Domain, in memory, for one generation.
It never reaches a View, a log, or disk outside the Keychain.

## Why this layering

It makes the security properties testable without a UI, and it makes `frozen_paths`
meaningful: `Crypto/`, `Keychain/` and `Backup/` are small, reviewed, and rarely changed.

## To document as it exists
- data model and schema version
- migration strategy
- time source and drift handling
- backup/export format
