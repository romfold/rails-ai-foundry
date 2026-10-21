## 1. Source editing and runtime isolation

- [x] 1.1 Replace setup regex reconciliation with AST source ranges; verify conventional acceptance/rejection, comments, Unicode, LF/CRLF, repeat behavior and publication failure cleanup.
- [x] 1.2 Add Runtime.reset! and owned-state preparation isolation; verify successive preparation/reload and unrelated globals.
- [x] 1.3 Add optional ExecutionStore and NullStore; verify existing duck-typed tracking and no-op persistence behavior.

## 2. Scaffolds and parser compatibility

- [x] 2.1 Demonstrate steps/step in newly generated commands and explicitly accept the template callback block; verify generated transaction rollback and real installed-template execution.
- [x] 2.2 Verify duplicate-key rejection against available supported JSON major versions, including nested duplicates; preserve fail-closed behavior without warning suppression.

## 3. Guidance and delivery

- [x] 3.1 Update current guidance, six development/seven shipped skill counts, and ADR index with Git-backed dated supersession notes; verify links and skill manifests.
- [x] 3.2 Verify exact foundry:check and foundry:projections:rebuild[package,name] command scenarios through actual Rails tasks.
- [x] 3.3 Run core, AI, installed-template and profile regressions, RuboCop and strict OpenSpec validation; record results, commit, merge deltas and archive only after success.
