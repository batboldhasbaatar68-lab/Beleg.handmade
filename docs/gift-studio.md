# Gift studio and owner experience management

Adds 16 editable occasion collections, 8 editable gift-group collections, 20 original greeting/verse templates, 3 pictured QR service packages, a greeting-to-checkout handoff, browser voice recording/file mixing with three original instrumental previews, and 8 QR card cut shapes in PNG/PDF.

Owner management is stored under the existing settings JSON through the owner-only settings endpoint. No database schema or authorization function changes. The owner can change collection names/images/product mappings and visibility, greeting text/public demo audio, allowed card shapes and the free-voice-tool link. Products continue to control prices, inventory and sale status.

Public audio route only serves catalog/demo/UUID uploads that are explicitly referenced by an enabled greeting in settings. It cannot read private order audio or uploads. Uploading demo audio requires the same server owner guard as catalog images. Unpublished files return 404. Demo files are MP3/M4A/WAV, up to 20MB.

AI limitations are visible: template composition is free and local; new generative poems, autonomous singing and integrated cloud TTS are not configured. WevoLabs' Mongolian page is linked as a manual free-tool handoff, with explicit copy/paste and local audio re-import; no customer text is automatically sent there and no undocumented API is used. Review of the provider's current pages: https://wevolabs.com/text-to-speech/mongolian ; https://wevolabs.com/terms-service ; https://wevolabs.com/ (no API access).

Card sample QR links to /ai-gifts and is labeled as a demo. Actual private listening QR links still require the existing approved order audio. PDFs use actual pixel dimensions at 300 DPI and require 100% print scaling; shaped cards show cut outlines and keep the QR quiet zone.

Build and TypeScript passed. Live interaction checks are performed after deployment. No claim that every device has a Mongolian browser TTS voice; if none exists, the UI reports it and offers recording/audio import/manual external TTS.

## Installable web app

PWA manifest with branded 192/512 PNG icons, a maskable icon, standalone display and homepage/AI shortcuts. Install UI handles Android beforeinstallprompt and provides iOS Safari Add to Home Screen instructions. Service worker caches only public static resources and a generic offline page, never API requests, admin pages, private /g/ links, order HTML or audio uploads. Dynamic navigation remains online-first. This is a web app, not an App Store or Play Store listing. Device installation must be performed on the user's device.
