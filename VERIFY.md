# SEO Magnet — End-to-End Verification Prompt

Copy and paste this into Claude CLI after pushing both repos.

---

```
I need you to verify the full SEO Magnet lead funnel is working end-to-end. Check every step below and report PASS/FAIL for each.

## 1. Landing Page (autobiz.digital/seo-magnet)
- [ ] Page loads without errors
- [ ] Form has 5 fields: name, email, phone, website (with static https:// prefix), business
- [ ] Form submit fires POST to https://autonomous.n8n888.cloud/webhook/seo-magnet (check Network tab)
- [ ] After submit, user is REDIRECTED to autonomous-seo.vercel.app with query params: ?url=...&name=...&autostart=true&ref=seo-magnet
- [ ] The redirect happens instantly (no success screen shown)

## 2. SEO Tool Auto-Scan (autonomous-seo.vercel.app)
- [ ] Tool loads with ?url=...&name=...&autostart=true&ref=seo-magnet params
- [ ] URL input is pre-filled with the website from the form
- [ ] Name input is pre-filled with business name (or person name as fallback)
- [ ] Scan starts automatically within ~300ms of page load
- [ ] URL params are cleaned from address bar after load (history.replaceState)
- [ ] isUnlocked is set to true in localStorage (check: localStorage.getItem('seo-tool-unlocked') === 'true')

## 3. Auto-Unlock Verification
- [ ] After scan completes, NO score-reveal gate overlay appears (user is pre-unlocked)
- [ ] All sidebar tabs are accessible (dashboard, pages, keywords, GEO, schema, sitemap, etc.)
- [ ] Export/PDF works without gate
- [ ] There is NO "limited mode" banner anywhere
- [ ] There is NO "skip gate" button in the score-reveal overlay HTML

## 4. Direct Visitor Gate (without ref param)
- [ ] Open autonomous-seo.vercel.app directly (no query params)
- [ ] Clear localStorage first: localStorage.removeItem('seo-tool-unlocked')
- [ ] Scan a website manually
- [ ] After scan completes, score-reveal gate SHOULD appear
- [ ] Gate shows score ring, top issues, and lead capture form (name, email, phone)
- [ ] NO "skip/limited mode" button exists — only the full unlock form
- [ ] Pressing Escape closes the gate overlay smoothly (no JS errors)
- [ ] Filling the form and clicking unlock: sends lead to webhook, sets isUnlocked=true, opens full dashboard

## 5. n8n Workflow (dd4JRXBccw8iVPe9)
- [ ] Workflow is active
- [ ] All 11 nodes present: Webhook → Respond OK + Verify Origin → Format Lead Data → Save to Airtable + Build AI Prompt → Gmail Notify Gal / Generate AI Action Plan (Gemini) → Format Report Email → Send Report to Lead
- [ ] Gemini SEO Analyst node is connected to Generate AI Action Plan via ai_languageModel
- [ ] Check latest execution — all nodes should show success (green)
- [ ] Airtable save works without errors (Source field was removed from mapping, source info is in Notes)
- [ ] Gmail internal notification sent (check for 🟣 emoji in subject for seo-magnet source)
- [ ] AI action plan email sent to lead with branded HTML, 3 priorities, impact badges, Calendly CTA

## 6. Vercel Config
- [ ] vercel.json CSP connect-src includes: autonomous-seo.vercel.app
- [ ] All 3 API proxies have CORS allowlist including autobiz.digital and autonomous-seo.vercel.app
- [ ] Check /api/proxy, /api/gemini, /api/psi endpoints respond (not 500)

## 7. Full Flow Timing Test
- Do one complete test: fill form on landing page with a real website
- Measure: form submit → redirect → scan starts → scan completes → dashboard loads
- Measure: form submit → AI email received in inbox
- Expected: redirect + scan start < 2 seconds, AI email < 30 seconds

Report each check as ✅ PASS or ❌ FAIL with details on any failures.
```
