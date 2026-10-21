## Why

The implemented architecture core verifies declared structure but cannot create or load package Ruby. Executable packages are needed before AI workflows can depend on reusable application boundaries.

## What Changes

- Add safe domain/platform package generation with manifest registration and a Minitest skeleton.
- Add explicitly enabled Rails autoloading, reloading, and eager loading for declared packages.
- Preserve the version 1 manifest, structural-check behavior, Ruby/Rails compatibility, and MIT licensing.
- Document executable packages as the next completed milestone before RubyLLM.

## Capabilities

### New Capabilities

- `package-generation`: Generate and register minimal packages without overwriting existing content.
- `package-loading`: Opt into Rails-managed loading of declared package code.

### Modified Capabilities

- `contributor-workflow`: Update the current capability-status scenario to distinguish implemented package loading from future enforcement and AI work. Existing installation, package configuration, and read-only structural checks retain their contracts.

## Impact

Add a generator, plain Ruby generation components, templates, and a Railtie initializer. Consumers explicitly set `config.rails_ai_foundry.autoload_packages = true`. No new runtime dependency or version bump is needed. Privacy enforcement, custom inflection policies, routing/views/assets, AI integrations, and publishing remain outside this change.
