# Autonomous SEO — All-in-One SEO Management Tool

## Overview
A standalone, single-file SEO management tool built for Autonomous's clients and as a sellable product. Users manage SEO for any website through an intuitive dashboard — no backend required. Doubles as a lead magnet via built-in audit capture.

## Architecture
- **Single HTML file** (`index.html`) — zero dependencies, runs in any browser
- **localStorage** for persistence — multi-project support
- **No server needed** — works offline, shareable via file or static hosting
- **n8n webhook integration** — lead capture sends audit data to n8n for CRM processing

## Features
- **Project Setup Wizard** — 3-step onboarding for any website
- **SEO Dashboard** — dynamic scoring engine with health overview
- **Page Manager** — add/edit/remove pages with full meta editing
- **SERP Preview** — live Google search result preview
- **Structured Data Builder** — schema templates (LocalBusiness, FAQ, Service, Breadcrumb, Product, Article, Review)
- **Sitemap Manager** — generate/edit/download sitemap.xml with auto-sync from pages
- **Robots.txt Editor** — edit/download with built-in guide
- **Keyword Strategy** — 4 sub-tabs: Keyword Map, Competitor Tracker, Content Gap Analysis, Keyword Clusters. Intent classification (informational/navigational/transactional/commercial), placement indicators (T/H1/D)
- **GEO (Generative Engine Optimization)** — per-page AI readiness scoring with E-E-A-T, content structure, schema, and citation management
- **Heading Analysis** — H1-H6 hierarchy per page
- **Google Search Console Guide** — step-by-step GSC setup
- **Launch Checklist** — interactive with auto-detection and manual checkmarks
- **Export System** — tabbed export (summary, meta, sitemap, schemas, robots) with copy/download
- **Lead Capture System** — modal form with webhook integration, sends full audit data to n8n
- **Multi-Project** — switch between client websites

## Brand
Uses Autonomous brand identity:
- Primary: Flow Blue (#2f55c7)
- Accent: Teal (#1aa2b0)
- Fonts: Rubik (headings), Assistant (body)
- Dark theme UI

## Scoring Engine
**Page Score (100 pts):** Content & Keywords 40% (title, description, keyword-in-title, keyword-in-H1, keyword-in-description, content depth), Technical Structure 25% (canonical, keywords mapped, indexable, HTTPS check, internal linking), Structured Data 15%, Social Meta 10% (OG title/desc/image), Media 10% (image alt, media optimization).
**Project Score:** 70% average page scores + 30% site-wide factors (sitemap, robots, schema type diversity, image health, link health, index health).
Thresholds: 80+ green, 50-79 yellow, <50 red.

## GEO (Generative Engine Optimization)
Optimizes pages for AI search engines (ChatGPT, Gemini, Perplexity, etc.).
**Per-Page GEO Score (100 pts):** E-E-A-T 30% (author name, credentials, experience signals), AI-Friendly Content 30% (structured answers, clear definitions, content depth checkboxes), Schema for AI 20% (FAQ, HowTo, and other AI-consumable schemas), Citation Readiness 20% (source citations, statistics, external references).
**Project GEO Score:** 70% average page GEO scores + 30% site-wide factors.
Features: author/credentials fields per page, content structure checkboxes, citation management UI, collapsible per-page cards.

## Keywords
Enhanced keyword management with 4 sub-tabs:
- **Keyword Map** — assign keywords to pages with intent badges (informational/navigational/transactional/commercial) and placement indicators (T = title, H1 = heading, D = description)
- **Competitor Tracker** — track competitor domains and their keyword targeting
- **Content Gap Analysis** — identify keyword opportunities not yet covered
- **Keyword Clusters** — group related keywords into topic clusters for content planning

## Lead Capture System
Built-in lead magnet funnel integrated with Autonomous sales pipeline.
- **Modal Form** — captures name, email, phone
- **Audit Payload** — sends full audit data (scores, per-page breakdown, issues list, competitor data) via webhook POST
- **n8n Workflow** — ID: `dd4JRXBccw8iVPe9`. Webhook POST → Airtable (Lead Management → Leads table) + Gmail notification + WhatsApp notification. Full audit data stored in Airtable Notes field
- **Two CTAs** — dashboard CTA (always visible) and low-score CTA (triggered when scores are below threshold)

## RTL
Full RTL Hebrew support. Language selector available (he/en/ar).

## Roadmap
- [ ] Live URL fetch & auto-analysis (CORS proxy)
- [ ] AI-powered meta suggestions (OpenAI integration)
- [ ] Lighthouse integration
- [ ] PDF report generation
- [ ] White-label support (custom branding per client)
- [ ] SaaS version with auth & cloud storage
