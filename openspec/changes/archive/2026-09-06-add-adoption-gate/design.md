## Context

See proposal.md. Assessment already emits structured dependency/privacy findings and separate fatal diagnostics. Strict check commands do not consume baselines.

## Goals / Non-Goals

Provide exact, reviewed debt comparison without changing strict validation or executing migration actions.

## Decisions

Use a standalone version-1 JSON object with version and entries only. Each entry has rule, file, constant, target_owner, count, and rationale. Group findings by the four identity fields, excluding line numbers; require positive integer counts and nonblank review rationale. Draft rationales are empty. Reject duplicate JSON keys, duplicate identities, unknown fields, unsafe paths, and wildcards.

Read the explicitly selected baseline as a regular file inside the assessed root. Compare counts exactly: increases identify new occurrences; decreases require reviewed pruning. No command automatically accepts or updates debt. Root ownership is the same dot identifier used by assessment. Fatal analysis failures cannot become exemptions.

## Risks / Trade-offs

Line-independent identity avoids churn but cannot distinguish replacement of one reference by another with the same identity/count. Developers still review diffs and runtime behavior. Source moves require deliberate baseline review. Human rationale quality cannot be proven mechanically.
