# Spec Kit integration

Foundry tests Specify CLI 1.0.0. Use its installed agent skills and bundled templates; do not recreate or fork upstream templates. Its supported flow is constitution, specify, plan, tasks, implement, and converge. Clarify and analyze are available when useful. Inspect installed help before assuming commands from a newer release.

The constitution records general principles and references to application configuration. Specifications own behavior and acceptance criteria, not another package inventory or dependency graph.

Foundry recommends living behavioral specifications: when requirements change, update their contract, reconcile implementation plans and tasks, and use converge to assess remaining work. This persistence convention is a Foundry recommendation, not an upstream universal requirement. Verify resulting behavior with application tests; converge is an agent workflow, not a deterministic equivalent of OpenSpec validation.

Setup is `foundry setup --specs=spec-kit`. Tool installation requires Python 3.11+ and uv or pipx, confined to development tooling. Neither Python nor Specify belongs in the Rails production dependency set. Switching selections preserves other specifications and does not convert their history.
