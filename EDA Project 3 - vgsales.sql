/*
vgsales Exploration

Skills used: CTE's, Views, Aggregate Functions, CAST, REPLACE.

[Since i converted most of the columns to varchar for presentation purposes I had to do conversion back to decimal]

*/


-- Retrieve all data from the vgsales1 table for an initial review.

SELECT *
FROM vgsales1;

-- Retrieve top North American sales by rank and filter out rows with $0.00 sales, sorted in descending order by sales and rank.

SELECT `Rank`, Name, Year, NA_Sales_Dollars
FROM vgsales1
WHERE Year BETWEEN 1990 AND 2008
  AND NA_Sales_Dollars != '$0.00'
ORDER BY CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) DESC, `Rank`;

-- Retrieve top Japanese sales by rank and filter out rows with $0.00 sales, sorted in descending order by sales and rank.

SELECT `Rank`, Name, Year, JP_Sales_Dollars
FROM vgsales1
WHERE Year BETWEEN 1990 AND 2008
  AND JP_Sales_Dollars != '$0.00'
ORDER BY CAST(REPLACE(REPLACE(JP_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) DESC, `Rank`;

-- Create CTE to rank top North American sales by year (1990-2008) Golden Era.

WITH TopSalesNA AS (
  SELECT 
    Name,
    Year,
    NA_Sales_Dollars,
    CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) AS NA_Sales_Dollars_Numeric,
    ROW_NUMBER() OVER (PARTITION BY Year ORDER BY CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) DESC) AS RowNum
  FROM vgsales1
  WHERE Year BETWEEN 1990 AND 2008
    AND NA_Sales_Dollars != '$0.00'
)
SELECT Name, Year, NA_Sales_Dollars
FROM TopSalesNA
WHERE RowNum <= 1
ORDER BY Year ASC, RowNum ASC;

-- Create a view for top North American sales by year for reuse in a visualization.

CREATE VIEW NA_Top_Sales AS
WITH TopSalesNA AS (
  SELECT 
    Name,
    Year,
    NA_Sales_Dollars,
    CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) AS NA_Sales_Dollars_Numeric,
    ROW_NUMBER() OVER (PARTITION BY Year ORDER BY CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) DESC) AS RowNum
  FROM vgsales1
  WHERE Year BETWEEN 1990 AND 2008
    AND NA_Sales_Dollars != '$0.00'
)
SELECT Name, Year, NA_Sales_Dollars
FROM TopSalesNA
WHERE RowNum <= 1
ORDER BY Year ASC, RowNum ASC;

-- Retrieve the top sales from the created NA_Top_Sales view.

SELECT *
FROM NA_Top_Sales;

-- Retrieve top global sales by genre, formatted with dollar signs and commas (1990-2008) Golden Era.

SELECT Genre, 
       CONCAT('$', FORMAT(MAX(CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))), 2)) AS Top_Global_Sales_Dollars
FROM vgsales1
WHERE Year BETWEEN 1990 AND 2008
GROUP BY Genre
ORDER BY MAX(CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))) DESC;

-- Use a CTE to identify the top-selling game globally by genre between (1990-2008) Golden Era.

WITH MaxSales AS (
  SELECT Genre,
         Name,
         CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) AS Top_Global_Sales_Numeric
  FROM vgsales1
  WHERE Year BETWEEN 1990 AND 2008
),
GlobalSales AS (
  SELECT Genre, 
         Name,
         Top_Global_Sales_Numeric,
         ROW_NUMBER() OVER (PARTITION BY Genre ORDER BY Top_Global_Sales_Numeric DESC) AS Sales
  FROM MaxSales
)
SELECT Genre,
       CONCAT('$', FORMAT(Top_Global_Sales_Numeric, 2)) AS Max_Global_Sales_Dollars,
       Name
FROM GlobalSales
WHERE Sales = 1
ORDER BY Top_Global_Sales_Numeric DESC;

-- Create a view for top global sales by genre for easier querying and visualization.

CREATE VIEW Top_Global_Sales_By_Genre AS
WITH MaxSales AS (
  SELECT Genre,
         Name,
         CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) AS Top_Global_Sales_Numeric
  FROM vgsales1
  WHERE Year BETWEEN 1990 AND 2008
),
GlobalSales AS (
  SELECT Genre, 
         Name,
         Top_Global_Sales_Numeric,
         ROW_NUMBER() OVER (PARTITION BY Genre ORDER BY Top_Global_Sales_Numeric DESC) AS Sales
  FROM MaxSales
)
SELECT Genre,
       CONCAT('$', FORMAT(Top_Global_Sales_Numeric, 2)) AS Max_Global_Sales_Dollars,
       Name
FROM GlobalSales
WHERE Sales = 1
ORDER BY Top_Global_Sales_Numeric DESC;

-- Retrieve data from the Top_Global_Sales_By_Genre view.

SELECT * 
FROM Top_Global_Sales_By_Genre;

-- Calculate the top-performing platform in the US based on total North American sales, formatted with dollar signs and commas (1990-2008) Golden Era.

SELECT Platform, 
       CONCAT('$', FORMAT(SUM(CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))), 2)) AS Total_NA_Sales_Dollars
FROM vgsales1
WHERE CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) > 0
  AND Year BETWEEN 1990 AND 2008
GROUP BY Platform
ORDER BY SUM(CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))) DESC;

-- Retrieve top-performing publishers globally with sales greater than $80,000,000 (1990-2008) Golden Era.

SELECT Publisher, 
       CONCAT('$', FORMAT(SUM(CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))), 2)) AS GlobalSales
FROM vgsales1
WHERE CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) > 0
  AND Year BETWEEN 1990 AND 2008
GROUP BY Publisher
HAVING SUM(CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))) > 80000000
ORDER BY SUM(CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))) DESC;

-- Create a view for top global sales publishers for easier analysis.

CREATE VIEW Top_Global_Sales_Publishers AS
SELECT Publisher, 
       CONCAT('$', FORMAT(SUM(CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))), 2)) AS GlobalSales
FROM vgsales1
WHERE CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2)) > 0
  AND Year BETWEEN 1990 AND 2008
GROUP BY Publisher
HAVING SUM(CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))) > 80000000
ORDER BY SUM(CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))) DESC;

-- Retrieve data from the Top_Global_Sales_Publishers view.

SELECT * FROM Top_Global_Sales_Publishers;

-- Retrieve all games from the Final Fantasy series. (Personal Analysis) (Family/Friends Discord Channel debate on highest selling Final Fantasy game)

SELECT *
FROM vgsales1
WHERE Name LIKE 'Final Fantasy%';

-- Calculate North American sales for each Final Fantasy game by platform, formatted with dollar signs and commas.

SELECT Name AS GameTitle, 
       Platform,
       CONCAT('$', FORMAT(SUM(CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))), 2)) AS NASales
FROM vgsales1
WHERE Name LIKE 'Final Fantasy%'
  AND Year BETWEEN 1990 AND 2008
GROUP BY Name, Platform
ORDER BY SUM(CAST(REPLACE(REPLACE(NA_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))) DESC;

-- Calculate global sales for each Final Fantasy game by platform, formatted with dollar signs and commas.

SELECT Name AS GameTitle, 
       Platform,
       CONCAT('$', FORMAT(SUM(CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))), 2)) AS GlobalSales
FROM vgsales1
WHERE Name LIKE 'Final Fantasy%'
  AND Year BETWEEN 1990 AND 2008
GROUP BY Name, Platform
ORDER BY SUM(CAST(REPLACE(REPLACE(Global_Sales_Dollars, '$', ''), ',', '') AS DECIMAL(15, 2))) DESC;

-- I said between 1990-2008 Final Fantasy III/VI was the highest selling due to the SNES and my love for the game, oh how I was wrong.

-- END
