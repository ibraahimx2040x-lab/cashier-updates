#!/usr/bin/env bash
# Runs the migration and RLS tests against a throwaway local PostgreSQL 15+.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
bin="${PG_BIN:-/usr/lib/postgresql/16/bin}"
dir="$(mktemp -d)"
trap '"$bin/pg_ctl" -D "$dir" stop -m immediate >/dev/null 2>&1 || true; rm -rf "$dir"' EXIT
"$bin/initdb" -D "$dir" -U postgres >/dev/null
"$bin/pg_ctl" -D "$dir" -o "-p 54329 -k $dir -c listen_addresses=''" -l "$dir/log" start >/dev/null
psql=(psql -h "$dir" -p 54329 -U postgres -d postgres -v ON_ERROR_STOP=1 -q)
"${psql[@]}" -f "$here/stub_auth.sql"
for f in "$here"/../migrations/*.sql; do "${psql[@]}" -f "$f"; done
"${psql[@]}" -f "$here/rls_test.sql"
