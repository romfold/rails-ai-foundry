## MODIFIED Requirements

### Requirement: Explicit native source migration checks
Native checking and read-only adoption SHALL support an explicit source check for explicit Foundry constant paths in application code. The check SHALL parse selected Ruby sources without initializing Rails or executing application code. It SHALL inspect application `app/` and every upstream-discovered package's `app/` directory, whether or not the package has a Foundry sidecar. Package topology SHALL come from upstream discovery; sidecars SHALL select architectural intent, not eligibility for source inspection.

#### Scenario: Development tool reference
- **WHEN** selected Ruby source references an explicit RailsAIFoundry runtime constant path
- **THEN** the source check reports file, line, rule, detected certainty and corrective guidance
- **AND** exits unsuccessfully without modifying source or accepted debt

#### Scenario: Syntax and non-code text
- **WHEN** Foundry constant names occur only in comments or plain strings
- **THEN** those names do not produce findings
- **AND** unparseable Ruby produces a failing syntax diagnostic rather than a clean result

#### Scenario: Custom roots and isolated verification
- **WHEN** a discovered package uses a custom upstream pack root with or without Foundry configuration
- **THEN** the same source checking applies without loading its classes or initializers
- **AND** symbolic link sources are rejected

#### Scenario: Package without architectural configuration
- **WHEN** an application contains an upstream package with a prohibited Foundry reference and no foundry.yml
- **THEN** both explicit checking and adoption report the reference and return failure
- **AND** the report includes the package's selected Ruby files in files_checked without inventing a configured context

### Requirement: Source findings declare their limits
Source reports SHALL distinguish detected syntax from proven constant resolution and behavioral correctness. They SHALL disclose excluded roots, aliases, dynamic lookup, lexical references, requires and non-Ruby files. Packwerk SHALL remain authoritative for dependency/privacy checking. Existing report fields and diagnostic semantics SHALL remain intact; files_checked SHALL count distinct inspected Ruby files. Documentation SHALL state that broader package coverage can expose existing violations previously omitted by source checking.

#### Scenario: Optional and composable checks
- **WHEN** sources are not explicitly requested
- **THEN** ordinary native configuration checking retains its current scope
- **AND WHEN** source and Packwerk checks are requested together
- **THEN** failure of either check fails the command

#### Scenario: Installed Rails task
- **WHEN** an installed-gem consumer runs foundry:architecture:sources
- **THEN** the Rake task invokes the same explicit boot-free source assessment including packages without Foundry configuration

#### Scenario: No eligible source
- **WHEN** discovered packages contain no app Ruby files and the application shell contains none
- **THEN** the source report truthfully records zero inspected files without claiming behavioral or boundary verification

### Requirement: Focused architecture diagnostics
Explicit source checking SHALL inspect configured pure-domain source for Rails/persistence/provider references, delivery source for direct provider access, and queries/projections for explicit persistence writes. It SHALL also report obvious provider calls within transactions or callbacks for review. Profile-independent rules SHALL apply to all selected sources; profile-dependent rules SHALL use only the owning package's explicit Foundry context. Unconfigured packages SHALL NOT inherit a parent context's profile or namespace, or application defaults. Each diagnostic SHALL separate severity (error or warning) from certainty (detected or inferred); concrete prohibited syntax fails, while inferred concerns are advisory. Query writes SHALL fail; projection writes SHALL be advisory because rebuildable read models legitimately persist state. Reports SHALL name limitations and retain Packwerk authority without evaluating Ruby.

#### Scenario: Direct domain persistence dependency
- **WHEN** a pure-domain file references an explicit persistence constant
- **THEN** source checking emits a detected error with a stable rule and location

#### Scenario: Inferred transaction concern
- **WHEN** a provider call appears inside a transaction block
- **THEN** source checking reports the location as an inferred warning and does not claim runtime proof

#### Scenario: Unconfigured package does not acquire a profile
- **WHEN** a package without Foundry configuration contains app/domain code using Active Record
- **THEN** it receives applicable profile-independent checks but no domain-profile violation solely from that directory name
- **AND** nesting it below a configured domain package does not change this result

#### Scenario: Unconfigured delivery still receives global rules
- **WHEN** a controller in a package without a Foundry sidecar directly calls a recognized provider
- **THEN** the existing delivery-provider rule reports a detected error at that file and line

## ADDED Requirements

### Requirement: Safe deterministic package source coverage
Source selection SHALL use normalized application-relative paths and inspect each eligible file once. The most specific upstream-discovered package SHALL own nested files; eligible source SHALL be within that owner's app directory, or the shell app directory when no package owns it. A root package SHALL NOT duplicate shell coverage. Invalid discovery, unsafe paths, symbolic links encountered within selected source trees and selected files that become unreadable or disappear SHALL fail explicitly without a successful partial assessment or mutation. Discovery failure SHALL NOT fall back to root-only checking.

#### Scenario: Root package and nested packages
- **WHEN** upstream discovery returns the root package and overlapping nested package paths
- **THEN** eligible sources are checked once, diagnostic paths are normalized and results have deterministic ordering
- **AND** configured rules are associated with the actual owning package

#### Scenario: Unsafe or failed discovery
- **WHEN** discovery fails, returns unsafe paths or selected source paths encounter symbolic links
- **THEN** verification fails with corrective location-based guidance without reading external targets or executing source

#### Scenario: Selected source disappears
- **WHEN** a selected source is removed or cannot be read before inspection finishes
- **THEN** the command reports the failure rather than reporting a successful partial check

#### Scenario: Unselected directories remain outside scope
- **WHEN** a package has Ruby files under lib, test or another directory outside its app tree
- **THEN** those files remain outside this source check and documented limitations describe that boundary
