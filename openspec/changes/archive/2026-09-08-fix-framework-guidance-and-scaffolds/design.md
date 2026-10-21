## Context

Setup currently matches a conventional Application declaration twice using a parser and regex. Runtime preparation replaces containers but has no reset API. Command inherits a transaction-wrapped steps implementation, yet its template only raises. Existing exact check and rebuild tasks lack explicit command specifications.

## Goals / Non-Goals

**Goals:** Make the existing contracts explicit, preserve conservative file editing, isolate Foundry runtime references, and correct current guidance using verifiable history.

**Non-Goals:** Broader accepted Ruby class shapes, rewriting generated applications, tracking persistence changes, altered partial-write cleanup, or event-semantic changes.

## Decisions

- Use parser nodes and source locations to identify the single accepted conventional Application subclass. Derive insertion from its header range in the original source, preserving comments and LF/CRLF. Reject ambiguous declarations, dynamic superclass expressions and noncanonical existing Foundry settings. Retain source/identity verification and tracked publication unchanged.
- Runtime.reset! clears only @containers and @events, and preparation starts from that reset state. Tests perform successive composition/reload cycles and ensure unrelated state remains.
- ExecutionStore documents the optional store port via methods; NullStore implements no-op behavior. Tracker selection remains duck typed. No mandatory mixin or new dependency is introduced.
- New command template uses steps with step on an application-owned placeholder method. Existing receipt-based repeat handling remains unchanged; installed-template tests continue exercising real Rails application generation.
- Duplicate keys remain rejected by the custom object builder on JSON versions that allow parsing them, and by strict parsing where the JSON parser rejects earlier. Detect relevant parser capability without globally suppressing warnings or allowing duplicate keys.
- Document exact existing commands in a new capability before archive, add the scaffold requirement to domain conventions, and update current documentation separately from preserved archived artifacts. ADR notes include the date and Git commit establishing supersession.

## Risks / Trade-offs

- Parser ranges and original line endings can diverge; test LF, CRLF, comments and Unicode before/after insertion plus rejection cases.
- Resetting third-party globals could affect consumers; only replace Foundry's own references, with explicit unrelated-state assertions.
- JSON behavior varies by version; run isolated parser-version subprocess tests and retain fail-closed behavior.

## Migration Plan

Implement after the internal-model refactor is verified. No existing application files or data are migrated. Run focused source-edit/runtime tests, core/AI acceptance, real installed-template execution, lint, skills and strict OpenSpec checks before archive.
