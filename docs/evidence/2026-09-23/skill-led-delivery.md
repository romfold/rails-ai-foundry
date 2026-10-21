# Skill-led AI delivery and distribution acceptance

Local verification on 2026-09-23, Ruby 3.4.10 / Node 20.19.0, macOS arm64 and disposable
Linux arm64 Docker services. No coding-agent trials, provider credentials, external AI
actions, publishing, deployment or Git-history rewriting occurred. Hosted CI remains
pending a repository destination. Historical studies and their open acceptance remain unchanged.

## Distribution

`packaging/files.txt` defines exact gem contents. Building both a clean tree and a tree
contaminated with unrelated Markdown, research, `.env`, master-key and private-key files
produced the same archive inventory. The privacy JSON manifest is installed alongside its
report. Archive tests check required local Markdown links; repository-only references are
explicitly labeled. The contributor privacy scan reports file/line/category, never values.
It is a heuristic text scan, not credential validation or a Git-history/binary audit.

Commands (run from the repository root with managed Ruby/Node on PATH):

```sh
TMPDIR=/private/tmp bundle exec rake test
TMPDIR=/private/tmp bundle exec rake test:package
TMPDIR=/private/tmp BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai
TMPDIR=/private/tmp bundle exec rake test:workflows
bundle exec rubocop
npm run contracts:validate
ruby script/validate_skills
ruby script/privacy_check.rb
npm run spec:validate
```

Observed before final documentation reconciliation: core 169 tests / 1,950 assertions;
packaged 6 / 486; AI 8 / 60; workflow integrations 3 / 39; contracts 10 / 142 plus eight
schemas / 73 configuration/report cases; six development skills and eight product skills;
772 Ruby files clean; privacy zero findings. After archive reconciliation, the focused
distribution controls passed 2 tests / 633 assertions and strict OpenSpec passed 35 items. The workflow lane initially failed because
Spec Kit was absent. Installing the pinned v1.0.0 in a disposable Python 3.12 environment,
and selecting the locally pinned OpenSpec 1.12.0, made all integrations pass. No fallback
or skipped check was counted as success.

## Installed reviewed-AI journey

`test_journey/installed_ai_test.rb` builds and installs the gem, reads the installed guide
and replays its file/command blocks into empty consumers. It does not copy application
code from the checkout. `test/ai_journey_parity_test.rb` separately checks shipped snippets
against the canonical example, with explicit Gemfile/workflow/routes/style adaptations.
Tests reuse an installed dependency cache; fresh users first fetch dependencies with
`bundle install`. The guide contains all application and teaching-test source.

```sh
TMPDIR=/private/tmp PGPORT=55544 BUNDLE_VERSION=2.6.9 bundle exec rake test:journey
```

The local run used disposable PostgreSQL 17 and an explicitly prepared ChromeDriver 153.
Each package root runs the native application baseline (31 tests / 103 assertions), HTTP
(3 / 12), browser (3 / 23), two valid direct/delegated controls (15 / 45 each) and four
fault controls rejected by assertion failures with zero test errors. It also verifies
Rails loading, source/prompt checks, Packwerk, RuboCop and native production loading
without Foundry. The final replay passed 2 outer tests / 120 assertions in 164 seconds. Its independent
review checkpoint passed 15 tests / 45 assertions and recovery checkpoint 7 / 25 in each root.

Repeat skill installation preserves customized instructions, receipt bytes, accepted debt
and each of `none`, `openspec`, `spec_kit`; it does not initialize or convert workflow history.
Real queue/process tests cover lost scheduling, lease recovery, before/after-commit crashes,
competing decisions and one completed local effect. Browser checks cover escaped generated
text, permissions, revoked identity and unsaved input during bounded polling.

Friction corrected during replay: unrelated delegated `/answers` test excluded from this
review-only tutorial; UTF-8 reads made explicit; executable permission added to the control
script; checkpoints reorganized so review and recovery each have executable evidence.
These changes do not alter the canonical example's `/answers` contract or twelve-app catalog.
Automated replay proves reproducibility, not independent-user usability or agent improvement.

## Independent study preparation

See `benchmarks/reviewed-ai/README.md` for the versioned six-trial proposal and
`benchmarks/evidence/2026-09-23/reviewed-ai-preparation/` for the frozen offline acceptance.
The independent evaluator tests the adapted SupportDesk application, not the tutorial's
teaching tests. Direct/delegated valid controls and intentionally faulty controls are
prerequisites. Agent/model/version/access/spend remain unselected and require separate
approval. Usage and cost are unknown, not zero-price productivity claims.

Build/grader friction is retained separately from final acceptance: initial image builds
could not resolve a previously verified pure-Ruby dependency remotely; preparation now
uses the canonical lock's cached artifacts. Non-root logs moved to writable temporary
storage. A missing favicon caused a browser fixture error. The upstream-only group's
restore list was corrected to exclude absent Foundry-owned directories. None of these
infrastructure failures is evidence of agent or application performance.

Final study acceptance: 14/14 expected control outcomes, no infrastructure errors and
zero agent trials. Direct/delegated references pass in both groups; all four fault classes
fail assertions in both groups. Candidate/grader isolation passes. Contributor unit tests
pass 82 / 654. Frozen hashes, resolved Linux dependencies and per-control logs are retained.
