## MODIFIED Requirements

### Requirement: Minimal application installation

`bin/rails generate foundry:install` SHALL create a supported architecture manifest at `config/architecture.yml` with an empty package registry and establish the `packages/` directory. It SHALL leave unrelated files, dependencies, and application behavior unchanged.

#### Scenario: Install into a fresh host

- **WHEN** installation runs in a Rails host without Foundry configuration
- **THEN** it creates a version 2 manifest with no declared packages and a trackable package root
- **AND** the architecture-check task succeeds without database or AI credentials
- **AND** the installer does not generate business packages, change the Gemfile, or modify application boot configuration

### Requirement: Declared compatibility is verified

The gem SHALL declare Ruby >= 3.3 and railties >= 7.1 and preserve Ruby 3.3-compatible runtime syntax. Its documented test matrix SHALL cover the approved upstream-compatible Ruby/Rails pairs and identify concrete versions and executed results.

#### Scenario: Install on the minimum compatibility line

- **WHEN** the gem is installed with Ruby 3.3 and Rails 7.1 using compatible dependencies
- **THEN** the require entry point, installer, and structural checker pass the same behavioral suite used for newer supported combinations

#### Scenario: Verify newer Ruby and Rails lines

- **WHEN** the suite runs for the documented Ruby 3.3 through 4.0 and Rails 7.2 through 8.1 combinations
- **THEN** the results identify the concrete Ruby, Rails, and Bundler versions
- **AND** unexecuted combinations or remote jobs are not reported as passing
