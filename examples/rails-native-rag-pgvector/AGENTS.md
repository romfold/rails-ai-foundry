# Tenant-scoped retrieval and evidence answers

Run commands from this application directory with its own Gemfile.lock.
Read config/foundry.yml, packs/knowledge/foundry.yml and package.yml before editing.
This application uses pinned Spec Kit 1.0.0. Read specs/001-rag-flagship/spec.md, plan.md,
tasks.md and reconciliation.md; update the living contract when behavior changes.
Use the installed upstream skills for constitution, specification, plan, tasks,
implementation and converge. Do not inherit the parent repository's OpenSpec workflow.

Start disposable services with `docker compose up -d --wait`, then run `bin/setup`,
`bin/verify` and `bundle exec rubocop`. A Spec Kit prerequisite check is not a behavioral validator.
Never send model requests during normal tests. Keep all feature-owned delivery and behavior
inside its pack, with Rails base classes and migrations at root.
