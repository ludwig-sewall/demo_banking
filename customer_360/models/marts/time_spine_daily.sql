select cast(date_day as date) as date_day
from {{ ref('spine_days') }}
