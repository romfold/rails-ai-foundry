## ADDED Requirements

### Requirement: Explicit bounded live study
Contributor tooling SHALL prepare exactly the authorized trial matrix with frozen inputs, model settings and resource budgets. Agent execution SHALL remain native upstream execution and SHALL require a dedicated limited provider key supplied outside candidate access and repository configuration.

#### Scenario: Preflight refuses unsafe execution
- **WHEN** credentials, accounting, routing, available allowance or frozen inputs cannot be verified
- **THEN** no eligible launch receipt is issued and no agent is started by preflight
- **AND** sanitized failure evidence identifies the reason

#### Scenario: Ordered single attempts
- **WHEN** a task was already reserved or a predecessor remains unverified
- **THEN** preflight rejects another launch rather than silently retrying or overlapping trials

### Requirement: Honest live study outcomes
Live reports SHALL distinguish behavioral failures, unscored resource stops, protocol violations, infrastructure errors and unstarted attempts. Smoke and upstream outcomes SHALL remain separate from Foundry group comparisons. Provider usage SHALL remain distinct from locally reported cost estimates.

#### Scenario: Partial candidate at a resource limit
- **WHEN** a native attempt reaches its cost, time or step limit
- **THEN** its incomplete outcome remains visible even if a diagnostic independent grade succeeds

#### Scenario: Missing authentication
- **WHEN** no usable key is available for an otherwise prepared study
- **THEN** reporting records unstarted trials and makes no claim that a model was evaluated
