# Knowledge task application

Run `bundle exec ruby test/visible_test.rb`. Dependencies are installed and locked.
Use `bundle exec ruby bin/rails runner ...` to inspect ordinary Rails loading.
The `/documents` endpoint accepts demo tokens `tenant-a-token` and `tenant-b-token`;
request parameters never establish tenant identity. SQLite is disposable test storage.
Provider and search transports are deterministic, offline injected dependencies.
Read TASK.md for the behavioral contract and AGENTS.md for the selected architecture.
