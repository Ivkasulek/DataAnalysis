CREATE TABLE IF NOT EXISTS t_Ivana_Sulekova_project_SQL_primary_final AS
SELECT 
    cpay.value,
    cpay.value_type_code,
    cpay.industry_branch_code,
    cpay.payroll_year,
    cp.value AS food_price,
    cp.category_code,
    cp.date_from,
    cpib.code AS cpib_code,
    cpib.name AS cpib_name,
    cpc.*,
    CASE 
        WHEN cpay.value_type_code = 5958 THEN cpay.value
        ELSE NULL
    END AS payroll_value,
    CASE 
        WHEN cpay.value_type_code = 316 THEN cpay.value
        ELSE NULL
    END AS employee_count
FROM czechia_payroll cpay 
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cpay.industry_branch_code = cpib.code
LEFT JOIN czechia_price cp 
	ON cpay.payroll_year = year(cp.date_from)
LEFT JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
WHERE year(cp.date_from) BETWEEN 2006 AND 2018
	AND cpay.payroll_year BETWEEN 2006 AND 2018;
