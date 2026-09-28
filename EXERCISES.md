# dbt Platform exercises

The Banking project (`demo_banking`) is already built in Production. Create a feature branch from `main` in Studio IDE. You can use the Run, Build, Test, and Preview icons in the interface for the relevant model, or enter commands in the Command bar at the bottom of Studio IDE.

---

## 1. Find the customer warning

**Problem:** A Production test warns that a customer has an invalid status. Find the customer before changing any data.

1. Open Catalog, select Production, and search for `banking_customer`.
2. Open the model’s Tests and find the `customer_status` warning. Allowed values are `active`, `inactive`, and `closed`.
3. Open the test and click Preview to inspect the failing rows. You can also click Edit in Studio on the model and use the Preview icon there.

**Finish when:** You know which customer is causing the warning and what status they have.

---

## 2. Reproduce and fix it in development

**Problem:** Your development schema is empty, so the Production row is not available there yet.

1. Open `demo_banking` → Develop → Studio IDE. In the Defer menu beside the Command bar, select **Development environment**.
2. Try the Preview icon on `banking_customer`. The development relation does not exist yet.
3. In the Command bar, run:
   ```bash
   dbt clone --select banking_customer
   ```
4. Click Preview again, or open the test and preview its failing rows. Find the same customer and invalid status.
5. In `seeds/customers.csv`, change the status to `active`, `inactive`, or `closed`.
6. Build `customers` and `banking_customer` using the interface icons or run:
   ```bash
   dbt build --select customers banking_customer
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

**Problem:** Customer 360 depends on Banking’s public `banking_customer` model. A missing contracted column should be caught before it reaches Production.

1. On a new branch, open `models/marts/banking_customer.sql` in Studio IDE and remove `party_key` from the final select. Leave `contract.enforced: true` and the column declaration in `models/marts/_marts.yml`.
2. Click the model’s Build icon or run `dbt build --select banking_customer`. Open the contract error in the run results.
3. Commit and push the change to a PR. From the PR’s dbt check, open **Advanced CI → Compare changes** to review what changed relative to Production. Check the result written back to GitHub.
4. Restore `party_key`, push again, and confirm the build and CI pass. In Catalog, open the model’s lineage to see its Customer 360 dependency.

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
4. Click Build on `banking_customer` or run `dbt build --select banking_customer`. Click Preview to compare the two columns.

**Finish when:** The build passes and `full_name_hash` contains a digest rather than the clear name.

---

## 6. Publish your own next best action model

**Problem:** Customer 360 has starter recommendation logic. Complete your own version and publish it for other projects.

1. Open `demo_banking_customer_360` → Develop → Studio IDE and create a branch.
2. Duplicate `models/marts/next_best_action.sql` as `models/marts/<your_name>_next_best_action.sql`.
3. Complete the case logic. Output `party_key`, `recommended_action`, and `as_of_date`:

   | Condition | Recommended action |
   |---|---|
   | Loss making with loans | `restructure_credit` |
   | Banked with no policy | `offer_insurance` |
   | Profitable with no wealth product | `offer_wealth` |
   | Large AUM | `priority_review` |
   | Otherwise | `retain` |

4. Add the model to `models/marts/_marts.yml` with `access: public` and a description naming you as the author.
5. Click Build and Preview on your model, or run `dbt build --select <your_name>_next_best_action`.
6. Open a PR, review the CI checks, and merge. After the Production job runs, find your model in Catalog.

**Finish when:** Your public model is available in Production for another project to reference with `ref('demo_banking_customer_360', '<your_name>_next_best_action')`.
