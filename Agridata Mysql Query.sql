use agricultural_db;
#Year-wise Trend of Rice Production Across States (Top 3)
#step1 to find out top3 states
SELECT State_Name,SUM(RICE_PRODUCTION_1000_tons) AS Total_Rice_Production
FROM agriculture
GROUP BY State_Name
ORDER BY Total_Rice_Production DESC
LIMIT 3;
#step2 to find year wise trend for top 3 states
SELECT Year,State_Name,SUM(RICE_PRODUCTION_1000_tons) AS Rice_Production
FROM agriculture
WHERE State_Name IN ('West Bengal', 'Uttar Pradesh', 'Punjab')
GROUP BY Year, State_Name
ORDER BY Year ASC, Rice_Production DESC;

#Top 5 Districts by Wheat Yield Increase Over the Last 5 Years
WITH Latest AS (SELECT MAX(Year) AS Latest_Year FROM agriculture),
Current_Year_Data AS (SELECT Dist_Name,State_Name,Year,WHEAT_YIELD_Kg_per_ha AS Current_Yield FROM agriculture
    WHERE Year = (SELECT Latest_Year FROM Latest)),
Five_Years_Back_Data AS (SELECT Dist_Name,State_Name,Year,WHEAT_YIELD_Kg_per_ha AS Old_Yield FROM agriculture
    WHERE Year = (SELECT Latest_Year - 5 FROM Latest))
SELECT c.Dist_Name,c.State_Name,c.Current_Yield,f.Old_Yield,(c.Current_Yield - f.Old_Yield) AS Yield_Increase
FROM Current_Year_Data c JOIN Five_Years_Back_Data f ON c.Dist_Name = f.Dist_Name
ORDER BY Yield_Increase DESC LIMIT 5;

#States with the Highest Growth in Oilseed Production 

WITH latest AS (SELECT MAX(Year) AS latest_year FROM agriculture),
curr AS (SELECT State_Name,SUM(OILSEEDS_PRODUCTION_1000_tons) AS curr_prod FROM agriculture 
WHERE Year = (SELECT latest_year FROM latest) GROUP BY State_Name),
prev AS (SELECT State_Name,SUM(OILSEEDS_PRODUCTION_1000_tons) AS prev_prod
FROM agriculture WHERE Year = (SELECT latest_year FROM latest) - 5 GROUP BY State_Name)
SELECT c.State_Name,c.curr_prod AS Latest_Production,p.prev_prod AS Production_5Y_Ago,(c.curr_prod - p.prev_prod) AS Absolute_Growth,
    ((c.curr_prod - p.prev_prod) / p.prev_prod) * 100 AS Growth_Percentage
FROM curr c JOIN prev p ON c.State_Name = p.State_Name ORDER BY Absolute_Growth DESC LIMIT 2;

#District-wise Correlation Between Area and Production for Major Crops (Rice, Wheat, and Maize)
#RICE
SELECT Dist_Name AS District,
    ROUND((COUNT(*) * SUM(RICE_AREA_1000_ha * RICE_PRODUCTION_1000_tons) - SUM(RICE_AREA_1000_ha) * SUM(RICE_PRODUCTION_1000_tons)) /
	SQRT((COUNT(*) * SUM(RICE_AREA_1000_ha * RICE_AREA_1000_ha) - SUM(RICE_AREA_1000_ha)*SUM(RICE_AREA_1000_ha)) *
	(COUNT(*) * SUM(RICE_PRODUCTION_1000_tons * RICE_PRODUCTION_1000_tons) - SUM(RICE_PRODUCTION_1000_tons)*SUM(RICE_PRODUCTION_1000_tons))),
	4) AS rice_area_prod_corr FROM agriculture
GROUP BY Dist_Name HAVING COUNT(*) > 1 ORDER BY rice_area_prod_corr DESC;

#WHEAT
SELECT Dist_Name AS District,
ROUND((COUNT(*) * SUM(WHEAT_AREA_1000_ha * WHEAT_PRODUCTION_1000_tons) - SUM(WHEAT_AREA_1000_ha) * SUM(WHEAT_PRODUCTION_1000_tons)) /
SQRT((COUNT(*) * SUM(WHEAT_AREA_1000_ha * WHEAT_AREA_1000_ha) - SUM(WHEAT_AREA_1000_ha)*SUM(WHEAT_AREA_1000_ha)) *
(COUNT(*) * SUM(WHEAT_PRODUCTION_1000_tons * WHEAT_PRODUCTION_1000_tons) - SUM(WHEAT_PRODUCTION_1000_tons)*SUM(WHEAT_PRODUCTION_1000_tons))),
4) AS wheat_area_prod_corr FROM agriculture GROUP BY Dist_Name HAVING COUNT(*) > 1 ORDER BY wheat_area_prod_corr DESC;

#MAIZE
SELECT Dist_Name AS District,
ROUND((COUNT(*) * SUM(MAIZE_AREA_1000_ha * MAIZE_PRODUCTION_1000_tons) - SUM(MAIZE_AREA_1000_ha) * SUM(MAIZE_PRODUCTION_1000_tons)) /
SQRT((COUNT(*) * SUM(MAIZE_AREA_1000_ha * MAIZE_AREA_1000_ha) - SUM(MAIZE_AREA_1000_ha)*SUM(MAIZE_AREA_1000_ha)) *
(COUNT(*) * SUM(MAIZE_PRODUCTION_1000_tons * MAIZE_PRODUCTION_1000_tons) - SUM(MAIZE_PRODUCTION_1000_tons)*SUM(MAIZE_PRODUCTION_1000_tons))
),4) AS maize_area_prod_corr FROM agriculture GROUP BY Dist_Name HAVING COUNT(*) > 1 ORDER BY maize_area_prod_corr DESC;

#Yearly Production Growth of Cotton in Top 5 Cotton Producing States
WITH top_states AS (SELECT State_Name,SUM(COTTON_PRODUCTION_1000_tons) AS total_production FROM agriculture
GROUP BY State_Name ORDER BY total_production DESC LIMIT 5),
yearly_data AS (SELECT Year, State_Name,SUM(COTTON_PRODUCTION_1000_tons) AS yearly_production FROM agriculture
WHERE State_Name IN (SELECT State_Name FROM top_states) GROUP BY Year, State_Name)
SELECT y1.State_Name,y1.Year,y1.yearly_production,ROUND(((y1.yearly_production - y2.yearly_production) / y2.yearly_production) * 100,2) AS growth_percentage
FROM yearly_data y1 LEFT JOIN yearly_data y2 ON y1.State_Name = y2.State_Name AND y1.Year = y2.Year + 1 ORDER BY y1.State_Name, y1.Year;

#Districts with the Highest Groundnut Production in 2017
SELECT Dist_Name,State_Name,GROUNDNUT_PRODUCTION_1000_tons
FROM agriculture WHERE Year = 2017 ORDER BY GROUNDNUT_PRODUCTION_1000_tons DESC LIMIT 10;

#Annual Average Maize Yield Across All States
SELECT Year,State_Name,ROUND(AVG(MAIZE_YIELD_Kg_per_ha), 2) AS avg_maize_yield
FROM agriculture GROUP BY Year, State_Name ORDER BY Year, avg_maize_yield DESC;

#Total Area Cultivated for Oilseeds in Each State
SELECT State_Name,SUM(OILSEEDS_AREA_1000_ha) AS total_oilseed_area_1000_ha
FROM agriculture GROUP BY State_Name ORDER BY total_oilseed_area_1000_ha DESC;

#Districts with the Highest Rice Yield
SELECT Dist_Name,RICE_YIELD_Kg_per_ha FROM agriculture
WHERE RICE_YIELD_Kg_per_ha IS NOT NULL ORDER BY RICE_YIELD_Kg_per_ha DESC LIMIT 10;

#Compare the Production of Wheat and Rice for the Top 5 States Over 10 Years
WITH top_states AS (SELECT State_Name FROM agriculture GROUP BY State_Name
ORDER BY SUM(WHEAT_PRODUCTION_1000_tons + RICE_PRODUCTION_1000_tons) DESC LIMIT 5)
SELECT a.State_Name,a.Year,SUM(a.WHEAT_PRODUCTION_1000_tons) AS Wheat_Production,SUM(a.RICE_PRODUCTION_1000_tons) AS Rice_Production
FROM agriculture a JOIN top_states t ON a.State_Name = t.State_Name GROUP BY a.State_Name, a.Year ORDER BY a.State_Name, a.Year;








