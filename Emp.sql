WITH RankedRecords AS (
    -- Get previous department using LAG
    SELECT 
        employee_id,
        employee_name,
        effective_date,
        department_name,
        LAG(department_name) OVER (PARTITION BY employee_id ORDER BY effective_date) AS prev_dept
    FROM employee_dept_history
    WHERE department_name = 'rms' OR department_name IS NOT NULL
),
PeriodGroups AS (
    -- Group continuous periods in 'rms'
    SELECT 
        employee_id,
        employee_name,
        effective_date,
        department_name,
        SUM(CASE WHEN department_name != prev_dept OR prev_dept IS NULL THEN 1 ELSE 0 END) 
            OVER (PARTITION BY employee_id ORDER BY effective_date) AS period_group
    FROM RankedRecords
    WHERE department_name = 'rms'
),
TenurePeriods AS (
    -- Calculate tenure for each period, using NOW() for ongoing periods
    SELECT 
        employee_id,
        employee_name,
        MIN(effective_date) AS period_start,
        CASE 
            WHEN MAX(effective_date) = (SELECT MAX(effective_date) FROM employee_dept_history WHERE employee_id = t.employee_id AND department_name = 'rms')
            AND NOT EXISTS (SELECT 1 FROM employee_dept_history WHERE employee_id = t.employee_id AND effective_date > MAX(t.effective_date) AND department_name != 'rms')
            THEN NOW() -- Use current date if this is the latest 'rms' period and no exit recorded
            ELSE MAX(effective_date)
        END AS period_end,
        DATEDIFF(
            CASE 
                WHEN MAX(effective_date) = (SELECT MAX(effective_date) FROM employee_dept_history WHERE employee_id = t.employee_id AND department_name = 'rms')
                AND NOT EXISTS (SELECT 1 FROM employee_dept_history WHERE employee_id = t.employee_id AND effective_date > MAX(t.effective_date) AND department_name != 'rms')
                THEN NOW()
                ELSE MAX(effective_date)
            END,
            MIN(effective_date)
        ) / 30 + 1 AS tenure_months
    FROM PeriodGroups t
    GROUP BY employee_id, employee_name, period_group
)
-- Sum total tenure across all periods
SELECT 
    employee_id,
    employee_name,
    SUM(tenure_months) AS total_tenure_in_rms_months
FROM TenurePeriods
GROUP BY employee_id, employee_name
ORDER BY employee_id;
