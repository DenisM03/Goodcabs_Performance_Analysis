-- Goodscab Ad-hoc Analysis

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Business Request-1:City-Level Fare and Trip Summary Report
-- ------------------------------------------------------------------------------------------------------------------------------------

WITH TotalTrips AS (
    SELECT 
		COUNT(trip_id) AS total_trips
    FROM trips_db.fact_trips
)
SELECT 
	c.city_name,
    COUNT(t.trip_id) AS "Total_trips",
    ROUND(SUM(t.fare_amount) / SUM(t.distance_travelled_km),2) AS "Avg_fare_per_km",
    ROUND(AVG(t.fare_amount),2) AS "Avg_fare_per_trip",
    ROUND((COUNT(t.trip_id) * 100.0 / tt.total_trips), 2) AS "%_contribution_to_total_trips"
FROM 
	trips_db.fact_trips AS t
JOIN 
	trips_db.dim_city AS c
ON 
	t.city_id=c.city_id
CROSS JOIN 
    TotalTrips tt
GROUP BY 
    c.city_name, tt.total_trips
ORDER BY 
    Total_trips DESC;

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Business Request-2:Monthly City-Level Trips Target Performance Report
-- ------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    cities.city_name AS "City",
    MONTHNAME(target_trips.month) AS "Month", 
	trips.Total_trips AS Actual_trips,
    target_trips.total_target_trips,
    CASE
		WHEN trips.Total_trips > target_trips.total_target_trips THEN "Above_target"
        ELSE "Below_target"
    END AS Performance_status,
	ROUND( (trips.Total_trips - target_trips.total_target_trips) / target_trips.total_target_trips * 100,2) AS "%_difference"
FROM 
	targets_db.monthly_target_trips AS target_trips
JOIN 
	trips_db.dim_city AS cities
ON 
	target_trips.city_id=cities.city_id
LEFT JOIN (
			SELECT 
				city_id,
				MONTHNAME(date) AS Month_name,
				COUNT(DISTINCT trip_id) AS Total_trips
			FROM 
				trips_db.fact_trips
			GROUP BY 
				city_id,MONTHNAME(date)
            ) AS trips
ON 
	target_trips.city_id = trips.city_id AND trips.Month_name = MONTHNAME(target_trips.month);

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Business Request-3: City-Level Repeat Passenger Trip Frequent Report
-- ------------------------------------------------------------------------------------------------------------------------------------

SELECT 
	cities.city_name,
    ROUND(SUM(CASE WHEN td.trip_count = "2-Trips" THEN td.repeat_passenger_count ELSE 0 END) / SUM(td.repeat_passenger_count) * 100 ,2) AS "2-Trips",
    ROUND(SUM(CASE WHEN td.trip_count = "3-Trips" THEN td.repeat_passenger_count ELSE 0 END) / SUM(td.repeat_passenger_count) * 100 ,2) AS "3-Trips",
    ROUND(SUM(CASE WHEN td.trip_count = "4-Trips" THEN td.repeat_passenger_count ELSE 0 END) / SUM(td.repeat_passenger_count) * 100 ,2) AS "4-Trips",
    ROUND(SUM(CASE WHEN td.trip_count = "5-Trips" THEN td.repeat_passenger_count ELSE 0 END) / SUM(td.repeat_passenger_count) * 100 ,2) AS "5-Trips",
    ROUND(SUM(CASE WHEN td.trip_count = "6-Trips" THEN td.repeat_passenger_count ELSE 0 END) / SUM(td.repeat_passenger_count) * 100 ,2) AS "6-Trips",
    ROUND(SUM(CASE WHEN td.trip_count = "7-Trips" THEN td.repeat_passenger_count ELSE 0 END) / SUM(td.repeat_passenger_count) * 100 ,2) AS "7-Trips",
    ROUND(SUM(CASE WHEN td.trip_count = "8-Trips" THEN td.repeat_passenger_count ELSE 0 END) / SUM(td.repeat_passenger_count) * 100 ,2) AS "8-Trips",
    ROUND(SUM(CASE WHEN td.trip_count = "9-Trips" THEN td.repeat_passenger_count ELSE 0 END) / SUM(td.repeat_passenger_count) * 100 ,2) AS "9-Trips",
    ROUND(SUM(CASE WHEN td.trip_count = "10-Trips" THEN td.repeat_passenger_count ELSE 0 END) / SUM(td.repeat_passenger_count) * 100 ,2) AS "10-Trips"
FROM 
	trips_db.dim_repeat_trip_distribution AS td
JOIN 
	trips_db.dim_city AS cities
ON 
	td.city_id=cities.city_id
GROUP BY 1;

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Business Request-4: Identify the Cities with Highest and Lowest New Passengers 
-- ------------------------------------------------------------------------------------------------------------------------------------

-- Top 3 Cities
SELECT 
	cities.city_name,
    SUM(tp.new_passengers) AS new_passengers,
    ROW_NUMBER() OVER(ORDER BY SUM(tp.new_passengers) DESC) AS "Top 3"
FROM 
	trips_db.fact_passenger_summary tp
JOIN 
	trips_db.dim_city cities
ON 
	tp.city_id = cities.city_id
GROUP BY 
	cities.city_name
LIMIT 3;

-- Bottom 3 Cities
SELECT 
	cities.city_name,
    SUM(tp.new_passengers) AS new_passengers,
    ROW_NUMBER() OVER(ORDER BY SUM(tp.new_passengers)) AS "Bottom 3"
FROM 
	trips_db.fact_passenger_summary tp
JOIN 
	trips_db.dim_city cities
ON 
	tp.city_id = cities.city_id
GROUP BY 
	cities.city_name
LIMIT 3;

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Business Request-5: Identify Month with Highest Revenue for each city
-- ------------------------------------------------------------------------------------------------------------------------------------

SELECT
		city_name AS City,
		Month_name AS Highest_Revenue_Month,
		revenue ,
        ROUND((revenue/total_revenue)*100,2) AS "Contribution_percentage_(%)"
FROM (  SELECT
		cities.city_id,
		cities.city_name,
		MONTHNAME(ft.date) AS Month_name,
		SUM(fare_amount) AS revenue,
		RANK() OVER(PARTITION BY cities.city_name ORDER BY SUM(fare_amount) DESC) AS ranks
		FROM 
			trips_db.fact_trips AS ft
		JOIN 
			trips_db.dim_city AS cities
		ON 
			ft.city_id=cities.city_id
		GROUP BY
			cities.city_id,cities.city_name,Month_name
		) AS rt
JOIN     (
		SELECT 
        city_id,
        SUM(fare_amount) AS total_revenue
		FROM trips_db.fact_trips
		GROUP BY city_id ) AS ct
ON rt.city_id=ct.city_id
WHERE rt.ranks=1;

-- ------------------------------------------------------------------------------------------------------------------------------------
-- Business Request-6: Repeat Passenger Rate Analysis
-- ------------------------------------------------------------------------------------------------------------------------------------

WITH CTE AS (
			 SELECT 
				cities.city_id,
				cities.city_name,
				MONTHNAME(ps.month) AS Month_name,
				SUM(ps.total_passengers) AS total_passengers,
				SUM(ps.repeat_passengers) AS repeat_passengers,
				ROUND(SUM(ps.repeat_passengers)/SUM(ps.total_passengers)*100 ,2) AS Monthly_repeat_passenger_rate,
				city_repeat_passenger_rate
			 FROM 
				trips_db.fact_passenger_summary AS ps
			 JOIN 
				trips_db.dim_city AS cities
			 ON ps.city_id = cities.city_id
			 JOIN
			 (
			  SELECT 
				city_id,
				ROUND(SUM(repeat_passengers)/SUM(total_passengers)*100,2) AS city_repeat_passenger_rate
			  FROM 
				trips_db.fact_passenger_summary
			  GROUP BY 
				city_id
			 ) crp
			 ON ps.city_id = crp.city_id
			 GROUP BY 
				cities.city_id,cities.city_name,MONTHNAME(ps.month)
             )
SELECT city_name,Month_name,total_passengers,repeat_passengers,Monthly_repeat_passenger_rate,city_repeat_passenger_rate
FROM CTE;

-- ------------------------------------------------------------------------------------------------------------------------------------