# Cheyenne Command Center

Dark-mode, responsive expense and travel PWA hosted on GitHub Pages. The repository contains only the public application shell. Personal transactions, receipts, travel requests, contact preferences, rotations, and start dates belong in local device storage or the private Supabase workspace. Never commit personal backups or receipt files.

## Daily use

- Overview includes today's on-site per diem status, meals, missing receipts, and collapsible insights.
- Quick add (or Alt+A) opens meal, rental fuel, receipt, rental, hotel, and other purchase shortcuts with today's local date.
- Travel includes rotation cards, travel-day flight/rental details, booking boards, agent requests, and a collapsible mileage log. Mileage reimbursement remains unconfirmed for rentals.
- Purchases includes a receipt inbox. Upload images/PDFs under 1.5 MB, review the details manually, and assign them to expenses. Exact byte duplicates are skipped. Receipt OCR is not enabled.
- Reimbursements separates employer payment progress from card payback, and includes monthly closeout and Concur preparation. Statuses are manually recorded; the app does not submit to Concur or verify deposits.
- Per diem is calculated only for Monday-Friday on or after the privately saved start date, with on-site eligibility confirmed by the user. Meals on excluded dates remain in the expense history but do not reduce per diem savings.

## Travel requests and imports

Agent contacts and editable email drafts are private records. Opening a draft in an email app does not send it or mark it Requested. Requests can be Draft, Requested, or Confirmed; confirmed bookings are imported separately to avoid invented confirmations or duplicate purchases.

Travel JSON accepts flights and/or rentals arrays, or CSV from the in-app template. Flights need a flight number, three-letter airports, and departure date; known times use YYYY-MM-DDTHH:MM in the airport local time. Rentals require a confirmation; unknown times may remain blank. Imports preview and merge matches by flight number, airports, and date, or rental confirmation. Costs in booking boards are reference values and do not create expenses.

## Sync and backups

See supabase/SETUP.md for owner-only Auth, membership authorization, RLS, revision-checked saves, and private receipt storage. Public cloud-config.json contains only a project URL and publishable key. Never expose elevated keys. Inbox receipts and expense receipts upload under owner/content-hash paths; cloud snapshots contain references, not embedded image bytes. Full backups fetch cloud-only receipts and include all record types. Existing mileage records remain compatible with backups.

Restore a full backup in the hosted app to move original file-based records. Sign in on the device containing your full records and choose Start syncing this device; then sign in on other devices and use cloud records. Stale writes pause for review instead of overwriting newer changes. Keep private backups.

## Deployment and verification

The GitHub Actions workflow builds the pinned Supabase SDK, runs responsive and two-device mock sync checks plus a PostgreSQL security harness, then publishes an explicit app-asset allowlist. No personal records or test harness files are deployed. GitHub Pages must use GitHub Actions.

On iPhone, open in Safari and choose Share > Add to Home Screen. On Android, use Install app / Add to Home screen. Load online once before offline use. Airfare and rental status, policy guidance, and amounts are user-entered and should be verified before submitting expenses.
