Рефлексия на предыдущее задание:
Задание выполнено верно, необходимо учесть для задания 4.3.1:
Более корректным будет такой вариант (если нужно именно имя, а не фамилия):
SELECT * FROM Customers
WHERE ContactName LIKE '% C%'

Выполнение следующего задания 5.4

Задание 5.4.1:
SELECT * FROM Employees
ORDER BY BirthDate DESC, Country;

Задание 5.4.2:
SELECT * FROM Employees
WHERE Region IS NOT NULL
ORDER BY BirthDate DESC, Country;

Задание 5.4.3:
SELECT AVG(UnitPrice), MIN(UnitPrice), MAX(UnitPrice) FROM [Order Details];

Задание 5.4.4:
SELECT COUNT(DISTINCT City) FROM Customers;