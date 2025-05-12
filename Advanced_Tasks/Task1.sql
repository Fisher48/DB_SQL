Задача 1*: Анализ эффективности экспедиций

Напишите запрос, который определит наиболее и наименее успешные экспедиции, учитывая:
- Соотношение выживших участников к общему числу
- Ценность найденных артефактов
- Количество обнаруженных новых мест
- Успешность встреч с существами (отношение благоприятных исходов к неблагоприятным)
- Опыт, полученный участниками (сравнение навыков до и после)


SELECT
   e.expedition_id,
   e.destination,
   e.status,
    ROUND ( ((SELECT COUNT(em.survived) * 100.0 AS survival
     FROM expedition_members em
     WHERE e.expedition_id = em.expedition_id AND survived = TRUE) /
     (SELECT COUNT(*) AS overall
      FROM expedition_members em
      WHERE e.expedition_id = em.expedition_id)), 2) AS survival_rate,

    (SELECT SUM(value) AS artifacts_value
     FROM expedition_artifacts ea
     WHERE e.expedition_id = ea.expedition_id) AS artifacts_value,

    (SELECT COUNT(site_id)
     FROM expedition_sites es
     WHERE e.expedition_id = es.expedition_id) AS discovered_sites,

    ROUND ( ((SELECT COUNT(outcome) * 100.0
     FROM expedition_creatures ec
     WHERE e.expedition_id = ec.expedition_id AND outcome = 'favorable') /
    (SELECT COUNT(*)
     FROM expedition_creatures ec
     WHERE e.expedition_id = ec.expedition_id)), 2) AS encounter_success_rate,

    ((SELECT level
     FROM dwarf_skills ds
     JOIN expedition_members em ON em.dwarf_id = ds.dwarf_id
     JOIN expeditions e ON e.expedition_id = em.expedition_id
     WHERE ds.dwarf_id = em.dwarf_id AND em.return_date IS NULL) /
     (SELECT level
      FROM dwarf_skills ds
      JOIN expedition_members em ON em.dwarf_id = ds.dwarf_id
      JOIN expeditions e ON e.expedition_id = em.expedition_id
      WHERE ds.dwarf_id = em.dwarf_id AND em.return_date IS NOT NULL)) AS skill_improvement,

     (e.return_date - e.departure_date) AS expedition_duration,

     (SELECT
        survival_rate / 10,
        artifacts_value / 1000,
        discovered_sites,
        skill_improvement / 10,
        encounter_success_rate / 10
      FROM
        expeditions e) AS overall_success_score,

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
FROM
  expeditions e;




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