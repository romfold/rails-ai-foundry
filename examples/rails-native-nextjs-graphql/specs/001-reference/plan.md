# Plan

Follow installed pack configuration. Use ordinary GraphQL Dataloader in the Rails context and keep all
models, sources and controllers owned there. Put Next.js App Router in frontend with its own npm lock.
Use a same-origin server route for backend requests and no-store responses with bounded upstream timeout.
Verify Rails tenant behavior, a real production frontend build and an end-to-end loopback HTTP smoke check.
