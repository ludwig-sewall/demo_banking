def model(dbt, session):
    """Logistic regression: probability a party is an at-risk relationship."""
    dbt.config(
        materialized="table",
        packages=["pandas", "numpy"],
    )

    from decimal import Decimal

    import numpy as np
    import pandas as pd
    from snowflake.snowpark.types import (
        BooleanType,
        DecimalType,
        IntegerType,
        StringType,
        StructField,
        StructType,
    )

    rows = dbt.ref("customer_360").collect()
    customers = pd.DataFrame([row.as_dict() for row in rows])
    customers.columns = [str(column).lower() for column in customers.columns]

    feature_names = [
        "total_profit",
        "domain_count",
        "account_count",
        "loan_balance",
        "active_policy_count",
        "annual_premium",
        "portfolio_count",
        "assets_under_management",
    ]
    at_risk = {"closed", "inactive", "frozen", "f"}

    def flagged(value):
        if value is None or (isinstance(value, float) and pd.isna(value)):
            return False
        text = str(value).strip().lower()
        return text in at_risk

    def number(value):
        if value is None or (isinstance(value, float) and pd.isna(value)):
            return 0.0
        return float(value)

    matrix = np.column_stack(
        [customers[name].map(number).to_numpy(dtype=float) for name in feature_names]
    )
    labels = np.array(
        [
            int(
                flagged(row.banking_status)
                or flagged(row.insurance_status)
                or flagged(row.wealth_status)
            )
            for row in customers.itertuples(index=False)
        ],
        dtype=float,
    )

    mean = matrix.mean(axis=0)
    scale = matrix.std(axis=0)
    scale[scale < 1e-6] = 1.0
    standardized = (matrix - mean) / scale
    design = np.column_stack([np.ones(len(customers)), standardized])

    weights = np.zeros(design.shape[1], dtype=float)
    learning_rate = 0.2
    penalty = 1.0
    if labels.min() != labels.max():
        for _ in range(400):
            linear = np.clip(design @ weights, -20, 20)
            probability = 1.0 / (1.0 + np.exp(-linear))
            gradient = (design.T @ (probability - labels)) / len(labels)
            regularized = penalty * weights / len(labels)
            regularized[0] = 0.0
            weights -= learning_rate * (gradient + regularized)

    linear = np.clip(design @ weights, -20, 20)
    probability = 1.0 / (1.0 + np.exp(-linear))

    scored = []
    for index, row in enumerate(customers.itertuples(index=False)):
        contribution = standardized[index] * weights[1:]
        driver = feature_names[int(np.argmax(np.abs(contribution)))]
        scored.append(
            (
                str(row.customer_id),
                Decimal(str(round(float(probability[index]), 4))),
                bool(probability[index] >= 0.5),
                int(labels[index]),
                driver,
                Decimal(str(round(float(weights[0]), 4))),
            )
        )

    schema = StructType(
        [
            StructField("customer_id", StringType()),
            StructField("churn_probability", DecimalType(6, 4)),
            StructField("predicted_churn", BooleanType()),
            StructField("observed_at_risk", IntegerType()),
            StructField("strongest_feature", StringType()),
            StructField("model_intercept", DecimalType(8, 4)),
        ]
    )
    return session.create_dataframe(scored, schema)
