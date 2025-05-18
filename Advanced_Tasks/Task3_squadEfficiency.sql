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
        COUNT(DISTINCT sm.dwarf_id) AS total_members_ever,
        SUM(CASE WHEN sm.exit_date IS NULL THEN 1 ELSE 0 END) AS current_members,
        AVG(e.quality) AS avg_equipment_quality
    FROM military_squads ms
    LEFT JOIN squad_members sm ON ms.squad_id = sm.squad_id
    LEFT JOIN dwarves d ON ms.leader_id = d.dwarf_id
    LEFT JOIN squad_equipment se ON ms.squad_id = se.squad_id
    LEFT JOIN equipment e ON e.equipment_id = se.equipment_id
    GROUP BY ms.squad_id, ms.name, ms.formation_type
),

battle_stats AS (
    SELECT
        sb.squad_id,
        COUNT(sb.report_id) AS total_battles,
        SUM(CASE WHEN outcome = 'Victory' THEN 1 ELSE 0 END) AS victories,
        SUM(CASE WHEN outcome = 'Defeat' THEN 1 ELSE 0 END) AS defeats,
        SUM(sb.casualties) AS casualties,
        SUM(sb.enemy_casualties) AS enemy_casualties
    FROM squad_battles sb
    GROUP BY sb.squad_id
),

training_stats AS (
    SELECT
        st.squad_id,
        COUNT(st.schedule_id) AS total_training_sessions,
        AVG(st.effectiveness) AS avg_training_effectiveness
    FROM squad_training st
    GROUP BY st.squad_id
),

skill_improvements AS (
    SELECT
        sm.squad_id,
        SUM(CASE WHEN ds.date > sm.join_date THEN ds.level ELSE 0 END) AS current_skill_level,
        SUM(CASE WHEN ds.date <= sm.join_date THEN ds.level ELSE 0 END) AS skill_level_before
    FROM squad_members sm
    JOIN dwarf_skills ds ON sm.dwarf_id = ds.dwarf_id
    JOIN skills s ON ds.skill_id = s.skill_id
    WHERE s.category = 'Combat'
    GROUP BY sm.squad_id, sm.dwarf_id
)

SELECT
    ss.squad_id,
    ss.squad_name,
    ss.formation_type,
    ss.leader_name,
    ss.avg_equipment_quality,
    bs.total_battles,
    bs.victories,
    bs.defeats,
    ss.total_members_ever,
    ss.current_members,
    bs.casualties,
    ROUND(bs.victories::DECIMAL / NULLIF(bs.total_battles, 0), 2) AS victory_percentage,
    ROUND(bs.enemy_casualties::DECIMAL / NULLIF(bs.casualties, 0), 2) AS casualty_exchange_ratio,
    ROUND(bs.casualties::DECIMAL / NULLIF(ss.total_members_ever, 0), 2) AS casualty_rate,
    ROUND(ss.current_members / NULLIF(ss.total_members_ever, 0), 2) AS retention_rate,
    ts.total_training_sessions,
    ts.avg_training_effectiveness,
    ROUND(AVG(si.current_skill_level - si.skill_level_before), 2) AS avg_combat_skill_improvement,
    CORR(ts.total_training_sessions, bs.victories) AS training_battle_correlation,
    ROUND(
        (bs.victories::DECIMAL / NULLIF(bs.total_battles, 0) * 0.35) +
        (AVG(si.current_skill_level - si.skill_level_before) * 0.25) +
        (ss.current_members / NULLIF(ss.total_members_ever, 0) * 0.25) +
        ts.avg_training_effectiveness * 0.2,
    3) AS overall_effectiveness_score,
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
GROUP BY ss.squad_id, ss.squad_name, ss.formation_type
ORDER BY overall_effectiveness_score DESC;



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