# Insurance

Policy-admin domain. Does not copy banking SQL. Customer 360 `ref()`s the public models below.

| Model | Access | Grain |
|---|---|---|
| `insurance_customer` | public, contracted | insurance customer |
| `insurance_policies` | public, contracted | insurance customer |

## Wire-up in dbt Cloud / Fusion

1. Create a project whose subdirectory is `insurance`.
2. Build after seeds are loaded. This project has no upstream project dependency.
3. Public models: `insurance_customer`, `insurance_policies`.

## Exercises

See [EXERCISES.md](../EXERCISES.md). Insert a negative premium and clear `warn_insurance_policies_non_negative`. Names stay `insurance_*`.
