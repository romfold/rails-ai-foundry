# Prompt contracts

`bundle exec foundry check --prompts --format=json` validates explicit contracts without booting Rails, resolving constants, evaluating templates or contacting providers. Combine --prompts with --sources and/or --boundaries; failure of any selected check fails the command. --prompts is supported by check only. Without it, ordinary configuration checking retains its scope.

New agent prompts default to the owning pack. Application-shell prompts remain possible for cross-context delivery. Each contract lives at app/prompts/.../contract.yml inside its owner:

```yaml
schema: 1
owner: packs/support
agent: Support::SummarizeAgent
templates:
  - instructions.txt
inputs:
  user_message: untrusted
  tool_result: untrusted
output_schema: Support::SummarizeSchema
tools:
  - Support::SummarizeTool
evaluations:
  - evaluation.yml
# Optional application-owned alias; runtime selection remains in config/ai.yml.
model_alias: support
authorization: Application policy runs before each tool operation.
acceptance:
  - Denied access never invokes the operation.
```

The fields through evaluations are required. Owner is the deepest upstream-discovered package path or `.` for the application shell/root package; the contract must reside under that owner's prompt root. Packages do not need foundry.yml for checking. Only the owning package's explicit configuration constrains the agent namespace; unconfigured children inherit no namespace or AI capability. Valid constant syntax remains required. Template/evaluation references are nonempty arrays of relative filenames beneath the contract directory; missing or unreadable files, symlinks, absolute paths, dot traversal and references crossing a nested package boundary fail. Inputs map names to trusted/untrusted. Tools is an array of constant names and can be empty; output_schema can be null for plain text. Model alias, authorization text and acceptance strings are optional. Unknown contract fields, duplicate YAML keys and unsupported schemas fail.

Discovery uses the upstream package inventory and inspects application and every discovered package app/prompts root, including custom, nested and root packages without foundry.yml. Explicit contract.yml files and instructions.txt/instructions.txt.erb files are checked; instructions without an adjacent contract fail. Arbitrarily named prompt files need an explicit contract. Other directories remain outside the check. Nested packages are inspected only through their own prompt roots, and each contract is counted once. Invalid discovery, unsafe paths and failed directory inspection stop the command without falling back to shell-only checking. Contract errors retain prompt.contract diagnostics; enumeration errors use the command error channel before a report is published.

The prompt.contract diagnostic reports the contract path, line 1, error severity and detected certainty. Line 1 denotes contract-level validation, not an exact YAML token. JSON reports add a prompts object with success, files_checked, diagnostics and limitations. The checker verifies declarations/file existence only: aliases and constants need application tests; evaluation files are never executed or interpreted as proof. files_checked counts attempted contract validations, including missing contracts required by conventional instructions. A zero count establishes no AI coverage. Broader discovery can expose previously omitted violations; review and fix ownership/contracts explicitly rather than adding configuration merely to satisfy checking. Generated evaluation.yml is a starting behavioral case to extend, not a model-quality score.

Keep user/tool content out of trusted instructions and enforce tenant authorization in application code. Missing files fail generated agent construction before provider calls. Live evaluation remains separate, explicitly activated and budgeted.

Prompt checking never changes generators or application artifacts. Optional agent scaffolding still requires an explicitly configured RubyLLM context. Preserve existing prompt placement and receipts; reviewed skill upgrades update guidance, not application AI behavior. Local path checks do not guarantee safety against hostile concurrent filesystem replacement.
