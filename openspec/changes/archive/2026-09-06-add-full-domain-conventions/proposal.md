## Why

The profile registry now describes full-domain folders, but domain component generators and layer reference checks are missing. Developers need executable separation and Rails-independent tests before these profiles can be considered working.

## What Changes

- Generate pure domain objects, domain events, persistence records, and repository adapters through the existing safe scaffold engine.
- Check declared namespaces and statically resolved layer references using the shared source roots.
- Verify constructor injection, domain isolation, and repository persistence contracts in minimal hosts.

## Capabilities

### New Capabilities
- `domain-conventions`: Pure domain generation, persistence contracts, and static layer enforcement.

### Modified Capabilities

None.

## Impact

Component generators, static conventions, runtime acceptance tests, and Foundry skill guidance. Legacy loading and structural/Packwerk boundary guarantees remain intact. Event sourcing and promotion stay in subsequent changes.
