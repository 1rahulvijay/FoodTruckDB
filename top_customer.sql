CREATE VIEW top_customer as 
select LastName, FirstName, Quantity from mydb.Customer
left join mydb.[Order]
ON mydb.[Order].[CustomerID] = mydb.Customer.CustomerID
WHERE Quantity IS NOT NULL 
group by LastName, FirstName, Quantity
order by Quantity DESC
OFFSET 3 ROWS
FETCH NEXT 3 ROWS ONLY;

go
select * from top_customer