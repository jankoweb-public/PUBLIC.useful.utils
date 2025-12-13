# 🧩 UserScript: Redirect GitHub Dashboard to Your Repositories

GitHub’s default dashboard is mostly useless — it shows random activity from people you follow, “Top repositories” sorted by some mysterious popularity algorithm, and no clear overview of **your own projects**.

If you’d rather have GitHub open **your personal repositories (sorted by last update)** every time you visit `github.com`, you can fix that easily with a simple **UserScript**.

If you already use a **UserScript manager** (like **Tampermonkey**, **Violentmonkey**, or **Userscripts** in Chrome/Edge), just follow the steps below.

---

## 📜 Script

Aktualizováno: 2025-12-13

Create a new UserScript and paste this code (includes optional IP-based profiles so you can personalize work/home targets, switching between user and organization pages):

```js
// ==UserScript==
// @name         GitHub Auto-Redirect to My Repos
// @namespace    github.com
// @version      1.2
// @description  Redirects from the default GitHub dashboard to your repositories list sorted by last update; supports IP-based profiles (user/org)
// @author       jankoweb
// @match        https://github.com/
// @match        https://github.com
// @run-at       document-start
// ==/UserScript==

(function() {
  // Default profile; used when no profile matches or IP lookup fails.
  const defaultProfile = { kind: "user", name: "jankoweb" }; // kind: "user" | "org"

  // Define IP-based profiles. Update regex masks and targets to match your networks.
  const profiles = [
    { label: "Work", pattern: /^10\.0\.\d+\.\d+$/, kind: "org", name: "YOUR_ORG" },
    { label: "Home", pattern: /^192\.168\.\d+\.\d+$/, kind: "user", name: "jankoweb" }
  ];

  const buildTarget = (profile) => profile.kind === "org"
    ? `https://github.com/orgs/${profile.name}/repositories?sort=updated&type=all`
    : `https://github.com/${profile.name}?tab=repositories&sort=updated`;

  const shouldRedirect = location.hostname === "github.com" && (location.pathname === "/" || location.pathname === "");
  if (!shouldRedirect) return;

  const pickProfile = (ip) => profiles.find((p) => p.pattern.test(ip)) || defaultProfile;

  const redirect = (profile) => {
    const target = buildTarget(profile);
    if (location.href !== target) {
      location.replace(target);
    }
  };

  // Fetch public IP and select profile; fall back to default if anything fails.
  fetch("https://api.ipify.org?format=json")
    .then((res) => res.json())
    .then((data) => pickProfile(data.ip))
    .catch(() => defaultProfile)
    .then((profile) => redirect(profile));
})();
```

---

## ⚙️ Setup

1. Open your UserScript manager (Tampermonkey, Violentmonkey, etc.)
2. Click **Create a new script**
3. Paste the code above
4. Replace `YOUR_USERNAME` with your actual GitHub username
5. Save ✅

---

## 💡 What It Does

- Runs automatically whenever you visit `https://github.com`
- Instantly redirects you to  
  `https://github.com/<your_username>?tab=repositories&sort=updated`
- Works whether you’re logged in or not
- No delay, no feed, no distractions

---

## 🧠 Why This Helps

- 💥 **No more clutter** – skips the random “home” feed entirely
- ⚡ **Faster workflow** – lands you right on your repositories, ready to work
- 🔍 **Clear overview** – repos are sorted by most recent activity
- 🧘 **Less noise** – no suggested projects, stars, or follower updates
- 🔒 **Lightweight and private** – runs locally in your browser, no API keys or logins required

---

## 🧩 Optional Improvement

You can easily extend the script with a simple condition to **skip redirecting** when you open other GitHub pages  
(e.g., `/explore`, `/orgs/`, or someone else’s profile).

Would you like me to include that safer version too?
