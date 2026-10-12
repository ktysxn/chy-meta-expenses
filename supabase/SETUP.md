# Connect the private free-plan project

The frontend is deployed with blank public connection settings until a real project is selected. Existing browser records remain local and are not uploaded before sign-in and first-sync selection.

1. Create/select a dedicated **Free** Supabase project. Apply `migrations/001_private_sync.sql` using the SQL editor or connected Supabase tooling. Do not apply `tests/bootstrap.sql` to a Supabase project; it is a CI-only schema harness.
2. Set Authentication → URL Configuration → Site URL and Redirect URLs to `https://ktysxn.github.io/chy-meta-expenses/`.
3. Create the owner’s Auth account (email/password, or existing account with email-link delivery). Disable public new-user signups. Configure production email delivery if using email links; password sign-in does not depend on email link delivery after account creation.
4. Add the approved Auth user’s UUID using a trusted administrative connection:

```sql
insert into cheyenne_private.members(user_id)
values ('REPLACE_WITH_OWNER_AUTH_USER_UUID')
on conflict do nothing;
```

5. Put only the project URL and **publishable** `sb_publishable_…` key in `cloud-config.json`. A publishable key is intentionally browser-visible. Do not put an elevated secret key, service-role key, database password, owner email, access token, or personal records in GitHub. Browser clients are restricted by membership checks, RLS, and private storage policies.
6. Deploy, then sign in on the device that has the complete existing dashboard. Back up its records and choose **Start syncing this device** once. Sign in to the same account on the second device and choose the cloud records. This avoids an empty device replacing existing records.

Cloud save happens shortly after changes. Other open devices check about every ten seconds and on returning to the app. Offline edits remain queued in the device cache. Revision comparison prevents stale overwrites; a conflicting edit pauses autosave and retains a recovery copy for explicit resolution.

Receipts sync to a private immutable bucket, not public URLs. Full backups download cloud-only receipts through authenticated access. Receipt copies orphaned by removed/replaced expenses are retained for recovery and may be cleaned by the owner later. Free-plan inactivity pausing and quota limits still apply; the app retains local records if cloud access fails.

CI tests use a mock backend to exercise two browser sessions and offline behavior, plus real PostgreSQL role/policy tests. These do not prove a real Supabase project is configured; verify actual sign-in, owner-only access, receipt downloads, and desktop/phone synchronization after connecting the project.
