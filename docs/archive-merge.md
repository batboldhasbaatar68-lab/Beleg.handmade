# ZIP comparison and restoration

48 ZIP files, 32 distinct SHA-256 contents. No archived server code was executed. The current GitHub/Netlify implementation and owner authorization remain the base.

| Archive | Copies | Entries | Feature evidence |
|---|---:|---:|---|
| beleg-handmade-integrated-v5.zip | 1 | 14 | chocolate, bundles, admin, audio |
| BELEG_Handmade_Orders_PWA.zip | 1 | 4 | PWA, bundles, chocolate |
| BELEG-Handmade-NEGDSEN-NEG-DELGuUR(1).zip | 3 | 204 | print, chocolate, bundles, admin, audio, PWA, feedback, photo-gifts |
| BELEG_Handmade_Orders_Admin_TEST_READY.zip | 1 | 28 | bundles, admin, PWA, feedback, print |
| BELEG-Handmade-GitHub-files(1).zip | 2 | 159 | admin, chocolate, print, audio, bundles, photo-gifts |
| BELEG-Handmade-print-gifts.zip | 2 | 203 | print, chocolate, bundles, admin, audio, PWA, feedback, photo-gifts |
| BELEG-Handmade-improved-source.zip | 1 | 69 | bundles, admin, photo-gifts, audio, PWA, feedback, print |
| BELEG-Handmade-admin-test-ready.zip | 1 | 79 | bundles, admin, photo-gifts, audio, PWA, feedback, print |
| beleg-handmade-integrated(1).zip | 1 | 7 | admin, chocolate, bundles, audio, print |
| BELEG-Handmade-candles-updated(1).zip | 2 | 60 | bundles, admin, photo-gifts, audio, PWA, feedback, print |
| BELEG_Handmade_website.zip | 1 | 3 |  |
| BELEG-Handmade-photo-catalog (1).zip | 2 | 170 | chocolate, bundles, admin, audio, print, PWA, feedback, photo-gifts |
| beleg_handmade_update.zip | 1 | 3 | bundles, admin |
| BELEG-Handmade-local-preview.zip | 2 | 73 | bundles, admin, photo-gifts, audio, PWA, feedback, print |
| BELEG_Handmade_Orders_Admin_TEST.zip | 1 | 13 | admin, PWA |
| beleg-handmade-integrated-v6-final.zip | 2 | 16 | chocolate, bundles, admin, audio |
| beleg-handmade-demo.zip | 1 | 1 | chocolate, bundles, admin |
| BELEG-Handmade-repaired-review(1).zip | 4 | 202 | print, admin, audio, bundles, chocolate, photo-gifts |
| beleg-handmade-integrated-v6-production (1).zip | 5 | 32 | chocolate, bundles, admin, audio, photo-gifts |
| beleg-handmade-integrated-v3.zip | 1 | 8 | chocolate, bundles, admin, audio, print |
| BELEG-Handmade-gifts-chocolate.zip | 1 | 136 | chocolate, bundles, admin, audio, print, PWA, feedback, photo-gifts |
| beleg-handmade-integrated-v4.zip | 1 | 11 | chocolate, bundles, admin, audio |
| BELEG-Handmade-floral-redesign.zip | 1 | 113 | bundles, admin, audio, print, PWA, feedback, photo-gifts |
| beleg-handmade-integrated-v2.zip | 1 | 7 | admin, chocolate, bundles, audio, print |
| BELEG_Handmade_PWA.zip | 2 | 7 | PWA |
| BELEG_Handmade_Orders_Admin_TEST_READY(1).zip | 1 | 17 | bundles, admin, PWA |
| BELEG-Handmade-zasvarlasan-source.zip | 1 | 69 | bundles, admin, photo-gifts, audio, PWA, feedback, print |
| BELEG_Work_materials.zip | 1 | 7 | bundles, admin |
| beleg-handmade-integrated-v6.zip | 1 | 14 | chocolate, bundles, admin, audio |
| BELEG_Handmade_Updated.zip | 1 | 21 | bundles, admin, PWA |
| beleg-handmade-integrated.zip | 1 | 6 | admin, chocolate, bundles |
| BELEG-Handmade-FINAL-ONE-PACKAGE.zip | 1 | 191 | admin, chocolate, print, photo-gifts, bundles, audio |

The final one-package catalog has 28 reference entries. Reference prices are preserved in lib/archive-catalog.ts. Examples remain non-orderable. Existing live IDs and prices take precedence; conflicting archive values are shown in the admin archive tab rather than silently overwriting them. Missing prices remain zero only in the reference file, never in checkout or live product rows. Wrong cupcake imagery for candle-flower is omitted.

Restored: reference photos, chocolate catalog, letters, photo-memory boxes, gift examples, archive import/hide controls, category filters and visible bag prices. Existing stock, server price checks, private uploads, QR and manual audio approval remain intact.

Not restored as production services: legacy Netlify Identity/Database migrations, unconfigured Gemini/QPay integrations, duplicate old carts, stale admin credentials, service workers that cache private routes.
