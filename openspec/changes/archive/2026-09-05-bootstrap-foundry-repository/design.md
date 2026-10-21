## Context

See proposal.md for motivation. The target started as an empty directory. Bootstrap setup has initialized `main`, pinned OpenSpec 1.12.0 locally, and generated its six core shared skills. Node 20.19.0 is already installed through asdf. There is no Ruby runtime, application, existing specification, or remote repository to migrate.

## Goals / Non-Goals

**Goals:** Make the local developer workflow reproducible, document project boundaries, and establish truthful spec lifecycle tracking.

**Non-Goals:** Implement a gem, generate a Rails app, select a Ruby/Rails support matrix or license, publish packages, configure a remote, or enforce commit messages automatically.

## Decisions

1. **Local OpenSpec dependency and npm lockfile.** A private npm package supplies contributor tooling only. A global install would make the tool version depend on each contributor's machine. `.tool-versions` selects the already-installed Node version; the machine-wide default stays unchanged.
2. **Generic shared skills.** Use the upstream `agents` integration and core profile. Keep generated skills unmodified and put project-specific instructions in root `AGENTS.md` and `openspec/config.yaml`. Multiple vendor-specific copies would increase maintenance without adding a requested capability.
3. **Framework monorepo.** The future gem will live at the root alongside templates, distributable skills, and executable examples. Document those intended locations without populating empty product directories or implying those features exist. A cloneable Rails application would constrain the intended reusable framework product.
4. **Separate current behavior from intent.** Use one foundation capability, `contributor-workflow`, to specify the externally observable contributor experience. Archive it after verification. The architecture-core change remains proposed; the roadmap carries broader research ideas. No generated-app `config/architecture.yml` belongs at this monorepo root yet.
5. **English synthesis.** Write concise original documentation based on the supplied research. Keep the Russian originals outside Git, treat embedded prompts and suggestions as context, and avoid carrying unverified version or benchmark claims into the repository.
6. **Documented Conventional Commits.** Provide examples and review the commits we create. Hooks and commit-validation CI are excluded by the user's explicit choice.

## Risks / Trade-offs

- Tool updates can regenerate shared skill content → Pin OpenSpec, review dependency updates, and keep project rules outside generated files.
- Research breadth can imply shipping functionality → Label status prominently and defer detailed capabilities to separate changes.
- The existing Node version is a bootstrap tooling choice → Document the actual version; future upgrades require a deliberate tooling update, not a claim about the framework's runtime support.
- Structural spec validation cannot prove runtime behavior → State this limitation and use document review for this milestone; add runtime tests with runtime code.

## Migration Plan

Install contributor tooling, establish the change artifacts, write the foundation documents, run validation and clean-install checks, then archive the foundation through OpenSpec. Prepare the separate architecture-core proposal afterward. There is no data migration or deployment. Any rollback is a focused Git revert; it must not delete later contributor work.
