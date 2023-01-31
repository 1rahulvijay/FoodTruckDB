CREATE VIEW Employee_Salary as 
select FirstName, LastName, Salary from mydb.FoodtruckStaff
left join mydb.Payslip
ON mydb.Payslip.StaffID = mydb.FoodtruckStaff.StaffID
WHERE Salary is NOT NULL

GO
select * from Employee_Salary