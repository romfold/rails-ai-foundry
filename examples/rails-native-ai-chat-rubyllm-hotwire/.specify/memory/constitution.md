# Chat principles

Keep tenant ownership in application code. Use native Rails, RubyLLM and Turbo APIs.
Keep external models optional; normal tests are offline. Preserve completed history and identify failures.
Architecture is authoritative in [config](../../config/foundry.yml) and [conversations](../../packs/conversations/foundry.yml).
Maintain the behavioral contract and reconcile plans/tasks as requirements change.
