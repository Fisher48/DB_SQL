1. Получить информацию о всех гномах, которые входят в какой-либо отряд, вместе с информацией об их отрядах.
SELECT d.*, s.name AS squad_name, s.mission
FROM dwarves d
JOIN squads s ON s.squad_id = d.squad_id
WHERE d.squad_id IS NOT NULL;


2. Найти всех гномов с профессией "miner", которые не состоят ни в одном отряде.
SELECT d.*
FROM dwarves d
WHERE d.profession = 'miner' AND d.squad_id IS NULL;


3. Получить все задачи с наивысшим приоритетом, которые находятся в статусе "pending".
SELECT t.*
FROM tasks t
WHERE status = 'pending'
AND priority = (SELECT MAX(priority) FROM tasks WHERE status = 'pending');


4. Для каждого гнома, который владеет хотя бы одним предметом, получить количество предметов, которыми он владеет.
SELECT d.dwarf_id, d.name, COUNT(*) AS items_count
FROM dwarves d
JOIN items i ON d.dwarf_id = i.owner_id
GROUP BY d.dwarf_id, d.name;


5. Получить список всех отрядов и количество гномов в каждом отряде. Также включите в выдачу отряды без гномов.
SELECT s.name AS squad_name, COUNT(d.dwarf_id) AS dwarf_count
FROM squads s
LEFT JOIN dwarves d ON s.squad_id = d.squad_id
GROUP BY s.squad_id, s.name;


6. Получить список профессий с наибольшим количеством незавершённых задач ("pending" и "in_progress") у гномов этих профессий.
SELECT d.profession, COUNT(t.task_id) AS tasks_count
FROM dwarves d
JOIN tasks t ON t.assigned_to = d.dwarf_id
WHERE status IN ('pending', 'in_progress')
GROUP BY d.profession
ORDER BY tasks_count DESC LIMIT 1;


7. Для каждого типа предметов узнать средний возраст гномов, владеющих этими предметами.
SELECT i.type, AVG(d.age) AS average_age
FROM items i
JOIN dwarves d ON i.owner_id = d.dwarf_id
WHERE owner_id IS NOT NULL
GROUP BY i.type;


8. Найти всех гномов старше среднего возраста (по всем гномам в базе), которые не владеют никакими предметами.
SELECT d.*
FROM dwarves d
WHERE d.age > (SELECT AVG(age) FROM dwarves)
AND NOT EXISTS (SELECT 1 FROM items i WHERE i.owner_id = d.dwarf_id);
