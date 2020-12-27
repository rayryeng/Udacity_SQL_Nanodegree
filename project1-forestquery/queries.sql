/* Please run the view creation code in the commented section below if you are creating this table for the first time */
/*
DROP VIEW IF EXISTS forestation;

CREATE VIEW forestation
AS
SELECT f.country_name, f.country_code, f.year, f.forest_area_sqkm, (l.total_area_sq_mi * 2.59) AS total_area_sqkm, (100.0 * f.forest_area_sqkm / (l.total_area_sq_mi * 2.59)) AS percent_land_area_as_forest, r.region, r.income_group
FROM forest_area f
JOIN land_area l
ON f.country_code = l.country_code AND f.year = l.year
JOIN regions r
ON f.country_code = r.country_code
ORDER BY f.country_code;
*/

/* Q 1-1 */
SELECT forest_area_sqkm
FROM forestation
WHERE region = 'World' AND year = 1990;

/* Q 1-2 */
SELECT forest_area_sqkm
FROM forestation
WHERE region = 'World' AND year = 2016;

/* Q 1-3 */
SELECT pp.forest_area_sqkm - p.forest_area_sqkm AS diff_forest_area_sqkm
FROM forest_area pp
JOIN forest_area p
ON pp.year = 1990 AND p.year = 2016
AND pp.country_name = 'World' AND p.country_name = 'World';

/* Q 1-4 */
SELECT 100.0*(pp.forest_area_sqkm - p.forest_area_sqkm) / p.forest_area_sqkm AS diff_forest_area_sqkm
FROM forest_area pp
JOIN forest_area p
ON pp.year = 1990 AND p.year = 2016
AND pp.country_name = 'World' AND p.country_name = 'World';

/* Q 1-5 */
SELECT country_name, country_code, year, total_area_sqkm, ABS(total_area_sqkm -
(SELECT pp.forest_area_sqkm - p.forest_area_sqkm AS diff_forest_area_sqkm
FROM forest_area pp
JOIN forest_area p
ON pp.year = 1990 AND p.year = 2016
AND pp.country_name = 'World' AND p.country_name = 'World')
) AS diff
FROM forestation
WHERE year = 2016
ORDER BY diff
LIMIT 1;

/* Q 2-a1 */
SELECT region, 100.0 * SUM(forest_area_sqkm) / SUM(total_area_sqkm) AS percent_forest_area, year
FROM forestation
WHERE region = 'World' AND year = 2016
GROUP BY region, year;

/* Q 2-a2 */
SELECT region, 100.0 * SUM(forest_area_sqkm) / SUM(total_area_sqkm) AS percent_forest_area, year
FROM forestation
WHERE year = 2016
GROUP BY region, year
ORDER BY percent_forest_area DESC
LIMIT 1;

/* Q 2-a3 */
SELECT region, 100.0 * SUM(forest_area_sqkm) / SUM(total_area_sqkm) AS percent_forest_area, year
FROM forestation
WHERE year = 2016
GROUP BY region, year
ORDER BY percent_forest_area
LIMIT 1;

/* Q 2-b1 */ 
SELECT region, 100.0 * SUM(forest_area_sqkm) / SUM(total_area_sqkm) AS percent_forest_area, year
FROM forestation
WHERE region = 'World' AND year = 1990
GROUP BY region, year;

/* Q 2-b2 */
SELECT region, 100.0 * SUM(forest_area_sqkm) / SUM(total_area_sqkm) AS percent_forest_area, year
FROM forestation
WHERE year = 1990
GROUP BY region, year
ORDER BY percent_forest_area DESC
LIMIT 1;

/* Q 2-b3 */
SELECT region, 100.0 * SUM(forest_area_sqkm) / SUM(total_area_sqkm) AS percent_forest_area, year
FROM forestation
WHERE year = 1990
GROUP BY region, year
ORDER BY percent_forest_area
LIMIT 1;

/* Q 2-c */
SELECT q.region, 100.0 * SUM(q.forest_area_sqkm) / SUM(q.total_area_sqkm) AS percent_forest_area_1990, 100.0 * SUM(qq.forest_area_sqkm) / SUM(qq.total_area_sqkm) AS percent_forest_area_2016
FROM forestation q
JOIN forestation qq
ON q.year = 1990 AND qq.year = 2016 AND q.region = qq.region
GROUP BY q.region, q.year
ORDER BY percent_forest_area_1990 DESC;

/* Q 3-a */
SELECT q.country_name, q.forest_area_sqkm AS forest_area_sqkm_1990, qq.forest_area_sqkm AS forest_area_sqkm_2016, qq.forest_area_sqkm - q.forest_area_sqkm AS diff
FROM forestation q
JOIN forestation qq
ON q.year = 1990 AND qq.year = 2016 AND q.country_name = qq.country_name
WHERE qq.forest_area_sqkm - q.forest_area_sqkm IS NOT NULL
ORDER BY diff DESC;

/* Q 3-a continued - largest concerns */
SELECT q.country_name, q.region, q.forest_area_sqkm AS forest_area_sqkm_1990, qq.forest_area_sqkm AS forest_area_sqkm_2016, qq.forest_area_sqkm - q.forest_area_sqkm AS diff
FROM forestation q
JOIN forestation qq
ON q.year = 1990 AND qq.year = 2016 AND q.country_name = qq.country_name
WHERE qq.forest_area_sqkm - q.forest_area_sqkm IS NOT NULL AND q.country_name != 'World'
ORDER BY diff
LIMIT 5;

/* Q 3-b */
SELECT q.country_name, q.forest_area_sqkm AS forest_area_sqkm_1990, qq.forest_area_sqkm AS forest_area_sqkm_2016, 100.0*(qq.forest_area_sqkm - q.forest_area_sqkm) / q.forest_area_sqkm AS diff
FROM forestation q
JOIN forestation qq
ON q.year = 1990 AND qq.year = 2016 AND q.country_name = qq.country_name
WHERE qq.forest_area_sqkm - q.forest_area_sqkm IS NOT NULL
ORDER BY diff DESC;

/* Q 3-b continued - biggest concerns */
SELECT q.country_name, q.region, q.forest_area_sqkm AS forest_area_sqkm_1990, qq.forest_area_sqkm AS forest_area_sqkm_2016, 100.0*(qq.forest_area_sqkm - q.forest_area_sqkm) / q.forest_area_sqkm AS diff
FROM forestation q
JOIN forestation qq
ON q.year = 1990 AND qq.year = 2016 AND q.country_name = qq.country_name
WHERE qq.forest_area_sqkm - q.forest_area_sqkm IS NOT NULL
ORDER BY diff
LIMIT 5;

/* Q 3-c */
SELECT quartiles, COUNT(*) as num_countries
FROM (
SELECT country_name, percent_land_area_as_forest,
CASE WHEN percent_land_area_as_forest <= 25 THEN '0-25%'
WHEN percent_land_area_as_forest > 25 AND percent_land_area_as_forest <= 50 THEN '25-50%'
WHEN percent_land_area_as_forest > 50 AND percent_land_area_as_forest <= 75 THEN '50-75%'
ELSE '75-100%' END AS quartiles
FROM forestation
WHERE year = 2016 AND percent_land_area_as_forest IS NOT NULL) AS q
GROUP BY quartiles
ORDER BY quartiles;

/* Q 3-d */
SELECT country_name, region, percent_land_area_as_forest
FROM (
SELECT country_name, region, percent_land_area_as_forest,
CASE WHEN percent_land_area_as_forest <= 25 THEN '0-25%'
WHEN percent_land_area_as_forest > 25 AND percent_land_area_as_forest <= 50 THEN '25-50%'
WHEN percent_land_area_as_forest > 50 AND percent_land_area_as_forest <= 75 THEN '50-75%'
ELSE '75-100%' END AS quartiles
FROM forestation
WHERE year = 2016 AND percent_land_area_as_forest IS NOT NULL) AS q
WHERE quartiles = '75-100%'
ORDER BY percent_land_area_as_forest DESC;

/* Q 3-e */
SELECT COUNT (*)
FROM (
SELECT country_name, percent_land_area_as_forest
FROM forestation
WHERE percent_land_area_as_forest > 
    (SELECT percent_land_area_as_forest as usa
	FROM forestation
	WHERE country_name = 'United States' AND year = 2016) 
    AND year = 2016) as q;