use AdventureWorks2019
GO
-- 1. Write a query that lists the country and province names from person. 
-- CountryRegion and person. StateProvince tables. Join them and produce
-- a result set similar to the following.
--     Country                        Province

SELECT c.Name AS Country, s.Name AS Province
FROM person.CountryRegion c LEFT JOIN person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode


-- 2. Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada.
-- Join them and produce a result set similar to the following.
--     Country                        Province

SELECT c.Name AS Country, s.Name AS Province
FROM person.CountryRegion c LEFT JOIN person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Germany', 'Canada')

--  Using Northwind Database: (Use aliases for all the Joins)

use Northwind
GO

-- 3. List all Products that has been sold at least once in last 25 years.

SELECT DISTINCT p.ProductName
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID JOIN dbo.Orders o ON od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) BETWEEN (2022-25) AND 2022

-- 4. List top 5 locations (Zip Code) where the products sold most in last 25 years.

SELECT TOP 5 COUNT(p.ProductName), o.ShipPostalCode
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID JOIN dbo.Orders o ON od.OrderID = o.OrderID
WHERE o.ShipPostalCode IS NOT NULL AND YEAR(o.OrderDate) BETWEEN (2022-25) AND 2022 
GROUP BY o.ShipPostalCode

-- 5. List all city names and number of customers in that city.     

SELECT City, COUNT(CustomerID) AS CustomerNum
FROM dbo.Customers
GROUP BY City

-- 6. List city names which have more than 2 customers, and number of customers in that city

SELECT City, COUNT(CustomerID) AS CustomerNum
FROM dbo.Customers
GROUP BY City
HAVING COUNT(CustomerID)>2


-- 7. Display the names of all customers  along with the  count of products they bought
SELECT c.ContactName, COUNT(o.OrderID) ProductsCnt
FROM dbo.Orders o JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.ContactName

-- 8. Display the customer ids who bought more than 100 Products with count of products.
SELECT o.CustomerID
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID JOIN dbo.Orders o ON od.OrderID = o.OrderID
GROUP BY o.CustomerID
HAVING COUNT(p.ProductID)>100



-- 9. List all of the possible ways that suppliers can ship their products. Display the results as below
--     Supplier Company Name                Shipping Company Name
--     ---------------------------------            ----------------------------------
WITH ProductOrderCTE
AS(
SELECT p.SupplierID, o.ShipVia
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID JOIN dbo.Orders o ON od.OrderID = o.OrderID
)
SELECT DISTINCT s.CompanyName, sh.CompanyName
FROM dbo.Suppliers s LEFT JOIN ProductOrderCTE cte ON s.SupplierID = cte.SupplierID LEFT JOIN dbo.Shippers sh ON cte.ShipVia = sh.ShipperID


-- 10. Display the products order each day. Show Order date and Product Name.
SELECT p.ProductName, o.OrderDate
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID JOIN dbo.Orders o ON od.OrderID = o.OrderID
ORDER BY o.OrderDate

-- 11. Displays pairs of employees who have the same job title.

SELECT e1.EmployeeID, e1.FirstName +' '+ e1.LastName FullName, e1.ReportsTo, e2.EmployeeID, e2.FirstName +' '+ e2.LastName FullName, e2.ReportsTo
FROM dbo.Employees e1 JOIN dbo.Employees e2 ON e1.ReportsTo = e2.ReportsTo
WHERE e1.EmployeeID < e2.EmployeeID

-- 12. Display all the Managers who have more than 2 employees reporting to them.

SELECT e2.FirstName +' '+ e2.LastName Manager
FROM dbo.Employees e1 LEFT JOIN dbo.Employees e2 ON e1.ReportsTo = e2.EmployeeID
GROUP BY e1.ReportsTo, e2.FirstName +' '+ e2.LastName
HAVING COUNT(e1.EmployeeID)>2


-- 13. Display the customers and suppliers by city. The results should have the following columns

-- City
-- Name
-- Contact Name,
-- Type (Customer or Supplier)
SELECT c.City, c.CompanyName, c.ContactName, 'Customer' As Type
FROM dbo.Customers c 
UNION ALL
SELECT s.City, s.CompanyName, s.ContactName, 'Supplier' As Type
FROM dbo.Suppliers s


-- All scenarios are based on Database NORTHWIND.


-- 14. List all cities that have both Employees and Customers.
SELECT DISTINCT c.City
FROM dbo.Customers c JOIN dbo.Suppliers s ON c.City = s.City

-- 15. List all cities that have Customers but no Employee.
-- a. Use sub-query
SELECT DISTINCT c.City
FROM dbo.Customers c
WHERE c.City NOT IN
(
SELECT s.City
FROM dbo.Suppliers s)

-- b. Do not use sub-query
SELECT DISTINCT c.City
FROM dbo.Customers c LEFT JOIN dbo.Suppliers s ON c.City = s.City
WHERE s.City IS NULL

-- 16. List all products and their total order quantities throughout all orders.
SELECT p.ProductName, COUNT(o.OrderID) OrderNum
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID JOIN dbo.Orders o ON od.OrderID = o.OrderID
GROUP BY  p.ProductName

-- 17. List all Customer Cities that have at least two customers.
-- a. Use union
-- b. Use sub-query and no union
SELECT c.City
FROM dbo.Customers c
GROUP BY c.City
HAVING COUNT(c.CustomerID)>=2


-- 18. List all Customer Cities that have ordered at least two different kinds of products.
WITH ProductOrderCTE
AS(
SELECT p.ProductID, o.CustomerID
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID JOIN dbo.Orders o ON od.OrderID = o.OrderID
)
SELECT c.City, COUNT(cte.ProductID)
FROM dbo.Customers c JOIN ProductOrderCTE cte ON c.CustomerID = cte.CustomerID
GROUP BY c.City
HAVING COUNT(cte.ProductID)>2

-- 19. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.

 WITH TopCity
AS
(
SELECT dt.ProductID, dt.City, dt.AvgPrice
FROM
(SELECT p.ProductID, c.City, AVG(od.UnitPrice) AvgPrice, SUM(od.Quantity) SoldQuantity, RANK() OVER(PARTITION BY p.ProductID ORDER BY SUM(od.Quantity) DESC) rnk
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID JOIN dbo.Orders o ON od.OrderID = o.OrderID JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
GROUP BY p.ProductID, c.City) dt
WHERE dt.rnk<2
)
SELECT topP.ProductID, t.AvgPrice, t.City
FROM
(SELECT TOP 5 p.ProductID, SUM(od.Quantity) TotalQuantity
FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID 
GROUP BY p.ProductID
ORDER BY TotalQuantity DESC) topP LEFT JOIN TopCity t ON topP.ProductID = t.ProductID


-- 20. List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered
-- from. (tip: join  sub-query)
SELECT topO.ShipCity
FROM
(
SELECT TOP 1 o.ShipCity, COUNT(o.OrderID) TotalOrder
FROM dbo.Orders o 
GROUP BY o.ShipCity
ORDER BY TotalOrder DESC) topO JOIN 
(
SELECT TOP 1 o.ShipCity, SUM(od.Quantity) TotalQ
FROM dbo.Orders o JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.ShipCity
ORDER BY TotalQ DESC) topQ ON topO.ShipCity = topQ.ShipCity



-- 21. How do you remove the duplicates record of a table?
--1.DISTINCT
--2.UNION
--3.GROUP BY