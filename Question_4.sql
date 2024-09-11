WITH Yearly_Averages AS (
    SELECT 
        year(date_from) AS `year`,
        name AS food_item,
        round(avg(value), 2) AS avg_wage,
        round(avg(food_price), 2) AS avg_food_price
    FROM t_Ivana_Sulekova_project_SQL_primary_final
    WHERE value_type_code = 5958
    GROUP BY 
    	year(date_from), 
    	name
),
Percentage_Changes AS (
    SELECT 
        current.year,
        current.food_item,
        current.avg_food_price AS current_food_price,
        previous.avg_food_price AS previous_food_price,
        current.avg_wage AS current_wage,
        previous.avg_wage AS previous_wage,
        CASE 
            WHEN previous.avg_food_price IS NOT NULL AND previous.avg_food_price <> 0 THEN 
                round(((current.avg_food_price - previous.avg_food_price) / previous.avg_food_price) * 100, 2)
            ELSE NULL
        END AS food_price_change_percent,
        CASE 
            WHEN previous.avg_wage IS NOT NULL AND previous.avg_wage <> 0 THEN 
                round(((current.avg_wage - previous.avg_wage) / previous.avg_wage) * 100, 2)
            ELSE NULL
        END AS wage_change_percent
    FROM Yearly_Averages current
    LEFT JOIN Yearly_Averages previous
        ON current.food_item = previous.food_item
        AND current.year = previous.year + 1
)
SELECT 
    year,
    food_item,
    food_price_change_percent,
    wage_change_percent,
    CASE 
        WHEN food_price_change_percent IS NOT NULL 
        AND wage_change_percent IS NOT NULL
        AND abs(food_price_change_percent) > (abs(wage_change_percent) + 10) THEN 'Yes'
        ELSE 'No'
    END AS significant_increase
FROM Percentage_Changes
WHERE 
	food_price_change_percent IS NOT NULL
ORDER BY 
	`year`, 
	food_item;


-- without food prices categorization
WITH Yearly_Averages AS (
    SELECT 
        year(date_from) AS `year`,
        round(avg(value), 2) AS avg_wage,
        round(avg(food_price), 2) AS avg_food_price
    FROM t_Ivana_Sulekova_project_SQL_primary_final
    WHERE value_type_code = 5958
    GROUP BY 
    	year(date_from)
),
Percentage_Changes AS (
    SELECT 
        current.`year`,
        current.avg_food_price AS current_food_price,
        previous.avg_food_price AS previous_food_price,
        current.avg_wage AS current_wage,
        previous.avg_wage AS previous_wage,
        CASE 
            WHEN previous.avg_food_price IS NOT NULL AND previous.avg_food_price <> 0 THEN 
                round(((current.avg_food_price - previous.avg_food_price) / previous.avg_food_price) * 100, 2)
            ELSE NULL
        END AS food_price_change_percent,
        CASE 
            WHEN previous.avg_wage IS NOT NULL AND previous.avg_wage <> 0 THEN 
                round(((current.avg_wage - previous.avg_wage) / previous.avg_wage) * 100, 2)
            ELSE NULL
        END AS wage_change_percent
    FROM Yearly_Averages current
    LEFT JOIN Yearly_Averages previous
        ON current.year = previous.year + 1
)
SELECT 
    year,
    food_price_change_percent,
    wage_change_percent,
    abs(food_price_change_percent - wage_change_percent) AS difference,
    CASE 
        WHEN food_price_change_percent IS NOT NULL 
        AND wage_change_percent IS NOT NULL
        AND abs(food_price_change_percent) > (abs(wage_change_percent) + 10) THEN 'Yes'
        ELSE 'No'
    END AS significant_increase
FROM Percentage_Changes
WHERE 
	food_price_change_percent IS NOT NULL
ORDER BY 
	`year`;