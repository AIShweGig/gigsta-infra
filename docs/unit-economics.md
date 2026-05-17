# Gigsta — Unit Economics

Numbers below are **illustrative model assumptions** — replace with actuals
as you collect data. The structure is designed to be defensible to investors
and clear to operate against.

## Per-creator economics (Pro plan, steady-state)

| Metric | Assumption | Source/note |
|---|---|---|
| Avg booking value (ABV) | $85 | Weighted across categories (culinary higher, dog-walking lower) |
| Avg bookings / creator / month | 12 | Pro creators only; Beginner is much lower |
| GMV per creator per month | $1,020 | = ABV × bookings |
| Take rate (Pro) | 8.0% | Below market — our wedge |
| Take revenue / creator / month | $81.60 | |
| Subscription / creator / month | $10.00 | Pro plan |
| **Revenue per Pro creator / mo** | **$91.60** | |

## Cost to acquire & maintain (CAC + ongoing)

| Item | One-time | Monthly |
|---|---|---|
| Verification (ID + cred review) | $8 | — |
| Customer acquisition (paid + content) | $40 | — |
| Stripe fees (2.9% + $0.30) | — | ~$30 |
| Hosting + email + S3 | — | ~$0.50/creator |
| Support cost (allocated) | — | ~$2 |
| **Total** | **$48 CAC** | **~$32 ongoing** |

## Margin per creator

- Revenue: **$91.60/mo**
- Variable cost: **$32.50/mo**
- **Contribution margin: $59/creator/mo (~64%)**
- **CAC payback: $48 / $59 = ~0.8 months**

## LTV (12-month basis, with retention curve)

Assume creator monthly retention curve: M1 100% → M3 80% → M6 65% → M12 50%.

- Average lifetime: ~14 months on the platform
- LTV at $59/mo margin × 14 months = **~$826**
- **LTV / CAC = ~17x** (target is 3x+; we have headroom to spend more)

## Scenario tables

### Bear (slow customer acquisition, low ABV)
| | |
|---|---|
| Active creators (Y1) | 300 |
| ABV | $70 |
| Bookings / creator / mo | 6 |
| **Monthly GMV** | $126K |
| **Monthly revenue** | $13K |
| **ARR** | **$156K** |

### Base (the model above)
| | |
|---|---|
| Active creators (Y1) | 1,000 |
| ABV | $85 |
| Bookings / creator / mo | 12 |
| **Monthly GMV** | $1.02M |
| **Monthly revenue** | $92K |
| **ARR** | **$1.1M** |

### Bull (multi-city working, high engagement)
| | |
|---|---|
| Active creators (Y2) | 3,500 |
| ABV | $95 |
| Bookings / creator / mo | 18 |
| **Monthly GMV** | $5.99M |
| **Monthly revenue** | $570K |
| **ARR** | **$6.8M** |

## Sensitivities (what really moves the needle)

1. **Bookings per creator per month** — biggest lever. Going from 8 to 14 doubles ARR.
2. **Retention** — losing creators on month 3 vs month 12 is a 2.5x LTV gap.
3. **ABV** — category mix matters. Adding culinary catering (ABV $300+) is worth as much as 4x dog-walking creators.

## What we're betting on

- **Verification + trust commands a premium take rate later.** Today 8% is a wedge; we can raise to 10–12% on VIP without churn once the brand sticks.
- **Word-of-mouth replaces paid acquisition by month 9.** Local marketplaces compound; CAC drops as soon as 5 creators in a neighborhood become 20.
- **B2B is 4x ABV at half the CAC.** Corporate accounts (perks, events) buy in volume.
