# Ledger

Append-only, machine-written records of what this project has learned.
One schema, one retrieval path: **`tags` is the entire index.**

```bash
grep -l -E "tags:.*(keychain|biometrics)" .ai/ledger/*.md
```

`preflight` runs that search before planning. If a record is not findable by tag, its tags
are wrong — that is the only quality bar the format needs.

## Schema

```yaml
---
id: INC-0001            # INC incident · LES lesson · DEC decision · EXP experiment · PM postmortem
type: incident
title: ...
tags: [subsystem, ...]
severity: low | medium | high | critical
occurrences: 1          # increment, never duplicate
status: recorded | proposed | automated | promoted
prevention: path/to/check  # empty until automated
links: [issue:12, pr:14, adr:001]
first_seen: YYYY-MM-DD
last_seen: YYYY-MM-DD
---
## Symptom
## Root cause
## Detection
## Resolution
## Prevention
```

## Seeded records

The `LES-000x` records below start at `occurrences: 0`. They are **known risk classes for
authenticator apps**, not incidents observed in this repository. They exist so the first
preflight is not empty. Increment them only if they actually happen here.
