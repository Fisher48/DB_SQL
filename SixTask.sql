Выполнение следующего задания 6.3:

Задание 6.3.1:
SELECT ContactType, COUNT(ContactType) as Quantity
FROM Contacts
GROUP BY ContactType;

Задание 6.3.2:
SELECT CategoryID, AVG(UnitPrice) as AVG_PRICE
FROM Products
GROUP BY CategoryID
ORDER BY AVG_PRICE;