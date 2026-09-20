---
name: preflight
description: Read the project's accumulated experience before planning a change. Use after an issue exists and before writing a plan, to surface prior incidents, failed approaches and required verification.
---

# Preflight

This is the **read path** of the memory system. If it finds nothing useful, the ledger's tags are wrong.

1. Derive tags from the change: subsystem (`keychain`, `crypto`, `totp`, `ui`, `backup`, `qr`, `biometrics`, `build`, `release`).
2. Search the ledger:
   ```bash
   grep -l -E "tags:.*(keychain|crypto)" .ai/ledger/*.md
   ```
3. Read every match. Read `docs/decisions/` ADRs that touch the same subsystem.
4. Check `gh issue list --state closed --search "<subsystem>"` for prior attempts.

Post this as a comment on the issue:

```md
# Preflight

## Relevant history
## Known incidents (with recurrence counts)
## Previously failed approaches
## Required verification for this change class
## Recommended precautions
```

Preflight never blocks. If there is no history, say "no prior records" — that is a
useful finding, not a failure.
