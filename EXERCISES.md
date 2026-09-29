# dbt Platform exercises

The Banking project (`op_banking`) is already built in Production. Create a feature branch from `main` in Studio IDE. You can use the Run, Build, Test, and Preview icons in the interface for the relevant model, or enter commands in the Command bar at the bottom of Studio IDE.

---

## 1. Find the customer warning

**Problem:** A Production test warns that a customer has an invalid status. Find the customer before changing any data.

1. Open **Catalog**, select **Production**, and open the **account lineage** (or Explore lineage) view so you can see how models connect across the account.
2. From lineage, open the relevant model: `banking_customer` in `op_banking`.
3. Open the model’s **Tests** and find the `customer_status` warning. Allowed values are `active`, `inactive`, and `closed`.
4. Open the test and click **Preview** to inspect the failing rows. You can also click Edit in Studio on the model and use the Preview icon there.

**Finish when:** You know which customer is causing the warning and what status they have.

---

## 2. Reproduce and fix it in development

**Problem:** Your development schema is empty, so the Production row is not available there yet.

1. Open `op_banking` → Develop → Studio IDE. In the Defer menu beside the Command bar, select **Development environment**.
2. Try the Preview icon on `banking_customer`. The development relation does not exist yet.
3. In the Command bar, run:
   ```bash
   dbt clone --select banking_customer
   ```
4. Click Preview again, or open the test and preview its failing rows. Find the same customer and invalid status.
5. In `seeds/customers.csv`, change the status to `active`, `inactive`, or `closed`.
6. Build `customers` and `banking_customer` using the interface icons or run:
   ```bash
   dbt build --select customers banking_customer --exclude banking_products
   ```
7. Check the test result and preview the corrected row.

**Finish when:** The warning is gone and the corrected status appears in development.

**Defer:** When working on a selected model, choose **Production** in the Defer menu to use existing Production parents without building them in development. Switch back to **Development environment** when you want to inspect only your development relations. [docs.getdbt.com](https://docs.getdbt.com/reference/commands/clone)

---

## 3. Review the pull request checks

**Problem:** The fix must pass both dbt CI and the repository’s naming rule.

1. Commit and push your change, then open a PR against `main`.
2. In the PR’s Checks, open the dbt CI run. Check which models and tests ran. `DEMO_CI` uses `state:modified+` and defers unchanged parents to Production. [docs.getdbt.com](https://docs.getdbt.com/docs/deploy/continuous-integration)
3. To try the naming check, temporarily rename `models/marts/banking_products.sql` to `models/marts/BankProducts.sql` and push. Read the GitHub Actions `ci` failure.
4. Restore the filename, push again, and confirm both checks pass.

**Finish when:** You can open the dbt run from the PR and see both checks passing.

---

## 4. Break a contract and review the impact

**Problem:** `banking_customer` is a public contracted model. A missing contracted column should be caught before it reaches Production.

1. On a new branch, open `models/marts/banking_customer.sql` in Studio IDE and remove `party_key` from the final select. Leave `contract.enforced: true` and the column declaration in `models/marts/_marts.yml`.
2. Click the model’s Build icon or run `dbt build --select banking_customer`. Open the contract error in the run results.
3. Commit and push the change to a PR. From the PR’s dbt check, open **Advanced CI → Compare changes** to review what changed relative to Production. Check the result written back to GitHub.
4. Restore `party_key`, push again, and confirm the build and CI pass. In Catalog, open `banking_customer` lineage to see `banking_products` and other downstreams.

**Finish when:** You have seen the contract failure, reviewed the PR in Advanced CI, and restored a passing build. Do not merge the version with the missing column. [docs.getdbt.com](https://docs.getdbt.com/docs/mesh/govern/model-contracts)

---

## 5. Use a shared macro

**Problem:** Banking needs a hashed customer name. The `anonymize` package contains the shared implementation.

1. In Studio IDE, inspect `packages.yml` and `anonymize/`. Run `dbt deps` in the Command bar.
2. Add these columns to `models/marts/banking_customer.sql`:
   ```sql
   full_name::varchar as full_name,
   {{ anonymize('full_name') }} as full_name_hash,
   ```
3. Add both columns to the enforced contract in `models/marts/_marts.yml` with `data_type: varchar`.
4. Click Build on `banking_customer` or run:
   ```bash
   dbt build --select customers banking_customer --exclude banking_products
   ```
   Click Preview to compare the two columns.

**Finish when:** The build passes and `full_name_hash` contains a digest rather than the clear name.

---

## 6. Publish your customer segmentation

**Problem:** Segment the `customer_360` feature table (with a recommended action per customer), then fold every published segmentation into one union model.

1. Open `op_customer_360` → Develop → Studio IDE and create a branch. Preview `customer_360` first — note `customer_id_hash` from the `anonymize` macro.
2. Copy `models/marts/demo_customer_segmentation.sql` to `models/marts/<your_name>_customer_segmentation.sql`.
3. Adjust the `case` rules. Output `customer_id`, `segment`, `recommended_action`, and `as_of_date`.

   Suggested segments: `payment_distress`, `claims_friction`, `commercial_whale`, `dormant_wealth`, `wealth_opportunity`, `onboarding`, `loyalist`, `credit_intensity`, `commercial_expand`, `unclassified`.

   Suggested actions: `payment_support`, `claim_resolution`, `wealth_management`, `business_banking`, `reactivation`, `retain`.

4. Add your model to `models/marts/_marts.yml` with `access: public` and a short author description.
5. Build your model. Then edit `customer_segmentation_model.sql` and add a `union all` branch that `ref()`s your model (see the commented example in that file). Build `customer_segmentation_model`.
6. Open a PR, merge, and confirm Production shows both your model and your rows inside `customer_segmentation_model`.

**Finish when:** `ref('op_customer_360', 'customer_segmentation_model')` includes your author, segments, and recommended actions.
