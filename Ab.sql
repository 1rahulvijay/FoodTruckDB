SELECT
    m.*,
    map.col1,
    map.col2,
    map.col3,
    map.col4,
    map.col5,
    map.col6,
    map.col7
FROM MainTable m
LEFT JOIN MappingTable map
    ON (

        -- CASE 1: CU has NO AU rules → CU join only
        (
            NOT EXISTS (
                SELECT 1 FROM MappingTable mx
                WHERE mx.CU_NAME = m.CU_NAME
                  AND TRIM(mx.AU) IS NOT NULL
                  AND TRIM(mx.AU) <> ''
            )
            AND m.CU_NAME = map.CU_NAME
        )

        OR

        -- CASE 2: CU has AU rules AND Main.AU matches a mapping AU → AU join
        (
            EXISTS (
                SELECT 1 FROM MappingTable mx
                WHERE mx.CU_NAME = m.CU_NAME
                  AND TRIM(mx.AU) IS NOT NULL
                  AND TRIM(mx.AU) <> ''
            )
            AND EXISTS (
                SELECT 1 FROM MappingTable mx2
                WHERE mx2.CU_NAME = m.CU_NAME
                  AND mx2.AU = m.AU
            )
            AND map.AU = m.AU
        )

        -- CASE 3 happens automatically:
        -- When MAIN.AU does NOT match → the fallback CU+iNULL-AU row joins
    );
