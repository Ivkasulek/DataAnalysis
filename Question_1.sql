-- comparison between year 2006 and 2018
SELECT
    cpib_name AS industry,
    round(avg(CASE WHEN payroll_year = '2006' THEN value ELSE NULL END), 2) AS payroll_2006,
    round(avg(CASE WHEN payroll_year = '2018' THEN value ELSE NULL END), 2) AS payroll_2018,
    CASE 
        WHEN round(avg(CASE WHEN payroll_year = '2006' THEN value ELSE NULL END), 2) > 0 THEN
            round(
                (avg(CASE WHEN payroll_year = '2018' THEN value ELSE NULL END) - 
                avg(CASE WHEN payroll_year = '2006' THEN value ELSE NULL END)) / 
                avg(CASE WHEN payroll_year = '2006' THEN value ELSE NULL END) * 100, 2)
        ELSE 
            NULL
    END AS percentage_change,
    CASE 
        WHEN round(avg(CASE WHEN payroll_year = '2018' THEN value ELSE NULL END), 2) > 
             round(avg(CASE WHEN payroll_year = '2006' THEN value ELSE NULL END), 2)
        THEN 'increasing'
        WHEN round(avg(CASE WHEN payroll_year = '2018' THEN value ELSE NULL END), 2) < 
             round(avg(CASE WHEN payroll_year = '2006' THEN value ELSE NULL END), 2)
        THEN 'decreasing'
        ELSE 'no change'
    END AS trend
FROM 
    t_ivana_sulekova_project_sql_primary_final tispspf 
WHERE 
    value IS NOT NULL
    AND cpib_name IS NOT NULL
    AND value_type_code = 5958
GROUP BY 
    cpib_name
ORDER BY 
    cpib_name;


-- year-over-year comparison
WITH Annual_Payroll AS (
    SELECT
        cpib_name AS industry,
        payroll_year,
        round(avg(value), 2) AS avg_payroll
    FROM
        t_ivana_sulekova_project_sql_primary_final
    WHERE
        value IS NOT NULL
        AND cpib_name IS NOT NULL
        AND value_type_code = 5958
    GROUP BY
        cpib_name, payroll_year
),
Yearly_Differences AS (
    SELECT
        industry,
        payroll_year,
        avg_payroll,
        lag(avg_payroll) OVER (PARTITION BY industry ORDER BY payroll_year) AS previous_year_payroll,
        CASE
            WHEN lag(avg_payroll) OVER (PARTITION BY industry ORDER BY payroll_year) IS NOT NULL AND lag(avg_payroll) OVER (PARTITION BY industry ORDER BY payroll_year) > 0 THEN
                round(((avg_payroll - lag(avg_payroll) OVER (PARTITION BY industry ORDER BY payroll_year)) / lag(avg_payroll) OVER (PARTITION BY industry ORDER BY payroll_year)) * 100, 2)
            ELSE NULL
        END AS payroll_percentage_difference
    FROM
        Annual_Payroll
)
SELECT
    industry,
    max(CASE WHEN payroll_year = '2006' THEN payroll_percentage_difference END) AS pct_diff_2006,
    max(CASE WHEN payroll_year = '2007' THEN payroll_percentage_difference END) AS pct_diff_2007,
    max(CASE WHEN payroll_year = '2008' THEN payroll_percentage_difference END) AS pct_diff_2008,
    max(CASE WHEN payroll_year = '2009' THEN payroll_percentage_difference END) AS pct_diff_2009,
    max(CASE WHEN payroll_year = '2010' THEN payroll_percentage_difference END) AS pct_diff_2010,
    max(CASE WHEN payroll_year = '2011' THEN payroll_percentage_difference END) AS pct_diff_2011,
    max(CASE WHEN payroll_year = '2012' THEN payroll_percentage_difference END) AS pct_diff_2012,
    max(CASE WHEN payroll_year = '2013' THEN payroll_percentage_difference END) AS pct_diff_2013,
    max(CASE WHEN payroll_year = '2014' THEN payroll_percentage_difference END) AS pct_diff_2014,
    max(CASE WHEN payroll_year = '2015' THEN payroll_percentage_difference END) AS pct_diff_2015,
    max(CASE WHEN payroll_year = '2016' THEN payroll_percentage_difference END) AS pct_diff_2016,
    max(CASE WHEN payroll_year = '2017' THEN payroll_percentage_difference END) AS pct_diff_2017,
    max(CASE WHEN payroll_year = '2018' THEN payroll_percentage_difference END) AS pct_diff_2018,
    sum(payroll_percentage_difference) AS total_percentage_difference,
    CASE
        WHEN sum(payroll_percentage_difference) > 0 THEN 'increasing' 
        WHEN sum(payroll_percentage_difference) < 0 THEN 'decreasing'
        ELSE 'no significant change'
    END AS trend
FROM
    Yearly_Differences
GROUP BY
    industry
ORDER BY
    industry;


