# demo_banking

Group customer 360 for the portal **PoC → Demo project** flow. Five dbt projects in one repo. Domain projects publish contracted models. Customer 360 only `ref()`s those contracts.

| Subdirectory | Project | Public models |
|---|---|---|
| *(repo root)* | `demo_banking` | `banking_customer`, `banking_products` |
| `insurance/` | `demo_banking_insurance` | `insurance_customer`, `insurance_policies` |
| `wealth/` | `demo_banking_wealth` | `wealth_customer`, `wealth_portfolios` |
| `financials/` | `demo_banking_financials` | `customer_profitability` (`customer_revenue` and `customer_cost` stay protected) |
| `customer_360/` | `demo_banking_customer_360` | `customer_360` (`group_customer` stays protected) |

Exercises for each project are in [EXERCISES.md](EXERCISES.md). Model names are snake_case with a prefix per project. GitHub `ci` and `cd` run that check. Customer 360 publishes a semantic model on `customer_360`. CI jobs use **state selection** (`dbt build --select state:modified+`) and defer to Production.

The repo also ships a small **GitHub Pages** chat UI under [`docs/`](docs/) that talks to the Customer 360 semantic metrics (paste a Semantic Layer service token in the page settings).

Choosing **Banking** in PoC → Demo project and creating the stack stands up all five dbt platform projects from this repo. The root project is Banking. The other four use the subdirectories above, and Customer 360 is linked to the four upstream projects. **dbt build** in the portal runs the domain projects first, then Customer 360, so the cross-project refs have a production manifest.

`demo_as_of_date` is 2026-03-31. Profit in Customer 360 is the trailing twelve months, and the seed history is October 2025 through March 2026.

## Profiles in the book

Names live on the seeds. The marts expose ids and measures.

| Party | Name | What the 360 shows |
|---|---|---|
| P-1001 | Elena Voss | Full relationship. Mortgage, two policies, two portfolios. Steady profit. |
| P-1002 | Jonas Berg | Levered and loss-making. Lapsed cover, no wealth. Profit below the floor. |
| P-1003 | Amira Haddad | Insurance only. January and February cost allocations are missing, so those months drop out of profit. |
| P-1004 | Marcus Okonkwo | Wealth whale, one checking account, no insurance. March revenue is an outlier. |
| P-1005 | Sofia Lind | Closed in every domain. Holdings are zero. Profit has already faded. |
| P-1006 | Chen Wei | Bank and a single auto policy. No wealth relationship. |
| P-1007 | Rivera Family Office | Insurance and wealth, no bank relationship. |
| P-1008 | Noah Keller | New banking-only customer. February revenue was not priced. Thin, slightly unprofitable. |
| P-1009 | Priya Shah | In all three books, but the banking status is `frozen`, outside the accepted list. |
| P-1010 | Harbor Logistics | Inactive bank relationship with a negative loan balance and a loss every month. |
| P-1011 | Lina Costa | Small wealth client. No banking, no insurance, and no finance rows, so `profit_12m` is null. |

## Tests that should warn

Error tests pass on this book. These warnings are the interesting rows:

- Banking status `frozen` on Priya Shah
- Negative loan balance on Harbor Logistics
- Missing February revenue on Noah Keller, and Marcus Okonkwo's March revenue above 50,000
- Missing cost allocation for Amira Haddad in January and February
- Profit below zero for Jonas Berg, Harbor Logistics, the thin Noah Keller months, and Sofia Lind after she churned
- Party found in only one domain: Amira Haddad, Noah Keller, Harbor Logistics, Lina Costa
- Customer 360 coverage gap for those same single-domain parties, and missing profit for Lina Costa
- `next_best_action` is `todo` until the case branches are uncommented

## Exercises

See [EXERCISES.md](EXERCISES.md). Fix Priya Shah's `frozen` status, or drop a contracted column and restore it. Names stay `banking_*`. `customers.loaded_at` drives `source_status:fresher`.
