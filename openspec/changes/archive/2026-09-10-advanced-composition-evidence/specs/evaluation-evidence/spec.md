## Purpose

Make evaluation and performance claims reproducible, bounded and distinct from workflow completion.

## ADDED Requirements

### Requirement: Bounded evaluations
Offline evaluations SHALL report behavioral quality using deterministic cases. Live evaluations SHALL require explicit activation, credentials, model, request, token, time and spend limits, stop on exhausted or unknown usage budgets, and record actual usage separately from estimates without claiming a guaranteed billing cap.

#### Scenario: Missing activation
- **WHEN** live evaluation lacks any required activation or budget input
- **THEN** it fails before making a provider request

### Requirement: Controlled benchmarks
Benchmarks SHALL compare vanilla Rails and Foundry with matched agent, model and specification-workflow conditions, repeated measurements, held-out behavioral tests and raw results. Architecture measurements SHALL be reported separately from complete onboarding comparisons and SHALL not imply production throughput or agent productivity from synthetic results.

#### Scenario: Behavior mismatch
- **WHEN** a measured implementation fails held-out behavior
- **THEN** the benchmark rejects the comparison instead of reporting a speed win
