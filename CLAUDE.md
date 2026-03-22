# Autonomous SEO — All-in-One SEO Management Tool

## Overview
A standalone, single-file SEO management tool built for Autonomous's clients and as a sellable product. Users manage SEO for any website through an intuitive dashboard — no backend required.

## Architecture
- **Single HTML file** (`index.html`) — zero dependencies, runs in any browser
- **localStorage** for persistence — multi-project support
- **No server needed** — works offline, shareable via file or static hosting

## Features
- **Project Setup Wizard** — 3-step onboarding for any website
- **SEO Dashboard** — dynamic scoring engine with health overview
- **Page Manager** — add/edit/remove pages with full meta editing
- **SERP Preview** — live Google search result preview
- **Structured Data Builder** — schema templates (LocalBusiness, FAQ, Service, Breadcrumb, Product, Article, Review)
- **Sitemap Manager** — generate/edit/download sitemap.xml with auto-sync from pages
- **Robots.txt Editor** — edit/download with built-in guide
- **Keyword Strategy** — map keywords to pages with placement guidance
- **Heading Analysis** — H1-H6 hierarchy per page
- **Google Search Console Guide** — step-by-step GSC setup
- **Launch Checklist** — interactive with auto-detection and manual checkmarks
- **Export System** — tabbed export (summary, meta, sitemap, schemas, robots) with copy/download
- **Multi-Project** — switch between client websites

## Brand
Uses Autonomous brand identity:
- Primary: Flow Blue (#2f55c7)
- Accent: Teal (#1aa2b0)
- Fonts: Rubik (headings), Assistant (body)
- Dark theme UI

## Scoring Engine
Pages scored on: title length (30-60), description length (120-160), canonical, schema, keywords, H1 structure. Project score aggregates all pages + sitemap + schemas.

## RTL
Full RTL Hebrew support. Language selector available (he/en/ar).

## Roadmap
- [ ] Live URL fetch & auto-analysis (CORS proxy)
- [ ] AI-powered meta suggestions (OpenAI integration)
- [ ] Lighthouse integration
- [ ] PDF report generation
- [ ] White-label support (custom branding per client)
- [ ] SaaS version with auth & cloud storage
