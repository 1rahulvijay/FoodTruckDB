WITH comm_valid AS (
    SELECT TRIM(au) AS au
    FROM mapping_table
    WHERE cu_name = 'COMM'
      AND au IS NOT NULL
),
main_norm AS (
    SELECT 
        m.*,
        TRIM(m.au) AS au_trim,

        CASE 
           WHEN m.cu_name <> 'COMM' 
                THEN NULL

           WHEN TRIM(m.au) IN (SELECT au FROM comm_valid) 
                THEN TRIM(m.au)

           ELSE NULL
        END AS resolved_au
    FROM main_table m
),
mapping_norm AS (
    SELECT 
        cu_name,
        TRIM(au) AS au_trim,
        map_val
    FROM mapping_table
)
SELECT 
    mn.cu_name,
    mn.au,
    mn.main_val,
    map.map_val
FROM main_norm mn
LEFT JOIN mapping_norm map
       ON mn.cu_name = map.cu_name
      AND NVL(map.au_trim, '###NULL###') = NVL(mn.resolved_au, '###NULL###');
