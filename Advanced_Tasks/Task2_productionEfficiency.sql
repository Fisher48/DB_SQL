Задача 2*: Комплексный анализ эффективности производства

Разработайте запрос, который анализирует эффективность каждой мастерской, учитывая:
- Производительность каждого ремесленника (соотношение созданных продуктов к затраченному времени)
- Эффективность использования ресурсов (соотношение потребляемых ресурсов к производимым товарам)
- Качество производимых товаров (средневзвешенное по ценности)
- Время простоя мастерской
- Влияние навыков ремесленников на качество товаров

Решение:

WITH workshop_stats AS (
    SELECT
        w.workshop_id,
        w.name AS workshop_name,
        w.type AS workshop_type,
        COUNT(DISTINCT wcd.dwarf_id) AS num_craftsdwarves,
        COUNT(DISTINCT wm.material_id) AS count_of_materials,
        SUM(wp.quantity) AS total_quantity_produced,
        SUM(p.value * wp.quantity) AS total_production_value,
        MIN(wp.production_date) AS first_production_date,
        MAX(wp.production_date) AS last_production_date,
        COUNT(DISTINCT wp.production_date) AS actual_product_days,
        SUM(wm.quantity) AS total_material_quantity
    FROM workshops w
    LEFT JOIN workshop_craftsdwarves wcd ON wcd.workshop_id = w.workshop_id
    LEFT JOIN workshop_products wp ON wp.workshop_id = w.workshop_id
    LEFT JOIN products p ON p.workshop_id = w.workshop_id
    LEFT JOIN workshop_materials wm ON wm.workshop_id = w.workshop_id
    GROUP BY w.workshop_id, w.name, w.type
),

workshop_period_stats AS (
    SELECT
        ws.workshop_id,
        EXTRACT(DAY FROM (ws.last_production_date - ws.first_production_date))
            AS total_days,
        ws.actual_product_days,
        ROUND(ws.total_quantity_produced / NULLIF(EXTRACT(DAY FROM (ws.last_production_date - ws.first_production_date)), 0), 2)
            AS daily_production_rate,
        ROUND(ws.total_production_value / NULLIF(ws.total_material_quantity, 0), 2)
            AS value_per_material_unit,
        ROUND(ws.actual_product_days * 100.0 / NULLIF(EXTRACT(DAY FROM (ws.last_production_date - ws.first_production_date)), 0), 2)
            AS workshop_utilization_percent,
        ROUND(ws.total_quantity_produced / NULLIF(ws.total_material_quantity, 0), 2)
            AS material_conversion_ratio,
        (EXTRACT(DAY FROM (ws.last_production_date - ws.first_production_date) - ws.actual_product_days))
            AS downtime_days
    FROM
        workshop_stats ws
    GROUP BY ws.workshop_id
),

craftsdwarf_skills AS (
    SELECT
        wcd.workshop_id,
        AVG(ds.level) AS average_craftsdwarf_skill,
        CORR(ds.level, p.value) AS skill_quality_correlation
    FROM workshop_craftsdwarves wcd
    JOIN dwarf_skills ds ON  ds.dwarf_id = wcd.dwarf_id
    JOIN workshop_products wp ON wp.workshop_id = wcd.workshop_id AND wp.dwarf_id = wcd.dwarf_id
    JOIN products p ON p.workshop_id = wp.workshop_id
    GROUP BY wcd.workshop_id
)

SELECT
    ws.workshop_id,
    ws.workshop_name,
    ws.workshop_type,
    ws.num_craftsdwarves,
    ws.total_quantity_produced,
    ws.total_production_value,
    wps.daily_production_rate,
    wps.value_per_material_unit,
    wps.workshop_utilization_percent,
    wps.downtime_days,
    wps.material_conversion_ratio,
    cs.average_craftsdwarf_skill,
    cs.skill_quality_correlation,
    JSON_BUILD_OBJECT (
             'craftsdwarf_ids', (
                 SELECT JSON_AGG(DISTINCT wc.dwarf_id)
                 FROM workshop_craftsdwarves wc
                 WHERE ws.workshop_id = wc.workshop_id
             ),
             'product_ids', (
                 SELECT JSON_AGG(DISTINCT wp2.product_id)
                 FROM workshop_products wp2
                 WHERE ws.workshop_id = wp2.workshop_id
             ),
             'material_ids', (
                 SELECT JSON_AGG(DISTINCT wm.material_id)
                 FROM workshop_materials wm
                 WHERE ws.workshop_id = wm.workshop_id
             ),
             'project_ids', (
                 SELECT JSON_AGG(DISTINCT pr.project_id)
                 FROM projects pr
                 WHERE ws.workshop_id = pr.workshop_id
             )
       ) AS related_entities
FROM workshop_stats ws
JOIN workshop_period_stats wps ON wps.workshop_id = ws.workshop_id
JOIN craftsdwarf_skills cs ON cs.workshop_id = ws.workshop_id
ORDER BY ws.total_production_value;


Возможный вариант выдачи:


[
  {
    "workshop_id": 301,
    "workshop_name": "Royal Forge",
    "workshop_type": "Smithy",
    "num_craftsdwarves": 4,
    "total_quantity_produced": 256,
    "total_production_value": 187500,

    "daily_production_rate": 3.41,
    "value_per_material_unit": 7.82,
    "workshop_utilization_percent": 85.33,

    "material_conversion_ratio": 1.56,

    "average_craftsdwarf_skill": 7.25,

    "skill_quality_correlation": 0.83,

    "related_entities": {
      "craftsdwarf_ids": [101, 103, 108, 115],
      "product_ids": [801, 802, 803, 804, 805, 806],
      "material_ids": [201, 204, 208, 210],
      "project_ids": [701, 702, 703]
    }
  },
  {
    "workshop_id": 304,
    "workshop_name": "Gemcutter's Studio",
    "workshop_type": "Jewelcrafting",
    "num_craftsdwarves": 2,
    "total_quantity_produced": 128,
    "total_production_value": 205000,

    "daily_production_rate": 2.56,
    "value_per_material_unit": 13.67,
    "workshop_utilization_percent": 78.95,

    "material_conversion_ratio": 0.85,

    "average_craftsdwarf_skill": 8.50,

    "skill_quality_correlation": 0.92,

    "related_entities": {
      "craftsdwarf_ids": [105, 112],
      "product_ids": [820, 821, 822, 823, 824],
      "material_ids": [206, 213, 217, 220],
      "project_ids": [705, 708]
    }
  }
]