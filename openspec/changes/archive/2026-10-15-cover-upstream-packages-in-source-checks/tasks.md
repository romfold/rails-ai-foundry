## 1. Source inventory and safe coverage

- [x] 1.1 Add regression fixtures for the reproduced sidecar-free omission in check and adopt, plus shell and package-only sources; verify the current implementation fails the new expectations and record baseline dependency lock hashes.
- [x] 1.2 Pass the assessment's upstream package inventory into source selection and normalize/deduplicate app Ruby paths; verify standard, custom, nested, overlapping and root-package layouts with exact file counts and deterministic diagnostic paths, including packages without app files and excluded lib/test files.
- [x] 1.3 Reject unsafe roots, source/directory symlinks, discovery failures and unreadable/disappeared selected files; verify explicit failure, no external target reads, no application execution and byte-preservation of application configuration, source, workflow history and accepted debt.

## 2. Rule ownership and existing interfaces

- [x] 2.1 Resolve the most specific owning package before assigning optional Foundry intent; verify root-domain enforcement, configured child overrides and unconfigured child non-inheritance, including sibling names sharing a prefix and same leaf model names in different namespaces.
- [x] 2.2 Exercise all existing profile-independent rules in unconfigured packages and retain configured-only domain rules; verify concrete errors, advisory warnings, literal/comment false-positive controls and healthy equivalents with and without sidecars.
- [x] 2.3 Integrate the existing source architecture task and preserve non-opt-in/composed-check behavior, JSON report shape and selected-context refactor semantics; verify CLI/Rake/core contract tests, exact zero-file reports and unchanged no-source checks.

## 3. Installed acceptance and guidance

- [x] 3.1 Extend built-gem acceptance under test_packaging for packs/ and components/ consumers without checkout access; verify check, adopt and architecture sources against both passing and failing sources, inspect archive inventory and compare application lock/debt/workflow hashes before and after.
- [x] 3.2 Add bounded offline omission/ownership controls that skip unconfigured packages, replace root selection or inherit parent intent incorrectly; verify each is rejected by the relevant acceptance assertion and a valid equivalent implementation passes after restoration.
- [x] 3.3 Update existing source-diagnostic/stable-contract documentation and relevant packs/native-conventions/verification guidance with the expanded coverage and limits; verify installed links and replay reviewed upgrades across agents, claude and cursor, preserving customizations, receipts, workflows and accepted debt.

## 4. Verification and reconciliation

- [x] 4.1 Run frozen Rails 7.1 and managed Rails 8.1 core lanes, packaged acceptance and the existing installed delivery replay; verify all intended tests actually execute, affected HTTP/browser checks still pass and all existing dependency lock hashes remain unchanged. Record blocked prerequisites explicitly without upgrading dependencies.
- [x] 4.2 Run relevant offline AI/workflow acceptance, bundle exec rubocop, npm run contracts:validate, ruby script/validate_skills, catalog validation, privacy/archive-content checks and npm run spec:validate; record full command text, actual outcomes and any corrections without presenting these checks as application behavioral proof.
- [x] 4.3 Record implementation commit, built-gem digest and local evidence; update the roadmap and rationale for inventory/intent separation, synchronize the delta and archive only after verified completion. Verify Campfire native acceptance, hosted release CI and unfinished study tasks remain open, historical evidence/research remain untouched and only intended files enter focused Conventional Commits.
