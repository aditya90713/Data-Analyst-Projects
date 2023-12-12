use zommato_db;

-- Add the new column 'Country_Name' to the existing table
ALTER TABLE zomatodata1
ADD COLUMN Country_Name VARCHAR(255);

-- Update the new column with data from the joined table
UPDATE zomatodata1 cd
LEFT JOIN zomato_country cn ON cd.CountryCode = cn.Country_Code
SET cd.Country_Name = cn.Country;

-- Verify the changes
SELECT * FROM zomatodata1;

-- select * from zomato_country;

-- alter table zomato_country 
-- change `Country Code` `Country_Code` int;
-- describe zomato_country;




-- ROLLING/MOVING COUNT OF RESTAURANTS IN INDIAN CITIES
SELECT 
    Country_Name,
    City,
    Locality,
    COUNT(Locality) AS TOTAL_REST,
    SUM(COUNT(Locality)) OVER (PARTITION BY City ORDER BY Locality DESC) AS ROLLING_COUNT
FROM ZomatoData1
WHERE Country_Name = 'INDIA'
GROUP BY Country_Name, City, Locality;




-- SEARCHING FOR PERCENTAGE OF RESTAURANTS IN ALL THE COUNTRIES
CREATE OR REPLACE VIEW TOTAL_COUNT AS
SELECT 
    DISTINCT(Country_Name),
    COUNT(CAST(RestaurantID AS UNSIGNED)) OVER() AS TOTAL_REST
FROM ZomatoData1;

SELECT * FROM TOTAL_COUNT;

WITH CT1 AS (
    SELECT Country_Name, COUNT(CAST(RestaurantID AS UNSIGNED)) AS REST_COUNT
    FROM ZomatoData1
    GROUP BY Country_Name
)
SELECT 
    A.Country_Name,
    A.REST_COUNT,
    ROUND(A.REST_COUNT / B.TOTAL_REST * 100, 2) AS PERCENTAGE
FROM CT1 A
JOIN TOTAL_COUNT B ON A.Country_Name = B.Country_Name
ORDER BY 3 DESC;





-- WHICH COUNTRIES AND HOW MANY RESTAURANTS WITH PERCENTAGE PROVIDE ONLINE DELIVERY OPTION
CREATE OR REPLACE VIEW COUNTRY_REST AS
SELECT Country_Name, COUNT(CAST(RestaurantID AS UNSIGNED)) AS REST_COUNT
FROM ZomatoData1
GROUP BY Country_Name;

SELECT * FROM COUNTRY_REST ORDER BY 2 DESC;

SELECT 
    A.Country_Name,
    COUNT(A.RestaurantID) AS TOTAL_REST,
    ROUND(COUNT(A.RestaurantID) / CAST(B.REST_COUNT AS DECIMAL) * 100, 2) AS PERCENTAGE
FROM ZomatoData1 A
JOIN COUNTRY_REST B ON A.Country_Name = B.Country_Name
WHERE A.Has_Online_delivery = 'YES'
GROUP BY A.Country_Name, B.REST_COUNT
ORDER BY 2 DESC;




-- FINDING FROM WHICH CITY AND LOCALITY IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO
WITH CT1 AS (
    SELECT City, Locality, COUNT(RestaurantID) AS REST_COUNT
    FROM ZomatoData1
    WHERE Country_Name = 'INDIA'
    GROUP BY City, Locality
)
SELECT Locality, REST_COUNT
FROM CT1
WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1);




-- TYPES OF FOODS ARE AVAILABLE IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO
WITH CT1 AS (
    SELECT City, Locality, COUNT(RestaurantID) AS REST_COUNT
    FROM ZomatoData1
    WHERE Country_Name = 'INDIA'
    GROUP BY City, Locality
),
CT2 AS (
    SELECT Locality, REST_COUNT
    FROM CT1
    WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1)
)
SELECT A.Locality, B.Cuisines
FROM CT2 A
JOIN ZomatoData1 B ON A.Locality = B.Locality;



WITH CT1 AS (
    SELECT City, Locality, COUNT(RestaurantID) AS REST_COUNT
    FROM ZomatoData1
    WHERE Country_Name = 'INDIA'
    GROUP BY City, Locality
),
CT2 AS (
    SELECT Locality, REST_COUNT
    FROM CT1
    WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1)
)
SELECT A.Cuisines, COUNT(A.Cuisines)
FROM VF A
JOIN CT2 B ON A.Locality = B.Locality
GROUP BY B.Locality, A.Cuisines
ORDER BY 2 DESC;





-- WHICH LOCALITIES IN INDIA HAVE THE LOWEST RESTAURANTS LISTED IN ZOMATO
WITH CT1 AS (
    SELECT City, Locality, COUNT(RestaurantID) AS REST_COUNT
    FROM ZomatoData1
    WHERE Country_Name = 'INDIA'
    GROUP BY City, Locality
)
SELECT * FROM CT1 WHERE REST_COUNT = (SELECT MIN(REST_COUNT) FROM CT1) ORDER BY City;




-- HOW MANY RESTAURANTS OFFER TABLE BOOKING OPTION IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO
WITH CT1 AS (
    SELECT City, Locality, COUNT(RestaurantID) AS REST_COUNT
    FROM ZomatoData1
    WHERE Country_Name = 'INDIA'
    GROUP BY City, Locality
),
CT2 AS (
    SELECT Locality, REST_COUNT
    FROM CT1
    WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1)
),
CT3 AS (
    SELECT Locality, Has_Table_booking
    FROM ZomatoData1
)
SELECT A.Locality, COUNT(A.Has_Table_booking) AS TABLE_BOOKING_OPTION
FROM CT3 A
JOIN CT2 B ON A.Locality = B.Locality
WHERE A.Has_Table_booking = 'YES'
GROUP BY A.Locality;




-- HOW RATING AFFECTS IN MAX LISTED RESTAURANTS WITH AND WITHOUT TABLE BOOKING OPTION (Connaught Place)
SELECT 
    'WITH_TABLE' AS TABLE_BOOKING_OPT,
    COUNT(Has_Table_booking) AS TOTAL_REST,
    ROUND(AVG(Rating), 2) AS AVG_RATING
FROM ZomatoData1
WHERE Has_Table_booking = 'YES'
AND Locality = 'Connaught Place'
UNION
SELECT 
    'WITHOUT_TABLE' AS TABLE_BOOKING_OPT,
    COUNT(Has_Table_booking) AS TOTAL_REST,
    ROUND(AVG(Rating), 2) AS AVG_RATING
FROM ZomatoData1
WHERE Has_Table_booking = 'NO'
AND Locality = 'Connaught Place';




-- AVG RATING OF RESTAURANTS LOCATION WISE
SELECT 
    Country_Name,
    City,
    Locality,
    COUNT(RestaurantID) AS TOTAL_REST,
    ROUND(AVG(CAST(Rating AS DECIMAL)), 2) AS AVG_RATING
FROM ZomatoData1
GROUP BY Country_Name, City, Locality
ORDER BY TOTAL_REST DESC;




-- FINDING THE BEST RESTAURANTS WITH MODERATE COST FOR TWO IN INDIA HAVING INDIAN CUISINES
SELECT *
FROM ZomatoData1
WHERE Country_Name = 'INDIA'
AND Has_Table_booking = 'YES'
AND Has_Online_delivery = 'YES'
AND Price_range <= 3
AND Votes > 1000
AND Average_Cost_for_two < 1000
AND Rating > 4
AND Cuisines LIKE '%INDIA%';




-- FIND ALL THE RESTAURANTS THOSE WHO ARE OFFERING TABLE BOOKING OPTIONS WITH PRICE RANGE AND HAVE HIGH RATING
SELECT 
    Price_range,
    COUNT(Has_Table_booking) AS NO_OF_REST
FROM ZomatoData1
WHERE Rating >= 4.5
AND Has_Table_booking = 'YES'
GROUP BY Price_range;
