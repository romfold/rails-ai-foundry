## Purpose

Give application developers one versioned description of their packages and predictable locations for domain and reusable platform code.

## ADDED Requirements

### Requirement: Versioned manifest contract

The application manifest SHALL be a data-only YAML mapping containing `version: 1` and a `packages` mapping. Each package SHALL have a unique lowercase snake_case identifier, a `type` of `domain` or `platform`, and an explicit list of dependency identifiers. The reserved identifier `platform`, unknown manifest fields, duplicate mapping keys, invalid field types, duplicate dependencies, YAML aliases, custom object tags, and executable template interpolation MUST be rejected. An empty package mapping SHALL be valid.

#### Scenario: Accept an empty installation

- **WHEN** the manifest declares version 1 and `packages: {}`
- **THEN** the configuration is accepted without requiring any business packages

#### Scenario: Accept domain and platform declarations

- **WHEN** the manifest declares `billing` as a domain package depending on the platform package `messaging`, with explicit dependency lists
- **THEN** those package declarations are accepted

#### Scenario: Reject unsupported or ambiguous configuration

- **WHEN** the manifest uses an unsupported version, repeats a key, omits a required field, introduces an unknown field, or uses an invalid value type
- **THEN** configuration validation fails with the source path and the affected field or location

#### Scenario: Do not evaluate configuration as code

- **WHEN** the manifest contains an object tag, alias, or executable template expression
- **THEN** validation rejects the input without evaluating it or constructing arbitrary objects

### Requirement: Predictable package ownership

The application SHALL have a real `packages/` directory even when the registry is empty. Domain package identifiers SHALL map to `packages/<identifier>`, while platform identifiers SHALL map to `packages/platform/<identifier>`. Each declared package SHALL have a `package.yml` mapping, an `app/` directory, and its conventional public entry file. Domain entry files SHALL be `app/public/<identifier>.rb`; platform entry files SHALL be `app/public/platform/<identifier>.rb` within their package. The declared package's directory, metadata, and public entry path MUST remain within the application's real package root and MUST NOT traverse symbolic links.

#### Scenario: Locate a domain package

- **WHEN** `billing` is a declared domain package with its required files
- **THEN** its root is `packages/billing` and its public entry is `packages/billing/app/public/billing.rb`

#### Scenario: Locate a platform package

- **WHEN** `messaging` is a declared platform package with its required files
- **THEN** its root is `packages/platform/messaging` and its public entry is `packages/platform/messaging/app/public/platform/messaging.rb`

#### Scenario: Reject an unsafe package location

- **WHEN** a required package path or an ancestor below the application root is a symbolic link
- **THEN** validation reports an unsafe path and does not traverse it

### Requirement: Declared dependency policy

Dependency identifiers SHALL reference declared packages without self-dependencies or cycles. Domain packages SHALL be allowed to declare domain or platform dependencies. Platform packages SHALL depend only on other platform packages.

#### Scenario: Unknown dependency

- **WHEN** a package depends on an identifier absent from the manifest
- **THEN** validation reports the source package and missing identifier

#### Scenario: Cyclic dependency

- **WHEN** the declared graph contains a self-dependency or a cycle across packages
- **THEN** validation fails and identifies the involved package or cycle

#### Scenario: Platform depends on business policy

- **WHEN** a platform package declares a dependency on a domain package
- **THEN** validation reports the prohibited dependency direction

### Requirement: Package metadata agrees with the manifest

Each package's `package.yml` SHALL declare `enforce_dependencies: true` and a `dependencies` list of canonical application-relative package paths corresponding exactly to the manifest's dependency identifiers, regardless of list ordering. Duplicate paths MUST be rejected. The manifest SHALL remain authoritative; validation MUST NOT rewrite either representation to reconcile a mismatch. Additional package metadata keys SHALL be preserved and ignored by this initial checker.

#### Scenario: Metadata diverges from declared architecture

- **WHEN** package metadata omits a declared dependency, adds an undeclared dependency, or disables dependency enforcement
- **THEN** validation identifies the metadata file and mismatch without changing it

#### Scenario: Additional metadata is present

- **WHEN** required metadata is consistent and the mapping contains other data-only fields
- **THEN** the structural check accepts those extra fields without claiming to validate their semantics
