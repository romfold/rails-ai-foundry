# 0011: Native conventions cutover

Date: 2026-09-09. Status: Accepted and implemented for 0.2.

Foundry had grown an application runtime alongside its development tooling. The approved product direction is a conventions kit, and the user confirmed that the 0.1 implementation has no consumers requiring compatibility. Keeping both execution models delayed the reset and gave agents conflicting guidance.

Remove the old manifest registry, loader, container, operation wrappers, transaction/event/projection runtimes, AI execution tracking, promotion machinery, obsolete fixtures and both old examples together. Use upstream package discovery and loading, native Rails transactions, direct operations and optional RubyLLM. Keep actionable migration evidence and a migration guide; provide no compatibility runtime or automatic business-data conversion.

Profiles, events, CQRS, capabilities, workload and specification workflow remain independent. New applications default to Spec Kit, adoption to OpenSpec, established workflows are preserved and none is valid. Foundry itself keeps OpenSpec. Workflows are setup integrations, not application execution dependencies.

The core acceptance boundary is native generated consumers, including built-gem installation and production execution without Foundry. The twelve standalone examples remain 0.3/0.4 delivery and do not gate removal of unused code. Later outbox, indexing, messaging, async and composition recipes need their own correctness evidence.

Earlier ADRs remain unchanged as historical records of 0.1; their runtime choices are superseded by this decision. Current specifications, configuration and the implementation program define current behavior and future scope. Publishing remains separate.
