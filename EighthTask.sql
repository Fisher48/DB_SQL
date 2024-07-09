Рефлексия на предыдущее задание:
Задание выполнено верно с небольшим недочетом, я не указал для вывода поле OrderID (ID Заказа) в SELECT.

Выполнение следующего задания 8.3:

Задание 8.3.1:
SELECT Products.ProductName, Categories.CategoryName
FROM Products, Categories;

Задание 8.3.2:
SELECT Products.ProductName, Categories.CategoryName, [Order Details].UnitPrice
FROM [Order Details], Products, Categories
WHERE Products.ProductID = [Order Details].ProductID
AND Products.CategoryID = Categories.CategoryID
AND [Order Details].UnitPrice < 20;