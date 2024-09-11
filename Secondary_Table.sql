CREATE TABLE t_Ivana_Sulekova_project_SQL_secondary_final AS 
SELECT 
	e.country AS economy_country,
	e.`year`,
	e.GDP,
	e.population,
	e.gini,
	e.taxes,
	c.country AS country_country,
	c.population_density,
	c.surface_area
FROM economies e 
LEFT JOIN countries c 
	ON e.country = c.country 
WHERE e.`year` BETWEEN 2006 AND 2018;