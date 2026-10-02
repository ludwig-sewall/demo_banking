def model(dbt, session):
    """One-step revenue forecast per party from monthly history.

    Fusion materializes the return value with session.create_dataframe().
    That call accepts a list, tuple, or pandas DataFrame, and rejects a
    Snowpark DataFrame. A list of Rows keeps names and types without pandas.
    """
    dbt.config(
        materialized="table",
        packages=["pandas", "numpy"],
    )

    from decimal import Decimal

    import numpy as np
    import pandas as pd
    from snowflake.snowpark import Row

    # to_pandas() fails inside the Snowflake procedure: the connector marks
    # pandas missing before packaged imports run.
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
            Row(
                party_key=str(party_key),
                history_months=int(len(revenues)),
                last_month=last_month.date(),
                forecast_month=(last_month + pd.DateOffset(months=1)).date(),
                last_revenue=Decimal(str(round(float(revenues[-1]), 2))),
                monthly_trend=Decimal(str(round(float(slope), 2))),
                predicted_revenue=Decimal(str(round(float(predicted), 2))),
            )
        )

    return forecasts
