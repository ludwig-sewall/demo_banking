def model(dbt, session):
    """One-step revenue forecast per party from monthly history."""
    dbt.config(
        materialized="table",
        packages=["pandas", "numpy"],
    )

    from decimal import Decimal

    import numpy as np
    import pandas as pd
    from snowflake.snowpark.types import (
        DateType,
        DecimalType,
        IntegerType,
        StringType,
        StructField,
        StructType,
    )

    # Collect instead of to_pandas(): the procedure imports pandas after the
    # connector has already decided pandas is unavailable.
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

    schema = StructType(
        [
            StructField("party_key", StringType()),
            StructField("history_months", IntegerType()),
            StructField("last_month", DateType()),
            StructField("forecast_month", DateType()),
            StructField("last_revenue", DecimalType(18, 2)),
            StructField("monthly_trend", DecimalType(18, 2)),
            StructField("predicted_revenue", DecimalType(18, 2)),
        ]
    )
    # Build the Snowpark frame here from a list. Returning a pandas frame makes
    # Fusion call create_dataframe() with a pandas class it does not recognize.
    return session.create_dataframe(forecasts, schema)
