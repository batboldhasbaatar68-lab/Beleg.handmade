# БЭЛЭГ Handmade

Existing ZIP project for Netlify. Production publication and mobile UI tests are pending.

Build: `node node_modules/next/dist/bin/next build --webpack`
Publish directory: `.next`
Node: 22

Set BELEG_GATEWAY_KEY and SUPABASE_SERVICE_ROLE_KEY as secret server environment variables in Netlify. Never commit them. Supabase project: iqwklalhyayetrlujghi. Existing database migrations have already been applied; do not rerun setup.sql.

Verified 2026-11-03: Next.js production build and TypeScript passed. Fourteen database checks passed in a rolled-back transaction, including shipping fees and authorization. Product media, Storage configuration, owner login, and complete mobile checkout still require verification.
