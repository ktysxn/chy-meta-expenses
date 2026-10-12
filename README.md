# Cheyenne Command Center

Dark-mode, responsive, browser-local expense dashboard and installable PWA.

Travel hub: flight legs, time-zone-aware schedules and countdowns, seats, gates, confirmation codes, and National rental pickup/return details. Booking states and schedule data are manually entered; no live flight-status integration is implied. Travel bookings do not create expense transactions.

Import a CSV using the in-app template or JSON with `flights` and `rentals` arrays. Each flight requires `flightNumber`, `from`, `to`, `departure`, and `arrival`; each rental requires `confirmation`, `pickupLocation`, `pickup`, `dropoffLocation`, and `dropoff`. Date/time values use `YYYY-MM-DDTHH:MM` in the airport/location's local time. Houston airports default to America/Chicago; Denver and Cheyenne default to America/Denver. Other supported zones can be selected explicitly. Preview before merging; flight matching uses flight number, airports and departure, while rentals match by confirmation. Matching imports replace all supplied record fields, including blanks. Full dashboard backups include travel and retain compatibility with older expense-only backups.

The repository contains only the app shell. It starts with no transactions, trips, receipts, housing amounts, or personal payment reminders. Records and receipts stay in localStorage on the device; backup and restore are manual local files. Never commit personal backups or receipts. GitHub Pages serves the shell and does not synchronize expense data.

Deployment: Settings → Pages → select GitHub Actions. The Pages workflow publishes an explicit allowlist of five app files. Private repositories require an eligible GitHub plan for Pages; repository visibility is not changed by this project.

On iPhone, open the deployed URL in Safari and select Share → Add to Home Screen. On Android, use the browser's Install app / Add to Home screen option. Open once online before offline use. Dark mode is the default and the chosen theme is saved locally.

Use Backup data in the original dashboard, then Restore in the hosted app to move your records privately. Data does not transfer automatically between file URLs and the hosted origin. Browser storage may be cleared, so keep private backups. Coding and policy guidance inherited from the source dashboard must be verified with WM before filing a claim.
