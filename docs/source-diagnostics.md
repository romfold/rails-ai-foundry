# Source diagnostics

`foundry plan refactor` shares these diagnostic rules but inspects only the selected
configured package, including its tests and lib. Nested packages are excluded independently
of Foundry intent; their models do not supply evidence to the parent's assessment.
Source checking retains its broader application/package app/ scope. See
[adoption](adoption.md) for root-context exclusions and the assessment/migration distinction.

Use `foundry check --sources` or read-only `foundry adopt --sources`. Parsing covers root app/ and every upstream-discovered package's app/ Ruby sources, including packages without foundry.yml, without Rails boot or code execution. Full Packwerk verification remains separate. Each finding has a stable rule, file, one-based line, message, severity and certainty. Error findings fail the selected check; warnings preserve a successful status when there are no errors. Detected means concrete syntax was observed; inferred means an architectural relationship needs review. Neither proves Ruby constant resolution or runtime reachability.

Package discovery and architectural intent are independent. General rules apply to all
selected files; domain rules require the owning package's explicit domain profile.
An unconfigured nested package inherits neither a parent's profile/namespace nor root
defaults. Root packages and overlapping app roots contribute each file once, with
normalized relative diagnostic paths. Packages without app Ruby files contribute zero.
Files under lib/, test/, or outside these app trees remain excluded.

For example, an unconfigured `components/search/package.yml` discovered upstream still
causes `components/search/app/services/query.rb` to be parsed. A prohibited Foundry
reference there fails the check even when `contexts` is empty. `files_checked` counts
distinct inspected Ruby files; a zero count proves no behavior. This expands earlier
sidecar-only coverage and can reveal existing violations. Correct the source rather
than creating sidecars or regenerating debt solely to obtain a passing check.

Invalid discovery, unsafe paths, symlinked files/directories in selected trees and
unreadable or disappeared selected sources fail without a successful partial report.
Checking does not provide a concurrent filesystem snapshot. Keep Packwerk and behavioral
HTTP/browser verification separate; the source architecture Rake task uses the same scope.

| Rule | Severity / certainty | Scope and action |
| --- | --- | --- |
| source.syntax | error / detected | Unparseable Ruby; repair before claiming source verification |
| source.foundry_dependency | error / detected | Explicit RailsAIFoundry constant path in application code; use application/upstream execution |
| source.domain_dependency | error / detected | Rails, ActiveRecord, ApplicationRecord, ROM, Sequel, RubyLLM, OpenAI or Anthropic references in a domain profile's app/domain; keep pure rules independent |
| source.delivery_provider | error / detected | Explicit RubyLLM/OpenAI/Anthropic receiver calls in controllers/jobs/mailers/channels; place I/O behind an application service or agent |
| source.query_write | error / detected | Explicit persistence mutation calls in queries, on a model declared in selected source with ApplicationRecord/ActiveRecord::Base inheritance |
| source.projection_write | warning / inferred | Such writes in projections; verify they update rebuildable projection state, not authoritative business state |
| source.provider_in_transaction | warning / inferred | Explicit provider receiver calls inside transaction/callback blocks or a method named by a callback in the file; move I/O outside transactions and recheck revisions |

The write rule recognizes create/create!, update/update!, update_all, update_columns, insert/insert!, insert_all/insert_all!, upsert/upsert_all, delete/delete_all, destroy/destroy_all and touch_all. It recognizes constant receivers and chains such as Invoice.where(...).update_all. It does not infer the runtime type of arbitrary variables or follow inherited model bases. Projectors are allowed to persist projections; their writes produce review evidence.

Callbacks cover before/after/around save/create/update/destroy/commit/rollback/validation syntax. Named callback warnings are file-scoped and can be conservative when several classes share a file. Aliases, dynamic lookup/dispatch, indirect provider calls, requires, ERB and non-Ruby files need review. Plain strings/comments produce no findings; interpolated Ruby is code. Domain rules use configured profile/placement, not a duplicated package inventory. Missing tenant filters and cross-pack private partials remain manual review items until reliable diagnostics exist. Do not change accepted debt or enable pks to silence findings.
