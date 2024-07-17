1. Получить информацию о всех гномах, которые входят в какой-либо отряд, вместе с информацией об их отрядах.
SELECT * FROM Dwarves
LEFT JOIN Squads
ON Squads.squad_id = Dwarves.squad_id
WHERE Dwarves.squad_id IS NOT NULL;

Также как вариант можно сделать:
SELECT d.name, d.age, d.profession,
 s.name AS squad_name, s.mission
FROM Dwarves d JOIN Squads s
ON d.squad_id = s.squad_id
WHERE d.squad_id IS NOT NULL;

2. Найти всех гномов с профессией "miner", которые не состоят ни в одном отряде.
SELECT * FROM Dwarves
WHERE profession = 'miner' AND  squad_id IS NULL;

3. Получить все задачи с наивысшим приоритетом, которые находятся в статусе "pending".
SELECT * FROM Tasks
WHERE priority IN (SELECT MAX(priority) FROM Tasks)
AND status = 'pending';

4. Для каждого гнома, который владеет хотя бы одним предметом, получить количество предметов, которыми он владеет.
SELECT Dwarves.name, COUNT (Items.item_id) AS CountOfItems
FROM Dwarves JOIN Items
ON Dwarves.dwarf_id = Items.owner_id;

5. Получить список всех отрядов и количество гномов в каждом отряде. Также включите в выдачу отряды без гномов.

6. Получить список профессий с наибольшим количеством незавершённых задач ("pending" и "in_progress") у гномов этих профессий.

7. Для каждого типа предметов узнать средний возраст гномов, владеющих этими предметами.

8. Найти всех гномов старше среднего возраста (по всем гномам в базе), которые не владеют никакими предметами.