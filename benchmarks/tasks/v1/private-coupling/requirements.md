# Repair private cross-context coupling

Repair Answering::RetrievalTool so it calls the public Knowledge::Catalog API rather than Knowledge::Document or another internal persistence object. Preserve query substring matching, ordering, authorization, trusted tenant identity and exclusion of drafts. Keep existing signatures. For package-enabled apps preserve enforced privacy/dependencies, declare only required public dependencies, and pass upstream Packwerk checks without baselines or disabling rules. Plain Rails requires the same source-level public API boundary and behavior.

Do not change dependency versions, visible tests, task instructions or disable verification. Add focused tests for your changes. Normal tests remain offline.
