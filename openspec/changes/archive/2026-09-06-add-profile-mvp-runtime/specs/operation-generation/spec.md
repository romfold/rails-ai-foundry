## MODIFIED Requirements

### Requirement: Package-owned operations

`foundry:operation NAME --package=PACKAGE` SHALL accept snake_case names and a registered domain or platform package. It SHALL generate a namespaced Ruby object with `#call`, a package-local executable test, and a generation receipt. In version 1 packages, operations SHALL be private by default under `app/operations`; `--public` SHALL place the operation under `app/public`. In version 1 packages, the generated call SHALL raise `NotImplementedError` until application behavior is implemented, and the generated test SHALL verify that scaffold contract.

#### Scenario: Generate and execute both package types
- **WHEN** private and public operations are generated in domain and platform packages
- **THEN** their tests execute in an opted-in Rails host and their constants follow the existing package namespace conventions

## ADDED Requirements

### Requirement: Profile-aware operation contract

Version 2 operations SHALL use the canonical application operations location and a standard success/failure result contract. Explicit public operations SHALL remain under app/public. Version 1 operation paths, plain Ruby behavior, public option, and repeat receipts SHALL remain supported unchanged.

#### Scenario: Generate in a profiled package

- **WHEN** an operation is generated in an MVP package
- **THEN** its class has the Application::Operations namespace and its test uses the result contract

#### Scenario: Repeat legacy generation

- **WHEN** a version 1 operation is generated again
- **THEN** its source, test, and receipt remain byte-for-byte unchanged
