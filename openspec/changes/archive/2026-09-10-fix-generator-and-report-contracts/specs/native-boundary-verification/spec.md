## ADDED Requirements

### Requirement: Locale-independent upstream report text
Boundary reports SHALL preserve valid UTF-8 upstream output independently of the caller's locale and replace invalid byte sequences with the Unicode replacement character. Encoding normalization SHALL NOT change command arguments, exit statuses or accepted debt.

#### Scenario: Non-ASCII output in the C locale
- **WHEN** upstream validation or checking emits Unicode under LC_ALL=C
- **THEN** the JSON report remains parseable and preserves the Unicode text and upstream status

#### Scenario: Invalid output bytes
- **WHEN** a successful or unsuccessful upstream command emits invalid UTF-8 bytes
- **THEN** report text contains replacement characters and the command's outcome remains unchanged
