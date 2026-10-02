def model(dbt, session):
    """One-step revenue forecast per party from monthly history."""
    dbt.config(
        materialized="table",
        packages=["pandas", "numpy"],
    )

    from decimal import Decimal

    import numpy as np
    import pandas as pd

    # Fusion materializes a Python model by passing the return value to
    # create_dataframe(), which accepts a list, tuple, or pandas DataFrame.
    # A Snowpark DataFrame cannot be written.
    rows = dbt.ref("customer_revenue").collect()
    history = pd.DataFrame([row.as_dict() for row in rows])
    history.columns = [str(column).lower() for column in history.columns]
    history = history.dropna(subset=["party_key", "month", "revenue"]).copy()
    history["month"] = pd.to_datetime(history["month"])
    history["revenue"] = history["revenue"].astype(float)

    forecasts = []
    for party_key, group in history.groupby("party_key", sort=True):
        group = group.sort_values("month")
        revenues = group["revenue"].to_numpy()
        months = np.arange(len(revenues), dtype=float)
        if len(revenues) >= 2:
            slope, intercept = np.polyfit(months, revenues, 1)
            predicted = float(intercept + slope * len(revenues))
        else:
            slope = 0.0
            predicted = float(revenues[-1])
        if not np.isfinite(predicted):
            slope = 0.0
            predicted = float(revenues[-1])

        last_month = group["month"].iloc[-1]
        forecasts.append(
            (
                str(party_key),
                int(len(revenues)),
                last_month.date(),
                (last_month + pd.DateOffset(months=1)).date(),
                Decimal(str(round(float(revenues[-1]), 2))),
                Decimal(str(round(float(slope), 2))),
                Decimal(str(round(float(predicted), 2))),
            )
        )

    return pd.DataFrame(
        forecasts,
        columns=[
            "party_key",
            "history_months",
            "last_month",
            "forecast_month",
            "last_revenue",
            "monthly_trend",
            "predicted_revenue",
        ],
    )
