Рефлексия на предыдущее задание:
Задание выполнено немного с ошибкой, в задании 8.3.1, у меня получаются все возможные комбинации в декартовой системе координат.
Я забыл указать явную связь между таблицами WHERE Products.CategoryID = Categories.CategoryID;
И в следующем задании у меня получается задание 8.3.2 это 8.3.3, по сути это одно задание в другом,
можно сказать недочет из-за спешки, необходимо внимательнее смотреть что отправляю.

Решение задания 9.4:

Задание 9.4.1:
SELECT t1.ContactName, t2.ContactName, t2.Region
FROM Customers t1, Customers t2
WHERE t1.CustomerID <> t2.CustomerID and t1.Region IS NULL and t2.Region IS NULL;

Задание 9.4.2:
SELECT * FROM Orders t1
WHERE t1.CustomerID IN
(SELECT CustomerID FROM Customers
WHERE Region IS NOT NULL);

Задание 9.4.3:
SELECT * FROM Orders
WHERE Freight >
(SELECT MAX(UnitPrice) FROM Products);
