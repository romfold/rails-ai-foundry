# Extract existing Rails delivery

Use this only when moving an existing feature's delivery into a package. Ordinary feature
work does not require extraction. Foundry guides the work; upstream packs owns package
operations, packs-rails integrates Rails paths, and Rails/your asset pipeline executes it.

1. Characterize named routes, authorization, persisted identities/content, helpers/views,
   DOM identifiers and frontend interactions before moving files. Freeze existing locks
   and record any broken baseline separately. Do not repair an immutable test harness.
2. Resolve profile/patterns from application intent and choose a namespace that does not
   collide with shell models. Keep established package roots. Move feature controllers,
   helpers, views, JavaScript and tests together; shared delivery, models retained by the
   shell, tables and migrations stay put unless explicitly in scope.
3. Reconcile route dispatch without changing URLs/helpers. Verify namespaced helper/view
   lookup and shared partials. Inspect the actual importmap/bundler and asset pipeline:
   packs-rails integration does not prove a moved JavaScript module is pinned or served.
   Keep module names and Stimulus identifiers stable when preserving behavior.
4. Declare dependencies and enforcement in package.yml. Do not expose private controllers
   as business APIs or silently regenerate accepted debt. Run loading, fresh production
   boot without Foundry, development reloading, asset and Packwerk checks separately.
5. Run the package-aware helper with explicit caller/browser selections. Require real
   authorization and UI assertions, including correct Rails DOM IDs and retained drafts.
   Missing asset wiring can pass static checks. Prove specific faults fail after a healthy
   baseline; restore and recheck. Equivalent native wiring is valid.
6. Record a reversible patch and compare lock/schema/data with the starting checkpoint.
   Preserve customized skills, receipts, workflow history and debt. Deliver new guidance
   through reviewed skill upgrades; instruction replacement is not application migration.

The installed gem's `docs/delivery-pack-extraction.md` provides a complete disposable
Rails/importmap/Propshaft exercise. Adapt other asset pipelines with their native tooling.
No auto-extractor, loader or production Foundry runtime is needed. Separate browser
observations add evidence but never satisfy blocked framework/installed-helper acceptance.
