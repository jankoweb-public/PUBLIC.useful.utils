# GitHub Dashboard Redirect (Tampermonkey)

UserScript that skips the GitHub dashboard and jumps straight to your repos, with optional IP-based profiles to pick between a user or org target (e.g., work vs. home).

## Install (Tampermonkey)
- In Tampermonkey, click **Create a new script**.
- Copy-paste the script from [redirect-from-dashboard.md](redirect-from-dashboard.md).
- Save the script; it runs on `https://github.com/` at document-start.

## Configure
- Default profile is user `jankoweb`.
- Edit the `profiles` array to match your IP masks and choose `kind: "user" | "org"` plus `name` (username or org slug).
- Leave the defaults if you only need your personal user page.

## How it works
- On the GitHub root page, it fetches your public IP via `https://api.ipify.org?format=json`.
- It matches the IP against your `profiles`; if none match, it uses the default profile.
- It redirects to the appropriate target:
  - User: `https://github.com/<name>?tab=repositories&sort=updated`
  - Org: `https://github.com/orgs/<name>/repositories?sort=updated&type=all`

## Notes
- Tested with Tampermonkey; uses no special grants (`@grant none`).
- You can add more profiles (VPN, mobile hotspot, etc.) by extending the `profiles` array.
