## Context

The current Python runner owns agent installation, trials and independent grading. The original Cursor pilot is complete and immutable. Le Mans 1.3.5 verifies in the candidate sandbox; its captured patch precedes restoration of grading surfaces.

## Goals / Non-Goals

Use upstream trial execution and prepare the complete AI-evals corpus. Retain fresh verification and six Foundry tasks without changing business requirements. No live models, paid providers, new tasks, product interfaces or skill content changes.

## Decisions

- Independent Ruby contributor bundle pins Le Mans by commit. External workspace pins AI-evals, excluding historical runs from generated suites.
- Native Le Mans commands own trials. Ruby suite preparation generates task profiles and patches; independent verification reconstructs a sealed baseline with the captured patch, then mounts trusted tests in a new offline container.
- Keep native and independent grades separately. Protocol violations and unavailable evidence cannot earn a credited pass. Preserve originals and write derived evidence to new directories.
- Use Docker locally with offline oracle/nop phases; do not inherit unsupported allowlists. Dependency preparation may access the network. Record overrides and resolved image identity.
- Six tasks times three groups preserve treatment boundaries. All 45 controls remain; upstream oracle/nop covers 42 tasks with the smoke task reported separately.
- Restore paths and forbidden-edit paths have different responsibilities. Upstream reference solutions legitimately update application-owned tests; preserve those edits in evidence but restore trusted tests before grading. Upstream runner/environment controls remain forbidden. Foundry's visible grading assets remain protected; additional application tests do not become trusted evaluators.
- Remove old execution code only after full acceptance. Historical reproduction references Git revisions instead of retaining a compatibility runner.

## Risks / Trade-offs

- Upstream test defects or environment incompatibilities may block full migration; record them without modifying upstream requirements or claiming completion.
- Le Mans Docker trial capabilities differ from hardened independent verification; document both and probe actual isolation.
- Redaction can make patches unreplayable; identify that outcome rather than accepting incomplete evidence.
- No new model authentication or experiment budget is selected. Offline acceptance does not demonstrate agent productivity.

## Migration Plan

Prepare pins; port Foundry inputs; implement and test fresh verification; run both full control suites; update documentation/CI and remove the old runner only after gates pass. Preserve historical evidence and keep the change open until acceptance is verified.
