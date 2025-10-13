# 🧩 UserScript: Redirect GitHub Dashboard to Your Repositories

GitHub’s default dashboard is mostly useless — it shows random activity from people you follow, “Top repositories” sorted by some mysterious popularity algorithm, and no clear overview of **your own projects**.

If you’d rather have GitHub open **your personal repositories (sorted by last update)** every time you visit `github.com`, you can fix that easily with a simple **UserScript**.

If you already use a **UserScript manager** (like **Tampermonkey**, **Violentmonkey**, or **Userscripts** in Chrome/Edge), just follow the steps below.

---

## 📜 Script

Create a new UserScript and paste this code:

```js
// ==UserScript==
// @name         GitHub Auto-Redirect to My Repos
// @namespace    github.com
// @version      1.0
// @description  Redirects from the default GitHub dashboard to your repositories list sorted by last update
// @author       you
// @match        https://github.com/
// @match        https://github.com
// @run-at       document-start
// ==/UserScript==

(function() {
  const username = "YOUR_USERNAME"; // <-- Replace with your GitHub login, e.g. jankohout
  const target = `https://github.com/${username}?tab=repositories&sort=updated`;
  if (location.href === "https://github.com/" || location.href === "https://github.com") {
    location.replace(target);
  }
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
