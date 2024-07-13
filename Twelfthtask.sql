Выполнение задания 12.3:

Задание 12.3.1
INSERT INTO Employees (LastName, FirstName, Title, TitleOfCourtesy, City, Country)
VALUES ('Rybakov', 'Ivan', 'Engineer', 'Mr', 'Lipetsk', 'Russia');

Задание 12.3.2
INSERT INTO EmployeeTerritories (EmployeeID, TerritoryID)
VALUES ('16', '125007');
Это новая территория Piter '125007' добавлена была из материала лекции.

Задание 12.3.3
INSERT INTO Orders (CustomerID, EmployeeID, ShipVia, ShipCity, ShipCountry)
VALUES ('VINET', '16', '1', 'Lipetsk', 'Russia');
Конфликтов не возникло.