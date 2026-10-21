## MODIFIED Requirements

### Requirement: Declared compatibility is verified

The gem SHALL declare Ruby >= 3.3 and railties >= 7.1 and preserve Ruby 3.3-compatible generated Ruby syntax. Its documented test matrix SHALL cover the approved upstream-compatible Ruby/Rails pairs and identify concrete versions and executed results.

#### Scenario: Install on the minimum compatibility line

- **WHEN** the gem is installed with Ruby 3.3 and Rails 7.1 using compatible dependencies
- **THEN** the require entry point, context generator, and structural checker pass the same behavioral suite used for newer supported combinations

#### Scenario: Verify newer Ruby and Rails lines

- **WHEN** the suite runs for the documented Ruby 3.3 through 4.0 and Rails 7.2 through 8.1 combinations
- **THEN** the results identify the concrete Ruby, Rails, and Bundler versions
- **AND** unexecuted combinations or remote jobs are not reported as passing


### Requirement: MIT licensing is included in distribution

The project SHALL use the standard MIT license with copyright `2026 romfold`. The local gem SHALL include LICENSE and declare MIT license metadata, retaining third-party notices.

#### Scenario: Inspect a built gem

- **WHEN** the locally built version 0.2.0 gem is inspected
- **THEN** its metadata declares MIT and its files include the complete project license
- **AND** packaging excludes credentials and installed development dependencies

## REMOVED Requirements

### Requirement: Framework integration is available through the gem
**Reason**: The old manifest installer is removed.
**Migration**: Use foundry new, foundry setup and foundry:context; see docs/migration-0.2.md.

### Requirement: Minimal application installation
**Reason**: The old manifest installer is removed.
**Migration**: Use foundry new, foundry setup and foundry:context; see docs/migration-0.2.md.

### Requirement: Repeat installation preserves user content
**Reason**: The old manifest installer is removed.
**Migration**: Use foundry new, foundry setup and foundry:context; see docs/migration-0.2.md.

### Requirement: Installation fails safely on conflicts
**Reason**: The old manifest installer is removed.
**Migration**: Use foundry new, foundry setup and foundry:context; see docs/migration-0.2.md.
