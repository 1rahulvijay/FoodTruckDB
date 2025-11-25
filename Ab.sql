I have a 2 table, Mapping and  Main table

And Joining on CU_NAME

There’s a special case where CU_NAME = COMM

Then I join with AU column 
All au values are blanks in mapping except 4

But for cu_name if those 4 are not AU then I will only take CU  
Derive other columns from mapping table 

And main table has au values in every line

I derive 7 columns from Mapping table in join

Write query

But there’s are CU=COMM but mapped to different AU not those 4

And I want all those CU=COMM

Would be easier if I add standalone AU blank row in mapping table 
