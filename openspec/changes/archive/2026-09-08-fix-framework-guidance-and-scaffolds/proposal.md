## Why

Current scaffolds do not demonstrate the command transaction contract, setup reconciles parser findings with a second regex, and runtime state has no explicit reset boundary. Contributor guidance and command specifications also lag the implemented framework.

## What Changes

- Add Runtime.reset! for Foundry-owned containers/event references and optional AI ExecutionStore/NullStore interfaces without requiring inclusion by existing stores.
- Insert setup configuration using AST source locations while preserving the conventional class policy, comments, and line endings.
- Demonstrate steps/step in new command scaffolds; preserve existing generated files.
- Specify the existing foundry:check and foundry:projections:rebuild[package,name] commands explicitly.
- Accept the template callback block explicitly in its test stub and verify fail-closed duplicate JSON key handling across installed supported JSON versions.
- Correct current contributor guidance, the six development/seven shipped skill distinction, and ADR index with dated supersession notes grounded in Git history.

## Capabilities

### New Capabilities

- `framework-maintenance-contracts`: runtime reset, exact verification/rebuild commands, and optional execution-store interface.

### Modified Capabilities

- `domain-conventions`: generated command examples demonstrate transactional steps.

## Impact

Runtime, optional AI support, setup source editing, command template and relevant tests/docs. No event semantics, application manifest changes, compatibility-floor changes, or historical ADR rewrites. Existing files are not regenerated.
