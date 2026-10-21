# Plan

Use installed pack configuration. GraphQL AsyncDataloader batches PeopleSource reads.
Enable Rails fiber isolation; pass trusted tenant and reading role as source arguments.
Use Current.set, connected_to and with_connection(prevent_permanent_checkout: true) scopes.
Tests exercise actual PostgreSQL, overlapping delayed database reads, cleanup on failures and multiplex isolation.
Falcon acceptance spawns one upstream server on an ephemeral loopback port and verifies Rails delivery.
