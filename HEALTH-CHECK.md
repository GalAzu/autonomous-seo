# SEO Magnet — Weekly Health Check SOP

**Purpose:** Weekly health check for the SEO Magnet lead capture funnel.
**Owner:** Gal
**Cadence:** Every Monday 09:00 IST
**Takes:** 2 minutes

---

## Why This Exists

The SEO Magnet funnel has multiple moving parts:
1. Landing page at `autobiz.digital/seo-magnet` (live, Vercel)
2. SEO analysis tool at `autonomous-seo.vercel.app` (live, Vercel)
3. n8n webhook `dd4JRXBccw8iVPe9` (autonomous.n8n888.cloud) — receives leads, generates AI audit, sends email
4. Gmail OAuth2 credential "autonomous" — sends audit email to lead + notification to Gal
5. Airtable base `appK1434KA6V9eJ8B` / table Leads — lead storage

**Any one of these breaks → the funnel silently fails.** Leads submit, nothing happens, no one notices until Gal asks "where are the leads?"

This SOP catches silent failures early.

---

## 2-Minute Weekly Check

### Option A — CLI (recommended)

```bash
cd /Users/galazulay/Documents/Autonomous/Projects/in-house/seoTool
./scripts/health-check.sh
```

**Expected output:** `✅ Workflow is reachable. Leads should be flowing.`

If you see `🚨 Action required` — jump to the remediation steps below.

### Option B — Manual browser check (fallback)

1. Go to `https://autobiz.digital/seo-magnet`
2. Fill the form with test data:
   - Name: `Test Health`
   - Email: `gal+healthcheck@autonomous.co.il`
   - Website: `https://autobiz.digital`
3. Submit
4. Wait 60 seconds
5. Check `gal+healthcheck@autonomous.co.il` inbox — should receive branded audit email
6. Check Airtable `Lead Management > Leads` — should see new row with "Test Health"
7. Delete the test lead from Airtable

---

## Remediation — If Unhealthy

### Case 1: `Webhook returned 404`

**Meaning:** The workflow is deactivated in n8n.

**Fix:**
1. Open `https://autonomous.n8n888.cloud`
2. Find workflow `[Autonomous] SEO Tool — Lead Capture` (ID `dd4JRXBccw8iVPe9`)
3. Click the active toggle (top right of workflow editor) → ON
4. Save
5. Re-run `./scripts/health-check.sh`

### Case 2: `Network error or timeout`

**Meaning:** n8n instance is down, or network between your machine and Hostinger is broken.

**Fix:**
1. Check Hostinger VPS status (panel.hostinger.com) — is the `46.202.154.198` instance up?
2. SSH into the VPS, check n8n container status
3. If n8n is down, restart: `docker restart n8n` (or equivalent)
4. Re-run health check

### Case 3: `Healthy but no real leads in 2+ weeks`

**Meaning:** Workflow is running but nothing is getting to it. Problem is upstream.

**Investigate:**
1. Visit `autobiz.digital/seo-magnet` in incognito — does the landing page load?
2. Open browser DevTools, submit test form, watch Network tab — is the POST firing?
3. Check Meta Pixel events — is `Lead` event firing on submit?
4. Most likely cause: Vercel deployment pushed a broken build that silently dropped form wiring.

### Case 4: `Webhook healthy but audit email never arrives`

**Meaning:** Workflow runs but email delivery is failing.

**Investigate:**
1. In n8n, open the workflow, go to Executions tab
2. Find the latest execution, click through each node
3. Check which node errored — most likely:
   - **Gemini SEO Analyst** — API quota exceeded, credential invalid
   - **Send Report to Lead** — Gmail OAuth2 expired (needs re-auth)
4. Fix the broken credential and test again

---

## Last Health Check Log

| Date | Status | Duration | Notes |
|---|---|---|---|
| 2026-04-12 09:48 | 🚨 INACTIVE | HTTP 500 | Found deactivated during Sprint 1 audit. |
| 2026-04-12 11:41 | ⚠ ACTIVE + AUTH BLOCK | HTTP 403 | Gal reactivated in UI. Webhook-level headerAuth silently blocking all real submissions (no execution record was created). |
| 2026-04-12 11:48 | ✅ LIVE | HTTP 200 | Removed `parameters.authentication: headerAuth` via MCP. Full end-to-end verified. Execution 157375 ran 12-node pipeline in 25.8s: Airtable rec recQ1yydcSuw3C9Lc created, Gmail notify sent, Gemini action plan generated, lead audit email delivered. |

**When you run a check, add a row.** Keeps a running log of uptime + catches regressions over time.

---

## References

- Workflow JSON archive: `/Users/galazulay/Documents/Autonomous/n8n-workflows/seo-magnet-lead-capture.json`
- Audit email template: `/Users/galazulay/Documents/Autonomous/Projects/in-house/seoTool/templates/seo-magnet-audit-email.html`
- CLAUDE.md: SEO Magnet section (updated 2026-04-12 to reflect Gemini+Gmail stack)
- Full E2E verification: `VERIFY.md` (deeper post-deployment test)
