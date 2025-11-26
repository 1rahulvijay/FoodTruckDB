I have two tables: main_table and mapping_table.

About mapping_table
	•	It contains 1304 distinct rows.
	•	For about 1300 rows, mapping is straightforward:
	•	main_table.cu_name = mapping_table.cu_name
	•	And mapping_table.au IS NULL
	•	There are 5 special rows where cu_name = 'COMM':
	•	4 rows have specific AU values (e.g., A1, A2, A3, A4)
	•	1 row has AU IS NULL → this is the fallback/default mapping for COMM

About main_table
	•	Always contains AU (never NULL)
	•	Has many rows with CU_NAME = 'COMM' and many non-COMM rows

⸻

⭐ My mapping rules

1. For CU_NAME ≠ ‘COMM’:

Map normally using:
	•	main_table.cu_name = mapping_table.cu_name
	•	mapping_table.au IS NULL

2. For CU_NAME = ‘COMM’:

There is special logic:

Case A — When main_table.AU is one of the 4 defined valid AUs under COMM
→ Join to the row with the exact same AU.

Case B — When main_table.AU is NOT one of those 4
→ Join to the single fallback row:

The problem I am facing

Even though:
	•	mapping_table has no duplicates
	•	only 5 COMM rows exist
	•	the fallback row is unique

My join query keeps producing duplicate rows for COMM.
COMM rows match more than once:
	•	Sometimes to both the AU-specific row and the fallback row
	•	Sometimes to multiple COMM rows
	•	Sometimes due to join OR conditions
	•	Sometimes due to whitespace/CHAR padding issues

I need a query that guarantees:

1 main row → exactly 1 mapping row (no duplicates)

AND satisfies the rules above.

⸻

🎯 What I need from you

Please write a correct Oracle SQL query that:
	•	Normalizes AU values (TRIM, handle NULL vs space)
	•	Resolves the special COMM logic
	•	Ensures exactly one match per main row
	•	Does not generate duplicates
	•	Does not rely on ambiguous OR conditions

Return the final query and explain how it avoids duplicate mapping.
