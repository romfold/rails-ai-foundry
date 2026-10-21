## MODIFIED Requirements

### Requirement: Explicit prompt validation
The check command SHALL support opt-in --prompts validation of contracts under application and every upstream-discovered package prompt root, including packages without Foundry configuration. Contracts SHALL identify ownership, template files, trust inputs, output schema, allowed tools and evaluation fixtures, with an optional application model alias. Validation SHALL check data shape and safe file references without resolving constants, evaluating templates or contacting providers. Failures SHALL carry file, line, stable rule, severity, certainty and guidance, compose with other selected checks and preserve files and debt.

#### Scenario: Unsafe or missing prompt artifact
- **WHEN** a contract references a missing file, symlink or path escaping its ownership root
- **THEN** validation fails before executing application code and reports the affected contract

#### Scenario: Ordinary checks remain opt-in
- **WHEN** prompt validation is not requested
- **THEN** ordinary configuration checks keep their existing scope

#### Scenario: Unconfigured package has invalid prompts
- **WHEN** an upstream-discovered package without foundry.yml contains conventional instructions without an adjacent contract or an invalid explicit contract
- **THEN** the prompt check includes that contract path and fails without creating configuration or changing application files

#### Scenario: Hand-written agent in an unconfigured package
- **WHEN** an unconfigured package has a valid correctly owned contract and safe required artifacts
- **THEN** prompt validation succeeds without requiring a profile, namespace or AI capability declaration
- **AND** the report does not claim that its agent, authorization or evaluation outcomes were verified

## ADDED Requirements

### Requirement: Prompt ownership follows package topology
A contract SHALL identify its deepest upstream-discovered owning package and reside under that owner's app/prompts root; application-shell and root-package contracts SHALL use owner `.`. Only the owner's explicit Foundry configuration SHALL constrain the agent namespace. Unconfigured packages SHALL NOT inherit namespace or capability intent. Referenced artifacts SHALL remain within the contract directory and the same package ownership boundary.

#### Scenario: Nested package cannot claim parent ownership
- **WHEN** a nested package's contract claims the parent package or shell as owner
- **THEN** validation fails even if its path has the parent's prompt root as a prefix

#### Scenario: Configured parent and unconfigured child
- **WHEN** an unconfigured nested package has a correctly owned contract using a different syntactically valid agent namespace
- **THEN** the parent's namespace restriction does not apply
- **AND** configured owners continue to reject agents outside their explicit namespace

#### Scenario: Reference enters another package
- **WHEN** an artifact reference beneath a contract directory crosses into a nested package
- **THEN** validation rejects that reference even without dot traversal

### Requirement: Deterministic and safe prompt coverage
Prompt checking SHALL inspect each selected contract once using normalized application-relative paths. Selection SHALL include explicit contract.yml and contracts required by instructions.txt or instructions.txt.erb under eligible prompt roots. Root, custom, nested and overlapping package discovery SHALL NOT duplicate or misattribute coverage. Invalid discovery, unsafe paths, encountered symlinks and selected artifacts or directories that cannot be inspected SHALL fail explicitly without a successful partial assessment or root-only fallback.

#### Scenario: Root and overlapping package discovery
- **WHEN** discovery includes a root package and nested packages with eligible prompts
- **THEN** contract paths and diagnostics are deterministic, each contract is counted once, and each belongs to its actual owner

#### Scenario: Discovery or inspection fails
- **WHEN** discovery fails or a selected directory, contract or referenced artifact cannot be safely inspected
- **THEN** the command fails with corrective location-based guidance without executing application code or following external symlink targets

#### Scenario: No recognized contracts
- **WHEN** eligible prompt roots contain no explicit contracts or conventional instruction files
- **THEN** the report records zero contracts checked
- **AND** it discloses that arbitrary prompt filenames and directories outside the selected roots are not covered

### Requirement: Prompt evidence retains its limits
The existing prompt report fields, schema version and diagnostic rule SHALL remain unchanged. files_checked SHALL count distinct attempted contract validations, including missing contracts required by conventional instructions. Templates and evaluation fixtures SHALL remain unexecuted; a successful check SHALL NOT claim constant resolution, authorization, prompt-injection resistance, model quality or behavioral correctness. Documentation SHALL disclose that expanded coverage can reveal previously omitted violations.

#### Scenario: Evaluation fixture contains executable-looking content
- **WHEN** a valid contract references an existing evaluation fixture and a template containing executable-looking text
- **THEN** the checker validates declarations and safe artifact references without interpreting or executing their content

#### Scenario: Another selected check fails
- **WHEN** prompt validation passes but another explicitly selected check fails
- **THEN** the combined command remains unsuccessful
