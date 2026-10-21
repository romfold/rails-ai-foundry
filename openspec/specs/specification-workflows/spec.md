# specification-workflows Specification

## Purpose
Allow applications to select optional upstream specification workflows without coupling application execution to those tools.

## Requirements

### Requirement: Local workflow selection
Selection SHALL prefer an explicit option, then configured selection, then one detected application-local installation. Otherwise greenfield SHALL default to spec_kit and adoption to openspec. CLI spec-kit SHALL normalize to spec_kit. None SHALL be supported without deleting existing artifacts.

#### Scenario: Existing selection
- **WHEN** greenfield setup encounters an explicitly configured OpenSpec workflow
- **THEN** it preserves OpenSpec rather than replacing it with the greenfield default

#### Scenario: Ambiguous detection
- **WHEN** both workflow installations exist without a configured or explicit selection
- **THEN** setup fails before changes and requests an explicit selection

#### Scenario: Parent application
- **WHEN** only the parent repository has a workflow installation
- **THEN** child application selection ignores it

### Requirement: Upstream initialization
Setup SHALL initialize only the selected workflow through a tested upstream CLI. Preview SHALL not initialize tools or write configuration. Missing prerequisites, version mismatches and upstream failures SHALL be reported without a successful setup claim.

#### Scenario: None without tooling
- **WHEN** none is selected and no specification tools are installed
- **THEN** setup succeeds without invoking or installing either workflow

#### Scenario: Failed initialization
- **WHEN** the upstream initializer exits unsuccessfully
- **THEN** setup preserves the previous selection and reports its output and incomplete state

#### Scenario: Repeat setup
- **WHEN** a selected workflow is already initialized and customized
- **THEN** repeated setup preserves its contents and does not rerun initialization
