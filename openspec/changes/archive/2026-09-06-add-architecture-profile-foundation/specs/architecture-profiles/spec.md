## Purpose

Provide one predictable package layout for each supported architecture profile while preserving legacy package behavior.

## ADDED Requirements

### Requirement: Explicit progressive profiles

Foundry SHALL support mvp (light/off/off), modular (light/lite/lite), domain (full/lite/lite), and event_sourced (full/full/sourced), representing DDD, CQRS, and events respectively. A version 2 package generator SHALL default to mvp and reject unknown profiles without writes. Repeat generation SHALL preserve content and reject changed declarations. Version 1 generation SHALL retain its existing layout and reject explicit profiles.

#### Scenario: Generate a default package

- **WHEN** a package is generated in a version 2 host without a profile option
- **THEN** it is registered as mvp with the canonical public namespace

#### Scenario: Preserve legacy packages

- **WHEN** generation or loading encounters version 1
- **THEN** the established declarations and loading semantics remain unchanged

### Requirement: Canonical profiled source locations

Profiled package Ruby SHALL use ordinary filename-to-constant mapping under public, application, composition, models for light profiles, domain for full profiles, and adapters. The conventions command SHALL reject unsupported source folders, package namespace mismatches, and profile-incompatible categories with source paths and expected locations. Package loading and static checks SHALL share those root definitions, without executing package code during checks.

#### Scenario: Misplaced Ruby

- **WHEN** a profiled package places Ruby in app/services or places models in a full-domain profile
- **THEN** convention validation fails with a canonical destination suggestion

#### Scenario: Lazy and eager loading

- **WHEN** package loading is explicitly enabled for a valid profiled package
- **THEN** Rails loads its canonical roots using its normal lazy, eager, and reload lifecycle
