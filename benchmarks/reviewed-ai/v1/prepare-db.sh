#!/bin/bash
set -eu
export PATH="$(echo /usr/lib/postgresql/*/bin):$PATH"
if [ ! -f /tmp/reviewed-pg/PG_VERSION ]; then
  initdb -D /tmp/reviewed-pg -A trust -U postgres --no-locale -E UTF8
fi
if ! pg_ctl -D /tmp/reviewed-pg status; then
  pg_ctl -D /tmp/reviewed-pg -l /tmp/reviewed-pg.log -o '-h 127.0.0.1 -p 55432 -k /tmp' -w start
fi
bundle exec rails db:prepare
