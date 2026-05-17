# Gigsta — Product Roadmap

A living document. Last updated 15 May 2026.

## Where we are today (v0.2)

✓ Browse + book end-to-end · ✓ Creator onboarding (5 steps) · ✓ Admin verification queue
✓ CMS-editable site copy & categories · ✓ Plans & pricing · ✓ Stripe Checkout (hookable)
✓ File uploads for credentials · ✓ Transactional email scaffolding · ✓ Rate limiting · ✓ HTTPS via Caddy

---

## Q3 2026 — Trust & money flow (the "real product" milestone)

**Goal:** every creator can be paid; every customer feels safe.

- [ ] **Real verification operations**
  - [ ] Integration with an ID verification vendor (Stripe Identity or Persona)
  - [ ] SLA dashboard for the verification team
  - [ ] Auto-rejection rules + appeal flow
- [ ] **Payouts**
  - [ ] Stripe Connect onboarding for creators
  - [ ] Weekly Friday payouts
  - [ ] Tax forms (T4A for CA creators)
- [ ] **Disputes & refunds**
  - [ ] Customer "report issue" flow
  - [ ] Admin dispute queue
  - [ ] Automated partial refund rules
- [ ] **Reviews**
  - [ ] Two-way reviews after every completed booking
  - [ ] Aggregate ratings on profile + per-service

## Q4 2026 — Discovery & growth

**Goal:** customers find the right creator in <30s.

- [ ] **Search**
  - [ ] Free-text search across name, tagline, bio, services
  - [ ] "Available this weekend" filter
  - [ ] Map view with proximity ranking
- [ ] **Recommendations**
  - [ ] "Because you booked X" on home
  - [ ] Personalised email digest (weekly)
- [ ] **Mobile apps** (iOS first)
- [ ] **Referrals**
  - [ ] Customer-side: $10 credit for each friend who books
  - [ ] Creator-side: skip the verification queue for referred creators

## Q1 2027 — B2B & multi-city

**Goal:** Calgary + Seattle pilots; revenue from corporate accounts.

- [ ] **Multi-city architecture** — city-scoped categories, neighborhoods, search
- [ ] **B2B portal** — corporate accounts can book on behalf of employees (perks, events)
- [ ] **Calendar sync** — Google Calendar 2-way for creators
- [ ] **In-app messaging** between client and creator
- [ ] **Public API** for partner integrations (insurance providers, trade associations)

## Q2 2027 — Series A prep

**Goal:** make ourselves boring enough to fund.

- [ ] **SOC 2 readiness** — security audit, vendor reviews, BCP
- [ ] **Analytics + cohorts** — CAC, LTV, contribution margin per category
- [ ] **Multi-language** — first French (Montreal), then traditional Chinese (Richmond)
- [ ] **Insurance partnership** — bundled coverage for VIP plan

---

## Things we're deliberately NOT building (yet)

- **Workforce management for big employers.** Different product, different sales motion.
- **Same-day on-demand.** Margin-killer; we'd compete with Uber-style logistics. Pass for now.
- **AI-generated profiles.** Trust is our moat; AI fluff dilutes it.
- **NFT/Web3 anything.** No.

---

## Engineering principles

1. **Stateless services, stateful data.** SQLite is the MVP store; swap to Postgres when we hit ~50K bookings.
2. **No frameworks on the frontend** until the team gets bigger than 3 people. Vanilla JS is cheap and fast.
3. **Tests on the critical paths.** Auth, bookings, payments, admin. Not 100% coverage.
4. **One-command deploys.** `docker compose up -d --build` is the bar.
5. **Boring, proven tech.** PostgreSQL, Stripe, S3, Cloudflare. We don't want to be the first user of anything.
