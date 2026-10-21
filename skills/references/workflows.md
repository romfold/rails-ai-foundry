# Application specification workflow

Read `config/foundry.yml` in the consuming application, not an ancestor repository. The explicit `workflow.specs` value selects `spec_kit`, `openspec`, or `none`. If no selection exists, inspect only the application's `.specify/` and `openspec/`. Preserve one established workflow. If both exist, resolve the selection before changing workflow artifacts. Foundry itself continues to use OpenSpec.

For `spec_kit`, load [Spec Kit guidance](spec-kit.md). For `openspec`, load [OpenSpec guidance](openspec.md). For `none`, proceed with the authorized implementation and behavioral tests; specification tooling is not a prerequisite. Existing documents are preserved when selecting `none` or switching tools.

Requirements describe intended behavior. Plans propose implementation. Installed `foundry.yml` files constrain architecture, `package.yml` owns topology, and code/tests provide evidence. Reference these files instead of copying context settings into specifications or constitutions. A proposed configuration change takes effect only after it is accepted and installed.

Inspect the owning context and current behavior before generating code. For a sidecar `foundry.yml` context, read [native conventions](native-conventions.md). Application execution uses Rails and upstream libraries directly. Run relevant behavioral tests and architecture checks after implementation. Agent completion messages and specification validation cannot establish behavioral correctness.
