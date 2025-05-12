Задача 1*: Анализ эффективности экспедиций

Напишите запрос, который определит наиболее и наименее успешные экспедиции, учитывая:
- Соотношение выживших участников к общему числу
- Ценность найденных артефактов
- Количество обнаруженных новых мест
- Успешность встреч с существами (отношение благоприятных исходов к неблагоприятным)
- Опыт, полученный участниками (сравнение навыков до и после)

Решение:

-- Соотношение выживших участников к общему числу
WITH survival_rate AS (
    SELECT em.expedition_id,
    ROUND (100.0 * COUNT(*) FILTER (WHERE survived) / COUNT(*), 2) AS survival_rate)
    FROM expedition_members em
    GROUP BY em.expedition_id
),

-- Ценность найденных артефактов
artifacts AS (
    SELECT ea.expedition_id, SUM(value) AS artifacts_value
    FROM expedition_artifacts ea
    GROUP BY ea.expedition_id
),

-- Количество обнаруженных новых мест
discovered_sites AS (
    SELECT es.expedition_id, COUNT(site_id) AS discovered_sites
    FROM expedition_sites es
    GROUP BY es.expedition_id
),

-- Успешность встреч с существами (отношение благоприятных исходов к неблагоприятным)
encounter_success_rate AS (
    SELECT ec.expedition_id,
    ROUND(100.0 * COUNT(*) FILTER (WHERE outcome = 'favorable') / COUNT(*), 2) AS encounter_success_rate
    FROM expedition_creatures ec
    GROUP BY ec.expedition_id
),

-- Опыт участников до экспедиции
skill_before AS (
    SELECT em.expedition_id, em.dwarf_id, SUM(ds.experience) AS experience_before
    FROM expedition_members em
    JOIN dwarf_skills ds ON em.dwarf_id = ds.dwarf_id
    WHERE em.return_date IS NULL
    GROUP BY em.expedition_id, em.dwarf_id
),

-- Опыт участников после экспедиции
skill_after AS (
    SELECT em.expedition_id, em.dwarf_id, SUM(ds.experience) AS experience_after
    FROM expedition_members em
    JOIN dwarf_skills ds ON em.dwarf_id = ds.dwarf_id
    WHERE em.return_date IS NOT NULL
    GROUP BY em.expedition_id, em.dwarf_id
),

-- Сравнение навыков до и после
skill_gained AS (
    SELECT sa.expedition_id,
    ROUND(AVG(sa.experience_after - sb.experience_before), 1) AS skill_improvement
    FROM skill_before sb
    JOIN skill_after sa
    ON sa.expedition_id = sb.expedition_id AND sa.dwarf_id = sb.dwarf_id
    GROUP BY sa.expedition_id
)

-- Основной запрос
SELECT
   e.expedition_id,
   e.destination,
   e.status,
   sr.survival_rate,
   COALESCE(a.artifacts_value, 0) AS artifacts_value,
   COALESCE(ds.discovered_sites, 0) AS discovered_sites,
   COALESCE(er.encounter_success_rate, 0) AS encounter_success_rate,
   COALESCE(sg.skill_improvement, 0) AS skill_improvement,
   (e.return_date - e.departure_date) AS expedition_duration,
   (ROUND(
      COALESCE(sr.survival_rate, 0) / 10 +
      COALESCE(a.artifacts_value, 0) / 1000 +
      COALESCE(ds.discovered_sites, 0) / 10 +
      COALESCE(sg.skill_improvement, 0) / 10 +
      COALESCE(er.encounter_success_rate, 0) / 10,
      2
   ) AS overall_success_score,
   JSON_BUILD_OBJECT (
         'member_ids', (
             SELECT JSON_AGG(em.dwarf_id)
             FROM expedition_members em
             WHERE e.expedition_id = em.expedition_id
         ),
         'artifact_ids', (
             SELECT JSON_AGG(ea.artifact_id)
             FROM expedition_artifacts ea
             WHERE e.expedition_id = ea.expedition_id
         ),
         'site_ids', (
             SELECT JSON_AGG(es.site_id)
             FROM expedition_sites es
             WHERE e.expedition_id = es.expedition_id
         )
   ) AS related_entities
FROM expeditions e
LEFT JOIN survival_rate sr ON e.expedition_id = sr.expedition_id
LEFT JOIN artifacts a ON e.expedition_id = a.expedition_id
LEFT JOIN discovered_sites ds ON e.expedition_id = ds.expedition_id
LEFT JOIN encounter_success_rate er ON e.expedition_id = er.expedition_id
LEFT JOIN skill_gained sg ON e.expedition_id = sg.expedition_id
WHERE e.status = 'Completed'
ORDER BY overall_success_score DESC;



Возможный вариант выдачи:

[
  {
    "expedition_id": 2301,
    "destination": "Ancient Ruins",
    "status": "Completed",
    "survival_rate": 71.43,
    "artifacts_value": 28500,
    "discovered_sites": 3,
    "encounter_success_rate": 66.67,
    "skill_improvement": 14,
    "expedition_duration": 44,
    "overall_success_score": 0.78,
    "related_entities": {
      "member_ids": [102, 104, 107, 110, 112, 115, 118],
      "artifact_ids": [2501, 2502, 2503],
      "site_ids": [2401, 2402, 2403]
    }
  },
  {
    "expedition_id": 2305,
    "destination": "Deep Caverns",
    "status": "Completed",
    "survival_rate": 80.00,
    "artifacts_value": 42000,
    "discovered_sites": 2,
    "encounter_success_rate": 83.33,
    "skill_improvement": 18,
    "expedition_duration": 38,
    "overall_success_score": 0.85,
    "related_entities": {
      "member_ids": [103, 105, 108, 113, 121],
      "artifact_ids": [2508, 2509, 2510, 2511],
      "site_ids": [2410, 2411]
    }
  },
  {
    "expedition_id": 2309,
    "destination": "Abandoned Fortress",
    "status": "Completed",
    "survival_rate": 50.00,
    "artifacts_value": 56000,
    "discovered_sites": 4,
    "encounter_success_rate": 42.86,
    "skill_improvement": 23,
    "expedition_duration": 62,
    "overall_success_score": 0.63,
    "related_entities": {
      "member_ids": [106, 109, 111, 119, 124, 125],
      "artifact_ids": [2515, 2516, 2517, 2518, 2519],
      "site_ids": [2420, 2421, 2422, 2423]
    }
  }
]