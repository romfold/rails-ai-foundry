# Repository privacy review — 2026-09-23

The working-tree review removed personal workstation home paths, the local account
name and macOS per-user temporary directory identifiers from 164 tracked files.
Documentation commands now use `$HOME`; recorded machine paths use
`/redacted/home` and `/tmp/redacted`. These placeholders are not replay locations.

Benchmark evidence was sanitized at the owner's request. Trial grades, model
choices, timings, token counts and previously recorded provenance hashes remain
unchanged. The affected artifacts are no longer byte-identical to their originals.
[The redaction manifest](privacy-sanitization.json) records original and sanitized
SHA-256 digests for each modified artifact. Original digests continue to describe
the original inputs; do not interpret them as checksums of sanitized copies or
recompute historical trial identities from those copies.

The review scanned 4,431 non-ignored text files and inspected tracked text for personal paths, account names, email
addresses, private-key headers, common provider/access token formats, JWTs,
authorization headers, credential assignments and authentication callback URLs.
It also checked tracked sensitive filenames and the untracked research and Cursor
planning files. Credential-field matches were explicit offline/test placeholders;
email matches were synthetic addresses or dependency filenames. No real credential
was identified by these checks. This is a pattern-based review, not proof that an
arbitrary secret cannot remain.

Application code, fixtures and behavioral outcomes were not changed. Local
dependency installations, ignored caches, external credential stores, Git history
and Git author metadata are outside this cleanup. Earlier commits can still
contain the removed identifiers. History removal requires a separately reviewed
rewrite and coordination with any existing clones.

Before committing new evidence, review both filenames and contents. Prefer
repository-relative paths and portable environment variables in instructions.
Sanitize local identities and authentication material before capturing shared
logs; record any later evidence redaction explicitly. Never print a suspected
secret into a review log. Report its file and classification instead.

## Verification

- All 164 changes match only the documented substitutions; both manifest hashes were verified.
- All 157 modified JSON artifacts parse, with structure and non-string values unchanged.
- No original workstation identifier or common credential-format match remains in the scanned files.
- `bundle exec rake test`: 166 tests / 1,250 assertions, zero failures or errors.
- `bundle exec rubocop`: 754 files, no offenses.
- `ruby script/validate_skills`: six development and eight product skills passed.
- `npm run contracts:validate`: ten tests / 142 assertions; eight schemas / 73 cases passed.
- `npm run spec:validate`: 33 passed, zero failed.
- `git diff --check`: passed.
