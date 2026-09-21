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
| hooks, `settings.json` | stop and ask | `human_paths` — the deny list already blocks the edit |
| Crypto, Keychain, Backup, adapter, `scripts/ai/**`, `.github/**` | stop and ask | `review_paths` — cold review must record APPROVE |

**The reviewer's verdict becomes evidence.** `/review` writes `.ai/run/<issue>/review.yml`
with `verdict` and the `commit` actually reviewed. `scope-check` refuses a `review_paths`
diff without `verdict: APPROVE` at the current HEAD, and `flow` derives `READY_TO_MERGE` from
that file instead of from `reviewDecision`. This is ADR-001's own principle applied to review:
observable data, not a sentence someone wrote.

**CI is deleted.** Verification becomes a precondition for opening a PR rather than something
that happens after it. `flow verify` now also runs the simulator runtime tier automatically,
so the common path reaches all-PASS without hand-editing the evidence file — which was itself
a quiet invitation to write `PASS` for something that never ran.

**A device run is recorded, not asserted.** `flow verify` reads `.ai/run/<issue>/device.yml`
(`commit` = HEAD, `result: PASS`, the real device string) and only then records
`runtime.target: device`. The requirement itself is detected two ways: the `device-required`
label, and `manifest.yml: device_required_markers` matched against the diff. The markers
matter because a label is a sentence someone remembered to write; `kSecAttrAccessible`
appearing in a diff is observable. The check **fails closed** — if the label set cannot be
read, the answer is "device required", because the cost of a wrong "no" is recording a
simulator run as device verification.

**A launch is not a runtime PASS.** CLAUDE.md defines the tier as *launched **and** the flow
worked*. `flow verify` grants `PASS` when a scenario script drove a flow, or when no app
source changed at all (tooling work has no user flow to drive, and launch plus the log secret
audit is then the whole claim). An app-source change with no scenario is `SKIP` — a third
outcome that is neither pass nor failure, and that `flow verify` exits non-zero on.

**`scope-check` has an automatic caller again.** The deleted CI job was its only one.
`flow precheck <issue>` re-checks evidence freshness and runs `scope-check` against the
verdict on disk, and `/review` must print `precheck OK` before `gh pr create`.

**The gates have a regression test.** `.ai/adapter/checks/gate-test` builds a throwaway repo
and makes 27 assertions, each one a way the gate could pass when it should not: every
`human_paths` and `review_paths` entry enforced individually; a human path refused even
with an APPROVE on record; missing, stale, nested and `REQUEST_CHANGES` verdicts; a rename
out of a guarded directory; a path differing only in case; a manifest pattern that is not a
valid regular expression; a rule list the manifest could not supply; and four ways to
narrow the base until the diff no longer contains the offending commit — a missing ref, a
ref that contains HEAD, a bare commit or SHA, and a tag pointing at one.

The residual is recorded rather than papered over: the base rule cannot tell a genuine
parent branch from one planted on an older commit, so `git branch x HEAD~1; BASE_REF=x`
still narrows the diff. Closing that would break the stacked-branch case the rule exists to
support. Every assertion
checks the **exit status**, not just the message: an earlier revision matched on output
text and stayed green against a `scope-check` that printed every refusal it prints today
and refused nothing. It runs inside the `static` tier. Without it the compensating control is exercised by nothing — the Swift tiers do not
touch a line of it, and two rounds of cold review found real holes in it that only the suite
could keep shut.

**Evidence records its own base.** `evidence.yml` carries `base: <ref> @ <sha>`. "No app
source changed" is only true relative to something, and a runtime verdict that depends on an
unrecorded `BASE_REF` is not reproducible from the repo plus the documented command.

## Alternatives considered

**Keep CI, pin the runner image to match the manifest.** Tried first, filed as #26. Rejected:
it still bills 10x for a duplicate of the local tiers, and pinning makes `manifest.yml`
describe two machines instead of one.

**Keep CI for the cheap jobs only** (`static`, `security` on `ubuntu-latest`). Rejected: both
need the Xcode toolchain, so neither leaves macOS.

**Remove every gate, including entitlements.** Rejected, and not because of risk appetite —
because it is not achievable. The `settings.json` deny list and `pre-tool-safety.sh` both
block those edits, so an agent cannot satisfy such a change no matter what the policy says.
The same test moved `.claude/hooks/**` and `.claude/settings.json` into `human_paths`: the
deny list blocks them too, and a manifest that invites an edit the tooling refuses is an
invitation to route around the deny list.

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

**Outstanding, and both need the human.**

**Every tool-layer block has the same gap, and the rules files twice overstated it.**
`pre-tool-safety.sh` matches on `tool_input.file_path`, which is populated for `Edit`,
`Write` and `NotebookEdit` and **empty for `Bash`**. So it blocks a `Write` to `Info.plist`
and allows `printf x > authenticator/Info.plist`; its `cmd` list covers credentials, force
push, `security`, publishing and `codesign`, but not a redirect. The `settings.json` deny
list has the same shape one level up: it blocks the Edit tool on `.claude/hooks/**` and
`.claude/settings.json`, and `git rm` goes straight past it — as this PR demonstrated by
deleting `ci.yml` that way.

`scope-check`'s `human_paths` rule is therefore the **only** layer that sees all of them,
because it reads the diff rather than the tool call. The first draft of this paragraph said
the hook blocked those paths "whatever tool is used", which was false and exactly the kind
of claim it exists to prevent — a rules file describing protection that is not there is
worse than one describing none, because it is read as permission to stop checking.

`.claude/settings.json` denies `Edit(./.github/workflows/**)`, while the manifest puts
`.github/**` in `review_paths`. That looks like the inconsistency this ADR calls
unacceptable, and the classification is deliberate: the criterion is *can an agent satisfy
this at all*, and it can — this PR deleted `ci.yml` with `git rm`, which the deny list does
not cover. So `review_paths` is the honest label and the **deny entry** is the misleading
half: it blocks one tool, not the capability, and buys a sense of protection it does not
provide. The human should either drop that deny entry or move `.github/workflows/**` into
`human_paths` and mean it. `settings.json` is itself `human_paths`, so an agent cannot
resolve this either way.

 `.claude/hooks/stop-evidence.sh` enforces the
evidence half of the Completion rule but not the review half: it checks `evidence.yml`'s
`commit` and stops there, so an agent could write `DONE` on a `review_paths` diff with no
verdict on disk. The hook is `human_paths` — an agent cannot edit it, which is the correct
classification and also why this is not fixed here. The fix is one line calling
`./scripts/ai/flow precheck "$issue"`. Until then `precheck` is enforced by procedure in
`/review`, not by the harness.

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
