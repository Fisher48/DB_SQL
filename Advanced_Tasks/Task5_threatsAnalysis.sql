 Задача 5*: Многофакторный анализ угроз и безопасности крепости

Разработайте запрос, который комплексно анализирует безопасность крепости, учитывая:
- Историю всех атак существ и их исходов
- Эффективность защитных сооружений
- Соотношение между типами существ и результативностью обороны
- Оценку уязвимых зон на основе архитектуры крепости
- Корреляцию между сезонными факторами и частотой нападений
- Готовность военных отрядов и их расположение
- Эволюцию защитных способностей крепости со временем

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
        l.zone_id,
        l.name AS zone_name,
        l.fortification_level AS fortification_level,
        ca.military_response_time_minutes AS military_response_time,
        (ca.military_response_time_minutes / 100) + (l.fortification_level / 10) AS vulnerability_score,
        SUM(CASE WHEN ca.outcome = 'Breached' THEN 1 ELSE 0 END) AS historical_breaches,
        AS defense_coverage...
    FROM locations l
    JOIN creature_attacks ca ON ca.location_id = l.location_id
    GROUP BY l.zone_id
),

fortress_defence_info AS (
    SELECT
        ca.defense_structures_used AS defense_type,
        AVG(ca.enemy_casualties) AS avg_enemy_casualties,
        COUNT(CASE WHEN ca.outcome = 'Breached' THEN 1 ELSE 0 END) AS defeats,
        COUNT(CASE WHEN ca.outcome = 'Defenced' THEN 1 ELSE 0 END) AS victories
    FROM creature_attacks ca
),

military_readiness_info AS (
    SELECT
        ms.squad_id,
        ms.name AS squad_name,
        COUNT(CASE WHEN sm.exit_date IS NULL THEN 1 ELSE 0 END) AS active_members,
        AVG(SELECT ds.level
            FROM dwarf_skills ds
            JOIN skills s ON s.skill_id = ds.skill_id
            JOIN squad_members sm ON sm.dwarf_id = ds.dwarf_id
            JOIN military_squad ms ON ms.squad_id = sm.squad_id
            WHERE s.category = 'Combat') AS avg_combat_skill,
           --- AS readiness_score

)


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
