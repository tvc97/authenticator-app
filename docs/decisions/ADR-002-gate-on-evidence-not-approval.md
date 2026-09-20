# ADR-002: Gate on local evidence, not on human approval or CI

Status: accepted
Date: 2026-09-20

Amends ADR-001 (gates as labels, CI as a second opinion). Does not supersede it — the
evidence-file principle is kept and extended.

## Context

ADR-001 built two waiting rooms into the workflow, and neither was paying for itself.

**The approval gate.** `gate:plan-approved` blocked all implementation until a human added a
label. On a single-maintainer repo the human adding the label is the same person who asked
for the work five minutes earlier. The label recorded that someone had been interrupted, not
that anything had been checked.

**The CI job.** `.github/workflows/ci.yml` ran four jobs on `macos-15`, which GitHub bills at
a **10x minute multiplier**. It duplicated tiers that already run locally and already write
`.ai/run/<issue>/evidence.yml`.

CI had also never once been green:

- the frozen-path check failed on any change to `.ai/adapter/**`, which is most workflow work
- the hosted runner image could not resolve the simulator named in `manifest.yml` (#26)

A check that is permanently red stops carrying information. The workflow learns to route
around it, and a genuine failure becomes indistinguishable from the standing one. That is the
same failure class as #25, where a stale `-resultBundlePath` produced a `unit FAIL` that
looked exactly like a real test failure.

There was also a live deadlock. `flow` derived `READY_TO_MERGE` from the PR's
`reviewDecision`, but GitHub does not let an author approve their own PR. An agent-opened PR
could never leave `AWAITING_REVIEW` on its own.

## Decision

**A gate exists only where the agent physically cannot act.** Three remain:

1. `needs:clarification` — a question addressed to the human.
2. A device run — someone has to plug in the iPhone.
3. `gate:release-approved` — publishing needs the human's Apple credentials, and is
   outward-facing and irreversible.

Everything else is derived from evidence on disk.

**`frozen_paths` splits in two.**

| | old | new |
|---|---|---|
| entitlements, `Info.plist` | stop and ask | `human_paths` — agent cannot edit them at all |
| Crypto, Keychain, Backup, adapter, hooks, `scripts/ai/**` | stop and ask | `review_paths` — cold review must record APPROVE |

**The reviewer's verdict becomes evidence.** `/review` writes `.ai/run/<issue>/review.yml`
with `verdict` and the `commit` actually reviewed. `scope-check` refuses a `review_paths`
diff without `verdict: APPROVE` at the current HEAD, and `flow` derives `READY_TO_MERGE` from
that file instead of from `reviewDecision`. This is ADR-001's own principle applied to review:
observable data, not a sentence someone wrote.

**CI is deleted.** Verification becomes a precondition for opening a PR rather than something
that happens after it. `flow verify` now also runs the simulator runtime tier automatically,
so the common path reaches all-PASS without hand-editing the evidence file — which was itself
a quiet invitation to write `PASS` for something that never ran.

## Alternatives considered

**Keep CI, pin the runner image to match the manifest.** Tried first, filed as #26. Rejected:
it still bills 10x for a duplicate of the local tiers, and pinning makes `manifest.yml`
describe two machines instead of one.

**Keep CI for the cheap jobs only** (`static`, `security` on `ubuntu-latest`). Rejected: both
need the Xcode toolchain, so neither leaves macOS.

**Remove every gate, including entitlements.** Rejected, and not because of risk appetite —
because it is not achievable. The `settings.json` deny list and `pre-tool-safety.sh` both
block those edits, so an agent cannot satisfy such a change no matter what the policy says.

**Let the agent approve its own PR on GitHub.** Rejected: GitHub forbids it, and routing
around that with a second token would fake independence rather than provide it.

## Consequences

Good:

- No GitHub-billed compute.
- The plan → implement path has no human turnaround.
- `flow` can reach `READY_TO_MERGE` unattended; the `reviewDecision` deadlock is gone.
- `flow verify` twice in a row now passes twice (#25), so a red tier means something again.

Bad, and accepted deliberately:

- **No verification on a second machine.** Every tier runs on the author's Mac with the
  author's Xcode. A "works here" failure will not be caught until someone else builds it.
- **The cold reviewer is now the only check before `main`.** Its independence is enforced by
  convention — it must not be given implementation context — not by a mechanism.
- Bringing CI back for genuine cross-machine verification requires a new ADR.

## Security implications

> does this change where a seed can exist, who can read it, or how long it lives?

**No.** Not one of the substantive rules moved. Seeds still live only in the Keychain with
`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`; a seed, derived code or `otpauth://` URI still
may not reach a log, crash report or analytics; pasteboard writes still expire and do not
sync; crypto is still not hand-rolled. The `security` tier still runs, unchanged, on every
verify, and the runtime log secret audit still runs on every simulator launch.

What changed is **who clears the path, not what the path requires**. A Keychain change used to
wait for a human to look at it. It now waits for a cold reviewer to look at it and record a
verdict — a check that produces an artifact rather than a pause.

The honest risk is concentration: with no CI and no human approver, a single compromised or
careless review decision reaches `main` unopposed. This is accepted on a single-maintainer
repo where the human was, in practice, approving their own work anyway. It would not be
acceptable with more than one contributor, and this ADR should be revisited on the day a
second person commits.
