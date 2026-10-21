# Supplied repository metadata

The user supplied `https://github.com/romfold/rails-ai-foundry` after the initial October
candidate. Commit `7a484c6ee0137cd011e810367084d3f7e29a0e76` adds the homepage, source,
documentation, changelog and issue links, adopts the requested skills-focused summary,
and updates current release guidance. No dependencies, runtime code, tests or skills changed.

[Artifact provenance](artifact.json) records the rebuilt gem, metadata and all 172 packaged
resource hashes. SHA-256:
`c7483c1002d4a6b8e5df528a90e8266c14a32aae9e21ff62bd2b0c09571ab238`.
The local handoff is `pkg/release-candidate-1.0-repository/rails_ai_foundry-1.0.0.gem`, with
`SHA256SUMS` and `artifact.json` alongside it. The previous candidate and its
[acceptance record](../release-candidate/README.md) remain unchanged historical evidence.
Only `ROADMAP.md` and `docs/release-preparation.md` differ in the packaged resources;
the gemspec metadata changes separately. All 33 tracked and ten local compatibility
lock hashes remain unchanged.

## Verification

Commands use managed Ruby 3.4.10 and Node 20.19.0. `$TMP` denotes the disposable
metadata-verification directory, and `$CANDIDATE` its extracted source. Commands that
require the repository's pinned Node tools run in the checkout.

```sh
PATH="$HOME/.asdf/installs/ruby/3.4.10/bin:$HOME/.asdf/installs/nodejs/20.19.0/bin:$PATH"
RUBOCOP_CACHE_ROOT="$TMP/rubocop" bundle exec rubocop rails_ai_foundry.gemspec
bundle exec rake test
ruby script/validate_skills
npm run contracts:validate
npm run spec:validate
ruby script/privacy_check.rb
git archive 7a484c6ee0137cd011e810367084d3f7e29a0e76 | tar -x -C "$CANDIDATE"
cd "$CANDIDATE"
SOURCE_DATE_EPOCH=315619200 gem build rails_ai_foundry.gemspec
BUNDLE_FROZEN=true bundle exec ruby -Itest -Ilib test/distribution_integrity_test.rb
gem install --local "$CANDIDATE/rails_ai_foundry-1.0.0.gem" --install-dir "$TMP/installed" --ignore-dependencies --no-document
```

- RuboCop: one changed Ruby file, no offenses.
- Core: 273 tests / 2,734 assertions; no failures, errors or skips.
- Distribution: 2 tests / 767 assertions in both checkout and committed archive; includes
  synthetic contamination controls and installed local-link availability.
- Contracts: 10 tests / 142 assertions; eight schemas / 73 cases.
- Skills: six development / eight product. Strict OpenSpec: 41 passing items.
- Privacy: zero findings. The gem's extracted bytes match all 172 source inventory entries.
- Actual rebuilt gem: installed outside the checkout with dependency installation disabled;
  existing installed dependencies supplied the load path. A plain Ruby process verified the
  installed location, version 1.0.0, homepage and four metadata URLs.

A preliminary working-tree build also succeeded; the distributed artifact is the separate
clean Git-archive build. The open-ended railties warning remains intentional; the missing
homepage warning is resolved. Git index writes initially failed under the filesystem
sandbox; retrying with local repository-write permission succeeded.

## Remote availability and release hold

The web reader could not fetch the new repository. Sandboxed curl failed DNS; a network-enabled
retry of `curl --location --head --max-time 20 https://github.com/romfold/rails-ai-foundry`
returned HTTP 200. Separate GET status checks of `/blob/main/README.md` and
`/blob/main/CHANGELOG.md` returned HTTP 404. These links identify the intended main-branch
files; their remote contents are not yet verified. Source must be pushed and links rechecked
before public distribution. No remote configuration or source push occurred in this scope.

Hosted CI remains skipped. RubyGems access/name ownership has not been verified. No tag,
registry upload, provider call or agent trial ran. Publication still requires the user's
explicit readiness. Earlier compatibility/browser/service evidence retains its original
candidate attribution; this metadata-only follow-up does not claim those lanes reran.
