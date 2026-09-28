# Customer 360

Cross-domain party view. This project does not copy producer SQL. It `ref()`s public models from banking, insurance, wealth, and financials.

| Model | Access | Grain |
|---|---|---|
| `group_customer` | protected | party |
| `customer_360` | public, contracted, semantic model | party |
| `next_best_action` | public, contracted | party |
| `customer_profit_month` | protected, semantic model | party + month |
| `time_spine_daily` | protected | day |

`profit_12m` sums `customer_profitability` for months inside the trailing twelve months ending on `demo_as_of_date` (2026-03-31). The demo book runs October 2025 through March 2026, so the published figure is that window.

## Wire-up in dbt Cloud / Fusion

1. Create a project whose subdirectory is `customer_360`.
2. Add project dependencies on `demo_banking`, `demo_banking_insurance`, `demo_banking_wealth`, and `demo_banking_financials`. `dependencies.yml` lists them.
3. Build the four upstream projects first, then `dbt build` here.

## Exercises

See [EXERCISES.md](../EXERCISES.md). Uncomment the `when` branches in `next_best_action` and replace `todo` with `retain`. Group the semantic model by `relationship`, `profit_band`, or `recommended_action`.
