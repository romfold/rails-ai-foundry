## 1. Specification and generation

- [x] 1.1 Validate proposal, capability specifications, design, and tasks against the standard schema.
- [x] 1.2 Implement package planning and safe registration; test identifiers, dependencies, normalized YAML, permissions, repeats, conflicts, partial writes, concurrent changes, and cleanup.
- [x] 1.3 Add the Rails package generator and templates; test discovery, default/explicit options, generated tests, pretend, force, and reversal.

## 2. Rails loading

- [x] 2.1 Add opt-in loading registration before Rails freezes paths; test disabled behavior, invalid configuration, root selection, lazy loading, reloading, eager loading, and loader errors.
- [x] 2.2 Add a bootable test host while preserving the existing host; verify structural checks with loading enabled still do not boot or execute package code.

## 3. Verification and completion

- [x] 3.1 Run the expanded suite across all seven documented Ruby/Rails pairs and record exact local results; run RuboCop with the Ruby 3.0 target.
- [x] 3.2 Build and inspect the gem, then install it in isolation and verify both generators and loading integration with MIT/runtime templates packaged.
- [x] 3.3 Update guides, roadmap, and agent guidance; verify examples, local links, and clear runtime-versus-structural scope.
- [x] 3.4 Run strict OpenSpec validation, complete the verified tasks, merge and archive the change, and verify focused Conventional Commits and a clean working tree.


## Verification record

Verified locally on 2026-09-05. All seven approved Ruby/Rails combinations passed 67 tests and 281 assertions with no failures, errors, or skips. Exact versions are recorded in docs/compatibility.md. RuboCop inspected 46 Ruby files with no offenses and a Ruby 3.0 target.

The final 0.1.0 gem contains 22 runtime/template/documentation/license files, retains MIT, and excludes development artifacts. Its isolated installation passed both generators, repeated package generation, structural checks, generated tests, and production package loading. The loaded source path was verified to be the installed archive.

The original non-booting host and both earlier change archives remain unchanged. Local documentation links, English content, and strict OpenSpec validation passed. No remote CI execution or publishing is claimed.
