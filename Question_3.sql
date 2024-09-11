-- year-over-year analysis between years 2006-2018
WITH Yearly_Prices AS (
    SELECT 
        name AS food_item,
        year(date_from) AS `year`,
        round(avg(food_price), 2) AS avg_food_price
    FROM t_ivana_sulekova_project_sql_primary_final
    WHERE food_price IS NOT NULL
    GROUP BY 
        name,
        year(date_from)
),
Price_Changes AS (
    SELECT 
        current.food_item,
        current.`year` AS current_year,
        previous.`year` AS previous_year,
        current.avg_food_price AS current_price,
        previous.avg_food_price AS previous_price,
        CASE 
            WHEN previous.avg_food_price IS NULL OR previous.avg_food_price = 0 THEN NULL
            WHEN current.avg_food_price IS NULL THEN NULL
            ELSE ((current.avg_food_price - previous.avg_food_price) / previous.avg_food_price) * 100
        END AS percentage_change
    FROM Yearly_Prices current
    LEFT JOIN Yearly_Prices previous 
        ON current.food_item = previous.food_item 
        AND current.`year` = previous.`year` + 1
),
Cumulative_Percentage_Change AS (
    SELECT 
        food_item,
        sum(percentage_change) AS total_percentage_change
    FROM Price_Changes
    GROUP BY food_item
)
SELECT 
    food_item,
    total_percentage_change
FROM Cumulative_Percentage_Change
ORDER BY total_percentage_change ASC;




-- comparison between year 2018 and 2006   
WITH Yearly_Prices AS (
    SELECT 
        year(date_from) AS `year`,
        name AS food_item,
        round(avg(food_price), 2) AS avg_food_price
    FROM t_ivana_sulekova_project_sql_primary_final
    WHERE food_price IS NOT NULL
    GROUP BY 
        year(date_from),
        name
),
Price_Comparison AS (
    SELECT 
        yp1.food_item,
        yp1.avg_food_price AS price_2006,
        yp2.avg_food_price AS price_2018
    FROM Yearly_Prices yp1
    JOIN Yearly_Prices yp2
        ON yp1.food_item = yp2.food_item
        AND yp1.`year` = 2006
        AND yp2.`year` = 2018
)
SELECT 
    food_item,
    price_2006,
    price_2018,
    CASE 
        WHEN price_2006 IS NULL OR price_2006 = 0 THEN NULL
        ELSE ((price_2018 - price_2006) / price_2006) * 100
    END AS percentage_increase
FROM Price_Comparison
ORDER BY percentage_increase DESC;

-- Obe metódy vám poskytnú rôzne pohľady na rýchlosť zvyšovania cien. Vyberte metódu, ktorá najlepšie vyhovuje vašim analytickým potrebám a ktorá poskytuje najrelevantnejšie informácie pre vašu analýzu.
-- uprav tieto SQL dotazy!



