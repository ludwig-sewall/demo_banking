# Wealth management

Client and portfolio domain. Customer 360 `ref()`s the public models below.

| Model | Access | Grain |
|---|---|---|
| `wealth_customer` | public, contracted | wealth client |
| `wealth_portfolios` | public, contracted | wealth client |

## Wire-up in dbt Cloud / Fusion

1. Create a project whose subdirectory is `wealth`.
2. Build after seeds are loaded. This project has no upstream project dependency.
3. Public models: `wealth_customer`, `wealth_portfolios`.

## Exercises

See [EXERCISES.md](../EXERCISES.md). Insert a negative market value and clear `warn_wealth_portfolios_non_negative`. Names stay `wealth_*`.
