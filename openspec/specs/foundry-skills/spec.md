# foundry-skills Specification

## Purpose
Deliver reusable Foundry implementation guidance with the same versioned gem that supplies its commands.

## Requirements

### Requirement: Self-contained product skills

The gem SHALL include eight skills for adding packages, implementing features, architecture review, delivery checks, explicit profile refactoring, event workflows, guided existing-app adoption, and workflow-aware architecture planning. Each SHALL have valid name/description frontmatter, a version matching the gem, and locally installed bundled references. Guidance SHALL reference installed context configuration rather than duplicate a package inventory or prescribe removed runtimes. Instructions SHALL use implemented commands and distinguish structural/static checks from runtime proof. Skills SHALL preserve user scope and SHALL NOT require OpenSpec, examples, model credentials, or a specific coding agent.

#### Scenario: Consume the packaged catalog
- **WHEN** the built gem is installed without its source checkout
- **THEN** every skill and any referenced resource is available locally

#### Scenario: Optional planning workflow
- **WHEN** ownership or profile decisions are unclear
- **THEN** the planning skill guides a concrete reviewed proposal before apply while direct explicit generation remains available without a plan

#### Scenario: Review existing seven-skill catalog
- **WHEN** an existing seven-skill installation is upgraded
- **THEN** installation requires manual catalog reconciliation and preserves customized guidance

### Requirement: Conservative application-local installation

`foundry:skills` SHALL install the catalog to `.agents/skills` by default and accept `--target=claude` for `.claude/skills`; `--target=agents` SHALL select the default explicitly, and `--target=cursor` SHALL install under `.cursor/skills`. It SHALL preserve unrelated skills and project instructions, preserve complete customized installs on repeat with a matching versioned receipt, reject partial/conflicting installs, unsupported targets, and symbolic links, and support pretend mode without writes. Ordinary generation with a different source receipt SHALL refuse replacement. Explicit upgrade actions SHALL provide digest-bound assessment, safe updates, recorded customization review and conditional recovery without automatically merging user changes.

#### Scenario: Repeat an edited installation
- **WHEN** a user customizes an installed skill and repeats installation of the same catalog
- **THEN** the edited skill and unrelated files remain unchanged

#### Scenario: Unsafe or partial destination
- **WHEN** a target is a symbolic link or only part of the catalog exists
- **THEN** installation fails without overwriting existing files

### Requirement: Optional application specification workflow
Product skills SHALL direct agents to the selected application workflow without requiring OpenSpec. Workflow references SHALL distinguish behavioral requirements, architectural intent, topology and implementation evidence.

#### Scenario: Spec Kit application
- **WHEN** an agent works in an application selecting spec_kit
- **THEN** the installed guidance follows that workflow and reads the owning context's actual configuration

#### Scenario: No specification workflow
- **WHEN** an application selects none
- **THEN** skills still prescribe targeted tests and architecture checks without requiring specification artifacts

### Requirement: Skill-led package and feature development
The eight product skills SHALL guide ownership, invariants, state, consistency, integrations and measured workload decisions before implementation. They SHALL route to the selected specification workflow, allow plain plans with none, and treat small generators as optional. Package guidance SHALL name Rails, packs, packs-rails and Packwerk foundations, use direct upstream commands, distinguish mutating operations from checks, preserve custom roots and accepted debt, and require reviewed reconciliation of moved code and receipts.

#### Scenario: Create a context without a Foundry generator
- **WHEN** a user creates a plain pack using upstream tooling
- **THEN** guidance explains adding adjacent architectural intent, public APIs, declared dependencies and behavioral/loading verification
- **AND** no Foundry CLI wrapper or capability generator is required

#### Scenario: Adapt RAG through a skill
- **WHEN** a feature needs retrieval
- **THEN** the skill points to the worked RAG example and guides tenant, lifecycle, authorization and offline evidence choices without copying an application blindly

### Requirement: Verified adoption checkpoints
Existing adoption, planning, refactoring and verification guidance SHALL prescribe characterization before extraction, independently useful package boundaries, explicit public caller repair, separate persistence changes, checkpoint rollback instructions and executable evidence. Guidance SHALL preserve selected workflows and reviewed debt and distinguish assessment completion from migration completion.

#### Scenario: Incremental knowledge extraction
- **WHEN** a skill guides extraction of a business boundary
- **THEN** it retains existing persistence for the extraction checkpoint and verifies endpoints, authorization and failure behavior before recommending a separate persistence change

#### Scenario: Failed checkpoint
- **WHEN** behavior or boundary acceptance fails
- **THEN** guidance requires repairing or rolling back the checkpoint and leaves completion unclaimed

### Requirement: Realtime callback and form verification guidance
Existing feature, event and verification skills SHALL direct realtime work to shared behavioral guidance that checks effective commit publication, rendered form actions and methods, and separate actor/viewer behavior. The guidance SHALL remain generic and contain no benchmark answers or evaluator material.

#### Scenario: Realtime feature verification
- **WHEN** an agent uses an applicable skill for committed browser updates
- **THEN** the shared reference directs verification of publication after commit, no publication after rollback, working authorized controls and preserved local drafts
- **AND** equivalent implementations remain valid when their observable behavior passes
