Рефлексия на предыдущее задание:

Задание 10.4.1 Выполнено верно, отличие только в том, что
я использую WHERE вместо ON для выборки стоимости UnitPrice меньше 20.

Задание 10.4.2 Выполнено верно.

Задание 10.4.3 В задании требовалось показать, как с помощью предложения WHERE превратить запрос CROSS JOIN в INNER JOIN.
В эталоне написано Добавить фильтрацию WHERE table1.primary_key = table2.foreign_key.
Мой ответ тоже верен т.к я сделал сразу пример с этой фильтрацией WHERE Orders.CustomerID = Customers.CustomerID

Задание 10.4.4 Выполнено верно.

Решение задания 11.5:

Задание 11.5.1
SELECT * FROM Customers
LEFT JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.CustomerID IS NULL;

Задание 11.5.2
SELECT 'Customer' As Type, ContactName, City, Country
FROM Customers
UNION
SELECT 'Supplier' As Type, ContactName, City, Country
FROM Suppliers
ORDER BY Type;



