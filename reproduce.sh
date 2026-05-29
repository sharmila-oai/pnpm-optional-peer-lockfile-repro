#!/bin/sh
set -eu

version=$(pnpm --version)
if [ "$version" != "11.4.0" ]; then
  printf 'Expected pnpm 11.4.0, found %s\n' "$version" >&2
  exit 1
fi

seed=$(mktemp)
trap 'rm -f "$seed"' EXIT
cp pnpm-lock.yaml "$seed"

pnpm install --lockfile-only --no-frozen-lockfile

if grep -Fq 'version: 3.2.4(jsdom@26.1.0)' pnpm-lock.yaml; then
  printf 'Reproduced: vitest optional peer changed from jsdom@27.4.0 to jsdom@26.1.0.\n'
  diff -u "$seed" pnpm-lock.yaml | grep -E '^[-+].*version: 3\.2\.4\(jsdom@' || true
  exit 0
fi

printf 'Did not reproduce the optional peer lockfile rewrite.\n' >&2
diff -u "$seed" pnpm-lock.yaml >&2 || true
exit 1
