## Purpose

Provide executable, business-context-first domain conventions with explicit application ports, infrastructure adapters, and static architecture diagnostics.

## ADDED Requirements

### Requirement: Full domain scaffolding
Foundry SHALL generate package-owned entities, value objects, aggregates, policies, domain events, records, and repositories in canonical category namespaces. Domain scaffolds and their tests SHALL run without Rails. Repeats SHALL preserve edited files and reject incompatible requests without partial changes.

#### Scenario: Pure domain component
- **WHEN** a developer generates an entity in a domain package
- **THEN** its Ruby implementation and test run without Rails or persistence libraries

#### Scenario: Persistence adapter
- **WHEN** a developer generates a record and implements a repository against an application port
- **THEN** the host migration creates a package-owned table and a contract test can verify persistence independently of domain objects

### Requirement: Static layer and namespace enforcement
Convention checks SHALL verify ordinary filename-to-constant declarations and statically discoverable references using the same roots as loading. Domain code SHALL reject Rails, persistence, container, application, and integration dependencies. Full-domain application code SHALL depend on ports instead of concrete adapters. Container resolution SHALL be restricted to composition and public entry points. Queries and projections SHALL reject references to commands. Existing structural and cross-package checks SHALL remain available without executing application code.

#### Scenario: Incorrect namespace
- **WHEN** a profiled source declares an unrelated constant instead of its canonical constant
- **THEN** checks fail with the path and expected constant

#### Scenario: Concrete infrastructure dependency
- **WHEN** a full-domain application object references its persistence adapter or a domain entity references Active Record
- **THEN** checks fail with a source location and guidance to use constructor injection or a port

#### Scenario: Valid wiring
- **WHEN** composition wires a repository into an application object's constructor and the domain references only its own domain objects
- **THEN** convention checks pass

#### Scenario: Dynamic Ruby limits
- **WHEN** references are created through dynamic dispatch or string constantization
- **THEN** documentation identifies the static limits and requires runtime tests rather than claiming behavioral proof
