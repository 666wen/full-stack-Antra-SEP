-- Use Northwind database. All questions are based on assumptions described by the 
--Database Diagram sent to you yesterday. When inserting, make up info if necessary.
-- Write query for each step. Do not use IDE. BE CAREFUL WHEN DELETING DATA OR 
--DROPPING TABLE.

-- 1.Create a view named “view_product_order_[your_last_name]”, list all products and total ordered quantity for that product.
CREATE VIEW view_product_order_pan
AS
SELECT p.ProductID, SUM(od.Quantity) totalQuanlity
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID
GROUP BY p.ProductID

-- 2.Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept product id as an input and total quantities of order as output parameter.
CREATE PROC sp_product_order_quantity_pan
@pId int, @totalQua int out
AS
BEGIN
SELECT @totalQua = totalQuanlity
FROM view_product_order_pan 
WHERE ProductID=@pId
END
GO

BEGIN
DECLARE @totalQua int
EXEC sp_product_order_quantity_pan  29, @totalQua out
PRINT @totalQua
END
GO
-- 3.Create a stored procedure “sp_product_order_city_[your_last_name]” that accept product name as an input and top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.
CREATE PROC sp_product_order_city_pan
@pName varchar(40) 
AS
BEGIN
WITH CityOrderMost
AS
(
SELECT dt.ProductName, dt.City, dt.QualityOfCity
FROM
(
SELECT p.ProductName, c.City, SUM( od.Quantity) QualityOfCity, RANK() OVER(PARTITION BY p.ProductName ORDER BY SUM( od.Quantity) DESC) rnk
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID=od.ProductID JOIN dbo.Orders o ON od.OrderID = o.OrderID JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
GROUP BY p.ProductName, c.City) dt
WHERE dt.rnk<=5
)

SELECT c.ProductName, c.City, c.QualityOfCity
FROM CityOrderMost c
WHERE c.ProductName=@pName

END
GO

EXEC sp_product_order_city_pan [Alice Mutton]

-- 4.Create 2 new tables “people_your_last_name” “city_your_last_name”. City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}. Remove city of Seattle. If there was anyone from Seattle, put them into a new city “Madison”. Create a view “Packers_your_name” lists all people from Green Bay. If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
CREATE TABLE #people_pan
(id int,
Name varchar(50),
City int
)
GO

CREATE TABLE #city_pan
(Id int,
City varchar(50)
)
GO

INSERT INTO #city_pan
VALUES
(1, 'Seattle'), 
(2, 'Green Bay')

INSERT INTO #people_pan
VALUES
(1, 'Aaron Rodgers',  2), 
(2, 'Russell Wilson', 1), 
(3, 'Jody Nelson', 2)
GO

SELECT *
FROM #city_pan

BEGIN
--DELETE FROM #city_pan
--WHERE City='Seattle'

INSERT INTO #city_pan
VALUES
(3, 'Madison')

UPDATE #people_pan
SET City=3
WHERE id IN
(
SELECT p.id
FROM #people_pan p JOIN #city_pan c ON p.City=c.Id
WHERE c.City='Seattle'
)
END

SELECT *
FROM #people_pan
GO

CREATE VIEW Packer_wen_pan
AS
SELECT Name
FROM #people_pan p JOIN #city_pan c ON p.City=c.Id
WHERE c.City='Green Bay'
GO

SELECT *
FROM Packer_wen_pan

DROP TABLE #city_pan
DROP TABLE #people_pan
DROP View Packer_wen_pan
-- 5.Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name” and fill it with all employees that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected.
CREATE PROC sp_birthday_employees_wenPan
AS
BEGIN
--DROP TABLE birthday_employees_wenpan 
CREATE TABLE birthday_employees_wenpan 
(EmployeeID int,
FullName varchar(50),
Birthdate datetime
)
INSERT INTO birthday_employees_wenpan 
SELECT e.EmployeeID, e.FirstName+' '+e.LastName, e.BirthDate
FROM dbo.Employees e
WHERE MONTH(e.BirthDate)=2
END
-- 6.How do you make sure two tables have the same data?
--BY using FULL JOIN, I can check the data from two table are same or not.
--