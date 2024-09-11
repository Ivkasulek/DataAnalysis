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
        ON current.`year` = previous.`year` + 1
),
GDP_Changes AS (
    SELECT 
        t2.`year`,
        t2.GDP,
        lag(t2.GDP) OVER (ORDER BY t2.`year`) AS prev_gdp,
        round((t2.GDP - LAG(t2.GDP) OVER (ORDER BY t2.`year`)) / nullif(lag(t2.GDP) OVER (ORDER BY t2.`year`), 0) * 100, 2) AS gdp_change_percent
    FROM t_ivana_sulekova_project_sql_secondary_final t2
    WHERE t2.economy_country = 'Czech Republic'
),
Comparison AS (
    SELECT 
        pc.`year`,
        pc.food_price_change_percent,
        pc.wage_change_percent,
        gdp.gdp_change_percent,
        abs(gdp.gdp_change_percent - pc.food_price_change_percent) AS difference_gdp_foodprice,
        abs(gdp.gdp_change_percent - pc.wage_change_percent) AS difference_gdp_wage,
        CASE
            WHEN gdp.gdp_change_percent > 10 AND ABS(pc.food_price_change_percent - gdp.gdp_change_percent) > 10 THEN 'Significant influence of GDP on prices'
            WHEN gdp.gdp_change_percent > 10 AND ABS(pc.wage_change_percent - gdp.gdp_change_percent) > 10 THEN 'Significant influence of GDP on payrolls'
            ELSE 'No significant influence'
        END AS gdp_influence_same_year
    FROM Percentage_Changes pc
    JOIN GDP_Changes gdp
        ON pc.`year` = gdp.`year`
    UNION ALL
    SELECT 
        pc.`year`,
        pc.food_price_change_percent,
        pc.wage_change_percent,
        gdp.gdp_change_percent,
        abs(gdp.gdp_change_percent - pc.food_price_change_percent) AS difference_gdp_foodprice,
        abs(gdp.gdp_change_percent - pc.wage_change_percent) AS difference_gdp_wage,
        CASE
            WHEN gdp.gdp_change_percent > 10 AND ABS(pc.food_price_change_percent - gdp.gdp_change_percent) > 10 THEN 'Significant influence of GDP on prices'
            WHEN gdp.gdp_change_percent > 10 AND ABS(pc.wage_change_percent - gdp.gdp_change_percent) > 10 THEN 'Significant influence of GDP on payrolls'
            ELSE 'No significant influence'
        END AS gdp_influence_next_year
    FROM Percentage_Changes pc
    JOIN GDP_Changes gdp
        ON pc.`year` = gdp.`year` - 1
)
SELECT * 
FROM Comparison
ORDER BY `year`;

   
   


