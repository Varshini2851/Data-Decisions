-- Data Cleaning
SET SQL_SAFE_UPDATES = 0;
USE world_layoff;
SELECT * FROM layoff_staging;

CREATE TABLE layoff_staging
LIKE layoffs;

INSERT INTO layoff_staging 
SELECT * FROM layoffs;

-- 1. Removing the duplicates
SELECT * ,
row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoff_staging;

-- USING CTE (common tabke expression)
WITH Duplicate_cte AS
(
SELECT * ,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, country, stage, funds_raised_millions) AS row_num
FROM layoff_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

SELECT * FROM layoff_staging
WHERE company LIKE 'casper';

-- creating a dup of layoff_staging and deleting the duplicate rows from tta table
CREATE TABLE `layoff_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_staging_2
SELECT * ,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, country, stage, funds_raised_millions) AS row_num
FROM layoff_staging;

SELECT * 
FROM layoff_staging_2;

DELETE
FROM layoff_staging_2
WHERE row_num > 1;

-- 2. Standardizing the Data

SELECT Company, trim(company)
FROM layoff_staging_2; 

UPDATE  layoff_staging_2
SET company = TRIM(company);

SELECT * FROM layoff_staging_2
WHERE industry LIKE 'crypto%';

UPDATE layoff_staging_2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT(industry)
FROM layoff_staging_2
ORDER BY 1;

SELECT DISTINCT(location)
FROM layoff_staging_2
ORDER BY 1;

UPDATE layoff_staging_2
SET location = 'Malmo'
WHERE location LIKE 'Malm%';

SELECT DISTINCT(country)
FROM layoff_staging_2
ORDER BY 1;

/*
Use Trailing with Trim instead of update statement for minor changes
SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country)
FROM layoff_staging_2
ORDER BY 1;
*/

UPDATE layoff_staging_2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT *
FROM layoff_staging_2;

SELECT `date`
FROM layoff_staging_2;

ALTER TABLE layoff_staging_2
MODIFY COLUMN `date` DATE;

UPDATE layoff_staging_2
SET `date` = STR_TO_DATE (`date`, '%m/%d/%Y');

-- 3. Dealing with NUll or Blank Values
SELECT * 
FROM layoff_staging_2
WHERE Total_laid_off IS NULL
      AND percentage_laid_off IS NULL;
      
SELECT *
FROM layoff_staging_2
WHERE industry IS NULL 
      OR industry = '';      

SELECT * FROM layoff_staging_2
WHERE company LIKE 'Airbnb';

UPDATE layoff_staging_2
SET industry = NULL
WHERE industry = ''; 

SELECT t1.company, t1.industry, t2.industry
FROM layoff_staging_2 T1
JOIN layoff_staging_2 T2
     ON t1.company = t2.company
   WHERE (t1.industry IS NULL OR t1.industry = '')
		AND t2.industry IS NOT NULL;

UPDATE layoff_staging_2 t1
JOIN layoff_staging_2 T2
     ON t1.company = t2.company
SET t1.industry = t2.industry
     WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT * 
FROM layoff_staging_2
WHERE industry IS NULL OR industry = '';

-- 4. Deleting the rows and coloumns 
SELECT * 
FROM layoff_staging_2
WHERE Total_laid_off IS NULL
      AND percentage_laid_off IS NULL;
      
DELETE
FROM layoff_staging_2
WHERE Total_laid_off IS NULL
      AND percentage_laid_off IS NULL;     
      
SELECT * 
FROM layoff_staging_2;

ALTER TABLE layoff_staging_2     
DROP COLUMN row_num;	