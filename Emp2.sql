WITH rms_periods AS (
    SELECT 
        employee_id,
        employee_name,
        effective_date,
        LEAD(effective_date, 1, CURRENT_DATE()) OVER (
            PARTITION BY employee_id 
            ORDER BY effective_date
        ) AS next_effective_date,
        department_name
    FROM your_table
    WHERE department_name = 'rms'
),
tenure_calc AS (
    SELECT 
        employee_id,
        employee_name,
        effective_date,
        next_effective_date,
        DATEDIFF('day', effective_date, next_effective_date) AS tenure_days
    FROM rms_periods
)
SELECT 
    employee_id,
    employee_name,
    SUM(tenure_days) AS total_tenure_days,
    ROUND(SUM(tenure_days) / 365.25, 2) AS total_tenure_years
FROM tenure_calc
GROUP BY employee_id, employee_name
ORDER BY employee_id;
