---
name: learn
description: Convert a finished issue into durable project knowledge. Use after merging, to record incidents, lessons and at most one improvement proposal.
---

# Learn

```bash
./scripts/ai/flow status <issue>    # expect COMPLETE
```

Read: the issue, review findings, every verification failure in `.ai/run/<issue>/*.log`, and the timings.

For each distinct failure or lesson write one `.ai/ledger/<TYPE>-<nnnn>-<slug>.md`:

```yaml
---
id: INC-0007
type: incident          # incident | lesson | decision | experiment | postmortem
title: ...
tags: [keychain, biometrics]      # the entire retrieval index — get these right
severity: low | medium | high | critical
occurrences: 1
status: recorded        # recorded | proposed | automated | promoted
prevention: ""
links: [issue:12, pr:14]
first_seen: YYYY-MM-DD
last_seen: YYYY-MM-DD
---
## Symptom
## Root cause
## Detection
## Resolution
## Prevention
```

If a matching record exists, **increment `occurrences` and update `last_seen`** instead of creating a duplicate.

## Promotion

| Severity | 1st | 2nd | 3rd+ |
|---|---|---|---|
| critical (seed exposure, signing, data loss, release) | guard proposal + stop for human | — | — |
| high | record + regression test | guard proposal | automate |
| medium | record | proposal | automate |
| low | record | record | proposal |

Always prefer, in this order: **regression test → automated check → documentation → rule.**
A prompt-only fix is the last resort.

## Write authority

| Write freely | Propose only (human merges) | Frozen |
|---|---|---|
| ledger entries, counters | `CLAUDE.md` | permissions / deny-list |
| regression tests | hooks | signing + credentials |
| `docs/troubleshooting/` | verification tiers | release gates |
| issue/PR bodies, labels | adapter verbs | `gate:*` semantics |

**One proposal per issue, maximum.** A workflow that rewrites itself after every mistake is unstable.
