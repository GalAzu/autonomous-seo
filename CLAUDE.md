# Autonomous SEO Tool — Lead Magnet Machine

## Overview
All-in-one SEO audit and management tool serving as Autonomous's primary lead magnet. Users scan their website, see a score reveal gate, enter email to unlock the full dashboard. Built as a single HTML file with 3 Vercel serverless functions.

**Live:** https://autonomous-seo.vercel.app
**Domain:** autobiz.digital/seo (to be configured)
**Repo:** https://github.com/GalAzu/autonomous-seo

## Architecture
- **`index.html`** — single-file app (~370KB, ~7000 lines), zero dependencies
- **`api/proxy.js`** — CORS proxy for scanning websites (SSRF-protected, domain-restricted)
- **`api/gemini.js`** — server-side proxy for Gemini AI calls (key in header, never URL)
- **`api/psi.js`** — server-side proxy for PageSpeed Insights API
- **`vercel.json`** — routing + security headers (CSP, X-Frame-Options, nosniff)
- **localStorage** for persistence — multi-project, keys obfuscated (base64)
- **Vercel** for hosting + serverless functions

## Lead Magnet Funnel
```
User enters URL → Site scan → Score Reveal Gate
                                    ↓
                    Score + Top 3 Issues (open)
                    Full Dashboard (email-gated)
                                    ↓
                    ├── Submit email → Full access (persists via localStorage)
                    └── Skip → Dashboard-only (limited mode, tabs locked)
                                    ↓
                    Lead → n8n webhook (HMAC signed)
                    → Airtable CRM (Lead Management → Leads)
                    → Gmail notification to galazu@gmail.com
```

## Modules (17)
1. **Dashboard** — SEO + GEO scores, health grid, priorities with fix-it snippets, AI insights, booking CTA, score history
2. **Pages Table** — all pages with scores, PSI button (⚡), edit/delete
3. **Page Editor** — meta editing, SERP preview, character counts, keyword tags, AI suggestions (✨)
4. **Structured Data** — 10 schema templates (LocalBusiness, FAQ, Service, Breadcrumb, Product, Article, HowTo, Organization, Review, Custom), AI schema recommendations
5. **Sitemap** — generate/edit/download XML, sync from pages
6. **Robots.txt** — editor + AI bot directives guide (GPTBot, ChatGPT-User, PerplexityBot, Google-Extended)
7. **Keywords** — 4 sub-tabs: Map (with AI suggest), Competitors, Content Gaps, Clusters
8. **GEO** — AI readiness scoring (E-E-A-T 30%, AI Content 30%, Schema 20%, Citations 20%), rescan, per-page recommendations
9. **Headings** — H1-H6 hierarchy analysis
10. **Images** — alt text audit with filtering
11. **Links** — internal link analysis (orphans, hubs)
12. **Hreflang** — multi-language tag generator
13. **GSC** — import CSV, analytics dashboard (stats, insights, filter chips, position chart, page performance)
14. **Checklist** — 6 categories including "AI Readiness (2026)", auto-detect + manual toggle with 3-state override
15. **Redirects** — 301/302 manager, export to .htaccess/Netlify/Vercel
16. **Export** — 6 tabs (summary, meta, sitemap, schemas, robots, GEO), all in Hebrew
17. **Settings** — project config, API keys (Gemini, PSI, Meta Pixel), rescan, backup/restore

## Scoring Engine
**Page SEO Score (100 pts):** Content & Keywords 40%, Technical Structure 25%, Structured Data 15%, Social Meta 10%, Media 10%.
- Uses `Math.max(manual content, scanned wordCount)` to avoid false thin-content penalties
- Data confidence indicator (6 signals per page: title 20+ch, desc 50+ch, content 100+words, 2+ headings, 1+ keywords, 1+ schema)
- GSC bonus: up to +5 pts for projects with real search data

**Project Score:** 70% avg page scores + 30% site-wide (sitemap, robots, schema diversity by unique types, link health, image health, HTTPS, indexability, content depth)

**GEO Score (100 pts):** E-E-A-T 30%, AI-Friendly Content 30%, Schema for AI 20%, Citation Readiness 20%
- Trust signals proportional (not all-or-nothing)
- Recommendations updated for 2026 AI Overview optimization

## AI Features (Gemini 2.0 Flash)
All routed through `/api/gemini` (key in header, never URL). Gated behind email unlock + API key.
- **Dashboard AI Insights** — personalized Hebrew recommendations based on full project data
- **Title/Description Rewriting** — ✨ buttons in page editor
- **Keyword Suggestions** — ✨ per page in keyword map, auto-adds + dedupes
- **Schema Recommendations** — suggests which schema types to add

## Scanner
Self-hosted CORS proxy (`/api/proxy`) as primary, no third-party fallbacks.
Extracts: title, description, canonical, OG tags, headings, internal links, JSON-LD schemas, images+alt, keywords (from content), GA tracking code, noindex, GEO signals (author, Q&A, statistics, citations), tech signals (viewport, charset, favicon, render-blocking scripts, image dimensions, mixed content, hreflang, word count).

## Security (Grade S)
- SSRF protection: private IP blocklist on proxy
- CORS: restricted to autobiz.digital only
- XSS: escapeHtml + escapeAttrJs (with backtick/dollar) everywhere
- API keys: server-side proxies, base64 obfuscated in localStorage
- Webhook: HMAC-SHA256 signed (shared secret: `autonomous-seo-2026`)
- Backup import: all strings sanitized
- Headers: CSP, X-Frame-Options DENY, nosniff, referrer-policy, permissions-policy
- Content-type forced to text/plain on proxy responses

## n8n Workflow (dd4JRXBccw8iVPe9)
**Name:** [Autonomous] SEO Tool — Lead Capture
**Flow:** Webhook → Verify HMAC Signature (Code node) → Format Lead Data → Respond OK + Save to Airtable → Gmail Notify Gal
- Source tracking: `score-reveal-gate` vs `lead-modal`
- HMAC validation: checks `X-Webhook-Signature` header
- Airtable: Lead Management → Leads (appK1434KA6V9eJ8B / tblSOxHfMQ5klKXhl)
- Gmail: branded HTML email with scores, page breakdown, audit summary

## Reports
- **PDF Report** — branded print-ready page: score rings, stats grid, full page table, issues list, CTA. Opens in new window with print dialog
- **HTML Report** — downloadable standalone dark-theme HTML with SERP previews, per-page actions, Autonomous branding

## UX (100/100)
- All buttons: hover + focus-visible + disabled states
- All inputs: labels or aria-labels
- All modules: collapsible guides (📖 accordion)
- All modules: empty state messages
- All modals: X close button + overlay click + Escape key
- Dark theme scrollbar styling
- Toast types: success (green), error (red border), neutral
- Score history: trend arrows on rescan
- Data confidence: badge showing scan coverage %

## Mobile Responsive
- 768px: sidebar hides, tables compact, 44px touch targets
- 640px: GEO grids → 2col, keyword rows compact, CTA stacks
- 480px: all grids → 1col, cards compact 16px, forms stack, modals 96% width

## Brand
- Primary: Flow Blue (#2f55c7), Accent: Teal (#1aa2b0)
- Fonts: Rubik (headings), Assistant (body)
- Dark theme UI, logo in sidebar + onboarding + reports
- All links point to autobiz.digital

## Dev Notes
- Rollback point before lead gate: `498dbca`
- Meta Pixel: fires ViewContent on scan, Lead on gate/modal submit
- Booking CTA: links to `calendly.com/autonomous-il/seo-strategy` (update if different)
- Keywords auto-extracted during scan via `extractKeywordsFromContent()` (weighted: title 5, H1 4, desc 3, H2 2, body 1)
- `isUnlocked` states: `true` (full access, persisted), `'limited'` (dashboard only, session), `false` (gated)

## Roadmap
- [ ] PDF auto-email via n8n after lead capture
- [ ] Meta ads campaign pointing to tool
- [ ] n8n nurture sequence (follow-up emails after capture)
- [ ] SaaS version with auth + cloud storage (if demand proves out)
- [ ] White-label (custom logo/colors per agency client)
