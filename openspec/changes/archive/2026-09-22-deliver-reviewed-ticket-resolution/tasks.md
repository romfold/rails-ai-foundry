## 1. Persisted review and local execution

- [x] 1.1 Add requests, attempts, audit and ticket migrations; verify constraints and rollback against PostgreSQL.
- [x] 1.2 Implement idempotent submission, approval, rejection, cancellation and linked retry; verify tenant, permission, revision and conflict behavior.
- [x] 1.3 Implement atomic execution; verify duplicate jobs and cancellation/approval races.

## 2. Generation and recovery

- [x] 2.1 Implement offline and controlled RubyLLM proposal contracts; verify limits, malformed output and absence of mutation tools.
- [x] 2.2 Implement leased generation and bounded retries; verify expiry, stale workers, cancellation and revocation.
- [x] 2.3 Add Solid Queue jobs and recurring discovery; verify lost scheduling and restart recovery.
- [x] 2.4 Add synchronized process crash tests around provider persistence and execution commit; verify one local effect and completion audit.

## 3. Review delivery

- [x] 3.1 Add authenticated HTTP endpoints; verify existing answers contract, status URLs, conflicts and identity injection.
- [x] 3.2 Add Rails/Hotwire review UI with CSRF and bounded frame polling; verify actual browser permissions, escaping and preserved input.
- [x] 3.3 Run shipped verification helper with baseline, selected HTTP and browser tests; verify four faulty controls are rejected.

## 4. Guidance and reconciliation

- [x] 4.1 Add shared guidance to existing skills and replay installed guidance with packs/ and components/; verify customizations, workflow, receipts and debt remain intact.
- [x] 4.2 Add ADR, runbook, compatibility evidence, living Spec Kit updates and roadmap reconciliation; verify links and honest evidence.
- [x] 4.3 Run example loading, Packwerk, RuboCop, prompt and workflow checks plus core, packaged, AI/workflow, contracts, skills/catalog and strict OpenSpec acceptance.
- [x] 4.4 Synchronize and archive only after verified completion; preserve historical studies and pending hosted CI.
