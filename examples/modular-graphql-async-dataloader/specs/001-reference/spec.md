# Async tenant directory

Authenticated requests may read only their tenant's people and managers. Nested reads batch manager keys.
Tenant and database role are explicit source cache keys; multiplexed tenants cannot share cached records.
Source fibers use the requested read role, release connections after success/failure, and restore ambient context.
Independent sources can overlap database I/O. GraphQL depth, complexity and requested key counts are bounded.
Falcon must serve an actual authenticated Rails GraphQL request and stop cleanly in acceptance.
