
# Goodcabs Performance Analysis

## **Project Overview** 

**Project Title** : Goodcabs Performance Analysis   
**Domain**:  Transportation & Mobility          

**Dashboard link :**   
https://app.powerbi.com/view?r=eyJrIjoiM2E0NzkxNDQtNDNjYS00ZGY2LTg5NzktYzc1ZTBiOTFlMWUyIiwidCI6IjUxNjk4MzNiLWUxZWItNDlkNC1iODBiLWM0MTNjOTMxMWZkYSJ9

## **About CodeX**

Goodcabs, a cab service company established two years ago, has gained a strong foothold in the Indian market by focusing on tier-2 cities. Unlike other cab service providers, Goodcabs is committed to supporting local drivers, helping them make a sustainable living in their hometowns while ensuring excellent service to passengers. With operations in ten tier-2 cities across India, Goodcabs has set ambitious performance targets for 2024 to drive growth and improve passenger satisfaction. 


As part of this initiative, the Goodcabs management team aims to assess the company’s performance across key metrics, including trip volume, passenger satisfaction, repeat passenger rate, trip distribution, and the balance between new and repeat passengers. 

## **Tasks**

- Perform analysis referring to the primary_and_secondary_questions. 
- Generate a SQL-based report addressing ad-hoc-requests.
- Design a dashboard with Metrics and analysis.
- Create a presentation with actionable insights.   
- Provide meaningful recommendations from the data.



## **Tools Used ⚙️**

- SQL - To address the ad-hoc-requests 
- Power Bi - To build the Dashboard
- PowerPoint - To prepare the report

## **Stakeholders💹 :-**
Chief of Operations

# **Project Structure**

1. Key Features of Dashboard     
2. Ad-hoc analysis  
3. Insights   
4. Recommendations

# **Key Features of Dashboard** 

**Revenue Overview**    

**Metrics :** Total Trips, Total Fare (Revenue), Average Fare per Trip (Average Trip Cost), Average Fare per Km, Revenue Growth Rate (Monthly)  
**Revenue Contribution :**  Dives into analyzing individual city revenue contributions.   
**Revenue Distribution :**  Uncovers insights on revenue contribution by weekend vs weekday trips and by new and repeated passengers.  
**Revenue Trend :** Provides seasonal trend of Revenue Growth Rate (Monthly) for each city.

**Trips Overview**  

**Metrics :**  New Trips, Repeated Trips, Total Distance Travelled, Average Trip Distance, Maximum Trip Distance, minimum Trip Distance.     
**Trips Distribution :** Provides insights on trip distribution over each month and city.    
**Trips Analysis :** Delivers insights on weekend vs weekday trips taken and trips taken by new and repeated passengers.   

**Passenger Performance**  

**Metrics :**  Total Passengers, Repeat Passengers, New Passenger Rate, Repeated Passengers, Repeated Passenger Rate    
**Passenger Metrics :** Delves deeper analysis of the metric performance of the cities.    
**RPR Distribution :** Understanding of repeat passenger rate by city.  
**Ratings Aalysis :** Insights on customer satisfaction and service provided.

**Passenger Performance**  

**Metrics :**  Total trips, New trips, Repeat trips, Repeated Passenger Rate      
**Demand Understanding :** Proactive measures to maximize resources for high-demand regions and improve services on low-demand regions.   
**Repeated Passengers frequency :** Insights on repeated Passenger distribution over months and city.


**Target Achievement**  

**Metrics :**  Revenue Growth Rate (Monthly),  New Passenger Achievement Rate, Total trips Achievement Rate, Average Rating Achievement Rate, Rating Passenger Rating, Average Driver Rating    
**Metrics View :** Provides insights on target achievement by each city.
**Target Achievement Trend :** Delivers insights on target achievement over months.




# **Ad-hoc analysis**

### Business Request-1:City-Level Fare and Trip Summary Report
``` sql 
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
     
```

### Business Request-2:Monthly City-Level Trips Target Performance Report

``` sql
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

```

### Business Request-3: City-Level Repeat Passenger Trip Frequent Report

``` sql
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

```

### Business Request-4: Identify the Cities with Highest and Lowest New Passengers 

``` sql
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
```
### Business Request-5: Identify Month with Highest Revenue for each city

``` sql
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


```
### Business Request-6: Repeat Passenger Rate Analysis

``` sql
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

```

# **Primary Insights**

[Check out the Project Insights pdf](https://github.com/DenisM03/Goodcabs_Performance_Analysis/blob/main/Goodcabs%20Performance%20Analysis.pdf)

### Further analysis & recommendations:

**1. Factors Influencing Repeat Passenger Rates**  
What factors (such as quality of service, competitive pricing, or city demographics) might contribute to higher or lower repeat passenger rates in different cities? Are there correlations with socioeconomic or lifestyle patterns in these cities?  

* **Quality of Service:** Cities with higher ratings (e.g., Mysore and Jaipur) often correlate with higher customer satisfaction. Investing in driver training, vehicle maintenance, and ensuring punctuality could elevate repeat passenger rates in underperforming cities.
* **Competitive Pricing:** Ensure pricing aligns with customer expectations while maintaining profitability. Variations between cities (e.g., Mysore and Indore) suggest the need for localized pricing strategies.
* **City Demographics and Lifestyle Patterns:**   
    * **Socioeconomic factors:** Cities with higher disposable income or a younger demographic (e.g., business hubs like Lucknow) may exhibit greater repeat passenger rates due to frequent commuting needs.
    * **Cultural preferences:** Tourism-focused cities like Jaipur and Kochi may have irregular patterns, influenced by seasonal tourist influx. A tailored approach during peak seasons could improve loyalty.


**2. Tourism vs. Business Demand Impact**  
How do tourism seasons or local events (festivals, conferences) impact Goodcabs' demand patterns? Would tailoring marketing efforts to these events increase trip volume in tourism-oriented cities?

* **Leverage Tourism Seasons:** Design promotional campaigns around festivals or events. For instance, Jaipur’s peak demand in February could be further amplified by collaborations with tourist agencies or discounted family packages.
* **Target Business Clients:** For cities like Lucknow and Surat, which display higher weekday demand, corporate tie-ups and business commuter packages could drive sustained growth.
* **Event-based Marketing:** Identify key local events (e.g., fairs, conferences, or exhibitions) and offer tailored services such as shuttles, group discounts, or premium rides.


**3. Emerging Mobility Trends and Goodcabs' Adaptation**  
What emerging mobility trends (such as electric vehicle adoption, and green energy use) are impacting the cab service market in tier-2 cities? Should Goodcabs consider integrating electric vehicles or eco-friendly initiatives to stay competitive?

* **Electric Vehicle (EV) Integration:** 
    * Introduce a pilot fleet of EVs in environmentally conscious cities or those with government incentives for greenmobility.
    * Highlight eco-friendly rides to attract environmentally aware customers.
* **Sustainability Initiatives:** Offer carbon offset options or discounts for shared rides to appeal to green-conscious passengers.
* **Tech Adoption:** Integrate real-time trip tracking, enhanced app features, or digital payment options to align with growing tech-savvy customer expectations.
* **Government Collaboration:**  Partner with local governments to align with smart city projects or EV subsidy programs. 


**4. Partnership Opportunities with Local Businesses**  
Are there opportunities for Goodcabs to partner with local businesses (such as hotels, malls, or event venues) to boost demand and improve customer loyalty? Could these partnerships drive more traffic, especially in tourism- heavy or high-footfall areas?

* **Tourism-oriented Cities:** Partner with hotels, tour operators, and airports in cities like Jaipur and Kochi to create bundled offerings (e.g., cab + hotel discounts).
* **High-footfall Areas:** Establish partnerships with malls, event venues, or corporate hubs to offer exclusive ride discounts or parking promotions.
* **Promotional Alliances:** Collaborate with local festivals or events (e.g., Jaipur Literature Festival) for sponsored rides or priority booking options.
* **Loyalty Incentives:** Co-develop reward programs with local businesses where customers earn benefits (e.g., hotel vouchers or mall discounts) for repeated rides.


**5. Data Collection for Enhanced Data-Driven Decisions**  
To make Goodcabs more data-driven and improve its performance across key metrics (such as repeat passenger rate, customer satisfaction, new passengers and trip volume), what additional data should Goodcabs collect? Consider data that could provide deeper insights into customer behaviour, operational efficiency, and market trends.

**Customer Behavior Information:**
* Collect granular data on passenger preferences, such as trip purpose (tourism, business) and booking time 	(advance vs. last-minute) and reason for cancellation to identify bottle necks.  
* Feedback and survey data on service quality and pricing perception.

**Operational Efficiency:** 
* Monitor real-time metrics on driver performance, vehicle utilization, and maintenance schedules.
* Analyze trip cancellations and delays for process improvements.

**Market Trends:** 
* Integrate external data sources like weather patterns, local event schedules, and competitor pricing.
* Track EV adoption rates and regulatory changes in tier-2 cities.

**Tech Usage:**   
Implement a data management platform that consolidates all metrics and provides predictive analytics for demand forecasting and service optimization.

