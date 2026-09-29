# Customer 360

One public model: `customer_360`. It is built only from cross-project `ref()`s:

| Upstream project | Models |
|---|---|
| `op_banking` | `banking_customer`, `banking_products` |
| `op_insurance` | `insurance_customer`, `insurance_policies` |
| `op_wealth` | `wealth_customer`, `wealth_portfolios` |
| `op_financials` | `customer_profitability` |

Grain is one row per `party_key`. `customer_id_hash` uses the shared `anonymize` package.

## Wire-up

1. Project subdirectory `customer_360`, run `dbt deps` (local `../anonymize`).
2. Upstream projects must already be built in Production (or deferred).
3. `dbt build`.

## Exercises

See [EXERCISES.md](../EXERCISES.md).
