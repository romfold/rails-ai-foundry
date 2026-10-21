# Implementation

Use the installed ledger configuration as the architectural authority.
Use Rails Event Store 3.1 JSONClient and its generated PostgreSQL schema, a pure Account replay object,
and a direct Dry::Operation command. Rails controllers select trusted tenant identities and translate results.
Test actual persistence, expected-version uniqueness, rollback and HTTP authorization offline.
