## Context

Version 1 has strict fields, fixed package roots, and arbitrary immediate app subdirectories registered as Object roots. Installation and scaffold publication already preserve user edits.

## Goals / Non-Goals

Define the shared profile and path contract. Event runtimes, component generators, and promotion belong to subsequent bounded changes.

## Decisions

Retain v1 parsing and generation rather than silently upgrading. Fresh installation uses v2; package entries explicitly name profiles. A shared immutable registry defines supported component categories and root names. Paths preserve the full namespace using ordinary Rails mapping, including application/domain and category names; no collapsed directories. Foundation validation is static and separate from existing structural guarantees. Runtime loading rejects invalid profile roots when enabled. Raise the Ruby floor to 3.3 as explicitly approved; retain railties 7.1.

## Risks / Trade-offs

Strict profile paths may reject custom layouts: legacy mode remains available for existing consumers. Static paths do not prove behavioral layering: later changes add reference rules and runtime tests. The profile registry describes conventions before all runtimes are delivered; guidance must distinguish foundation from complete profile support.

## Migration Plan

Keep v1 files byte-for-byte on repeat installation. Do not auto-promote. Maintain minimum/current/newer compatibility lanes and record actual evidence.
