# Exercises

Each exercise has a **point** (what you are learning) and **steps** (what to do). Work in a branch off `main`. The dbt Cloud CI job already uses state selection and defers to Production:

```text
dbt build --select state:modified+
```

GitHub Actions `ci` / `cd` run `scripts/check_naming.py` on every pull request and merge.

---

## 1. Naming standard (GitHub Action)

**Point:** Model file names are enforced in CI by a GitHub Action, not only by convention.

**Rules**

| Project | Allowed model files |
|---|---|
| Banking (repo root) | `banking_<noun>.sql` |
| Insurance | `insurance_<noun>.sql` |
| Wealth | `wealth_<noun>.sql` |
| Financials | `customer_<noun>.sql` |
| Customer 360 | `group_customer`, `customer_360`, `customer_profit_month`, `next_best_action`, `time_spine_daily` |

Tests must be `assert_*` or `warn_*`.

**Steps**

1. In Banking, rename `models/marts/banking_products.sql` → `models/marts/BankProducts.sql` (and update any refs / YAML name if needed).
2. Open a pull request.
3. Watch GitHub Actions: `ci` fails on `scripts/check_naming.py`.
4. Rename it back to `banking_products.sql`, push, confirm CI goes green.

---

## 2. Fresh development copy (clone / defer)

**Point:** Development starts empty. Unchanged models should be **read from Production**, not rebuilt from scratch every time. That is what `dbt clone` (local) and CI defer-to-Production (Cloud) are for.

**Setup trap:** After Create, Production already has a successful build. Your personal DEV schema does not.

**Steps**

1. Open a branch. Change **only** a comment in `models/marts/banking_customer.sql` (no logic change).
2. In an empty DEV target, run:
   ```bash
   dbt build --select state:modified+
   ```
   without cloning first. You either rebuild far more than the one file, or refs to untouched upstreams/seeds behave differently than Production.
3. Copy Production into DEV, then build only what changed:
   ```bash
   dbt clone
   dbt build --select state:modified+
   ```
4. Confirm only `banking_customer` (and anything downstream of it) ran, while unmodified models were satisfied from the cloned Production relations.

In dbt Cloud CI this is automatic: the job defers to the Production environment and runs `state:modified+`.

**Optional freshness twist:** bump `loaded_at` on one seed row, run `dbt source freshness`, then:

```bash
dbt build --select state:modified+ source_status:fresher+
```

That builds models whose **code** changed **or** whose **source data** got newer.

---

## 3. Data quality warning (Banking)

**Point:** A singular warning test catches values outside the allowed status list.

**What is wrong:** Priya Shah (`party_key` `P-1009`, banking customer `B-1009`) has `customer_status = frozen` in `seeds/customers.csv`. `banking_customer` only allows `active`, `inactive`, or `closed`, so `warn_*` (or the accepted-values test) fires.

**Steps**

1. Run `dbt build` in Banking and find the warning for Priya Shah / `frozen`.
2. Change her seed status to `active` (or `inactive` / `closed`).
3. Rebuild and confirm the warning is gone.

---

## 4. Break a model contract (same project)

**Point:** A model contract fails the build when the SQL no longer matches the enforced YAML columns.

**Steps**

1. Open `models/marts/banking_customer.sql` and remove the `customer_status` column from the select.
2. Run `dbt build --select banking_customer`.
3. Read the contract error (column missing / mismatch).
4. Put `customer_status` back and rebuild until green.

Repeat the same drill on `insurance_policies` or `wealth_portfolios` if you want.

---

## 5. Break a cross-project contract (Mesh)

**Point:** Customer 360 depends on **contracted** public models from Banking (and the other domains). Removing a contracted column upstream breaks the downstream project, not only the local build.

**Steps**

1. In Banking, remove a contracted column that Customer 360 needs from `banking_customer` (for example `party_key` or `customer_status` — use whatever is `contract: enforced` and selected downstream).
2. Build Banking. The local contract should fail; if you temporarily weaken the YAML to force a ship, continue.
3. In Customer 360, run `dbt build` (or build `customer_360` / `group_customer`).
4. See the cross-project failure: the downstream `ref()` / contract no longer matches the upstream public model.
5. Restore the column and the YAML, rebuild Banking, then rebuild Customer 360.

---

## 6. Domain data warnings

**Insurance:** set one `annual_premium` in `insurance/seeds/policies.csv` negative → `warn_insurance_policies_non_negative` → fix the row.

**Wealth:** set one open portfolio `market_value` negative in `wealth/seeds/portfolios.csv` → warning → fix.

**Financials:** Noah Keller is missing a revenue month, or Amira Haddad is missing cost months. Fill the seed **or** leave it and read the warning. Optionally break the `profit` contract on `customer_profitability` (change type to `varchar`, build, restore `number(18,2)`).

---

## 7. Customer 360 logic + semantic layer

**Point:** `next_best_action` is intentionally unfinished, and the semantic model is how you slice governed metrics.

**Steps**

1. Read `warn_party_in_one_domain` and `warn_customer_360_coverage_gaps`.
2. In `next_best_action.sql`, uncomment the `when` branches and change `else 'todo'` to `else 'retain'`. Leave `when 1 = 0` so the `case` still parses.
3. Rebuild until every row is one of `restructure_credit`, `offer_insurance`, `offer_wealth`, `priority_review`, `retain`.
4. Query the semantic model (Fusion):

```bash
dbt sl query --metrics customers,trailing_profit --group-by party__relationship,party__profit_band
dbt sl query --metrics customers,trailing_profit --group-by party__recommended_action
dbt sl query --metrics monthly_profit,monthly_revenue,monthly_cost --group-by metric_time__month
```

Or use the GitHub Pages chat under `docs/` (paste a Semantic Layer token in the page settings).
