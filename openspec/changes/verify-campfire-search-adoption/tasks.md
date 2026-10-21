## 1. Baseline and compatibility

- [x] 1.1 Prepare an isolated branch at the pinned Campfire revision; verify the original checkout and lock remain unchanged.
- [x] 1.2 Install locked dependencies and record baseline test, browser, loading and asset results against disposable state. Recorded failures remain failures, not successful behavioral acceptance.
- [x] 1.3 Install the built gem, upstream package integration and OpenSpec/agents guidance; verify exact dependency resolution without replacing locked application versions.

## 2. Incremental Search extraction

- [x] 2.1 Extract Search delivery and frontend assets into the configured Rails-native pack; verify routes, loading, assets and unchanged persistence ownership.
- [ ] 2.2 Add characterization and browser acceptance for authorization, history, indexing and query behavior; verify root and pack tests through the installed application command.
- [ ] 2.3 Verify enforced boundaries and production-like loading without Foundry; run authorization, omitted-coverage and private-access fault controls.

## 3. Reconciliation

- [x] 3.1 Assess demonstrated Foundry defects and fix only those requiring correction; verify the installed helper's failure behavior. No Foundry product defect was demonstrated: it correctly rejects unloaded planned files. No product fix or template update was made.
- [x] 3.2 Preserve a reviewable Campfire branch and portable recovery artifact; record revisions, hashes, commands, limitations and rollback instructions.
- [x] 3.3 Update application guidance and roadmap; run affected core/archive, contract, skill, privacy, RuboCop and strict specification checks. Installed consumer verification was attempted and its behavioral failures remain open in 2.2/2.3; do not archive.

## Current prerequisite

The unchanged application selects Minitest 6.0.6. Both ordinary and system Rails test commands exit zero with no tests. Explicit Rails plugin registration reaches test_helper.rb and fails on the removed minitest/unit require. See docs/evidence/2026-10-10/campfire-adoption.md. The revised authorized scope permits extraction while preserving these failures. All existing locked versions remain unchanged; no test-harness repair or compatibility adapter is authorized. Behavioral acceptance remains incomplete and the change must stay unarchived.

## Implementation checkpoint

Campfire branch codex/foundry-search-adoption contains implementation 5925c10 and evidence e9b63a2. Full continuation evidence is docs/evidence/2026-10-10/campfire-search-extraction.md. Task 2.3 has passing boundary and production-loading checks, but its behavioral controls remain blocked by task 2.2. The portable bundle and 23 new gem archives are local ignored artifacts, not a thirteenth example or distributed gem resources.

## 4. Separate browser review with frozen dependencies

This authorized review adds evidence; it does not replace tasks 2.2/2.3 or repair the test harness.

- [x] 4.1 Freeze revisions and dependency fingerprints; prepare isolated applications, services and identical synthetic data.
- [x] 4.2 Compare navigation, queries, result windows, authorization, history, indexing and frontend behavior through real browsers and authenticated HTTP.
- [x] 4.3 Detect a deliberate visibility bypass in a disposable copy and confirm healthy recovery.
- [x] 4.4 Record attributable results, limitations, reproduction and rollback; verify frozen dependencies and original checkout preservation.

Browser review completed on 2026-10-14: see
`docs/evidence/2026-10-14/campfire-browser-review/README.md`. The original and extracted
applications matched; the visibility-bypass control failed specifically on disclosure and
passed after restoration. Application evidence-only follow-up is fdd3635. The change is
11/13 tasks complete; original automated tasks 2.2/2.3 remain unchecked and unarchived.
