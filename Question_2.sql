WITH Prices_Payrolls AS (
    SELECT 
        year(date_from) AS `year`,
        name AS food_item,
        round(avg(value), 2) AS avg_wages,
        round(avg(food_price), 2) AS avg_food_price
    FROM t_ivana_sulekova_project_sql_primary_final
    WHERE 
        (name LIKE 'chléb%' OR name LIKE 'Mléko%')
        AND value IS NOT NULL
    GROUP BY 
        year(date_from),
        name
)
SELECT 
    year,
    food_item,
    avg_wages,
    avg_food_price,
    round(avg_wages / avg_food_price, 2) AS affordable_quantity
FROM Prices_Payrolls
WHERE year IN (2006, 2018)
ORDER BY 
	`year`, 
	food_item;


