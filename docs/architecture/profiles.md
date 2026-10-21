# Independent architecture settings

| Profile | Command example | Intent |
| --- | --- | --- |
| rails_native | app/operations/billing/charge.rb → Billing::Charge | Rails conventions with minimal structure |
| modular | app/commands/billing/charge.rb → Billing::Charge | Explicit package ownership and public boundaries |
| domain | app/application/billing/commands/charge.rb → Billing::Commands::Charge | Separate domain and application responsibilities where needed |

Paths are relative to the owning pack. Select events independently as none, integration or event_sourced; select CQRS as none, queries or read_model. Capabilities are explicit adapter selections. Workload is balanced, read_heavy, job_heavy, ingestion or realtime. Workflow is spec_kit, openspec or none. No setting silently changes another.

All profiles allow optimized persistence queries. Ports and repositories serve actual domain or integration boundaries, not mandatory object mapping. Event-sourced intent does not install a Foundry runtime or transform business data.

See [native contexts](../native-contexts.md) for executable commands and safe generation behavior.
