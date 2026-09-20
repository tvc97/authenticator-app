# ADR-001: Operate this repository as an AI-native development system

Status: accepted — amended by ADR-002
Date: 2026-09-20

## Context

This is a single-maintainer iOS app in a security-sensitive category. The binding
constraint is human attention, not typing speed. Conversation history is not durable
project memory, and a model's assertion that something works is not evidence.

## Decision

- **GitHub is the only state store.** Workflow state is derived from issues, labels,
  branches, PRs and checks. No state file is committed.
- **Gates are labels**, not prose: `gate:plan-approved`, `gate:release-approved`.
  *(ADR-002 removed `gate:plan-approved`: a gate now exists only where the agent physically
  cannot act. `gate:release-approved` remains.)*
- **Completion is an evidence file** (`.ai/run/<issue>/evidence.yml`) whose `commit`
  matches HEAD, with every required tier `PASS`. A Stop hook enforces this.
- **Commands live in an adapter** (`.ai/adapter/`), eight verbs, with project facts in
  `manifest.yml`. Claude reads them; it never invents a scheme, simulator or build command.
- **Verification has five tiers**: static, unit, integration, **security**, runtime. The
  security tier exists because this is an authenticator.
- **Experience accumulates in one ledger** (`.ai/ledger/`) with one schema, retrieved by tag.

## Alternatives considered

- *Prose workflow document only* — rejected: prose cannot be enforced by a hook or CI, and
  does not survive a context reset.
- *Store workflow state in a local file* — rejected: guarantees silent divergence from GitHub.
- *React Native / Expo* — rejected: Keychain, Secure Enclave and biometrics are the product;
  a JS bridge adds attack surface and indirection for no benefit here.

## Consequences

- Extra scaffolding cost up front; every later cycle is cheaper and auditable.
- Claude cannot claim done without evidence, which is the point.
- Adding a platform means writing one adapter, not rewriting the workflow.

## Security implications

Signing, entitlements, credentials, hooks and release gates are **frozen paths**: an agent
may propose changes but never apply them.
