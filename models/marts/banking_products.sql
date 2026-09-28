-- depends_on: {{ ref('accounts') }}
-- depends_on: {{ ref('loans') }}
with open_accounts as (
  select
    banking_customer_id,
    count(*) as account_count
  from {{ source('banking', 'accounts') }}
  where lower(account_status) = 'open'
  group by 1
),

outstanding_loans as (
  select
    banking_customer_id,
    count(*) as loan_count,
    sum(balance) as loan_balance
  from {{ source('banking', 'loans') }}
  where lower(loan_status) = 'outstanding'
  group by 1
)

select
  customers.banking_customer_id,
  coalesce(open_accounts.account_count, 0)::integer as account_count,
  coalesce(outstanding_loans.loan_count, 0)::integer as loan_count,
  coalesce(outstanding_loans.loan_balance, 0)::numeric(18, 2) as loan_balance
from {{ ref('banking_customer') }} as customers
left join open_accounts
  on customers.banking_customer_id = open_accounts.banking_customer_id
left join outstanding_loans
  on customers.banking_customer_id = outstanding_loans.banking_customer_id
