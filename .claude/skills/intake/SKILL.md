---
name: intake
description: Turn a human request into a GitHub issue with acceptance criteria and a required-verification list. Use at the start of any non-trivial change, before reading or writing code.
---

# Intake

Do not edit code. Produce a contract.

1. **Deduplicate** — `gh issue list --search "<keywords>" --state all`. If it exists, update it instead.
2. **Classify** — feature / bug / task / investigation. Pick the matching template in `.github/ISSUE_TEMPLATE/`.
3. **Write acceptance criteria** as checkboxes a reviewer could verify without asking you anything.
4. **Decide the required verification tiers.** Consult `.ai/adapter/manifest.yml`:
   - Touches anything in `device_required_for` → runtime target is **device**, not simulator. Say so in the issue.
   - Touches seeds, Keychain, pasteboard, logging, backup → `security` tier is required.
   - Touches code generation, counters or drift → clock-skew scenarios are required.
5. **Create it** — `gh issue create --template <type>.md`.
6. If scope is genuinely ambiguous, ask at most **three** questions, add label `needs:clarification`, and stop.

Never start implementing in the same turn. The issue is the definition of done; write it first.
