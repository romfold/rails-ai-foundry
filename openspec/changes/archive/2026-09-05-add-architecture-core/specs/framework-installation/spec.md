## Purpose

Allow a Rails application to install the Foundry architecture foundation without losing existing application files or requiring unrelated infrastructure.

## ADDED Requirements

### Requirement: Framework integration is available through the gem

A Rails host that includes `rails_ai_foundry` SHALL expose the `foundry:install` generator and `foundry:architecture:check` task. Loading the gem through `require "rails_ai_foundry"` SHALL expose the `RailsAIFoundry` namespace without requiring a running Rails application or initiating external-service calls.

#### Scenario: Load the framework in Ruby

- **WHEN** a Ruby process requires the installed gem
- **THEN** the require succeeds and `RailsAIFoundry` is defined
- **AND** no database, AI provider, or network service is needed

#### Scenario: Discover Rails integration

- **WHEN** a supported minimal Rails host loads the gem and lists its generators and tasks
- **THEN** the installation generator and architecture-check task are discoverable

### Requirement: Minimal application installation

`bin/rails generate foundry:install` SHALL create a supported architecture manifest at `config/architecture.yml` with an empty package registry and establish the `packages/` directory. It SHALL leave unrelated files, dependencies, and application behavior unchanged.

#### Scenario: Install into a fresh host

- **WHEN** installation runs in a Rails host without Foundry configuration
- **THEN** it creates a version 1 manifest with no declared packages and a trackable package root
- **AND** the architecture-check task succeeds without database or AI credentials
- **AND** the installer does not generate business packages, change the Gemfile, or modify application boot configuration

### Requirement: Repeat installation preserves user content

Repeated installation SHALL preserve compatible existing configuration and package content byte-for-byte. It SHALL report which managed artifacts already exist instead of resetting the package registry.

#### Scenario: Repeat an unchanged installation

- **WHEN** installation runs a second time after a successful installation
- **THEN** it exits successfully without changing tracked file contents

#### Scenario: Preserve a customized supported manifest

- **WHEN** installation finds a valid version 1 manifest declaring packages
- **THEN** it preserves the manifest and existing package files
- **AND** it does not empty the registry or repair package violations implicitly

### Requirement: Installation fails safely on conflicts

The installer MUST reject unsupported or invalid existing manifests, incompatible destination types, and symbolic links in managed destination paths before writing managed files. It SHALL report the conflicting path and an actionable reason. It MUST NOT offer an implicit overwrite or delete existing user files while handling a failure.

#### Scenario: Existing configuration is incompatible

- **WHEN** `config/architecture.yml` contains malformed configuration or an unsupported version
- **THEN** installation exits unsuccessfully, identifies the configuration problem, and leaves the existing filesystem contents unchanged

#### Scenario: Package destination is not a safe directory

- **WHEN** `packages` is a file or a symbolic link
- **THEN** installation exits unsuccessfully before creating the manifest
- **AND** the diagnostic identifies `packages`

#### Scenario: Write fails after preflight

- **WHEN** a filesystem error prevents completion after an initially valid preflight
- **THEN** installation reports the failed path and exits unsuccessfully
- **AND** it preserves every pre-existing file and removes only artifacts created by that failed invocation when cleanup is possible

### Requirement: Declared compatibility is verified

The gem SHALL declare Ruby >= 3.0 and railties >= 7.1 and preserve Ruby 3.0-compatible runtime syntax. Its documented test matrix SHALL cover the approved upstream-compatible Ruby/Rails pairs and identify concrete versions and executed results.

#### Scenario: Install on the minimum compatibility line

- **WHEN** the gem is installed with Ruby 3.0 and Rails 7.1 using compatible dependencies
- **THEN** the require entry point, installer, and structural checker pass the same behavioral suite used for newer supported combinations

#### Scenario: Verify newer Ruby and Rails lines

- **WHEN** the suite runs for the documented Ruby 3.1 through 4.0 and Rails 7.2 through 8.1 combinations
- **THEN** the results identify the concrete Ruby, Rails, and Bundler versions
- **AND** unexecuted combinations or remote jobs are not reported as passing

### Requirement: MIT licensing is included in distribution

The project SHALL use the standard MIT license with copyright `2026 romfold`. The local gem SHALL include LICENSE and declare MIT license metadata, retaining third-party notices.

#### Scenario: Inspect a built gem

- **WHEN** the locally built version 0.1.0 gem is inspected
- **THEN** its metadata declares MIT and its files include the complete project license
- **AND** packaging excludes credentials and installed development dependencies
