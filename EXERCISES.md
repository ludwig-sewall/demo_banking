# Exercises

Run these from the project directory. CI defers to Production, so `state:` compares your branch with the last production build.

```bash
dbt clone
dbt build --select state:modified+
dbt source freshness
dbt build --select state:modified+ source_status:fresher+
```

`dbt clone` copies production tables into development. `state:modified+` builds models whose code changed, plus downstream. After you move a source `loaded_at` forward, `source_status:fresher+` also builds models fed by that new data.

Pipelines:

- GitHub Actions `ci` on a pull request, and `cd` on merge, run `scripts/check_naming.py`.
- The dbt CI job runs `dbt build --select state:modified+`.
- The dbt CD job runs `dbt build`.

## Naming

snake_case.

| Project | Model files |
|---|---|
| Banking | `banking_<noun>.sql` |
| Insurance | `insurance_<noun>.sql` |
| Wealth | `wealth_<noun>.sql` |
| Financials | `customer_<noun>.sql` |
| Customer 360 | `group_customer`, `customer_360`, `customer_profit_month`, `next_best_action`, `time_spine_daily` |

Tests are `assert_*` or `warn_*`.

## Banking

- Fix the warning. Priya Shah (`P-1009`) has status `frozen`. `banking_customer` only accepts `active`, `inactive`, `closed`.
- Break the contract. Remove `customer_status` from `models/marts/banking_customer.sql`, run `dbt build --select banking_customer`, then put the column back.
- Break the name. Rename `banking_products.sql` to `BankProducts.sql` and open a pull request. `ci` fails. Rename it back.

## Insurance

- Put a negative `annual_premium` on one row in `seeds/policies.csv`. `warn_insurance_policies_non_negative` warns. Fix the row.
- Same contract and naming drills as Banking, on `insurance_policies`.

## Wealth

- Put a negative market value on one open row in `seeds/portfolios.csv`. `warn_wealth_portfolios_non_negative` warns. Fix the row.
- Same contract and naming drills as Banking, on `wealth_portfolios`.

## Financials

- Fix one warning. Noah Keller is missing February revenue, or Amira Haddad is missing January and February cost. Fill the seed, or leave it and read the warning.
- Break the contract. Change `profit` on `customer_profitability` to `varchar`, build, then restore `number(18,2)`.

## Customer 360

- Read `warn_party_in_one_domain` and `warn_customer_360_coverage_gaps`. Amira Haddad, Noah Keller, Harbor Logistics, and Lina Costa sit in one book.
- Finish `next_best_action`. Uncomment the `when` branches and change `else 'todo'` to `else 'retain'`. Leave `when 1 = 0` so the `case` still parses. The warning clears when every row is one of `restructure_credit`, `offer_insurance`, `offer_wealth`, `priority_review`, `retain`.
- Query the semantic model on `customer_360`. Metrics: `customers`, `trailing_profit`, `total_assets_under_management`, `total_loan_balance`, `total_annual_premium`, `profit_per_customer`, `customers_in_loss`, `full_relationship_customers`. Group by `relationship`, `profit_band`, `recommended_action`, or `metric_time`.

On Fusion:

```bash
dbt sl query --metrics customers,trailing_profit --group-by party__relationship,party__profit_band
dbt sl query --metrics customers,trailing_profit --group-by party__recommended_action
dbt sl query --metrics monthly_profit,monthly_revenue,monthly_cost --group-by metric_time__month
```
