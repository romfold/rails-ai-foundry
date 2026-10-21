# Authoritative ledger

An authenticated tenant can post integer credits and debits to its account and read its balance/version.
Balances replay from persisted events. Invalid amounts and overdrafts append no event.
A client supplies its observed version; stale or concurrent writers receive a conflict.
Requests cannot choose another tenant. An outer database rollback removes its appended events.

Acceptance: replay after a fresh client, invalid debit/amount rejection, concurrent append,
stale HTTP writes, tenant isolation and outer rollback tests must pass against PostgreSQL.
