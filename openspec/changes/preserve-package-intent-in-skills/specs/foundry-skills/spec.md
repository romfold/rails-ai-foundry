## ADDED Requirements

### Requirement: Preserve selected architecture during package creation
Package creation and adoption guidance SHALL resolve architectural intent before writing a context sidecar. Explicit requested changes SHALL take precedence; otherwise existing context settings SHALL remain authoritative, and new contexts SHALL use application defaults. Illustrative values SHALL NOT override that selection. Verification guidance SHALL compare discovered context values with the intended selection, independently of structural validity.

#### Scenario: Example differs from selected profile
- **WHEN** a package example uses a different profile from an explicit request or the new context's application default
- **THEN** guidance directs the agent to record the selected profile and independent patterns rather than copy the illustrative values

#### Scenario: Existing context differs from application defaults
- **WHEN** an existing context has valid settings different from root defaults and no change is requested
- **THEN** guidance preserves that context's settings

#### Scenario: Structurally valid but unintended profile
- **WHEN** a structural report succeeds but reports a profile different from the requested one
- **THEN** guidance requires reconciling that difference before claiming completion
- **AND** the checker continues accepting all supported profiles without inferring task intent

## MODIFIED Requirements

### Requirement: Self-contained product skills

The gem SHALL include eight skills for adding packages, implementing features, architecture review, delivery checks, explicit profile refactoring, event workflows, guided existing-app adoption, and workflow-aware architecture planning. Each SHALL have valid name/description frontmatter, a version matching the gem, and locally installed bundled references. Guidance SHALL reference installed context configuration rather than duplicate a package inventory or prescribe removed runtimes. Instructions SHALL use implemented commands and distinguish structural/static checks from runtime proof. Skills SHALL preserve user scope and SHALL NOT require OpenSpec, examples, model credentials, or a specific coding agent. The verification skill SHALL include optional executable Rails/Minitest HTTP verification support that runs the baseline and explicitly selected caller/browser tests and rejects missing evidence, failed commands, empty selections, unreviewed skips and timeouts. Guidance SHALL require an application-owned CI step for enforcement and disclose that test relevance and adversarial tampering remain outside this helper's guarantee.

#### Scenario: Consume the packaged catalog
- **WHEN** the built gem is installed without its source checkout
- **THEN** every skill and any referenced resource is available locally

#### Scenario: Optional planning workflow
- **WHEN** ownership or profile decisions are unclear
- **THEN** the planning skill guides a concrete reviewed proposal before apply while direct explicit generation remains available without a plan

#### Scenario: Review existing seven-skill catalog
- **WHEN** an existing seven-skill installation is upgraded
- **THEN** installation requires manual catalog reconciliation and preserves customized guidance

#### Scenario: Empty or skipped behavioral checks
- **WHEN** a selected test file executes no matching HTTP/system tests or skips a selected requirement
- **THEN** the helper exits unsuccessfully even when the test process exits zero

#### Scenario: Broken caller after passing unit tests
- **WHEN** unit tests pass but a selected endpoint or browser test fails
- **THEN** the helper rejects completion and retains the actual test output

#### Scenario: Missing report or interrupted test process
- **WHEN** a command exits without structured test evidence or exceeds its configured timeout
- **THEN** the helper fails without reusing earlier evidence or reporting successful verification

#### Scenario: CI enforcement and existing installations
- **WHEN** an application adopts the helper in a required CI step
- **THEN** failed verification blocks that step while existing customized catalogs require explicit review and remain unchanged by repeat generation

### Requirement: Realtime callback and form verification guidance
Existing feature, event and verification skills SHALL direct realtime work to shared behavioral guidance that checks effective commit publication, rendered form actions and methods, and separate actor/viewer behavior. Feature and verification entrypoints SHALL state the essential browser evidence before implementation or completion: visible authorized interactions, idempotent effects and preserved unsaved input through child and ancestor updates. Guidance SHALL distinguish existing baseline tests from evidence for changed interactive behavior and report unexecuted browser checks explicitly. The guidance SHALL remain generic and contain no benchmark answers or evaluator material.

#### Scenario: Realtime feature verification
- **WHEN** an agent uses an applicable skill for committed browser updates
- **THEN** the shared reference directs verification of publication after commit, no publication after rollback, working authorized controls and preserved local drafts
- **AND** equivalent implementations remain valid when their observable behavior passes

#### Scenario: Nested ownership and ancestor updates
- **WHEN** a realtime feature reuses viewer-specific controls or updates a parent through callbacks
- **THEN** guidance requires checking visible actions with differently owned nested records and draft preservation through all affected update paths

#### Scenario: Baseline passes without browser coverage
- **WHEN** existing application tests pass but the changed interactive behavior was not exercised in a browser
- **THEN** guidance leaves that behavior unverified and does not treat the baseline as completion evidence
