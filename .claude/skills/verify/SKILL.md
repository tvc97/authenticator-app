---
name: verify
description: Run the verification tiers and write the machine-readable evidence file. Use after implementing, and again after every subsequent commit, before claiming anything is done.
---

# Verify

```bash
./scripts/ai/flow verify <issue>
```

That runs `static → unit → integration → security`, stopping at the first failure, and
writes `.ai/run/<issue>/evidence.yml` stamped with the current commit.

**Runtime is not automatic.** Run it deliberately:

```bash
./.ai/adapter/run sim                # launches, drives, audits the log for secrets
```

For anything in `manifest.yml: device_required_for`, the simulator is not acceptable.
Build to the physical iPhone, perform the scenarios in `docs/testing/security-matrix.md`
by hand, and edit the evidence file to record:

```yaml
runtime:
  target: device
  device: 'iPhone 17 Pro / iOS 27.0'
  scenarios:
    - { name: 'code survives app relaunch after Face ID', result: PASS }
```

Three rules, no exceptions:

1. `PASS` only for a tier that executed and exited 0.
2. `SKIP` is not `PASS`. List it under `unverified` with a reason.
3. Simulator ≠ device. Never record one as the other.

Any commit after verification invalidates the evidence. Re-run.
