## Context

The profile foundation supplies v2 declarations and canonical paths. Existing operation installers use conservative receipts but render legacy POROs.

## Goals / Non-Goals

Deliver one executable MVP workflow without event infrastructure or application examples. Component generation stays package-owned; normal Rails migrations stay host-owned.

## Decisions

Use dry-operation ~>1.1 and dry-system ~>1.2.5 as core dependencies, lazily required by runtime helpers. Active Record remains consumer-owned and optional. A Foundry abstract record base inherits ActiveRecord::Base. Profile component templates share the registry and conservative installer. Model attributes accept explicit supported Rails scalar types. Record each migration path in a safe receipt so repeat generation preserves timestamps and user edits. Public operation generation retains its existing option. Runtime preparation rebuilds a map of package composition containers on each Rails reload; containers use explicit registrations and Rails loading, not dry-system component autoloading. Tests use SQLite and the real runtime libraries.

## Risks / Trade-offs

Domain/application enforcement cannot prove arbitrary dynamic Ruby behavior. No generated operation claims business correctness before its scaffold is implemented. Adding roots still requires restart. User migration files are never applied automatically by a generator.

## Migration Plan

Legacy v1 operations remain unchanged. New profile operations use result contracts. Consumers explicitly implement public facade methods and constructor wiring. Tests and packaged acceptance demonstrate the transition without rewriting existing operations.
