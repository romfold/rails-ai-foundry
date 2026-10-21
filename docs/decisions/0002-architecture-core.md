# 0002: Structural architecture core and compatibility

- Status: Accepted
- Date: 2026-09-05

## Decision

Implement the root gem as a Railtie plus plain Ruby validation components. Use one versioned application manifest as the package source of truth, with derived domain/platform paths and explicit agreement with package metadata. Keep installation separate from read-only structural validation.

Choose Ruby >= 3.0 and railties >= 7.1 as compatibility floors, Ruby 3.4.10 for development, and MIT licensing with copyright 2026 romfold. This resolves the compatibility and license deferrals in decision 0001 without rewriting its historical record.

## Rationale and consequences

A Railtie supplies tasks without introducing an Engine or application runtime. An explicit data-only manifest makes configuration errors diagnosable without loading package Ruby. Structural validation remains useful before autoload integration or Packwerk enforcement, but cannot claim those capabilities.

Newer Rails releases impose their own Ruby minimums. Separate test Gemfiles avoid coupling older compatibility runs to the development lockfile. See [compatibility evidence](../compatibility.md).

Conservative installation preserves compatible user content and reports conflicts. It cannot provide an atomic transaction across several files. Publishing, AI integration, privacy enforcement, and package autoloading require later work.

## Supersession note — 2026-09-08

The historical Ruby floors above were superseded on 2026-09-06 by commit `b2ef134` and [decision 0007](0007-progressive-package-profiles.md): core and optional AI now require Ruby >= 3.3, with railties >= 7.1 unchanged. This note preserves the original milestone rationale; current compatibility evidence belongs in [the compatibility guide](../compatibility.md).
