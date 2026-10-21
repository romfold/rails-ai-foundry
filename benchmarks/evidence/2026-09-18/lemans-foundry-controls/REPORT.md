# Foundry Le Mans offline control acceptance

All 45 controls retain their expected outcomes through native Le Mans and fresh
verification: 24 valid implementations pass; 21 faulty implementations fail actual
behavioral assertions. There are no native/independent disagreements, invalid
protocol outcomes or infrastructure errors in the selected set.

The first native run had three infrastructure errors because the private-coupling
faults intentionally produce empty diffs. Their corrected preparation uses Le Mans'
native `solution/solve.sh` with a no-op body. Only those three controls were replayed.
`selection.json` identifies the original sources and correction. Originals remain
unchanged outside the repository; they were not converted into behavioral failures.

The fresh verifier ran in disposable Docker containers without network, credentials,
capabilities or writable evaluator assets. `isolation.json` records the separate
candidate and grader probes. `historical-pilot-hashes.json` confirms that all 345
tracked historical pilot files match the pre-migration Git revision byte-for-byte.

A subsequent integrity test exposed that `git apply --allow-empty` accepts arbitrary
non-patch text. Verification now uses it only for a zero-byte patch. The corrected
process controls pass: seven tests, 21 assertions, covering skipped checks, disabled
assertions, forged summaries, protected edits, added/deleted files, absent/corrupt
patches and redacted non-replayable patches. The 45-control summary records the
verifier revision actually used; it has not been rewritten to imply later code ran.
All 21 negative controls were additionally inspected for actual assertion failures.

Conditions: managed Ruby 3.4.10; pinned Le Mans 1.3.5; Docker Desktop Linux ARM64,
two CPUs and approximately 5.8 GiB total engine memory; independent graders limited
to two CPUs, 2 GiB and 256 processes. Provider usage is zero: these are oracle/fault
controls, not coding-agent trials or productivity measurements.

**The complete upstream migration remains pending.** This report accepts only the
Foundry control parity gate. It does not authorize removal of the old runner,
archiving the OpenSpec change, publishing or additional agent trials. The original
Cursor pilot and its separately attributed grader correction are unchanged.
