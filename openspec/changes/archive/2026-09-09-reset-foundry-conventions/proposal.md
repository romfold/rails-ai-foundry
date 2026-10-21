## Why

Foundry currently owns package topology, Rails loading and application execution semantics. The approved breaking reset makes these upstream responsibilities and gives consuming applications independent architecture and specification-workflow choices.

## What Changes

- Add context intent with rails_native/modular/domain profiles, independent event/CQRS patterns and capability selections.
- Add specification workflow selection and initialization: Spec Kit for greenfield, OpenSpec for adoption, existing selections preserved, and none supported.
- Delegate pack discovery, package operations, Rails loading and boundary validation upstream.
- Replace legacy generators and application runtimes with application-owned Rails/upstream code, conservative generation and source-only assessment.
- **BREAKING**: retire the old manifest, runtime APIs, profile names and promotion machinery after replacement acceptance passes.
- Record the complete approved delivery program, including the twelve named examples, without representing later milestones as implemented.

## Capabilities

### New Capabilities

- `context-intent`: independent architectural intent and upstream package ownership.
- `specification-workflows`: optional setup-only specification workflows and application-local detection.

### Modified Capabilities

- `fresh-app-setup`: configurable greenfield and existing-app workflow setup.
- `architecture-planning`: generation proposals and refactoring assessments use context intent.
- `foundry-skills`: route work through the selected application workflow.

## Impact

CLI, configuration, generation, packaged assets, tests and contributor documentation. Existing runtime removal and upstream loading cutover require their own replacement coverage before retirement. The complete release program remains authorized and is tracked separately from completion of individual changes. Ruby/Rails floors and the repository's pinned OpenSpec workflow remain in place.

### Breaking retirement details

All retired 0.1 capability requirements are explicitly listed in removal deltas. Contributor workflow, distribution, compatibility and skill-installation contracts survive with updated native behavior. Retired capability Purposes are removed with their obsolete current specifications; historical ADRs and prior archives remain unchanged.
