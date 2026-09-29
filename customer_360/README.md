# Customer 360

Feature table for group customers: domain revenue, payment and claims signals, service notes, and current interest. Ready for a later `customer_segmentation_model` on the same grain.

| Model | Access | Grain |
|---|---|---|
| `customer_360` | public, contracted, semantic model | customer |
| `next_best_action` | public, contracted | customer |
| `customer_profit_month` | protected | party + month (mesh lineage) |
| `time_spine_daily` | protected | day |

`customer_360` is seeded from `customer_book` and hashes `customer_id` with the shared `anonymize` package (`customer_id_hash`). Totals and monthly averages are computed in SQL.

Semantic layer is intentionally thin: a few revenue / risk metrics and `current_interest` / `banking_payment_remark` dimensions.

## Patterns in the book

| Id | Pattern | Why it matters later |
|---|---|---|
| C001 | Rate-shop mortgage + portfolio review | Refinance / retain |
| C002 | Deposit-heavy, no wealth revenue | Classic wealth cross-sell |
| C003 | Monthly investor, no insurance | Investment plan |
| C004 | Gambling loss + missed payments | Distress / payment support |
| C005 | Claims contact storm | Claim resolution |
| C006 | €50M business prospect | Commercial whale |
| C007 | Late payment + credit ask | Credit increase |
| C008 | High AUM, silent for 14 months | Reactivation |
| C009 | Quote-shopper, near end of student loan | Bundled protection |
| C010 | Wealth-only family office | Cash management |
| C011 | Happy multi-product | Advocacy / retain |
| C012 | Many small paid claims | Fraud watch |
| C013 | Seasonal SME facility | Working capital |
| C014 | Job-loss hardship | Hardship support |
| C015 | Brand-new digital account | Onboarding nudge |

## Wire-up

1. Project subdirectory `customer_360`, run `dbt deps` (local `../anonymize`).
2. Upstream deps in `dependencies.yml` still support `customer_profit_month`.
3. `dbt build`.

## Exercises

See [EXERCISES.md](../EXERCISES.md). Complete `next_best_action` from the 360 feature columns.
