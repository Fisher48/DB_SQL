Рефлексия на предыдущее задание:

Задание выполнено практически верно, только с одним недочетом, я указал что Поставщики
связан с Товары – как один ко одному, но в эталоне указывается как один ко многим.
Хотя действительно у одного поставщика может быть много товаров.
Я немного сбил себя тем, что каждый товар уникален у каждого поставщика, и в голове построил обратную связь, от товара к поставщику.

Выполнение следующего задания 3.9

Задание 3.9.1:
SELECT ProductName, UnitsInStock FROM Products;

Задание 3.9.2:
SELECT ProductName, UnitPrice FROM Products
WHERE (UnitPrice < 20);

Задание 3.9.3:
SELECT * FROM Orders
WHERE (Freight >= 11.7) AND (Freight <= 98.1);

Задание 3.9.4:
SELECT * FROM Employees
WHERE (TitleOfCourtesy = 'Mr.');

Задание 3.9.5:
SELECT * From Suppliers
WHERE (Country = 'Japan');

Задание 3.9.6:
SELECT * FROM Orders
WHERE (EmployeeID = 2) OR (EmployeeID = 4) OR (EmployeeID = 8);

Задание 3.9.7:
SELECT OrderID, ProductID FROM [Order Details]
WHERE (UnitPrice > 40) AND (Quantity < 10);
