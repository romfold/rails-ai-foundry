# Rails-native Next.js and GraphQL

The focal context is [directory](packs/directory/foundry.yml). This is a Rails-root monorepo with an independent
Next.js frontend in frontend/. Rails owns PostgreSQL data, authorization, GraphQL and batching.

```sh
docker compose up -d --wait
bundle install
npm --prefix frontend ci
bin/setup
bin/rails db:seed
bin/verify
bundle exec rubocop
bin/rails server
# Separate terminal:
npm --prefix frontend run dev
```

Open localhost:3001, choose a demo identity and enter seeded person IDs. Only the selected tenant's records
and managers are returned. Demo tokens are public demonstration credentials; replace both frontend proxy
identity handling and Rails authentication with your application's trusted identity flow for deployment.

The frontend server proxies to RAILS_API_URL (default localhost:3000); this URL is server-owned and cannot
be supplied by the browser. Responses are no-store and backend timeouts/failures return 503. Rails enforces
tenant boundaries even when caller parameters claim another identity. React renders returned data as text.
The application shell retains migrations while feature code and seeds remain pack-owned.

The frontend pins Next.js 16.3.4 and React 19.3.0; Node 20.19.0 satisfies the upstream >=20.9 requirement.
`npm --prefix frontend run build` builds production assets; `npm --prefix frontend start` serves them.
`bin/verify` runs Rails tests, builds the frontend, starts real servers on ephemeral loopback ports,
checks rendering/authenticated proxying/backend failure, then runs Packwerk and production loading.
No model requests, cloud deployment or performance benchmark are involved.

Keep [the living specification](specs/001-reference/spec.md), plan and tasks reconciled. Foundry remains
a development dependency; frontend libraries are never injected into the Rails runtime.
