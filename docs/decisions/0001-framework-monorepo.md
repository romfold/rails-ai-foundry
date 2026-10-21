# 0001: Framework monorepo and spec-driven foundation

- Status: Accepted
- Date: 2026-09-05

## Context

The project starts without application code. The intended audience needs reusable Rails conventions, AI guidance, examples, and an eventual path for existing applications. The supplied research offers broader possibilities than can be responsibly shipped in the first milestone.

## Decision

Develop Rails AI Foundry as a framework monorepo. The root will contain the reusable Ruby gem when implemented, with supporting templates, skills, documents, and executable examples introduced incrementally.

Begin with English project documentation and a local, pinned OpenSpec workflow using shared agent skills. Use Conventional Commits as a documented contributor convention. Complete and archive the foundation; keep the architecture-core implementation as a separate active proposal.

Separate framework development configuration from the architecture manifests owned by applications that will use the framework. Adopt research as context and select capabilities through explicit specifications.

## Alternatives considered

- A cloneable Rails starter application would provide an immediate app, but would make reusable framework and adoption work secondary.
- A gem-only repository would simplify the initial layout, but separate the eventual playbooks and examples from the framework changes they explain and exercise.
- Implementing the full research vision immediately would create too many unverified interfaces and integrations before the core is tested.

## Consequences

The first milestone contains no working Rails runtime. Future work must prove each capability with appropriate tests and examples. Shared documentation can evolve with the gem, while each example remains clearly identified as a consumer application.

Licensing, publishing, Ruby/Rails support versions, and advanced architecture capabilities remain deferred. This record accepts the product organization and development workflow, not every architectural recommendation in the research.
