## Purpose

Provide optional, deterministic review of package ownership and profiles before safely applying proposed additions to a consuming Rails application.

## ADDED Requirements

### Requirement: Versioned questionnaire and plan
Questionnaires SHALL contain integer version 1, greenfield/adopt mode, and a nonempty list of packages with name, type, dependencies, owner, rationale, ownership_confirmed and boolean answers separate_read_write, rich_invariants, history_authoritative, rebuild_required. Plans SHALL additionally require profile. Unknown or missing fields, duplicate names/keys, invalid identifiers, unsupported versions, aliases and unsafe YAML SHALL fail. Plans SHALL contain proposed additions, while the installed manifest remains authoritative.

#### Scenario: Invalid questionnaire
- **WHEN** an answer is missing or YAML contains duplicate keys or object tags
- **THEN** proposal fails without creating output or installing packages

### Requirement: Advisory recommendations
Recommendations SHALL prefer event_sourced for authoritative history and required rebuild, otherwise domain for rich invariants, otherwise modular for separate read/write paths, otherwise mvp, for both package types. Different selections SHALL produce advice without rejection except that event_sourced requires history_authoritative true. Adoption application SHALL require ownership_confirmed true and SHALL NOT infer ownership from source assessment.

#### Scenario: Deliberate profile choice
- **WHEN** a platform package selects domain although the recommendation is mvp
- **THEN** validation succeeds with advice and preserves the selection

#### Scenario: Explicit event source
- **WHEN** event_sourced is selected without authoritative history
- **THEN** validation and application fail with actionable guidance

### Requirement: Safe proposal and review
The non-booting CLI SHALL expose foundry plan propose --root=PATH --answers=FILE [--out=foundry/plan.yml], validate --root=PATH [--file=foundry/plan.yml], and apply with the same file options plus --reviewed-digest=SHA256 and optional --pretend. Proposal SHALL work before installation, create output exclusively through tracked writes, reject traversal/symlinks and out-of-root paths, and conservatively clean up failed writes. Validate SHALL be read-only, require structurally valid manifest v2, and print selected/recommended profiles, dependency order, existing/create actions and a digest bound to canonical root and exact plan bytes. The digest SHALL acknowledge reviewed input without claiming identity or authorization.

#### Scenario: Review changed input
- **WHEN** plan bytes change or the digest is used for another application root
- **THEN** application including pretend fails without writes until reviewed again

#### Scenario: Uninstalled or legacy application
- **WHEN** validation targets missing installation or manifest v1
- **THEN** it explains separate setup or migration without changing the application

#### Scenario: Existing output or unsafe destination
- **WHEN** proposal output exists or a file argument traverses or follows a symlink
- **THEN** it fails without overwriting files

### Requirement: Combined preflight and resumable application
Validation and application SHALL check installed and proposed declarations as a combined graph with existing dependency rules. Full-plan destination preflight SHALL occur before writes. Exact matches SHALL preserve customized files; conflicting declarations, incomplete artifacts and unregistered destinations SHALL fail. Application SHALL order dependencies first with name tie-breaking, recheck plan and relevant application state before each package, and preserve each installer's manifest-last publication, permissions, exclusive creation and conservative rollback guarantees. Successful earlier packages SHALL remain after later failure, with completed/existing/failed/pending reporting and safe exact-match resume. Pretend SHALL perform full validation without writes. Commands SHALL return 0 on success or 1 on failure and SHALL NOT initialize Rails, read consumer Packwerk configuration, migrate code/data or enable events.

#### Scenario: Preflight failure
- **WHEN** a later planned package conflicts before application begins
- **THEN** no earlier package is installed

#### Scenario: Later write failure and resume
- **WHEN** an earlier package succeeds and a later write fails
- **THEN** the earlier package remains, the failing install cleans up conservatively, and rerun preserves completed artifacts while creating remaining packages

#### Scenario: Concurrent edit
- **WHEN** plan bytes or conflicting application state change between package installations
- **THEN** application stops and reports partial progress without overwriting the edit

#### Scenario: Successful application
- **WHEN** all packages are applied or already match
- **THEN** the CLI prints structural/static check and package-test instructions without claiming runtime validation
