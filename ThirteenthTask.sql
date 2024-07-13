Рефлексия на предыдущее задание:
Задание 12.3.3 выполнено верно (не описал возможные конфликты), я не указал причины по которым может возникнуть конфликт,
в эталоне все написано верно, я просто не проверил возможность возникновения конфликтов, хотя в голове эту мысль держал).

Выполнение задания 13.3:

Задание 13.3.1
UPDATE [Order Details]
SET Discount = 0.20
WHERE Quantity > 50;

Задание 13.3.2
UPDATE Contacts
SET City = 'Piter', Country = 'Russia'
WHERE City = 'Berlin' AND Country = 'Germany';

Задание 13.3.3
Добавили 2 компании:
INSERT INTO Shippers (CompanyName)
VALUES ('IHP Appliances');

INSERT INTO Shippers (CompanyName, Phone)
VALUES ('NLMK', '972-32342-231');

Удаляем тех перевозчиков, у которых не указан телефон (удаление прошло успешно).
DELETE FROM Shippers
WHERE Phone IS NULL;

Удалил нового перевозчика по названию (удаление прошло успешно).
DELETE FROM Shippers
WHERE CompanyName = 'NLMK';

Также можно удалить по ID перевозчика
DELETE FROM Shippers
WHERE ShipperID = '6';
