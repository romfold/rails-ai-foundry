## Why

Foundry should maintain its behavioral tasks and evidence contracts rather than a second general-purpose agent runner. Le Mans provides upstream execution infrastructure; Rails AI-evals supplies an independent Rails capability corpus.

## What Changes

- Pin Le Mans and all 42 AI-evals tasks in independent contributor tooling.
- Port six Foundry tasks and three groups while retaining all 45 controls.
- Independently verify captured patches in fresh offline containers, with protocol and evidence controls.
- **BREAKING**: Remove historical contributor runner commands only after parity and full-corpus acceptance; preserve historical evidence unchanged.
- Prepare native agent support without model calls or credentials. No new agent trial is authorized.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `skill-benchmark`: upstream execution, separate complete Rails corpus, independent verification and immutable evidence.

## Impact

Contributor benchmarks, their CI and documentation only. No Foundry public CLI, configuration, production dependency, application or product-skill changes.
