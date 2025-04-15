USE stolen_vehicles_db;

-- Objective 1: Identify when vehicles are likely to be stolen
-- Task 1: Find the number of vehicles stolen each year
SELECT
	YEAR(date_stolen) AS year,
    COUNT(vehicle_id) AS total_vehicles
FROM
	stolen_vehicles
GROUP BY YEAR(date_stolen)
ORDER BY total_vehicles DESC;

-- Task 2: Find the number of vehicles stolen each month
SELECT
	YEAR(date_stolen) AS YEAR,
	MONTH(date_stolen) AS month,
    COUNT(vehicle_id) AS total_vehicles
FROM
	stolen_vehicles
GROUP BY YEAR(date_stolen), MONTH(date_stolen)
ORDER BY year, month;

SELECT
	YEAR(date_stolen) AS year,
	MONTH(date_stolen) AS month,
    DAY(date_stolen) AS day,
    COUNT(vehicle_id) AS total_vehicles
FROM
	stolen_vehicles
WHERE MONTH(date_stolen) = 4
GROUP BY YEAR(date_stolen), MONTH(date_stolen), DAY(date_stolen)
ORDER BY year, month, day;

-- Task 3: Find the number of vehicles stolen each day of the week
SELECT
	DAYOFWEEK(date_stolen) AS day_of_week,
    COUNT(vehicle_id) AS total_vehicles
FROM
	stolen_vehicles
GROUP BY DAYOFWEEK(date_stolen)
ORDER BY day_of_week;

-- Task 4: Replace the numeric day of week values with the full name of each day of the week (Sunday, Monday, Tuesday, etc)
SELECT
	DAYOFWEEK(date_stolen)  AS day_of_week,
    CASE 
		WHEN DAYOFWEEK(date_stolen) = 1 THEN 'Sunday'
        WHEN DAYOFWEEK(date_stolen) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(date_stolen) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(date_stolen) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(date_stolen) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(date_stolen) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(date_stolen) = 7 THEN 'Saturday'
	ELSE 'Other'
    END AS 	day_name,
    COUNT(vehicle_id) AS total_vehicles
FROM
	stolen_vehicles
GROUP BY DAYOFWEEK(date_stolen), day_name
ORDER BY day_of_week;


-- Objective 2: Identify which vehicles are likely to be stolen 

-- Task 1: Find the vehicle types that are most often and least often stolen 
SELECT
	vehicle_type,
    COUNT(vehicle_id) AS total_vehicles
FROM
	stolen_vehicles
GROUP BY vehicle_type
ORDER BY total_vehicles DESC
LIMIT 5;

SELECT
	vehicle_type,
    COUNT(vehicle_id) AS total_vehicles
FROM
	stolen_vehicles
GROUP BY vehicle_type
ORDER BY total_vehicles 
LIMIT 5;


-- Task 2: For each vehicle type, find the average age of the cars that are stolen 
SELECT
	vehicle_type,
    AVG(YEAR(date_stolen) - model_year) AS avg_age
FROM
	stolen_vehicles
GROUP BY vehicle_type
ORDER BY avg_age DESC;

-- Task 3: For each vehicle type, find the percent of vehicles stolen that are luxury versus standard 
WITH make_type_count AS (
SELECT
	vehicle_type,
    COUNT(CASE
			WHEN make_type = 'Standard' THEN vehicle_id
            END) AS standard_count,
	COUNT(CASE
			WHEN make_type = 'Luxury' THEN vehicle_id
			END) AS luxury_count
FROM
	stolen_vehicles s
    LEFT JOIN
    make_details m ON s.make_id = m.make_id
GROUP BY vehicle_type
)
SELECT
	s.vehicle_type,
    ROUND(standard_count * 100.0 / COUNT(vehicle_id),2) AS pct_standard,
    ROUND(luxury_count * 100.0 / COUNT(vehicle_id),2) AS pct_luxury
FROM
	stolen_vehicles s
    JOIN 
    make_type_count c ON s.vehicle_type = c.vehicle_type
GROUP BY vehicle_type;

-- Task 4: Create a table where the rows represent the top 10 vehicles types, the columns represents the top 7 vehicle colors 
-- (plus 1 column for all other colors) and the value are the number of vehicles stolen. 
SELECT * FROM stolen_vehicles;
/* 
Silver	1272
White	934
Black	589
Blue	512
Red	390
Grey	378
Green	224 
Other 
*/ 
SELECT
	vehicle_type,
    COUNT(CASE
			WHEN color = 'Silver' THEN vehicle_id
            END) AS silver,
	COUNT(CASE
			WHEN color = 'White' THEN vehicle_id
            END) AS white,
	COUNT(CASE
			WHEN color = 'Black' THEN vehicle_id
            END) AS black,
	COUNT(CASE
			WHEN color = 'Blue' THEN vehicle_id
            END) AS blue,
	COUNT(CASE
			WHEN color = 'Red' THEN vehicle_id
            END) AS red,
	COUNT(CASE
			WHEN color = 'Grey' THEN vehicle_id
            END) AS grey,
	COUNT(CASE
			WHEN color = 'Green' THEN vehicle_id
            END) AS green,
	COUNT(CASE
			WHEN color NOT IN ('Silver','White','Black','Blue','Red','Grey','Green') THEN vehicle_id
            END) AS other,
	COUNT(vehicle_id) AS total_vehicles
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY total_vehicles DESC
LIMIT 10
;

-- Objective 3: Identify where vehicles are likely to be stolen 
-- Task 1: Find the number of vehicles that were stolen in each region 
SELECT * FROM stolen_vehicles;
SELECT * FROM locations;

SELECT
	region,
    COUNT(vehicle_id) AS total_vehicles
FROM
	stolen_vehicles sv
    LEFT JOIN
    locations l ON sv.location_id = l.location_id
GROUP BY region;

-- Task 2: Combine the previous ouput with the population and density statistics for each region
SELECT
	l.region,
    COUNT(sv.vehicle_id) AS total_vehicles,
    l.population,
    l.density
FROM
	stolen_vehicles sv
    LEFT JOIN
    locations l ON sv.location_id = l.location_id
GROUP BY l.region, l.population, l.density
ORDER BY total_vehicles DESC;

-- Task 3: Do the types of vehicles stolen in the three most dense region differ from the three last dense regions? 
WITH top_dense_ranking AS (
SELECT
	l.region,
    COUNT(sv.vehicle_id) AS total_vehicles,
    l.population,
    l.density,
    ROW_NUMBER() OVER(ORDER BY density DESC) AS rn
FROM
	stolen_vehicles sv
    LEFT JOIN
    locations l ON sv.location_id = l.location_id
GROUP BY l.region, l.population, l.density
), 
top_3_dense_region AS (
SELECT
	region,
    total_vehicles,
    density
FROM 
	top_dense_ranking 
WHERE rn <= 3
),
bottom_dense_ranking AS (
SELECT
	l.region,
    COUNT(sv.vehicle_id) AS total_vehicles,
    l.population,
    l.density,
    ROW_NUMBER() OVER(ORDER BY density) AS rn
FROM
	stolen_vehicles sv
    LEFT JOIN
    locations l ON sv.location_id = l.location_id
GROUP BY l.region, l.population, l.density
),
bottom_3_dense_region AS (
SELECT
	region,
    total_vehicles,
    density
FROM
	bottom_dense_ranking
WHERE rn <= 3
),
region_report_extreme AS (
SELECT
	'High Density' AS dense_level,
	region,
    total_vehicles,
    density
FROM top_3_dense_region
UNION ALL
SELECT
	'Low Density',
	region,
    total_vehicles,
    density
FROM bottom_3_dense_region
ORDER BY density DESC
),
region_vehicle_type_ranking AS (
SELECT
	dense_level,
	rre.region,
    vehicle_type,
    COUNT(vehicle_id) AS total_vehicles,
    ROW_NUMBER() OVER(PARTITION BY region ORDER BY COUNT(vehicle_id) DESC) AS rn
FROM
	region_report_extreme rre
    LEFT JOIN
    locations l ON rre.region = l.region
    LEFT JOIN
    stolen_vehicles sv ON sv.location_id = l.location_id
GROUP BY rre.region, vehicle_type, dense_level
)
SELECT 
	dense_level,
	region,
    vehicle_type,
    total_vehicles
FROM
	region_vehicle_type_ranking
WHERE rn <= 3
ORDER BY dense_level;
