# pnpm optional peer lockfile candidate repro

This repository demonstrates a lockfile rewrite involving an optional peer
dependency in `pnpm@11.4.0`.

The committed lockfile was seeded with two public `jsdom` versions while
`vitest@3.2.4` resolved its optional `jsdom` peer to `27.4.0`. The seeding
direct dependency has then been removed from `packages/newer/package.json`.

With pnpm 11.4.0, a writable lockfile-only install discards the compatible
locked optional peer candidate and resolves Vitest against `jsdom@26.1.0`:

```sh
pnpm --version
# 11.4.0

pnpm install --lockfile-only --no-frozen-lockfile
git diff -- pnpm-lock.yaml
```

The relevant diff is:

```diff
-        version: 3.2.4(jsdom@27.4.0)
+        version: 3.2.4(jsdom@26.1.0)
```

To run the repro from a fresh checkout:

```sh
./reproduce.sh
```
