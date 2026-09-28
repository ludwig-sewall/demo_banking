# Financials

Party-level revenue, cost, and profit. Revenue and cost stay protected inside this project. Customer 360 `ref()`s `customer_profitability` only.

| Model | Access | Grain |
|---|---|---|
| `customer_revenue` | protected | party + month |
| `customer_cost` | protected | party + month |
| `customer_profitability` | public, contracted | party + month |

Months with a null revenue total or a missing cost drop out of profit so `profit = revenue - cost` can be enforced. Those gaps stay visible on the protected models as warnings.

`revenue_outlier_warn` defaults to 50000. `profit_floor_warn` defaults to 0.

## Wire-up in dbt Cloud / Fusion

1. Create a project whose subdirectory is `financials`.
2. Build after seeds are loaded. This project has no upstream project dependency.
3. Public model: `customer_profitability`.

## Exercises

See [EXERCISES.md](../EXERCISES.md). Fill one missing revenue or cost month, or break the `profit` contract and restore it. Names stay `customer_*`. `revenue_transactions.loaded_at` drives `source_status:fresher`.
