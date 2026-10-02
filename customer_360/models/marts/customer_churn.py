def model(dbt, session):
    """Churn score for each customer_360 party."""
    dbt.config(
        materialized="table",
        packages=["pandas"],
    )

    from decimal import Decimal

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

    at_risk = {"closed", "inactive", "frozen", "f"}

    def flagged(value):
        if value is None or (isinstance(value, float) and pd.isna(value)):
            return False
        return str(value).strip().lower() in at_risk

    def number(value):
        if value is None or (isinstance(value, float) and pd.isna(value)):
            return 0.0
        return float(value)

    scored = []
    for row in customers.itertuples(index=False):
        status_hit = int(
            flagged(getattr(row, "banking_status", None))
            or flagged(getattr(row, "insurance_status", None))
            or flagged(getattr(row, "wealth_status", None))
        )
        profit_hit = int(number(getattr(row, "total_profit", None)) < 0)
        domain_count = int(number(getattr(row, "domain_count", None)))
        holdings = (
            number(getattr(row, "account_count", None))
            + number(getattr(row, "active_policy_count", None))
            + number(getattr(row, "portfolio_count", None))
        )
        thin_hit = int(domain_count <= 1)
        empty_hit = int(holdings == 0)
        score = (0.40 * status_hit) + (0.30 * profit_hit) + (0.20 * thin_hit) + (0.10 * empty_hit)
        reasons = []
        if status_hit:
            reasons.append("inactive relationship")
        if profit_hit:
            reasons.append("negative profit")
        if thin_hit:
            reasons.append("single domain")
        if empty_hit:
            reasons.append("no open products")
        scored.append(
            (
                str(row.customer_id),
                Decimal(str(round(score, 2))),
                score >= 0.40,
                "high" if score >= 0.40 else "medium" if score >= 0.20 else "low",
                ", ".join(reasons) if reasons else "none",
                status_hit,
                profit_hit,
                thin_hit,
                empty_hit,
            )
        )

    schema = StructType(
        [
            StructField("customer_id", StringType()),
            StructField("churn_score", DecimalType(4, 2)),
            StructField("predicted_churn", BooleanType()),
            StructField("churn_band", StringType()),
            StructField("churn_reasons", StringType()),
            StructField("status_risk", IntegerType()),
            StructField("profit_risk", IntegerType()),
            StructField("concentration_risk", IntegerType()),
            StructField("product_risk", IntegerType()),
        ]
    )
    return session.create_dataframe(scored, schema)
