 Задача 5*: Многофакторный анализ угроз и безопасности крепости

Разработайте запрос, который комплексно анализирует безопасность крепости, учитывая:
- Историю всех атак существ и их исходов
- Эффективность защитных сооружений
- Соотношение между типами существ и результативностью обороны
- Оценку уязвимых зон на основе архитектуры крепости
- Корреляцию между сезонными факторами и частотой нападений
- Готовность военных отрядов и их расположение
- Эволюцию защитных способностей крепости со временем


Хочу заранее отметить, скорее всего не хватает описания 8 таблиц, 5 из которых возможно требуются для выполнения этого задания:
47.Структуры защиты (Defense_Structures): Размещены в локациях (n:1), используются при обороне.
48.Военные станции (Military_Stations): Связаны с отрядами (n:1), локациями (n:1), определяют размещение отрядов.
49.Передвижения отрядов (Squad_Movement): Связывают отряды с патрулируемыми зонами (n:m).
50.Зоны военного покрытия (Military_Coverage_Zones): Связывают отряды с зонами и временем реакции (n:m).
51.События крепости (Fortress_Events): Фиксируют важные события, влияющие на крепость.
52.Записи о погоде (Weather_Records): Содержат данные о погодных условиях в разные даты.
53.Фазы луны (Moon_Phases): Фиксируют фазы луны, влияющие на игровые механики.
54.Рекомендации по безопасности (Security_Recommendations): Содержат рекомендации по улучшению защиты крепости.
Исхожу из того, что было в БД на момент 1-ой задачи.

Решение:
WITH threat_history_info AS (
    SELECT
        c.type AS creature_type,
        c.threat_level AS threat_level,
        MAX(cs.date) AS last_sighting_date,
        MIN(cd.distance_to_fortress) AS territory_proximity,
        c.estimated_population AS estimated_population
    FROM creatures c
    JOIN creature_sightings cs ON cs.creature_id = c.creature_id
    WHERE c.active IS NOT NULL
    GROUP BY c.type, c.threat_level
),

vulnerability_analysis AS (
    SELECT
        l.location_id AS zone_id,
        l.name AS zone_name,
        l.fortification_level AS fortification_level,
        ca.military_response_time_minutes AS military_response_time,
        (ca.military_response_time_minutes / 100) + (l.fortification_level / 10) AS vulnerability_score,
        SUM(CASE WHEN ca.outcome = 'Breached' THEN 1 ELSE 0 END) AS historical_breaches
    FROM locations l
    JOIN creature_attacks ca ON ca.location_id = l.location_id
    GROUP BY l.location_id
),

fortress_defence_info AS (
    SELECT
        ds.type AS defense_type,
        AVG(ca.enemy_casualties) AS avg_enemy_casualties,
        COUNT(CASE WHEN ca.outcome = 'Breached' THEN 1 END) AS defeats,
        COUNT(CASE WHEN ca.outcome = 'Defended' THEN 1 END) AS victories,
        COUNT(DISTINCT ca.attack_id) AS all_attacks
    FROM creature_attacks ca
    LEFT JOIN defense_structures ds ON ca.defense_structures_used = ds.defense_structure_id
    GROUP BY ds.type
),

military_readiness_info AS (
    SELECT
        ms.squad_id,
        ms.name AS squad_name,
        COUNT(CASE WHEN sm.exit_date IS NULL THEN sm.dwarf_id END) AS active_members,
        AVG(s.level) AS avg_combat_skill,
        ca.military_response_time_minutes * COUNT(CASE WHEN sm.exit_date IS NULL THEN sm.dwarf_id END) AS readiness_score
    FROM dwarf_skills ds
    JOIN skills s ON s.skill_id = ds.skill_id
    JOIN squad_members sm ON sm.dwarf_id = ds.dwarf_id
    JOIN military_squads ms ON ms.squad_id = sm.squad_id
    JOIN creature_attacks ca ON ms.fortress_id = ca.location_id
    WHERE s.category IN ('Combat', 'Military')
    GROUP BY ms.squad_id, ms.name
),

security_evolution_history AS (
    SELECT
        EXTRACT(YEAR FROM ca.date) AS year,
        SUM(CASE WHEN ca.outcome = 'Defended' THEN 1 ELSE 0) as successful_defenced,
        COUNT(DISTINCT ca.attack_id) AS total_attacks,
        SUM(ca.casualties) AS casualties,
        ROUND(
            COUNT(CASE WHEN ca.outcome = 'Defended' THEN 1 ELSE 0)::DECIMAL /
            NULLIF(COUNT(DISTINCT ca.attack_id), 0) * 100, 2
        ) AS defense_success_rate
    FROM creature_attacks ca
    GROUP BY EXTRACT(YEAR FROM ca.date)
)

SELECT
    (SELECT COUNT(*) FROM creature_attacks ca) AS total_recorded_attacks,
    (SELECT COUNT(DISTINCT(ca.attack_id)) FROM creature_attacks ca) AS unique_attackers,
    (SELECT
        ROUND(COUNT(CASE WHEN ca.outcome = 'Defended' THEN 1 ELSE 0)::DECIMAL /
                    NULLIF(COUNT(*), 0) * 100, 2)
                    FROM creature_attacks ca) AS overall_defense_success_rate,

    JSON_BUILD_OBJECT(
        'threat_assessment',
            JSON_BUILD_OBJECT(
                'current_threat_level',
                    (SELECT
                        CASE
                            WHEN AVG(thi.threat_level) > 10 THEN 'High'
                            WHEN AVG(thi.threat_level) BETWEEN 5 AND 10 THEN 'Moderate'
                            ELSE 'Low'
                            END
                            FROM threat_history_info thi),
                'active_threats', (
                    SELECT
                        JSON_AGG(
                            JSON_BUILD_OBJECT(
                                'creature_type', thi.creature_type,
                                'threat_level', thi.threat_level,
                                'last_sighting_date', thi.last_sighting_date,
                                'territory_proximity', thi.territory_proximity,
                                'estimated_numbers', thi.estimated_population,
                                'creature_ids', (
                                    SELECT JSON_AGG(c.creature_id)
                                    FROM creatures c
                                    WHERE c.type = thi.type
                                )
                            )
                        )
                    FROM threat_history_info thi
                )
            ),
        'vulnerability_analysis', (
            SELECT
                JSON_AGG(
                    JSON_BUILD_OBJECT(
                        'zone_id', va.zone_id,
                        'zone_name', va.zone_name,
                        'vulnerability_score', va.vulnerability_score,
                        'historical_breaches', va.historical_breaches,
                        'fortification_level', va.fortification_level,
                        'military_response_time', va.military_response_time,
                        'defense_coverage',
                        JSON_BUILD_OBJECT(
                            'structure_ids', (
                                SELECT JSON_AGG(ds.defense_structure_id)
                                FROM defense_structures ds
                                WHERE va.zone_id = ds.location_id
                            ),
                            'squad_ids', (
                                SELECT JSON_AGG(ms.squad_id)
                                FROM military_squads ms
                                JOIN fortress f ON f.fortress_id = ms.fortress_id
                                JOIN locations l ON l.name = f.locations
                                WHERE l.location_id = va.zone_id
                            )
                        )
                    )
                )
            FROM vulnerability_analysis va
        ),
        'defense_effectiveness', (
            SELECT
                JSON_AGG(
                    JSON_BUILD_OBJECT(
                        'defense_type', fdi.defense_type,
                        'effectiveness_rate', (fdi.victories::DECIMAL / fdi.all_attacks) * 100,
                        'avg_enemy_casualties', fdi.avg_enemy_casualties,
                        JSON_BUILD_OBJECT(
                            'structure_ids', (
                                SELECT JSON_AGG(ds.defense_structure_id)
                                FROM defense_structures ds
                                WHERE ds.defense_type = fdi.defense_type
                            )
                        )
                    )
                )
            FROM fortress_defence_info fdi
        ),
        'military_readiness_assessment', (
            SELECT
                JSON_AGG(
                    JSON_BUILD_OBJECT(
                        'squad_id', mri.squad_id,
                        'squad_name', mri.squad_name,
                        'readiness_score', mri.readiness_score,
                        'active_members', mri.active_members,
                        'avg_combat_skill', mri.avg_combat_skill,
                        'combat_effectiveness',
                            (mri.active_members * mri.avg_combat_skill) / 100,
                        'response_coverage', (
                            SELECT
                                JSON_AGG(
                                    JSON_BUILD_OBJECT(
                                        'zone_id', mcz.zone_id,
                                        'response_time', mcz.response_time
                                    )
                                )
                            FROM military_coverage_zones mcz
                            WHERE mcz.squad_id = mri.squad_id
                        )
                    )
                )
            FROM military_readiness_info mri
        ),
        'security_evolution', (
            SELECT
                JSON_AGG(
                    JSON_BUILD_OBJECT(
                        'year', seh.year,
                        'defense_success_rate', seh.defense_success_rate,
                        'total_attacks', seh.total_attacks,
                        'casualties', seh.casualties,
                        'year_over_year_improvement',
                            seh.defense_success_rate - LAG(seh.defense_success_rate) OVER (ORDER BY seh.year)
                    )
                )
            FROM security_evolution_history seh
        )
    ) AS security_analysis
FROM (SELECT 1) AS dummy
ORDER BY overall_defense_success_rate;


Возможный вариант выдачи:

{
  "total_recorded_attacks": 183,
  "unique_attackers": 42,
  "overall_defense_success_rate": 76.50,
  "security_analysis": {
    "threat_assessment": {
      "current_threat_level": "Moderate",
      "active_threats": [
        {
          "creature_type": "Goblin",
          "threat_level": 3,
          "last_sighting_date": "0205-08-12",
          "territory_proximity": 1.2,
          "estimated_numbers": 35,
          "creature_ids": [124, 126, 128, 132, 136]
        },
        {
          "creature_type": "Forgotten Beast",
          "threat_level": 5,
          "last_sighting_date": "0205-07-28",
          "territory_proximity": 3.5,
          "estimated_numbers": 1,
          "creature_ids": [158]
        }
      ]
    },
    "vulnerability_analysis": [
      {
        "zone_id": 15,
        "zone_name": "Eastern Gate",
        "vulnerability_score": 0.68,
        "historical_breaches": 8,
        "fortification_level": 2,
        "military_response_time": 48,
        "defense_coverage": {
          "structure_ids": [182, 183, 184],
          "squad_ids": [401, 405]
        }
      }
    ],
    "defense_effectiveness": [
      {
        "defense_type": "Drawbridge",
        "effectiveness_rate": 95.12,
        "avg_enemy_casualties": 12.4,
        "structure_ids": [185, 186, 187, 188]
      },
      {
        "defense_type": "Trap Corridor",
        "effectiveness_rate": 88.75,
        "avg_enemy_casualties": 8.2,
        "structure_ids": [201, 202, 203, 204]
      }
    ],
    "military_readiness_assessment": [
      {
        "squad_id": 403,
        "squad_name": "Crossbow Legends",
        "readiness_score": 0.92,
        "active_members": 7,
        "avg_combat_skill": 8.6,
        "combat_effectiveness": 0.85,
        "response_coverage": [
          {
            "zone_id": 12,
            "response_time": 0
          },
          {
            "zone_id": 15,
            "response_time": 36
          }
        ]
      }
    ],
    "security_evolution": [
      {
        "year": 203,
        "defense_success_rate": 68.42,
        "total_attacks": 38,
        "casualties": 42,
        "year_over_year_improvement": 3.20
      },
      {
        "year": 204,
        "defense_success_rate": 72.50,
        "total_attacks": 40,
        "casualties": 36,
        "year_over_year_improvement": 4.08
      }
    ]
  }
}
