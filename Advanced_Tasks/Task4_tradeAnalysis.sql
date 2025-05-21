 Задача 4*: Комплексный анализ торговых отношений и их влияния на крепость

Разработайте запрос, анализирующий торговые отношения со всеми цивилизациями, оценивая:
- Баланс торговли с каждой цивилизацией за все время
- Влияние товаров каждого типа на экономику крепости
- Корреляцию между торговлей и дипломатическими отношениями
- Эволюцию торговых отношений во времени
- Зависимость крепости от определенных импортируемых товаров
- Эффективность экспорта продукции мастерских

Решение:

WITH traders_info AS (
    SELECT
        c.civilization_type,
        COUNT(DISTINCT t.trader_id) AS total_trading_partners,
        SUM(tt.value) AS all_time_trade_value,
        SUM(CASE cg.type = 'Import' THEN cg.value ELSE 0 END) AS import_trade_value,
        SUM(CASE cg.type = 'Export' THEN cg.value ELSE 0 END) AS export_trade_value,
        SUM(CASE cg.type = 'Export' THEN cg.value ELSE 0 END) -
        SUM(CASE cg.type = 'Import' THEN cg.value ELSE 0 END) AS all_time_trade_balance,
    FROM traders t
    JOIN trade_transactions tt ON tt.caravan_id = t.caravan_id
    JOIN caravans c ON c.caravan_id = t.caravan_id
    GROUP BY c.civilization_type
),

caravans_info AS (
    SELECT
        tt.caravan_id,
        SUM(tt.value) AS total_value,
        de.relationship_change AS relationship_change
        --CASE WHEN de.outcome = 'Success' THEN 'Favorable' ELSE 'Unfavorable' END AS trade_relationship, --Возможный вариант
    FROM trade_transactions tt
    JOIN diplomatic_events de ON tt.caravan_id = de.caravan_id
    GROUP BY tt.caravan_id
),

civilization_data AS (
    SELECT
        c.civilization_type,
        COUNT(DISTINCT c.caravan_id) AS total_caravans,
        SUM(tt.value) AS total_trade_value,
        SUM(CASE WHEN cg.type = 'Export' THEN tt.value ELSE -tt.value) as trade_balance,
        de.relationship_change AS trade_relationship,
        CORR(ci.total_value, ci.relationship_change) AS diplomatic_correlation,
        JSON_AGG(DISTINCT c.caravan_id) AS caravan_ids
    FROM caravans c
    JOIN trade_transactions tt ON tt.caravan_id = c.caravan_id
    JOIN caravans_info ci ON ci.caravan_id = c.caravan_id
    JOIN caravan_goods cg ON cg.caravan_id = c.caravan_id
    GROUP BY c.civilization_type
),

critical_import_info AS (
    SELECT
        c.civilization_type,
        cg.material_type AS material_type,
        (SUM(cg.quantity) * 100.0 / NULLIF((
               SELECT SUM(fr.quantity)
               FROM fortress_resources fr
               JOIN resources r ON fr.resource_id = r.resource_id
               WHERE r.type = cg.material_type
        ), 0)) AS dependency_score,
        SUM(cg.quantity) AS total_imported,
        COUNT(DISTINCT cg.material_type) AS import_diversity,
        JSON_AGG(DISTINCT cg.goods_id) AS resource_ids
    FROM caravan_goods cg
    JOIN caravans c ON c.caravan_id = cg.caravan_id
    WHERE cg.type = 'Import'
    GROUP BY c.civilization_type, cg.material_type
),

export_info AS (
    SELECT
        c.civilization_type,
        w.type AS workshop_type,
        p.type AS product_type,
        SUM(CASE WHEN cg.type = 'Export' THEN tt.value) * 100.0 / NULLIF(cd.total_trade_value, 0) AS export_ratio,
        AVG(cg.price_fluctuation) AS avg_markup,
        JSON_AGG(DISTINCT w.workshop_id) AS workshop_ids
    FROM caravans c
    JOIN trade_transactions tt ON tt.caravan_id = c.caravan_id
    JOIN caravan_goods cg ON c.caravan_id = cg.caravan_id
    JOIN products p ON cg_product_id = p.product_id
    JOIN workshops w ON w.workshop_id = p.workshop_id
    JOIN civilization_data cd ON c.civilization_type = cd.civilization_type
    GROUP BY c.civilization_type, workshop_type, product_type
),

trade_timeline_info AS (
    SELECT
        c.civilization_type,
        EXTRACT(YEAR FROM tt.date) AS year,
        EXTRACT(QUARTER FROM tt.date) AS quarter,
        SUM(tt.value) AS quarterly_value,
        SUM(CASE WHEN cg.type = 'Export' THEN tt.value ELSE -tt.value) AS quarterly_balance,
        COUNT(DISTINCT cg.material_type) AS trade_diversity
    FROM trade_transactions tt
    JOIN caravan_goods cg ON cg.caravan_id = tt.caravan_id
    WHERE tt.date IS NOT NULL
    GROUP BY c.civilization_type, year, quarter
    ORDER BY c.civilization_type, year, quarter
)

SELECT
    ti.total_trading_partners,
    ti.all_time_trade_value,
    ti.all_time_trade_balance,

        -- Торговля между цивилизациями
        (
            SELECT JSON_BUILD_OBJECT(
                'civilization_trade_data', JSON_AGG(
                    JSON_BUILD_OBJECT(
                    'civilization_type', cd.civilization_type,
                    'total_caravans', cd.total_caravans,
                    'total_trade_value', cd.total_trade_value,
                    'trade_balance', cd.trade_balance,
                    'trade_relationship', cd.trade_relationship,
                    'diplomatic_correlation', cd.diplomatic_correlation,
                    'caravan_ids', cd.caravan_ids,
                    )
                )
            )
            FROM civilization_data cd
        ) AS civilization_data,

        -- Импорт
        (
            SELECT JSON_BUILD_OBJECT(
                'resource_dependency', JSON_AGG(
                    JSON_BUILD_OBJECT(
                    'material_type', ci.material_type,
                    'dependency_score', ROUND(ci.dependency_score, 1),
                    'total_imported', ci.total_imported,
                    'import_diversity', ci.import_diversity,
                    'resource_ids', ci.resource_ids
                    )
                )
            )
            FROM critical_import_info ci
        ) AS critical_import_dependencies,

        -- Экспорт
        (
            SELECT JSON_BUILD_OBJECT(
                'export_effectiveness', JSON_AGG(
                    JSON_BUILD_OBJECT(
                    'workshop_type', ei.workshop_type,
                    'product_type', ei.product_type,
                    'export_ratio', ei.export_ratio,
                    'avg_markup', ROUND(ei.avg_markup, 2),
                    'workshop_ids', ei.workshop_ids
                    )
                )
            )
            FROM export_info ei
        ) AS export_effectiveness,

        -- Хронология торговли
        (
            SELECT JSON_BUILD_OBJECT(
                'trade_growth', JSON_AGG(
                    JSON_BUILD_OBJECT(
                    'year', tti.year,
                    'quarter', tti.quarter,
                    'quarterly_value', tti.quarterly_value,
                    'quarterly_balance', tti.quarterly_balance,
                    'trade_diversity', tti.trade_diversity
                    ) ORDER BY tti.year, tti.quarter
                )
            )
            FROM trade_timeline_info tti
        ) AS trade_timeline

FROM civilization_data cd
LEFT JOIN traders_info ti ON ti.civilization_type = cd.civilization_type
ORDER BY cd.civilization_type;


Возможный вариант выдачи:

{
  "total_trading_partners": 5,
  "all_time_trade_value": 15850000,
  "all_time_trade_balance": 1250000,
  "civilization_data": {
    "civilization_trade_data": [
      {
        "civilization_type": "Human",
        "total_caravans": 42,
        "total_trade_value": 5240000,
        "trade_balance": 840000,
        "trade_relationship": "Favorable",
        "diplomatic_correlation": 0.78,
        "caravan_ids": [1301, 1305, 1308, 1312, 1315]
      },
      {
        "civilization_type": "Elven",
        "total_caravans": 38,
        "total_trade_value": 4620000,
        "trade_balance": -280000,
        "trade_relationship": "Unfavorable",
        "diplomatic_correlation": 0.42,
        "caravan_ids": [1302, 1306, 1309, 1316, 1322]
      }
    ]
  },
  "critical_import_dependencies": {
    "resource_dependency": [
      {
        "material_type": "Exotic Metals",
        "dependency_score": 2850.5,
        "total_imported": 5230,
        "import_diversity": 4,
        "resource_ids": [202, 208, 215]
      },
      {
        "material_type": "Lumber",
        "dependency_score": 1720.3,
        "total_imported": 12450,
        "import_diversity": 3,
        "resource_ids": [203, 209, 216]
      }
    ]
  },
  "export_effectiveness": {
    "export_effectiveness": [
      {
        "workshop_type": "Smithy",
        "product_type": "Weapons",
        "export_ratio": 78.5,
        "avg_markup": 1.85,
        "workshop_ids": [301, 305, 310]
      },
      {
        "workshop_type": "Jewelery",
        "product_type": "Ornaments",
        "export_ratio": 92.3,
        "avg_markup": 2.15,
        "workshop_ids": [304, 309, 315]
      }
    ]
  },
  "trade_timeline": {
    "trade_growth": [
      {
        "year": 205,
        "quarter": 1,
        "quarterly_value": 380000,
        "quarterly_balance": 20000,
        "trade_diversity": 3
      },
      {
        "year": 205,
        "quarter": 2,
        "quarterly_value": 420000,
        "quarterly_balance": 35000,
        "trade_diversity": 4
      }
    ]
  }
}
