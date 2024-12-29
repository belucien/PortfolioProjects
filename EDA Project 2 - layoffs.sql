-- EDA Layoffs

-- Retrieve all columns and rows from the layoffs_staging2 table to examine the data.
SELECT *
FROM layoffs_staging2;

-- Find the maximum values for total_laid_off and percentage_laid_off columns to identify the largest layoff figures.
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Retrieve all rows where the percentage_laid_off is 100%, this was used to see if the percentage_laid_off could be used as a exploratory source.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Aggregate the total layoffs by company, ordering the results by the total layoffs in descending order to identify companies with the highest layoffs.
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Determine the earliest and latest dates in the dataset to understand the time range of the data (COVID Years).
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Aggregate total layoffs by country, ordering the results in descending order to identify countries with the highest layoffs.
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Retrieve all columns and rows again for a second review of the data.
SELECT *
FROM layoffs_staging2;

-- Aggregate total layoffs by year, ordering the results in descending order to identify trends over time.
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Aggregate total layoffs by company stage, ordering results by stage in descending order to analyze layoffs across business stages.
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 1 DESC;

-- Aggregate total layoffs by month, extracting the month from the date, and order the results by month to analyze layoffs monthly.
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Use a CTE to calculate rolling total layoffs by month for a cumulative view of layoffs over time.
WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Aggregate total layoffs by company again to confirm companies with the highest layoffs.
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- SAggregate total layoffs by company and year, ordering by total layoffs in descending order to analyze company-year combinations with the highest layoffs.
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Use second CTE to rank companies by year based on total layoffs and filter to show only the top 5 companies per year.
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


-- END