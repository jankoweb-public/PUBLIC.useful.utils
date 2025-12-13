// ==UserScript==
// @name         GitHub Auto-Redirect to My Repos
// @namespace    github.com
// @version      1.2
// @description  Redirects from the default GitHub dashboard to your repositories list sorted by last update; supports IP-based profiles (user/org)
// @author       jankoweb
// @match        https://github.com/
// @match        https://github.com
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function() {
  // Set your defaults here before publishing.
  const workProfile = { kind: "org", name: "YOUR_ORG" };
  const homeProfile = { kind: "user", name: "YOUR_USERNAME" };

  // Add as many work ranges as needed (regex for IP string).
  const workRanges = [
    /^10\.0\.\d+\.\d+$/,
    /^172\.(1[6-9]|2\d|3[0-1])\.\d+\.\d+$/
  ];

  const buildTarget = (p) => p.kind === "org"
    ? `https://github.com/orgs/${p.name}/repositories?sort=updated&type=all`
    : `https://github.com/${p.name}?tab=repositories&sort=updated`;

  if (!(location.hostname === "github.com" && (location.pathname === "/" || location.pathname === ""))) return;

  const isWorkIp = (ip) => workRanges.some((re) => re.test(ip));

  fetch("https://api.ipify.org?format=json")
    .then((res) => res.json())
    .then((data) => (isWorkIp(data.ip) ? workProfile : homeProfile))
    .catch(() => homeProfile)
    .then((profile) => {
      const target = buildTarget(profile);
      if (location.href !== target) location.replace(target);
    });
})();
