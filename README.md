# op_banking

Five dbt platform projects in one GitHub repo (`op_banking`):

| Directory | Platform project | Public marts |
|---|---|---|
| *(repo root)* | `op_banking` | `banking_customer`, `banking_products` |
| `insurance/` | `op_insurance` | `insurance_customer`, `insurance_policies` |
| `wealth/` | `op_wealth` | `wealth_customer`, `wealth_portfolios` |
| `financials/` | `op_financials` | `customer_profitability` (`customer_revenue` and `customer_cost` stay protected) |
| `customer_360/` | `op_customer_360` | `customer_360` feature table (+ `next_best_action`) |
