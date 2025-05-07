Задача 2: Получение данных о гноме с навыками и назначениями.
Создайте запрос, который возвращает информацию о гноме, включая идентификаторы всех его навыков,
текущих назначений, принадлежности к отрядам и используемого снаряжения.

Решение 2-й задачи:
SELECT
    d.dwarf_id,
    d.name,
    d.age,
    d.profession,
    JSON_BUILD_OBJECT (
    'skill_ids', (
        SELECT JSON_AGG(ds.skill_id)
        FROM dwarf_skills ds
        WHERE ds.dwarf_id = d.dwarf_id
        ),
    'assignment_ids', (
        SELECT JSON_AGG(da.assignment_id)
        FROM dwarf_assignments da
        WHERE da.dwarf_id = d.dwarf_id
        ),
    'squad_ids', (
        SELECT JSON_AGG(sm.squad_id)
        FROM squad_members sm
        WHERE sm.dwarf_id = d.dwarf_id
        ),
    'equipment_ids', (
        SELECT JSON_AGG(de.equipment_id)
        FROM dwarf_equipment de
        WHERE de.dwarf_id = d.dwarf_id
        )
    ) AS related_entities
FROM
    dwarves d;
WHERE
    d.dwarf_id = 101;

Задача 3: Данные о мастерской с назначенными рабочими и проектами
Напишите запрос для получения информации о мастерской,
включая идентификаторы назначенных ремесленников, текущих проектов, используемых и производимых ресурсов.

Решение 3-й задачи:
SELECT
    w.workshop_id,
    w.name,
    w.type,
    w.quality,
    JSON_BUILD_OBJECT (
        'craftsdwarf_ids', (
            SELECT JSON_AGG(wc.dwarf_id)
            FROM workshop_craftsdwarves wc
            WHERE w.workshop_id = wc.workshop_id
        ),
        'project_ids', (
            SELECT JSON_AGG(p.project_id)
            FROM projects p
            WHERE w.workshop_id = p.workshop_id
        ),
        'input_material_ids', (
            SELECT JSON_AGG(wm.material_id)
            FROM workshop_materials wm
            WHERE w.workshop_id = wm.workshop_id AND wm.is_input = TRUE
        ),
        'output_product_ids', (
             SELECT JSON_AGG(wp.product_id)
             FROM workshop_products wp
             WHERE w.workshop_id = wp.workshop_id
        )
    ) AS related_entities
FROM
    workshops w;
WHERE
    w.workshop_id = 301;

Задача 4: Данные о военном отряде с составом и операциями
Разработайте запрос, который возвращает информацию о военном отряде,
включая идентификаторы всех членов отряда, используемого снаряжения, прошлых и текущих операций, тренировок.

Что примерно выдаст REST на основании этих данных:

[
  {
    "squad_id": 401,
    "name": "The Axe Lords",
    "formation_type": "Melee",
    "leader_id": 102,
    "related_entities": {
      "member_ids": [102, 104, 105, 107, 110],
      "equipment_ids": [5004, 5005, 5006, 5007, 5008],
      "operation_ids": [601, 602],
      "training_schedule_ids": [901, 902],
      "battle_report_ids": [1101, 1102, 1103]
    }
  }
]

Решение 4-й задачи:
SELECT
    ms.squad_id,
    ms.name,
    ms.formation_type,
    ms.leader_id,
    JSON_BUILD_OBJECT (
        'member_ids', (
            SELECT JSON_AGG(sm.dwarf_id)
            FROM squad_members sm
            WHERE sm.squad_id = ms.squad_id AND sm.exit_date IS NULL -- только текущие члены отряда
        ),
        'equipment_ids', (
            SELECT JSON_AGG(se.equipment_id)
            FROM squad_equipment se
            WHERE se.squad_id = ms.squad_id
        ),
        'operation_ids', (
            SELECT JSON_AGG(so.operation_id)
            FROM squad_operations so
            WHERE so.squad_id = ms.squad_id AND status IN ('current', 'previous') -- статусы прошлых и текущих операций (указаны возможны статусы)
        ),
        'training_schedule_ids', (
            SELECT JSON_AGG(st.schedule_id)
            FROM squad_training st
            WHERE st.squad_id = ms.squad_id
        ),
        'battle_report_ids', (
            SELECT JSON_AGG(sb.report_id)
            FROM squad_battles sb
            WHERE sb.squad_id = ms.squad_id
        )
    ) AS related_entities
FROM
    military_squads ms
WHERE
    squad_id = 401;