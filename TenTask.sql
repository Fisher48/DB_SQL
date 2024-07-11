Рефлексия на предыдущее задание:
Задание 9.4.1 Выполнено верно.

Задание 9.4.2 Выполнено верно, только я использую вывод не только ID заказа,
а всей строки, также я использовал другую конструкцию IN вместо ANY в выборе WHERE.

Задание 9.4.3 Выполнено с недочетом, я также выводил всю строку заказа, а не только его ID.
И также в эталоне используется другая конструкция выборки
WHERE Freight > ALL (SELECT UnitPrice..., а у меня WHERE Freight > (SELECT MAX(UnitPrice)...
В моем случае я сразу определяю максимальную цена товара, которая превышает цену за доставку товара.
В эталоне сделано корректнее чем у меня (хоть и выводится одинаковый ответ),
MAX в моем случае будет сравнивать стоимость перевозки только с самой высокой ценой за единицу товара,
тогда как ALL гарантирует, что стоимость перевозки будет больше, чем каждая отдельная цена за единицу товара.

Решение задания 10.4

Задание 10.4.1
SELECT Products.ProductName, [Order Details].UnitPrice
FROM [Order Details] JOIN Products
ON [Order Details].ProductID = Products.ProductID
WHERE [Order Details].UnitPrice < 20;

Задание 10.4.2
SELECT Orders.Freight, Customers.CompanyName
FROM Orders INNER JOIN Customers
ON Orders.CustomerID = Customers.CustomerID
ORDER BY Freight;
С вариантом FULL JOIN выдача получилась объёмнее за счет того, что присоединялись Поставщики
у которых не было Заказов (т.е даже там где не было совпадений) и поэтому к ним по полу Freight указывалось NULL.
То есть если нет Заказ у Поставщика, или Поставщика не существует у такого Заказа и возникает NULL в пересечении.

Задание 10.4.3
SELECT Orders.Freight, Customers.CompanyName
FROM Orders CROSS JOIN Customers
WHERE Orders.CustomerID = Customers.CustomerID
ORDER BY Freight;

Задание 10.4.4
SELECT Products.ProductName, [Order Details].UnitPrice
FROM Products INNER JOIN [Order Details]
ON Products.ProductID = [Order Details].ProductID