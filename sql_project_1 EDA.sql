-- Exploratory Data Analysis (EDA)
SELECT * 
FROM layoff_staging_2;

SELECT MAX(total_laid_off), MIN(total_laid_off), MAX(percentage_laid_off)
FROM layoff_staging_2;

SELECT MIN(`date`), MAX(`date`)
FROM layoff_staging_2;

SELECT * 
FROM layoff_staging_2
WHERE total_laid_off = 12000;

-- Total Laid off (companies that went completely under)
SELECT * 
FROM layoff_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off), MAX(percentage_laid_off)
FROM layoff_staging_2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY country
ORDER BY 2 DESC;

-- using time series to know more
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT MONTHNAME(`date`), SUM(total_laid_off)
FROM layoff_staging_2
WHERE year(`date`) = 2023
GROUP BY MONTHNAME(`date`)
ORDER BY 2 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY STAGE
ORDER BY 2 DESC;

-- Progression of lay_off The Rolling Sum
SELECT SUBSTRING(`date`, 1, 7) AS `Month`, SUM(total_laid_off) 
FROM layoff_staging_2
WHERE SUBSTRING(`date`, 6, 2) IS NOT NULL 
GROUP BY `Month`
ORDER BY 1 DESC;

WITH Rolling_total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `Month`, SUM(total_laid_off) AS total_off 
FROM layoff_staging_2
WHERE SUBSTRING(`date`, 6, 2) IS NOT NULL 
GROUP BY `Month`
ORDER BY 1 DESC
)
SELECT `Month`, total_off,  
SUM(total_off) OVER(ORDER BY `Month`) AS Rolling_Total
FROM Rolling_total;

-- looking at companies with highest lay off in each year and Ranking them
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Rank (company, Years, Total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
),
Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS `Rank`
FROM Company_rank
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_year_rank
WHERE `rank` <= 5;

SELECT * 
FROM layoff_staging_2;
/*  looking at industries with most lay_offs using time series
    findind relation b/w companies who raised funds and their total lay_offs
*/
WITH Industry_year AS
(
SELECT industry, SUBSTRING(`date`, 1, 7) AS `Date`, SUM(total_laid_off) Total_off
FROM layoff_staging_2
GROUP BY industry, `Date`
), Industry_off AS
( 
SELECT *, DENSE_RANK() OVER(PARTITION BY `date` ORDER BY total_off DESC) Ranking
FROM Industry_year
WHERE total_off IS NOT NULL AND `date` IS NOT NULL
)
SELECT *
FROM Industry_off
WHERE ranking <=3
ORDER BY `date`, ranking;

SELECT company, SUM(funds_raised_millions), SUM(total_laid_off)
FROM layoff_staging_2
WHERE funds_raised_millions IS NOT NULL AND funds_raised_millions <>0
GROUP BY company
ORDER BY SUM(funds_raised_millions) DESC;



