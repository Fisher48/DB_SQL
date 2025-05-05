1. Найдите все отряды, у которых нет лидера.
SELECT s.*
FROM squads s
WHERE s.leader_id IS NULL;


2. Получите список всех гномов старше 150 лет, у которых профессия "Warrior".
SELECT name, age, profession
FROM dwarves
WHERE age > 150 and profession = 'Warrior';


3. Найдите гномов, у которых есть хотя бы один предмет типа "weapon".
SELECT DISTINCT d.*
FROM dwarves d
JOIN items i ON d.dwarf_id = i.owner_id
WHERE i.type = 'weapon';


4. Получите количество задач для каждого гнома, сгруппировав их по статусу.
SELECT assigned_to, status, COUNT(*) AS tasks_count
FROM tasks
GROUP BY assigned_to, status;


5. Найдите все задачи, которые были назначены гномам из отряда с именем "Guardians".
SELECT t.*
FROM tasks t
JOIN dwarves d ON t.assigned_to = d.dwarf_id
JOIN squads s ON d.squad_id = s.squad_id
WHERE s.name = 'Guardians';


6. Выведите всех гномов и их ближайших родственников, указав тип родственных отношений.
SELECT d1.name AS dwarf_name, d2.name AS relative_name, r.relationship AS relation
FROM relationships r
JOIN dwarves d1 ON d1.dwarf_id = r.dwarf_id
JOIN dwarves d2 ON d2.dwarf_id = r.related_to
WHERE relationship IN ('Супруг', 'Родитель');