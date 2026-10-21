## Purpose
Provide bounded offline evidence for optional branching workflows and adoption of an existing AI stack.

## ADDED Requirements

### Requirement: Independent experimental recipes
FlowNodes branching and Langchainrb adoption recipes SHALL own independent locked bundles outside the twelve-app catalog, offline acceptance and separate CI lanes. Branching acceptance SHALL cover retry, interruption, repeat and duplicate effects without claiming durability. Adoption SHALL make history, tools, retries and lifecycle explicit without requiring RubyLLM. Neither SHALL raise the core compatibility floor or introduce a universal AI abstraction.

#### Scenario: Run recipe acceptance
- **WHEN** a contributor runs either recipe's normal verification
- **THEN** no live provider request occurs and evidence states its dependency versions and behavioral limits
