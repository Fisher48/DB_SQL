Решения задания 15.7:
Сначала создаем таблицу Regions как было в теоретической части
(со структурой, аналогичной таблице Region из базы Northwind):
CREATE TABLE Region (
    RegionID int NOT NULL,
    RegionDescription nchar(50) NOT NULL );

Затем создаем таблицу Territories со структурой, аналогичной структуре таблицы Territories из учебной базы:
CREATE TABLE Territories (
    TerritoryID nvarchar(20) NOT NULL,
    TerritoryDescription nchar(50) NOT NULL,
    RegionID int NOT NULL );

Далее добавляем значения в таблицу Region и таблицу Territories:
INSERT INTO Region (RegionID, RegionDescription)
VALUES ('1', 'Eastern');

INSERT INTO Region (RegionID, RegionDescription)
VALUES ('2', 'Western');

INSERT INTO Region (RegionID, RegionDescription)
VALUES ('3', 'Northern');

INSERT INTO Region (RegionID, RegionDescription)
VALUES ('4', 'Southern');

Делаем PK_Territory в таблице Territories и PK_Region в таблице Regions, через Design.
Также добавил внешний ключ FK_Territories_RegionID для таблицы Territories через установку ключей в таблице.

INSERT INTO Territories (TerritoryID, TerritoryDescription, RegionID)
VALUES ('28', 'Amur', '1');

INSERT INTO Territories (TerritoryID, TerritoryDescription, RegionID)
VALUES ('48', 'Lipetsk', '2');

INSERT INTO Territories (TerritoryID, TerritoryDescription, RegionID)
VALUES ('51', 'Murmansk', '3');

INSERT INTO Territories (TerritoryID, TerritoryDescription, RegionID)
VALUES ('05', 'Dagestan', '4');


