# Optional recipes and evidence

These are independently bundled, development-time recipes, separate from the twelve Rails applications in examples/catalog.yml. Copy the relevant application-owned code and its tested dependency constraints deliberately; constructor injection and ordinary Rails remain defaults.

- [Advanced composition](advanced-composition/README.md): ROM/PostgreSQL atomic outbox, dry-system wiring, native Trailblazer alternative.
- [Experimental vectors](experimental-vectors/README.md): Pinecone protocol contracts and local Weaviate acceptance.
- [Evaluation and benchmark evidence](evidence/README.md): offline scoring, budgeted opt-in RubyLLM evaluation, paired runtime measurements and onboarding protocol.
- [Experimental FlowNodes branching](flow-nodes-branching/README.md): native graph branches, bounded retry/interruption and explicit effect semantics.
- [Experimental Langchainrb adoption](langchainrb-adoption/README.md): native assistant lifecycle, authorized tools and application-owned history without RubyLLM.

Use each recipe's own Gemfile.lock with Bundler 2.6.9. Ruby 3.4.10 is the verified recipe lane; core floors remain Ruby 3.3 and Rails 7.1. These files are repository examples, not a Foundry application runtime or automatically installed gem components.
