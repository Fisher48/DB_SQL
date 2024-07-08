Выполнение следующего задания 7.3:

Задание 7.3.1:
SELECT ProductID, Discount * 100 as DiscountInPercent
FROM [Order Details];

Задание 7.3.2:
SELECT * FROM [Order Details]
WHERE ProductID IN
(SELECT ProductID FROM Products
WHERE UnitsInStock > 40);

Задание 7.3.3:
SELECT * FROM [Order Details]
WHERE ProductID IN
(SELECT ProductID FROM Products
WHERE UnitsInStock > 40)
AND OrderID IN
(SELECT OrderID FROM Orders
WHERE Freight >= 50);