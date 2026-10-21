## Why

Foundry has verified synthetic adoption journeys but lacks evidence from an independently developed application. Campfire exercises existing SQLite search, Rails delivery, and a pinned edge Rails dependency without requiring a replacement architecture.

## What Changes

- Adopt the built gem in an isolated Campfire branch based on d2155e85a01b8439c32a3604ebb7f39fea1ace0f.
- Extract Search delivery into one Rails-native pack while preserving authorization, URLs, history, indexing, and rendering.
- Execute installed package-aware verification and negative controls, then record attributable adoption evidence and rollback instructions.
- Repair only reproducible Foundry defects exposed by acceptance, with focused regression coverage.
- Continue extraction despite the recorded pre-existing zero-test baseline, as explicitly authorized. Preserve every existing locked dependency and the test harness; keep behavioral acceptance incomplete rather than adding compatibility work.
- Add a separate real-browser comparison against identical synthetic data, with a deliberate visibility-bypass control. Keep frozen dependencies and blocked automated acceptance unchanged.

## Capabilities

### New Capabilities
- `campfire-adoption`: reproducible real-application adoption with behavior preservation and explicit compatibility evidence.

### Modified Capabilities
None initially; any demonstrated product defect will be reconciled with its existing contract.

## Impact

Campfire remains a separate MIT-licensed application with its existing lock, SQLite, Resque, Redis and Hotwire. Foundry retains eight skills and twelve catalog applications. No production runtime, data migration, publication, hosted CI or agent study is introduced.
