# Adoption and debt evidence

Refactor assessment follows selected package ownership. It includes non-hidden Ruby in
tests, lib and other owned locations, but prunes independently discovered nested packages
even without foundry.yml. Select configured children separately; unconfigured packages
receive general checks through `foundry check --sources` without an inferred profile.
Configured upstream root packages are supported. Their scan excludes vendor, node_modules,
tmp, log, storage and coverage at application root, plus hidden entries and other packages.
The report describes installed intent; `--profile` proposes a change without applying it.
Completed assessment is neither implemented migration nor behavioral acceptance.

Run `foundry adopt --format=json` for a read-only assessment of the installed workflow, upstream-discovered packages, configured contexts and complete accepted debt identities. Preserve roots and existing workflows; an unconfigured brownfield application is recommended OpenSpec. Characterize behavior, select one owning context, preview `foundry plan refactor`, and extract delivery incrementally with behavioral and Packwerk checks. Foundry does not automate business-data conversion or rewrite package topology from a guessed domain model.

`foundry check --sources` stays boot-free and reports syntax evidence with uncertainty. `foundry check --boundaries` runs upstream Packwerk validate/check in test with an installed locked bundle. Never regenerate accepted debt in the original application merely to pass a check.

```sh
bundle exec foundry audit --root=/path/to/application
bundle exec foundry parity --root=/path/to/application --pks=/path/to/pks > /tmp/app-parity.json
bundle exec foundry parity --root=/path/to/application --pks=/path/to/pks --verify=/tmp/app-parity.json
```

Audit copies the application to a disposable directory, removes copied debt, then invokes Packwerk validation and regeneration. It compares complete identities: owning package, target package, constant, violation type and source file. JSON lists retained, new and resolved debt. New debt or failed analysis fails the command; resolved debt is reported for explicit review and manual cleanup in the source. This catches fully resolved baselines that Packwerk 3.1.0's normal check can miss. Original source/baseline fingerprints must remain unchanged. Blank/comment-only baselines represent no identities; malformed mappings fail with the path.

Parity runs the same process with Packwerk and pks in separate disposable copies. Only matching identities on the same source snapshot produce successful parity evidence. Reports include the application root, input fingerprint, Ruby/tool versions and pks binary hash. `--verify` rejects failed, wrong-application or stale evidence and rechecks both tools; it is an explicit supplementary verification, not a permanent backend switch. Source/configuration/dependency changes require fresh parity. Packwerk remains authoritative even after a successful comparison. Upstream pks does not support every Packwerk plugin or constant resolution case, so agreement on one application never implies universal parity.

Save reports outside the application so the report itself does not alter its fingerprint. Copies exclude Git/editor/agent metadata, dependency caches, tmp/log/storage, environment files, encrypted credentials and database files. Source symlinks are rejected. The original installed Gemfile supplies dependencies while code/configuration analysis runs from the copy. This is filesystem isolation, not a sandbox for application code: Packwerk may boot Rails and use configured services. Run against a disposable test database with test-only credentials; retain the application's network guards. Custom analysis that depends on excluded files must be reviewed before using this audit.

The legacy-adoption flagship also supplies a real endpoint extraction exercise and tests existing behavior. `PKS_BIN=/path/to/pks bundle exec ruby script/verify_adoption_evidence.rb` from the Foundry repository verifies real parity, fully resolved debt, new-source rejection and unchanged originals using disposable copies. No source baseline is silently cleaned up or accepted. [pks upstream verification and limitations](https://github.com/alexevanczuk/packs#verification).

## Verified audit inputs

Both analyzer copies and accepted debt derive from one verified pristine capture.
Copied bytes must match its inventory; detected source changes or incomplete copies fail.
This is not a filesystem-atomic snapshot. Adoption and audit use the same eligible baseline
paths, so excluded vendor/private baselines cannot appear as resolved application debt.
New eligible baselines produced by an analyzer still contribute full violation identities.
The opaque fingerprint includes an input-policy revision: regenerate older parity reports,
even at the same gem version. Do not rewrite historical reports or edit their hashes.

Exclusions include `.claude` and application-root `.foundry/skill-upgrades` backups.
Ordinary `.foundry` receipts remain eligible; changing them invalidates parity evidence.
Temporary roots are owner-private and removed on normal success/failure. Hard termination
can leave temporary copies. The capture does not isolate environment variables, external
bundle paths or service access. Move required analysis inputs out of excluded locations;
there is no override that silently imports private data.

## Executable knowledge journey

The [knowledge adoption walkthrough](../recipes/knowledge-adoption/README.md "Repository-only reference; not installed") replays characterization, read-only assessment, Active Record pack extraction, reviewed caller/debt repair, a separate ROM change and integration features. Installed-gem replay passed for both `packs/` and `components/`, preserving endpoints, existing data and OpenSpec history. Pack extraction is useful independently of ROM or the advanced stack.
