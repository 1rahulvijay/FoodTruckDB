CREATE VIEW sum_salary_expense AS

select SUM(Salary) as Total_Salary_Expense from mydb.Payslip

select * from sum_salary_expense