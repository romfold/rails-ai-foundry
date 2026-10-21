# Rails directory with a separate frontend

A user can open the built Next.js interface and query authorized Rails directory records.
Rails GraphQL restricts tenant ownership, batches manager reads and bounds query complexity.
The frontend proxy forwards authenticated identity to a configured Rails backend without caching tenant data.
Unauthenticated requests are rejected and unavailable Rails returns a visible failure.
The frontend has its own exact dependency lock and production build; the repository remains Rails-root.
Acceptance starts real Rails and Next.js servers and verifies rendering, proxying, authorization and failure behavior.
