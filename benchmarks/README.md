# Contributor benchmarks

Foundry uses pinned **Le Mans** for native agent execution and standard reporting.
Ruby contributor tooling prepares suites, verifies captured patches independently,
checks offline controls and summarizes immutable evidence. It is outside Foundry's
production dependencies and CLI.

Read [the Le Mans workflow](LEMANS.md) for installation, commands, Docker isolation,
local overrides and evidence rules. Checked-in defaults select offline oracle/no-op
controls and no live model. Future coding-agent studies require separate authorization.

## Separate suites

- **Upstream Rails:** the complete pinned AI-evals corpus, with 21 atomic tasks,
  20 feature tasks and one separately reported smoke task. It measures upstream
  capability; local environment validation does not reproduce the Rails leaderboard.
- **Foundry:** six frozen tasks across plain Rails, packs/Packwerk and Foundry,
  using workflow `none`. Identical business requirements and independent grading
  separate shared correctness from package checks. The 45 controls include delegated
  and relocated valid implementations and deliberately faulty behavior.

[Full migration evidence](evidence/2026-09-19/lemans-upstream-controls/REPORT.md)
records all 84 accepted upstream controls, all earlier failed attempts and corrections.
[Foundry parity evidence](evidence/2026-09-18/lemans-foundry-controls/REPORT.md)
records 24 valid and 21 faulty controls. No new coding-agent trials ran in this migration.

## Authorized OpenRouter study

The [GPT-5.6 Luna study guide](OPENROUTER_STUDY.md) documents the separately authorized
ten-attempt, $7-allocation experiment, terminal-only key setup and non-executing preflight.
The [completed study report](evidence/2026-09-19/openrouter-luna-study/REPORT.md) records
all ten attempts, independent outcomes and $0.12507726 provider-confirmed spend.
The study authorization is exhausted; further attempts require separate authorization.

The separately authorized [post-repair rerun](evidence/2026-09-21/openrouter-luna-study/REPORT.md)
completed ten fresh attempts at `13cc872`: nine passed, one failed, and provider-confirmed
spend was $0.11535134. Foundry boundary extraction recovered through actionable checker
errors and passed; the unchanged upstream live-reaction task still failed. Both graders
agreed on every result. This rerun is complete and authorizes no further attempts.

The next authorized [repeatability study](evidence/2026-09-21/openrouter-luna-repeatability-study/REPORT.md)
stopped after seven attempts: five passed, one failed package privacy policy, and one
edited a protected test file. Independent verification rejected that native pass;
the frozen preflight blocked the three remaining upstream tasks. Provider-confirmed
spend was $0.05949285. Task/profile hashes and shipped gem payload matched the prior
study; this run does not measure adoption of the offline repair.

The subsequent [offline repairs and protocol hardening](evidence/2026-09-21/repeatability-repairs/REPORT.md)
passed ten task controls using five saved candidates, two repaired candidates and
three upstream references. The original privacy/protocol failures remain negative
controls. Guidance now clarifies enforcement and protected tests; new studies can
continue after fully diagnosed isolated protocol violations without awarding credit.
These controls are not a new ten-trial agent score.

The separately authorized [guidance study](evidence/2026-09-21/openrouter-luna-guidance-study/REPORT.md)
ran ten fresh trials at `ce57b26`: nine passed and the unchanged upstream live-reaction
task failed, with both graders agreeing. All six Foundry comparisons passed without
protocol violations. Provider-confirmed spend was $0.12277142. Foundry-suite inputs
changed from the prior run; this single sample does not establish a causal improvement.
The study is complete and authorizes no additional attempts.

The separately authorized [study after realtime guidance](evidence/2026-09-22/openrouter-luna-realtime-guidance-study/REPORT.md)
ran ten fresh attempts at `545e12f`: eight passed, one failed the required modular
profile, and one could not be independently graded because its migration remained
pending before baseline tests. Native Le Mans records eight passes and two failures;
the independent infrastructure error remains distinct. Provider-confirmed spend was
$0.13908446. The unchanged upstream realtime task receives no Foundry skills, so this
run does not measure the new realtime guidance's effect. No retries or repairs ran.

The [package-intent study](evidence/2026-09-22/openrouter-luna-package-intent-study/REPORT.md)
ran ten fresh attempts at `8188992`: nine native passes and one failure, with nine
independent passes and one infrastructure error. All six comparison cells passed;
the Foundry boundary agent selected the required modular profile. Provider-confirmed
spend was $0.13146371.

The separately labeled [Foundry-guided realtime treatments](evidence/2026-09-22/foundry-guided-realtime-study/REPORT.md)
install all eight skills in the unchanged upstream application. The first attempt
failed two browser requirements. After generic verification guidance changed at
`b545b6d`, the second agent read the revised instructions but omitted browser checks
and submitted a broken association. Both native and independent graders rejected
both attempts. Their combined cost was $0.06611021, bringing the shared cycle to
$0.19757392 of its $7 stopping budget. These results preserve the earlier cohort's
score and leave ten-of-ten acceptance unmet; no candidate was manually repaired.

## Offline candidate repairs

[Repair fixtures and reproduction](repairs/README.md) preserve separate incremental and
complete patches for the two failed saved candidates. The [repair report](evidence/2026-09-19/study-repairs/REPORT.md)
records independent human-assisted regression evidence, original negative controls and
intentionally faulty variants. These results do not revise the original study's scores.

The [second study's realtime repair](evidence/2026-09-21/second-study-repair/REPORT.md)
has its own dated fixture selection, exact-record authorization checks and separate
fresh-container evidence. Its paid result remains nine passes and one failure.

The [guidance-study repair](evidence/2026-09-21/guidance-study-repair/REPORT.md)
records the later candidate's callback collision and malformed deletion form, its
separate repair, and six isolated fault controls. Existing skills now explicitly
route realtime work to generic callback, rendered-form and actor/viewer verification
guidance. Offline repairs do not change any paid result or predict a future score.

## Historical studies

The [Cursor Composer 2.5 pilot](evidence/2026-09-16/pilot-cursor-composer-2.5/OUTCOME.md)
ran at `fde15a8a36c15fe648f31b5aa56f002d6883232b`. Its original grades, raw evidence
and separately attributed grader correction remain unchanged. Earlier Codex
[startup results](evidence/2026-09-16/pilot-0.142.5/REPORT.md) and
[Spark outcome](evidence/2026-09-16/pilot-spark-0.154.0/OUTCOME.md) remain historical.

The retired Python runner and its documentation are available at
`d6fa504d0140888c02010988e6127ed7fd3e2769`. Use an isolated checkout of that revision
when inspecting historical execution; the current repository provides no old-command
wrapper, agent installer or authentication bridge. Historical reproduction instructions
are not authorization to rerun a pilot or spend provider credits.

The catalog retains eight product skills and twelve applications. Hosted release CI
still awaits a repository destination; offline control jobs do not authorize publication.
