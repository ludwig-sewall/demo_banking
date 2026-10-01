def model(dbt, session):
    """One-step revenue forecast per party from monthly history."""
    dbt.config(
        materialized="table",
        packages=["pandas", "numpy"],
    )

    import numpy as np
    import pandas as pd

    history = dbt.ref("customer_revenue").to_pandas()
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
            {
                "party_key": str(party_key),
                "history_months": int(len(revenues)),
                "last_month": last_month.date(),
                "forecast_month": (last_month + pd.DateOffset(months=1)).date(),
                "last_revenue": round(float(revenues[-1]), 2),
                "monthly_trend": round(float(slope), 2),
                "predicted_revenue": round(float(predicted), 2),
            }
        )

    return pd.DataFrame(forecasts)
