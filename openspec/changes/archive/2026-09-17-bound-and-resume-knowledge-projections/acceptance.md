# Verified bounded knowledge operations

Implementation and local evidence are recorded in
[knowledge operations acceptance](../../../../docs/knowledge-operations-evidence.md), with
the [operator runbook](../../../../docs/knowledge-operations.md), raw final scale samples and
adoption checkpoint hashes. The archive retains the task-to-evidence mapping below.

| Tasks | Executed evidence |
| --- | --- |
| 1.1–1.3 | `bounded_reads_test.rb`, delivery/projection tests and authorized-tool/citation acceptance |
| 2.1 | `projection_upgrade_test.rb` compares existing documents/outbox/events/selections through all additive migrations; journal rollback tests |
| 2.2 | `projection_journal_test.rb` uses synchronized competing writers, sequence gaps and missing-history rejection; behind-cursor creation test |
| 2.3 | Persisted ownership, mismatch, cancellation, lost-wake-up and quarantine cases in rebuild progress/validation tests |
| 2.4–2.5 | Partial real bulk failure, oversized record rejection, vector-provider/revision tests and process-kill checkpoint replay |
| 3.1–3.2 | Multi-page manifest corruption/content checks, final-gate source change, forbidden full scan and budget-expiry tests |
| 3.3–3.4 | Pinned Elasticsearch guarded alias failure, dropped acknowledgment, real process kill after alias mutation and post-fence deletion |
| 3.5 | Operator Rake smoke, status/retry fields, safe notifications, cancellation and dry-run/active/leased cleanup tests |
| 4.1 | Pipe-synchronized process recovery against loopback PostgreSQL/pgvector and Elasticsearch |
| 4.2 | Final 1,000/10,000-document samples, matched source hash, offline 1,536-dimensional vectors and recorded resource bounds |
| 4.3–4.4 | Installed-gem direct/delegated/relocated positives and structural-pass/behavior-fail controls; both adoption roots and protected receipts |
| 5.1 | Existing independent recipe CI invokes the locally replayed `bin/verify`, including three-page and process recovery tests |
| 5.2–5.4 | Runbook/evidence, reconciled recipe Spec Kit artifacts, full local acceptance, strict specification validation and verified archive |

No production identity, high-load certification, live provider quality, hosted CI or
productivity improvement is claimed. The original agent pilot remains unchanged.
