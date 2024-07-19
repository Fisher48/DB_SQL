1. Найдите все отряды, у которых нет лидера.
SELECT
    s.name AS Squad_name_without_leader
FROM
    Squads s
WHERE
    leader_id IS NULL;

2. Получите список всех гномов старше 150 лет, у которых профессия "Warrior".
SELECT
    d.dwarf_id,
    d.name AS Dwarf_name,
    d.profession AS Profession
FROM
    Dwarves d
WHERE
    d.profession = 'Warrior'
    AND d.age > 150;

3. Найдите гномов, у которых есть хотя бы один предмет типа "weapon".
SELECT
    d.dwarf_id,
    d.name AS DwarfName,
    i.type AS Weapon
FROM
    Dwarves d
JOIN
    Items i
ON
    i.owner_id = d.dwarf_id
WHERE
    i.type = 'weapon';
GROUP BY
    d.dwarf_id, d.name, i.type;

4. Получите количество задач для каждого гнома, сгруппировав их по статусу.
SELECT
    d.dwarf_id,
    d.name AS DwarfName,
    t.status AS Status,
    COUNT(t.task_id) AS TasksCount
FROM
    Dwarves d
LEFT JOIN
    Tasks t
ON
    t.assigned_to = d.dwarf_id
GROUP BY
    d.dwarf_id, d.name, t.status;

5. Найдите все задачи, которые были назначены гномам из отряда с именем "Guardians".
SELECT
    t.task_id,
    t.description AS DescriptionOfTask,
    t.status AS Status
FROM
    Tasks t
JOIN
    Dwarves d
ON
    t.assigned_to = d.dwarf_id
JOIN
    Squads s
ON
    d.squad_id = s.squad_id
WHERE
    s.name = 'Guardians';


6. Выведите всех гномов и их ближайших родственников, указав тип родственных отношений.
SELECT
    d1.name AS Dwarf_name,
    d2.name AS Relative_dwarf,
    r.relationship AS TypeRelationships
FROM
    Dwarves d1
JOIN
    Relationships r
ON
    r.dwarf_id = d1.dwarf_id OR r.related_to = d1.dwarf_id
JOIN
    Dwarves d2
ON
    r.related_to = d2.dwarf_id OR r.dwarf_id = d2.dwarf_id
WHERE
    r.relationship IN ('Друг', 'Супруг', 'Родитель');


