# Exercises

Work in a feature branch off `main`. The banking mesh is already built in **Production**. Use the **Banking** project (`demo_banking`) unless a step says otherwise.

---

## Finding and fixing

### 1. Find the warning in Catalog

**Point:** Catalog surfaces job warnings from Production so you do not need to rediscover them in SQL.

1. Open the **demo_banking** project in dbt platform → **Catalog** (or the latest Production run).
2. Find the warning on **`banking_customer`**.
3. Confirm it is about **Priya Shah** (`party_key` `P-1009` / `B-1009`) whose `customer_status` is `frozen`.
4. Allowed values are only `active`, `inactive`, and `closed`.

Keep that finding — you will fix it after you can see the same row in development.

### 2. Reproduce in development with `dbt clone`

**Point:** Your DEV schema starts empty. You will not see Production’s `customer_status` values unless you copy Production relations into DEV.

1. Point your profile at the **Development** target (empty schema).
2. Try to inspect the live table without cloning, for example:
   ```bash
   dbt show --select banking_customer --limit 20
   ```
   or query `banking_customer` in the DEV database. The table is missing (or empty) — you cannot see Priya’s `frozen` status yet.
3. Copy Production into DEV:
   ```bash
   dbt clone
   ```
4. Inspect again. You should now see Priya Shah with `customer_status = frozen` from the cloned Production table.
5. Fix the source of truth: in `seeds/customers.csv`, change Priya’s status from `frozen` to `active` (or `inactive` / `closed`).
6. Rebuild the model (and its seed if needed):
   ```bash
   dbt build --select customers banking_customer
   ```
7. Confirm the warning is gone and Priya’s status looks correct.

### 3. State reuse on the second build

**Point:** Slim CI / local state selection skips work when nothing relevant changed.

1. Without changing any more files, run:
   ```bash
   dbt build --select state:modified+
   ```
2. Confirm dbt reports **nothing to do** (or does not rebuild `banking_customer` again) because state sees no new model or source changes.
3. Optional: bump `loaded_at` on one seed row, run `dbt source freshness`, then:
   ```bash
   dbt build --select state:modified+ source_status:fresher+
   ```
   That rebuilds only what the fresher source feeds.

### 4. Open a PR — CI runs state + naming

**Point:** A pull request starts Cloud CI (changed models only) and GitHub Actions (naming rules) together.

1. Create a branch and commit a **small intentional naming break**, for example rename:
   `models/marts/banking_products.sql` → `models/marts/BankProducts.sql`
2. Open a pull request against `main`.
3. Watch two checks start:
   - **GitHub Actions `ci`** — runs `scripts/check_naming.py` and should **fail** on `BankProducts`.
   - **dbt Cloud CI** — runs `dbt build --select state:modified+` and **defers to Production** so unchanged models are not rebuilt from scratch.
4. Rename the file back to `banking_products.sql`, push, and confirm naming CI goes green.

### 5. Open the CI job from GitHub

**Point:** The PR is the entry point into the dbt CI run.

1. From the pull request checks, open the **dbt Cloud CI** job link (or open **demo_banking** → Jobs → `DEMO_CI` → latest run).
2. Confirm the run used **state selection** (`state:modified+`) and deferred to Production.
3. Skim which nodes ran vs skipped.

### 6. Advanced CI and writeback to GitHub

**Point:** Advanced CI compares your PR to Production and can write findings back onto the pull request.

1. In the same CI run (or Job settings → CI), open **Advanced CI** / compare-changes output.
2. Check what would change vs Production (models added, modified, or removed).
3. Confirm the result is **written back to the GitHub PR** (check comment or status check on the pull request).
4. Merge only when both naming CI and dbt CI are green.

---

## Contracts and governance

### 1. Protect Customer 360 with upstream contracts

**Point:** Customer 360 consumes **public, contracted** models from Banking (and other domains). Breaking an upstream contract fails in Banking **before** you poison the mesh.

**Concrete example — remove a contracted column Banking publishes to Customer 360:**

1. Open `models/marts/banking_customer.sql` and remove `party_key` from the `select`.
2. Leave `models/marts/_marts.yml` as-is (`contract.enforced: true` still requires `party_key`).
3. Run:
   ```bash
   dbt build --select banking_customer
   ```
4. Read the **contract** failure: the SQL no longer matches the enforced YAML. That is the preflight — Banking refuses to ship a broken public interface.
5. (Optional, only to feel the mesh impact) If you temporarily disable the contract and force a bad build, open **demo_banking_customer_360** and run `dbt build --select group_customer customer_360`. Downstream `ref('banking_customer')` / column expectations fail.
6. Restore `party_key` in the SQL (and the contract if you changed it). Rebuild Banking, then Customer 360, until green.

Customer 360 should keep depending on `banking_customer`, `banking_products`, and the other domain public models — never on the raw seeds.

### 2. Native package: `anonymize`

**Point:** Shared logic lives in a **central dbt package**, not copy-pasted macros per project.

The repo includes a local package at `anonymize/` (declared in `packages.yml`). It exposes:

```sql
{{ anonymize('full_name') }}
```

which hashes the value with Snowflake `sha2` (demo stand-in for encryption / irreversible anonymization).

**Steps**

1. In the Banking project root:
   ```bash
   dbt deps
   ```
2. Extend `models/marts/banking_customer.sql` so it selects the name and a hashed copy:
   ```sql
   full_name::varchar as full_name,
   {{ anonymize('full_name') }} as full_name_hash,
   ```
3. Add both columns to the enforced contract in `models/marts/_marts.yml` (`data_type: varchar`).
4. Run `dbt build --select banking_customer` and confirm `full_name_hash` is a SHA-2 digest, not the clear name.
5. Keep or revert on your branch — either way you used the shared **`anonymize`** package instead of inlining `sha2(...)`.

---

## Build your own next best action

**Point:** Ship a personal variant of the NBA model with a clear owner prefix, then publish it for others to `ref()`.

1. Copy `customer_360/models/marts/next_best_action.sql` to:
   ```text
   customer_360/models/marts/<your_name>_next_best_action.sql
   ```
   Example: `ludwig_next_best_action.sql`.
2. Implement real `case` logic (uncomment / replace the `todo` branches). Output `party_key`, `recommended_action`, and `as_of_date`.
3. Add a model entry in `customer_360/models/marts/_marts.yml` with:
   - `access: public`
   - a short description that names you as the author
4. Naming CI allows `*_next_best_action` under Customer 360 — keep snake_case.
5. Open a PR, let CI run, merge.
6. After Production builds, another project (or a teammate) can:
   ```sql
   select * from {{ ref('ludwig_next_best_action') }}
   ```
   (use your model name).

Starter logic to finish (same rules as the shared `next_best_action` exercise):

- loss-making with loans → `restructure_credit`
- banked but no policy → `offer_insurance`
- profitable with no wealth → `offer_wealth`
- large AUM → `priority_review`
- else → `retain`
