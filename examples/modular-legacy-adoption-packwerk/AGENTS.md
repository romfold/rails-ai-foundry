# Adoption example

Run commands from this directory with its own Gemfile.lock. Read README.md and local OpenSpec behavior requirements, then the owning package.yml and foundry.yml. Use upstream OpenSpec skills installed locally; do not inherit the monorepo's selected change or specifications as application requirements.

Keep the reviewed legacy debt intact during normal work. New debt must fail. Retiring accepted debt requires an explicit extraction with behavior parity, as demonstrated in script/verify_adoption.rb. Never run baseline regeneration to make checks green.

Use direct Rails and upstream APIs. Run bin/verify, bundle exec rubocop and npm run spec:validate. Keep model/provider requests out of ordinary tests. This application demonstrates incremental extraction; do not claim RAG, outbox, production authentication or real payments.
