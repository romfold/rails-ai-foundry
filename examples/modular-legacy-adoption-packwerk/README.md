# Modular legacy adoption with Packwerk

An executable invoice application midway through extraction. The focal context is **Billing**, whose actual [modular configuration](packs/billing/foundry.yml) and [public boundary](packs/billing/package.yml) govern the example. Reports is a separate consumer of Billing's public API. The prefix describes Billing, not every pack.

The legacy `/legacy_report` endpoint still accesses a private invoice model through `LegacySalesReport`. Its exact dependency/privacy debt is reviewed in [package_todo.yml](package_todo.yml). `/report` implements the same behavior through the public API. Both sum paid invoices and exclude open invoices. The home page lists demo invoices and supports an idempotent local “mark paid” action.

## Run independently

Use Ruby 3.4.10. This application has its own locked bundle; run every command from this directory. Its development dependency points to the Foundry checkout, while production uses Rails, packs-rails and Dry::Operation directly.

```sh
bundle install
bin/setup
bin/rails server --binding=127.0.0.1
```

Open http://127.0.0.1:3000. Data is local demonstration data; this is an extraction example without authentication or a payment-provider integration. SQLite keeps the boundary exercise self-contained. It is not the PostgreSQL outbox or high-load recipe. Setup preserves existing invoices and their status.

```sh
bin/verify
bundle exec rubocop
npm ci
npm run spec:validate
```

`bin/verify` runs database preparation, behavior tests, Foundry source checks, actual Packwerk validation, the disposable extraction journey and production eager loading without Foundry execution code. Bundler may evaluate the path gem's version metadata while resolving the development dependency. It never regenerates accepted debt. Normal tests block outbound TCP requests and require no model credentials or service containers.

## Follow the extraction

1. Inspect the single accepted identity in package_todo.yml and its existing caller.
2. Compare `/legacy_report` and `/report` against the same paid/unpaid invoices.
3. Run `bundle exec ruby script/verify_adoption.rb`. It copies the app to a temporary directory, keeping the checked-in application unchanged.
4. The script introduces a second file referencing the same private model. Packwerk must fail and the accepted baseline must remain byte-identical.
5. In that disposable copy, the script moves the legacy URL to the Reports controller, removes the retired caller and explicitly deletes its now-resolved debt identity. It runs Packwerk and the same HTTP/behavior tests again.

This models an incremental endpoint extraction while preserving the externally visible URL and JSON response. It is not automatic migration tooling. Packwerk 3.1.0 can miss fully resolved stale baselines, so retirement is explicit and reviewed; ordinary checks never silently accept or regenerate debt. No pks parity is claimed.

## Ownership and workflow

Root Rails base classes remain in the shell. Billing owns its model, command, controller, view and seeds; root migrations remain ordinary Rails migrations. Cross-pack report calls use a declared dependency and Billing's public API. Existing legacy access is the sole accepted exception.

[config/foundry.yml](config/foundry.yml) selects OpenSpec. Upstream CLI 1.12.0 initialized the local workflow and Codex integration. Behavioral requirements live in [the invoice contract](openspec/specs/invoice-adoption/spec.md), which references the installed configuration instead of duplicating package topology. Change requirements and tests together. Root monorepo specifications describe Foundry itself, not this application.
