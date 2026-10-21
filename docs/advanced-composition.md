# Advanced composition and evidence

Foundry 0.5 adds optional executable recipes and development evidence tools. Applications still execute ordinary Rails and upstream code. Profiles, event/CQRS choices and capabilities remain independent; selecting ROM, DI or a vector provider does not silently change architecture.

| Capability | Entry point | Evidence tier |
| --- | --- | --- |
| ROM atomic outbox, constructor/DI wiring, native workflow alternative | [Composition recipe](../recipes/advanced-composition/README.md "Repository-only reference; not installed") | Advanced, real PostgreSQL acceptance |
| Pinecone and Weaviate | [Experimental vectors](../recipes/experimental-vectors/README.md "Repository-only reference; not installed") | Experimental; Pinecone contracts and local Weaviate service |
| Debt inventory/audit and pks parity | [Adoption](adoption.md) | Packwerk remains authoritative; application-specific comparison |
| Offline scoring, bounded live runner and controlled benchmarks | [Evidence recipe](../recipes/evidence/README.md "Repository-only reference; not installed") | Offline checks and actual runtime samples; live/agent claims require separate runs |

Recipe bundles live outside the twelve-app catalog and core dependency graph. Their independent CI lanes install locked optional dependencies; the core Ruby 3.3/Rails 7.1 floor remains unchanged. See [compatibility](compatibility.md) for exact local results and known constraints.

The [integrated knowledge application](../recipes/domain-knowledge-rag-rom-res-elasticsearch-pgvector/README.md "Repository-only reference; not installed") now verifies ROM + RES + Elasticsearch + RubyLLM + pgvector together. The [adoption walkthrough](../recipes/knowledge-adoption/README.md "Repository-only reference; not installed") demonstrates the same domain incrementally, starting with ordinary Rails and Active Record. Their independent bundles and recorded acceptance remain separate from runtime or coding-agent benchmark claims.
