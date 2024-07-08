Рефлексия на предыдущее задание:

Задание выполнено верно, с небольшим недочетом в задании на отбор всех сотрудников мужчин.
Я поспешил и не обратил внимание на то, что в таблице есть также степень вежливости как Dr. - Докторская степень.
И поэтому необходимо было в условии указать также WHERE TitleOfCourtesy = 'Dr.'.

Выполнение следующего задания 4.3

Задание 4.3.1:
SELECT * FROM Customers
WHERE ContactName Like 'C%';

Задание 4.3.2:
SELECT * FROM Orders
WHERE (Freight BETWEEN 100 AND 200) AND ShipCountry IN ('USA', 'France');

Задание 4.3.3:
SELECT * FROM EmployeeTerritories
WHERE TerritoryID BETWEEN 6897 AND 31000;