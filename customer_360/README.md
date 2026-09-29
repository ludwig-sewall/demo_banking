# Customer 360

Feature table for group customers: domain revenue, payment and claims signals, service notes, and current interest. Ready for a later segmentation model on the same grain.

| Model | Access | Grain |
|---|---|---|
| `customer_360` | public, contracted, semantic model | customer |
| `demo_customer_segmentation` | public, contracted | customer |
| `customer_segmentation_model` | public, contracted | customer + author |
| `mesh_lineage_anchors` | protected | domain |
| `customer_profit_month` | protected | party + month (mesh lineage) |
| `time_spine_daily` | protected | day |

`customer_360` is seeded from `customer_book` and hashes `customer_id` with the shared `anonymize` package (`customer_id_hash`). Totals and monthly averages are computed in SQL.

Semantic layer is intentionally thin: a few revenue / risk metrics and `current_interest` / `banking_payment_remark` dimensions.

Workshop exercise 6: copy `demo_customer_segmentation` to `<developer>_customer_segmentation_model` (segment + recommended_action). `customer_segmentation_model` remains an optional union of published segmentations.

`mesh_lineage_anchors` refs public models from banking, insurance, wealth, and financials so Account Lineage shows the full mesh.

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
| C016 | Dual-income mortgage top-up | Refinance / retain |
| C017 | Large idle deposits | Wealth cross-sell |
| C018 | Monthly equity DCA | Investment plan |
| C019 | Divorce payment distress | Payment support |
| C020 | Delayed storm claim | Claim resolution |
| C021 | Group treasury RFP | Commercial whale |
| C022 | Late cards + credit ask | Credit increase |
| C023 | High AUM, silent 18 months | Reactivation |
| C024 | First-home insurance shopper | Bundled protection |
| C025 | Family office cash elsewhere | Cash management |
| C026 | Happy multi-product | Advocacy / retain |
| C027 | Many micro claims | Fraud watch |
| C028 | Seasonal inventory RCF | Working capital |
| C029 | Hardship application | Hardship support |
| C030 | Student digital account | Onboarding nudge |
| C031 | Green renovation loan | Credit increase |
| C032 | Insurance-only open claim | Claim resolution |
| C033 | SME personal + business | Business banking |
| C034 | Advisory → discretionary | Investment plan |
| C035 | Clinic group expansion | Working capital |

## Wire-up

1. Project subdirectory `customer_360`, run `dbt deps` (local `../anonymize`).
2. Upstream deps in `dependencies.yml` still support `customer_profit_month`.
3. `dbt build`.

## Exercises

See [EXERCISES.md](../EXERCISES.md). Copy `demo_customer_segmentation` to `<developer>_customer_segmentation_model` (segment + recommended_action) and build it.
