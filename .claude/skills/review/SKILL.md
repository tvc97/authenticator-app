---
name: review
description: Get an independent cold review of a PR against its issue, plan and evidence, and record the verdict as evidence. Use after verification passes, before opening or merging a PR.
---

# Review

There is no CI and no human approver. This step is the only thing between a diff and `main`,
so it produces **evidence**, not an opinion: `/review` writes `.ai/run/<issue>/review.yml`,
and `scope-check` and `flow` both read it. See ADR-002.

## 1. Refuse early if the work is not verified

```bash
./scripts/ai/flow evidence <issue>     # must end: PASS fresh (matches HEAD)
```

If it prints `STALE` or any tier is `FAIL`/`SKIP`, stop. Do not open a PR, do not review.
Re-run `./scripts/ai/flow verify <issue>` first. A review of an unverified diff is theatre.

## 2. See which guarded paths the diff touches

```bash
./.ai/adapter/checks/scope-check origin/main <issue>
```

For a **stacked** branch, pass the parent branch instead — `BASE_REF=<parent> …`.
Diffed against `main`, a stacked branch re-litigates its parent's commits. `scope-check`
refuses a base that already contains HEAD, so `BASE_REF=HEAD` is not a way around a
red gate.

Before a verdict exists this reports `BLOCKED` for any `review_paths` touched. That is the
gate working, not noise — it is telling you which hunks the reviewer must read line by line.
Note them. **Step 5 re-runs this check for real**, after the verdict is on disk; do not treat
this first run as the enforcement.

## 3. Delegate to the `reviewer` subagent

Give it the issue, the plan, the diff and the evidence file. Do **not** give it your
implementation reasoning — its independence is the entire value. If you explain why you did
something, you have replaced a review with a negotiation.

## 4. Record the verdict

```yaml
# .ai/run/<issue>/review.yml
issue: 24
commit: 5fbea7a          # must equal HEAD, or the review is stale
reviewed: 2026-09-20T09:12:00Z
verdict: APPROVE          # APPROVE | REQUEST_CHANGES
reviewer: cold-subagent
scope:
  human_paths_touched: false
  review_paths_touched: [".ai/adapter/**"]
items:
  - n: 1
    severity: minor
    summary: "..."
    resolution: "fixed in 88cfc02"
```

Three rules, the same three that govern the evidence file:

1. `APPROVE` only if the reviewer actually returned APPROVE. Never translate "no blocking
   findings" into APPROVE on the reviewer's behalf.
2. `commit` is the HEAD the reviewer actually saw. Any commit after it invalidates the
   review — `scope-check` enforces this, so writing a future SHA breaks the build, not the rule.
3. On `REQUEST_CHANGES`, every numbered item is addressed and the whole cycle repeats:
   verify → review. Do not argue with a finding you have not first verified against the code.

## 5. Re-run the gate, for real this time

```bash
./scripts/ai/flow precheck <issue>
```

This re-checks that evidence is fresh and all-PASS, then runs `scope-check` against the
verdict now on disk. Nothing else calls `scope-check` any more — the deleted CI job used to
be its only automatic caller — so if this is skipped, the APPROVE requirement is enforced by
nobody. It must print `precheck OK`.

## 6. Open the PR

Only after `precheck OK`:

```bash
gh pr create --fill --body-file .github/pull_request_template.md
```

Put the verdict and the reviewed commit in the PR body. `.ai/run/` is gitignored, so the PR
is the only place the verdict leaves this machine.

Then the state is `READY_TO_MERGE`. Confirm with `./scripts/ai/flow next <issue>`.
