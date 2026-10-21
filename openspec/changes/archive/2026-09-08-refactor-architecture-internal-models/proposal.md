## Why

Package paths, profile decisions, and component locations are reconstructed from mutable hashes throughout the framework. LayerRules combines six independent policies whose precedence must remain stable during maintenance.

## What Changes

- Introduce immutable Architecture package, profile, and component-location values with copied, deeply frozen collections.
- Retain Manifest's string-keyed packages hash and serialization interfaces; construct fresh typed views so hash edits remain observable.
- Use typed accessors internally for canonical paths and profile decisions.
- Split layer policy into focused container, domain, AI, projection-effect, command/read, and application-port rules with unchanged precedence and diagnostics.

## Capabilities

### New Capabilities

None. This is a pure internal refactor with `skip_specs: true`.

### Modified Capabilities

None. Manifest v1/v2, canonical namespaces/directories, generated output, and static diagnostic contracts remain unchanged.

## Impact

Architecture models, manifest accessors, generator profile decisions, and layer rules/tests. No dependencies, public commands, runtime behavior, or archived specifications change. The generation-internals milestone is verified and committed before implementation of this change.
