## Purpose

Track explicitly reviewed legacy boundary debt without allowing new violations or weakening strict architecture validation.

## ADDED Requirements

### Requirement: Reviewable baseline drafts
`foundry adoption baseline --root=PATH` SHALL emit a versioned JSON draft to stdout only after complete assessment. Entries SHALL identify a dependency or privacy rule, source file, referenced constant, target owner, and occurrence count, with an initially empty rationale requiring review. The command SHALL NOT write or update baseline files.

#### Scenario: Draft current debt
- **WHEN** complete assessment finds repeated references violating a boundary
- **THEN** the draft groups exact identities with their occurrence counts and requires a rationale before acceptance

### Requirement: Separate migration gate
`foundry adoption check --root=PATH --baseline=FILE` SHALL accept only exact reviewed entries. New identities, increased counts, resolved entries, and reduced counts requiring baseline cleanup SHALL fail. Line-number movement alone SHALL not change identity. Malformed JSON, duplicate fields or entries, unknown fields or versions, wildcard exemptions, invalid counts, unsafe paths, and missing rationales SHALL fail. Fatal assessment diagnostics SHALL never be baselined.

#### Scenario: Changed legacy debt
- **WHEN** new debt is introduced or accepted debt is resolved
- **THEN** the gate fails and identifies additions or the baseline entries needing removal or count reduction

#### Scenario: Strict checks remain strict
- **WHEN** an adoption baseline acknowledges existing privacy debt
- **THEN** the adoption gate can pass while ordinary strict boundary checks continue to fail on that debt

#### Scenario: Non-boundary failure
- **WHEN** malformed configuration, unsafe source paths, syntax errors, or forbidden profile layers are present
- **THEN** the gate fails regardless of baseline contents

### Requirement: Honest adoption status
Gate output and installed guidance SHALL distinguish no unaccepted boundary debt from completed adoption. Completion SHALL require strict checks and application runtime tests. Commands SHALL not boot Rails, execute application source, contact services, or write application files.

#### Scenario: Passing migration gate
- **WHEN** current debt exactly matches reviewed entries
- **THEN** the command reports limited gate success without claiming completed extraction or runtime correctness
