# reviewed-skill-upgrades Specification

## Purpose
Deliver updated development guidance through explicit review while preserving application customizations and recoverable provenance.

## Requirements

### Requirement: Digest-bound upgrade assessment
The skills generator SHALL provide read-only upgrade assessment for complete current eight-skill receipts in agents, claude and cursor targets. It SHALL classify local/template changes by content, reject unsafe or incomplete ownership, and bind application to the inspected receipt, catalog, current bytes and actions.

#### Scenario: Stale assessment
- **WHEN** an inspected file changes before apply
- **THEN** apply fails without modifying installed skills or receipts

#### Scenario: Same-version template changes
- **WHEN** template bytes change without a version change
- **THEN** assessment identifies the changes by content rather than treating the catalogs as equivalent

### Requirement: Explicit customization decisions
An explicit upgrade SHALL update unchanged owned files and preserve conflicts pending keep_local, use_upstream or merged decisions bound to reviewed hashes. It SHALL retain original provenance and publish the incoming receipt only after review completes. Customized retired files kept locally SHALL become unmanaged.

#### Scenario: Conflicting local guidance
- **WHEN** both application and upstream changed a file
- **THEN** safe updates apply, the local file and old receipt remain, and pending review returns nonzero

#### Scenario: Accepted customization
- **WHEN** all decisions are validated
- **THEN** the incoming template receipt and actual customization provenance are recorded separately and subsequent ordinary generation preserves local content

### Requirement: Recoverable conditional filesystem changes
Upgrade writers SHALL serialize, preserve original bytes and modes before replacement, recover interrupted actions, and refuse to overwrite unexpected edits. Rollback SHALL restore only recorded upgrade states. Output SHALL omit file content and private workstation paths; upgrade artifacts SHALL remain outside agent discovery and the distributed gem.

#### Scenario: Interrupted file replacement
- **WHEN** a process dies after replacement but before progress publication
- **THEN** the same apply action recognizes the recorded replacement and safely resumes

#### Scenario: Later user edit
- **WHEN** rollback encounters a later edit
- **THEN** it reports a blocker without overwriting that edit or partially restoring other files
