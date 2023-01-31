CREATE VIEW Cusine_IND AS
Select * FROM mydb.Foodtruck
WHERE Cusine = 'IND'
Go
Select * from Cusine_IND