# Installation

Build the local gem with `gem build rails_ai_foundry.gemspec`, install it, then run `foundry new NAME`. In existing apps, put Foundry in development/test and keep packs-rails plus dry-operation in production dependencies. Ruby >= 3.3 and railties >= 7.1 are required. Optional RubyLLM belongs to the consuming app bundle.

See [native contexts](native-contexts.md), [native AI](native-ai.md) and [the implementation program](implementation-program.md) for detailed contracts and delivery status.
