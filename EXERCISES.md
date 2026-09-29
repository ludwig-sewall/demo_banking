# dbt Platform exercises

The Banking project (`op_banking`) is already built in Production. Create a feature branch from `main` in Studio IDE. Use the Preview, Build, and Test icons on models as you work, or enter commands in the Command bar.

---

## 1. Find the customer warning

A Production test warns that a customer has an invalid status. Start with the wider lineage to understand where the model fits.

1. In Catalog, select **Production**. Explore the account-level lineage, then zoom into the `op_banking` project lineage.
2. Open `banking_customer` and find the warning on its `customer_status` test. Valid values are `active`, `inactive`, and `closed`.
3. Open the test and click **Preview** to see the failing row. Then choose **Edit in Studio** to open the model in Studio IDE.

**Done when:** You know which customer caused the warning and what status the model returned.

---

## 2. Fix the warning in development

Your development schema is empty. Use deferral and a clone to bring the Production model into development, then fix the status in code. Leave `seeds/customers.csv` unchanged.

1. In Studio IDE, enable the **Defer** toggle beside the Command bar and select **Production** as the environment to defer to.
2. Run the following command to clone `banking_customer` into your development schema with fresh Production data:

   ```bash
   dbt clone --select banking_customer
   ```

3. Preview the model or the failing test rows to find the same customer.
4. Edit the SQL that produces `customer_status` so it handles the customer’s source value correctly. Keep the accepted values test.
5. Click **Build** on the affected model, then Preview the corrected row and check the test result.

**Done when:** The customer has the intended status in development and the warning is gone.

---

## 3. See what happens when you open a PR

1. Commit and push your change from Studio IDE, then open a PR against `main`.
2. A dbt CI job runs automatically. Open it from the PR’s Checks to see which models and tests ran.
3. The Platform handles state selection and deferral using the Production state: CI runs the changed models and their downstream dependencies while reusing unchanged Production parents.
4. Review the dbt metadata written back to the PR, including the run result and any model or test failures.
5. To try the repository’s naming check, temporarily rename `models/marts/banking_products.sql` to `models/marts/BankProducts.sql` and push. Read the GitHub Actions `ci` failure, then restore the filename and push again.

**Done when:** The dbt CI and naming checks both pass on the PR.

---

## 4. Break a model contract

`banking_customer` has an enforced contract. Try removing a required column and see the error before the change reaches Production.

1. In Studio IDE, remove `party_key` from the final select in `models/marts/banking_customer.sql`. Leave the column declaration and `contract.enforced: true` in `models/marts/_marts.yml`.
2. Click **Build** on `banking_customer` and open the contract error in the run results.
3. Restore `party_key` and build again.

**Done when:** You have seen the contract failure and restored a passing build.

---

## 5. Apply a shared standard across domains

When several domains publish customer data, shared macros help them apply the same transformation consistently. Banking will use the `anonymize` package to hash customer names.

1. In Studio IDE, inspect `packages.yml` and `anonymize/`. Run `dbt deps` in the Command bar.
2. Add these columns to `models/marts/banking_customer.sql`:

   ```sql
   full_name::varchar as full_name,
   {{ anonymize('full_name') }} as full_name_hash,
   ```

3. Add both columns to the enforced contract in `models/marts/_marts.yml` with `data_type: varchar`.
4. Click **Build**, then Preview `banking_customer` to compare the clear name and its hash.

**Done when:** The build passes and `full_name_hash` contains a digest rather than the clear name.

---

## 6. Create a customer segmentation model

Build a segmentation directly in the `op_customer_360` project, with a recommended action for each customer.

1. Open `op_customer_360` → Develop → Studio IDE and create a branch. Preview `customer_360` to see the available customer signals.
2. Copy `models/marts/demo_customer_segmentation.sql` to `models/marts/<developer>_customer_segmentation_model.sql`.
3. Edit the case rules. Return `customer_id`, `segment`, `recommended_action`, and `as_of_date`. Use `ref('customer_360')` to read the model in the same project.

   Possible segments: `payment_distress`, `claims_friction`, `commercial_whale`, `dormant_wealth`, `wealth_opportunity`, `onboarding`, `loyalist`, `credit_intensity`, `commercial_expand`, `unclassified`.

   Possible actions: `payment_support`, `claim_resolution`, `wealth_management`, `business_banking`, `reactivation`, `retain`.

4. Click **Build** on your model, then Preview the segments and recommended actions.

**Done when:** Your `<developer>_customer_segmentation_model` builds and returns an action for each customer.
