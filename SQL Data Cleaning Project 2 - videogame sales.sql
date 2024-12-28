-- Videogame Sales Cleaning
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Remove Any Columns or Rows
-- 4. Null Values or blank values

-- Initial Review of the Dataset

SELECT *
FROM vgsales;

SELECT DISTINCT Year
FROM vgsales
WHERE Year = (SELECT MAX(Year) FROM vgsales);

SELECT DISTINCT Year
FROM vgsales
WHERE Year = (SELECT MIN(Year) FROM vgsales);

SELECT  *
FROM vgsales
WHERE CAST(Year AS UNSIGNED) BETWEEN 2016 AND 2020
ORDER BY Year ASC;

-- 1. Removing Duplicates

// -- Creating a staging Table

CREATE TABLE `vgsales1` (
  `Rank` INT NOT NULL, -- Rank is likely always a number and a required field
  `Name` VARCHAR(255) NOT NULL, -- Use VARCHAR for better performance compared to TEXT
  `Platform` VARCHAR(50) NOT NULL, -- Platforms are usually short strings
  `Year` YEAR DEFAULT NULL, -- Use the YEAR data type specifically for storing years
  `Genre` VARCHAR(50) NOT NULL, -- Genres are short descriptive strings
  `Publisher` VARCHAR(100) DEFAULT NULL, -- Use VARCHAR for publisher names
  `NA_Sales` DECIMAL(10, 2) DEFAULT NULL, -- Use DECIMAL for precise financial data
  `EU_Sales` DECIMAL(10, 2) DEFAULT NULL,
  `JP_Sales` DECIMAL(10, 2) DEFAULT NULL,
  `Other_Sales` DECIMAL(10, 2) DEFAULT NULL,
  `Global_Sales` DECIMAL(10, 2) DEFAULT NULL,
  `row_num` INT -- Checking for Duplicates
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM vgsales1;

INSERT INTO vgsales1
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY `Rank`, Name, Platform, Year, Genre, Publisher, NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales) AS row_num
FROM vgsales;

SELECT *
FROM vgsales1
WHERE row_num > 1; 

DELETE
FROM vgsales1
WHERE row_num > 1; -- No Duplicates within the Dataset :)

SELECT *
FROM vgsales1;

-- 2. Standardize the Data

-- Converting decimal sales to respective market currency

SELECT 
    *,
    -- NA Sales in Dollars
    CONCAT('$', FORMAT(NA_Sales * 1000000, 2)) AS NA_Sales_Dollars,
    -- EU Sales in Pounds
    CONCAT('£', FORMAT(EU_Sales * 1000000, 2)) AS EU_Sales_Pounds,
    -- EU Sales in Dollars (from Pounds)
    CONCAT('$', FORMAT((EU_Sales * 1000000) * 1.25, 2)) AS EU_Sales_Dollars,
    -- JP Sales in Yen
    CONCAT('¥', FORMAT(JP_Sales * 1000000, 2)) AS JP_Sales_Yen,
    -- JP Sales in Dollars (from Yen)
    CONCAT('$', FORMAT((JP_Sales * 1000000) * 0.007, 2)) AS JP_Sales_Dollars,
    CONCAT('$', FORMAT(Other_Sales * 1000000, 2)) AS Other_Sales_Dollars,
    CONCAT('$', FORMAT(Global_Sales * 1000000, 2)) AS Global_Sales_Dollars
FROM 
    vgsales1;
    
-- Add New Columns with Dollars as Currency

ALTER TABLE vgsales1
MODIFY COLUMN NA_Sales_Dollars VARCHAR(50),
MODIFY COLUMN EU_Sales_Pounds VARCHAR(50),
MODIFY COLUMN EU_Sales_Dollars VARCHAR(50),
MODIFY COLUMN JP_Sales_Yen VARCHAR(50),
MODIFY COLUMN JP_Sales_Dollars VARCHAR(50),
MODIFY COLUMN Other_Sales_Dollars VARCHAR(50),
MODIFY COLUMN Global_Sales_Dollars VARCHAR(50);

    
-- Populating the New Currency Columns

UPDATE vgsales1
SET 
    NA_Sales_Dollars = CONCAT('$', FORMAT(NA_Sales * 1000000, 2)),
    EU_Sales_Pounds = CONCAT('£', FORMAT(EU_Sales * 1000000, 2)),
    EU_Sales_Dollars = CONCAT('$', FORMAT((EU_Sales * 1000000) * 1.25, 2)),
    JP_Sales_Yen = CONCAT('¥', FORMAT(JP_Sales * 1000000, 2)),
    JP_Sales_Dollars = CONCAT('$', FORMAT((JP_Sales * 1000000) * 0.007, 2)),
    Other_Sales_Dollars = CONCAT('$', FORMAT(Other_Sales * 1000000, 2)),
    Global_Sales_Dollars = CONCAT('$', FORMAT(Global_Sales * 1000000, 2));


-- Checking populated Currency Columns

SELECT
	`Rank`,
    Name,
    Platform,
    Year,
    Genre,
    Publisher,
    NA_Sales_Dollars,
    EU_Sales_Dollars,
    JP_Sales_Dollars,
    Other_Sales_Dollars,
    Global_Sales_Dollars
FROM
	vgsales1
ORDER BY Year ASC;

-- 3. Remove Any Columns or Rows

-- Removing 2016 - 2020 Data from the dataset as shown in the Initial Review portion that this data was incomplete

DELETE FROM vgsales1
WHERE Year BETWEEN 2016 AND 2020;

SELECT *
FROM vgsales1
WHERE Year BETWEEN 2016 AND 2020;

SELECT DISTINCT Year
FROM vgsales1
WHERE Year = (SELECT MAX(Year) FROM vgsales1);

SELECT DISTINCT Year
FROM vgsales1
WHERE Year = (SELECT MIN(Year) FROM vgsales1);

-- Deleting row_num column as there were no duplicates in this dataset

ALTER TABLE vgsales1
DROP COLUMN row_num;

-- Deleting NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales from dataset

ALTER TABLE vgsales1
DROP COLUMN NA_Sales,
DROP COLUMN EU_Sales,
DROP COLUMN JP_Sales,
DROP COLUMN Other_Sales,
DROP COLUMN Global_Sales;

-- Checking

DESCRIBE vgsales1; -- varchar is used to display currency type, this is used solely for presentation

SELECT *
FROM vgsales1;

-- 4. Null Values or blank values

SELECT *
FROM vgsales1
WHERE 
    `Rank` IS NULL OR `Rank` = '' OR
    Name IS NULL OR Name = '' OR
    Platform IS NULL OR Platform = '' OR
    Year IS NULL OR Year = '' OR
    Genre IS NULL OR Genre = '' OR
    Publisher IS NULL OR Publisher = '' OR
    NA_Sales_Dollars IS NULL OR NA_Sales_Dollars = '' OR
    EU_Sales_Pounds IS NULL OR EU_Sales_Pounds = '' OR
    EU_Sales_Dollars IS NULL OR EU_Sales_Dollars = '' OR
    JP_Sales_Yen IS NULL OR JP_Sales_Yen = '' OR
    JP_Sales_Dollars IS NULL OR JP_Sales_Dollars = '' OR
    Other_Sales_Dollars IS NULL OR Other_Sales_Dollars = '' OR
    Global_Sales_Dollars IS NULL OR Global_Sales_Dollars = ''; -- NO NULL or BLANK fields in dataset
 
-- Presentation of Cleaned Dataset

SELECT *
FROM vgsales1; 

-- END








