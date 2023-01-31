create view supplies_expense as
select sum(Price) supplies_expense from mydb.SuppliesItem

select * from supplies_expense