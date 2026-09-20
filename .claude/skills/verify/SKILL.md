---
name: verify
description: Run the verification tiers and write the machine-readable evidence file. Use after implementing, and again after every subsequent commit, before claiming anything is done.
---

# Verify

```bash
./scripts/ai/flow verify <issue>
```

That runs `static → unit → integration → security`, stopping at the first failure, then runs
the **runtime** tier, then writes `.ai/run/<issue>/evidence.yml` stamped with the current
commit. Do not run the tiers by hand and do not edit the evidence file — the next
`flow verify` overwrites it, and hand-editing is how a `PASS` gets written for something that
never ran.

## What earns a runtime PASS

`runtime` is defined as *the app actually launched **and** the flow actually worked*. Half of
that is not a pass. `flow verify` resolves it for you:

| situation | result |
|---|---|
| `.ai/scenarios/<issue>.sh` exists and passed | `PASS`, `scenarios: driven by …` |
| no app source changed | `PASS`, `scenarios: none-required` |
| app sources changed, no scenario script | `SKIP` — write `.ai/scenarios/<issue>.sh` |
| device required (see below) | `SKIP` until a device run is recorded |

A `SKIP` here is not a failure and not a pass. `flow verify` exits non-zero and says so.

## Device runs

A device run is required when the issue carries `device-required`, **or** when the diff hits
any `manifest.yml: device_required_markers` (`kSecAttrAccessible`, `LAContext`,
`AVCaptureDevice`, …). The marker check is deliberate: a label is a sentence someone
remembered to write; a marker in the diff is observable.

No agent can plug in a phone, so this is one of the three real human gates. Build to the
attached iPhone from Xcode, perform the scenarios in `docs/testing/security-matrix.md`, and
record the result as data:

```yaml
# .ai/run/<issue>/device.yml
issue: 12
commit: 5fbea7a                       # must equal HEAD, or the run does not count
device: "iPhone 17 Pro / iOS 27.0"    # the real device string, not the manifest's
result: PASS
scenarios:
  - { name: "code survives app relaunch after Face ID", result: PASS }
```

`flow verify` reads that file and records `runtime.target: device`. Nothing else can produce
a device claim.

## Three rules, no exceptions

1. `PASS` only for a tier that executed and exited 0.
2. `SKIP` is not `PASS`. It stays listed under `unverified` with a reason.
3. Simulator ≠ device. Never record one as the other.

Any commit after verification invalidates the evidence. Re-run. Before opening a PR, run
`./scripts/ai/flow precheck <issue>` — it re-checks freshness and runs `scope-check`, which
nothing else calls now that CI is gone (ADR-002).
