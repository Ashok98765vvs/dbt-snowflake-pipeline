-- Fact table: loan-level performance metrics
-- Grain: one row per loan per reporting month

{{ config(
    materialized='incremental',
    unique_key='loan_month_key',
    cluster_by=['reporting_month', 'loan_status'],
    tags=['finance', 'daily']
) }}

WITH loans AS (
    SELECT * FROM {{ ref('stg_loans') }}
),

payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
),

payment_agg AS (
    SELECT
        loan_id,
        DATE_TRUNC('month', payment_date) AS reporting_month,
        SUM(principal_paid)               AS total_principal_paid,
        SUM(interest_paid)                AS total_interest_paid,
        COUNT(*)                          AS payment_count,
        MAX(payment_date)                 AS last_payment_date
    FROM payments
    GROUP BY 1, 2
),

final AS (
    SELECT
        l.loan_id,
        l.borrower_id,
        l.origination_date,
        l.loan_amount,
        l.interest_rate,
        l.loan_status,
        pa.reporting_month,
        COALESCE(pa.total_principal_paid, 0) AS principal_paid_mtd,
        COALESCE(pa.total_interest_paid, 0)  AS interest_paid_mtd,
        COALESCE(pa.payment_count, 0)        AS payments_made_mtd,
        pa.last_payment_date
    FROM loans l
    LEFT JOIN payment_agg pa ON l.loan_id = pa.loan_id
)

SELECT * FROM final

{% if is_incremental() %}
WHERE reporting_month >= (SELECT MAX(reporting_month) FROM {{ this }})
{% endif %}
