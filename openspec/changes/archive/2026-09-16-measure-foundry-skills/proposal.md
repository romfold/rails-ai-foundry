## Why

Existing runtime samples and offline evaluation recipes do not measure whether Foundry's
skills improve coding-agent outcomes. The approved program calls for a controlled,
reproducible benchmark and an explicitly bounded local pilot with independently graded behavior.

## What Changes

- Add contributor-only preparation, execution, grading and reporting tools under benchmarks/.
- Freeze six knowledge tasks with visible tests, withheld acceptance, reference solutions and
  deliberately faulty controls across plain Rails, packs/Packwerk and packs/Foundry groups.
- Isolate candidates from evaluator/reference files, other trials and this repository;
  grade final candidate copies independently and record failures without replacement trials.
- Run the authorized eighteen serial local Cursor CLI trials: boundary extraction and stale
  embedding repair, three groups, three repetitions, Composer 2.5 (composer-2.5), without a separately configurable reasoning effort, ten minutes per trial
  and three hours total. Stop on authentication/quota failure without resets or substitutions.
- Record exact hashes, versions, diffs, events, usage, duration, interventions and limits;
  make only demonstrated guidance fixes and distinguish later fixes from measured revisions.

## Capabilities

### New Capabilities

- `skill-benchmark`: Reproducible tasks, isolated grading controls and bounded local pilot evidence.

### Modified Capabilities

None. Existing evaluation requirements remain in force; this change implements a new contributor surface.

## Impact

Contributor-only benchmarks, isolated runtime images and offline CI grading. Existing CLI,
production dependencies, eight skill identities and twelve-example catalog remain unchanged.
Existing local Cursor browser authentication is the only permitted pilot model access; application
AI providers remain deterministic. Publication, deployment and broad productivity claims are excluded.
