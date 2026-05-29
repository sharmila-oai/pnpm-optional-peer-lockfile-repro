#!/bin/sh
set -eu

version=$(pnpm --version)
if [ "$version" != "11.4.0" ]; then
  printf 'Expected pnpm 11.4.0, found %s\n' "$version" >&2
  exit 1
fi

seed=$(mktemp)
trap 'cp "$seed" pnpm-lock.yaml; rm -f "$seed"' EXIT
cp pnpm-lock.yaml "$seed"

pnpm install --lockfile-only --no-frozen-lockfile

if grep -Fq 'version: file:fixtures/context-low(jsdom@26.1.0)' pnpm-lock.yaml &&
  grep -Fq 'version: file:fixtures/context-high(jsdom@26.1.0)' pnpm-lock.yaml; then
  printf 'Reproduced: two nested Vitest peer contexts collapsed to jsdom@26.1.0.\n'
  diff -u "$seed" pnpm-lock.yaml | grep -E '^[-+].*(context-(low|high)|vitest: 3\.2\.4\(jsdom@)' || true
  exit 0
fi

printf 'Did not reproduce the nested optional peer context rewrite.\n' >&2
diff -u "$seed" pnpm-lock.yaml >&2 || true
exit 1
