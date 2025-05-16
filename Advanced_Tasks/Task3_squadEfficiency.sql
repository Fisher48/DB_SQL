Задача 3*: Комплексная оценка военной эффективности отрядов

Создайте запрос, оценивающий эффективность военных отрядов на основе:
- Результатов всех сражений (победы/поражения/потери)
- Соотношения побед к общему числу сражений
- Навыков членов отряда и их прогресса
- Качества экипировки
- Истории тренировок и их влияния на результаты
- Выживаемости членов отряда в долгосрочной перспективе

Решение:

WITH squad_stats AS (
    SELECT
        ms.squad_id,
        ms.name AS squad_name,
        ms.formation_type,
        sm.dwarf_name AS leader_name,
        AVG(e.equipment_id) AS avg_equipment_quality
    FROM military_squads ms
    LEFT JOIN squad_members sm ON ms.squad_id = sm.squad_id AND ms.leader_id = sm.dwarf_id
    LEFT JOIN squad_equipment se ON ms.squad_id = se.squad_id
    LEFT JOIN equipment e ON e.equipment_id = se.equipment_id

),

WITH battle_stats AS (
    SELECT
        sb.squad_id,
        COUNT(sb.report_id) AS total_battles,
        SUM(CASE sb.report_id WHERE outcome = 'Victory' 1 ELSE 0) AS victories,
        SUM(CASE sb.report_id WHERE outcome = 'Defeat' 1 ELSE 0) AS defeats,
        ROUND(sb.victories::DECIMAL / NULLIF(sb.total_battles), 2) AS victory_percentage,
        SUM(sb.casualties) AS casualties,
        SUM(sb.enemy_casualties) AS enemy_casualties
        COUNT(DISTINCT sb.dwarf_id) AS total_members_ever,
        (total_members_ever - casualties) AS current_members,
    FROM squad_battles sb
),

WITH training_stats AS (
    SELECT
        st.squad_id,
        COUNT(CASE st.schedule_id WHERE st.squad.id = ms.squad.id 1 ELSE 0) AS total_training_sessions,
        AVG(st.effectiveness) AS avg_training_effectiveness
    FROM squad_training st
    JOIN military_squads ms ON st.squad_id = ms.squad_id

)

SELECT
    ss.squad_id,
    ss.squad_name,
    ss.formation_type,
    ss.leader_name,
    ss.avg_equipment_quality,
    bs.total_battles,
    bs.victories,
    bs.victory_percentage,
    bs.casualties,
    bs.total_members_ever,
    bs.current_members,
    ROUND(current_members / NULLIF(total_members_ever, 0), 2) AS retention_rate,
    JSON_BUILD_OBJECT (
        'member_ids', (
            SELECT JSON_AGG(sm.dwarf_id)
            FROM squad_members sm
            WHERE sm.squad_id = ss.squad_id
        ),
        'equipment_ids', (
            SELECT JSON_AGG(se.equipment_id)
            FROM squad_equipment se
            WHERE se.squad_id = ss.squad_id
        ),
        'battle_report_ids', (
            SELECT JSON_AGG(sb.report_id)
            FROM squad_battles sb
            WHERE sb.squad_id = ss.squad_id
        ),
        'training_ids', (
            SELECT JSON_AGG(st.schedule_id)
            FROM squad_training st
            WHERE st.squad_id = ss.squad_id
        )
    )
FROM
    squad_stats ss
LEFT JOIN battle_stats bs ON bs.squad_id = ss.squad_id
LEFT JOIN training_stats ts ON ts.squad_id = ss.squad_id
GROUP BY
    ss.squad_id, ss.squad_name, formation_type, ss.leader_name,ss.avg_equipment_quality, bs.total_battles,
    bs.victories, bs.victory_percentage, bs.casualties, bs.total_members_ever, bs.current_members
ORDER BY
    ss.victory_percentage, ss.casualty_rate, ss.retention_rate, overall_effectiveness_score;



Возможный вариант выдачи:


[
  {
    "squad_id": 401,
    "squad_name": "The Axe Lords",
    "formation_type": "Melee",
    "leader_name": "Urist McAxelord",
    "total_battles": 28,
    "victories": 22,
    "victory_percentage": 78.57,
    "casualty_rate": 24.32,
    "casualty_exchange_ratio": 3.75,
    "current_members": 8,
    "total_members_ever": 12,
    "retention_rate": 66.67,
    "avg_equipment_quality": 4.28,
    "total_training_sessions": 156,
    "avg_training_effectiveness": 0.82,
    "training_battle_correlation": 0.76,
    "avg_combat_skill_improvement": 3.85,
    "overall_effectiveness_score": 0.815,
    "related_entities": {
      "member_ids": [102, 104, 105, 107, 110, 115, 118, 122],
      "equipment_ids": [5001, 5002, 5003, 5004, 5005, 5006, 5007, 5008, 5009],
      "battle_report_ids": [1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108],
      "training_ids": [901, 902, 903, 904, 905, 906]
    }
  },
  {
    "squad_id": 403,
    "squad_name": "Crossbow Legends",
    "formation_type": "Ranged",
    "leader_name": "Dokath Targetmaster",
    "total_battles": 22,
    "victories": 18,
    "victory_percentage": 81.82,
    "casualty_rate": 16.67,
    "casualty_exchange_ratio": 5.20,
    "current_members": 7,
    "total_members_ever": 10,
    "retention_rate": 70.00,
    "avg_equipment_quality": 4.45,
    "total_training_sessions": 132,
    "avg_training_effectiveness": 0.88,
    "training_battle_correlation": 0.82,
    "avg_combat_skill_improvement": 4.12,
    "overall_effectiveness_score": 0.848,
    "related_entities": {
      "member_ids": [106, 109, 114, 116, 119, 123, 125],
      "equipment_ids": [5020, 5021, 5022, 5023, 5024, 5025, 5026],
      "battle_report_ids": [1120, 1121, 1122, 1123, 1124, 1125],
      "training_ids": [920, 921, 922, 923, 924]
    }
  }
]