   # Netflix Data Analysis with Advanced SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project leverages advanced SQL to explore a dataset of Netflix movies and TV shows. The primary goal is to answer complex business questions by demonstrating proficiency in advanced SQL

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix_01;
CREATE TABLE netflix_01
(
	Show_id	    VARCHAR(10),
	type_of	    VARCHAR(10),
	Title	    VARCHAR(150),
	Director    VARCHAR(220),
	Casts	    VARCHAR(1000),
	Country	    VARCHAR(150),
	Date_added	VARCHAR(50),
	Release_year INT,
	Rating	    VARCHAR(10),
	Duration	VARCHAR(25),
	listed_in	VARCHAR(50),
	Description VARCHAR(300)
);

SELECT * FROM netflix_01;
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows
**Objective:** Determine the distribution of movies versus TV shows to understand the overall content mix on Netflix.

```sql
SELECT 
    type_of,
    COUNT(*)
FROM netflix_01
GROUP BY 1;
```


### 2. Find the most common rating for movies and TV shows.
**Objective:**  Find the single most common rating for movies and the most common rating for TV shows.

```sql
SELECT type_of, rating, COUNT(*)
FROM netflix_01
GROUP BY type_of, rating
ORDER BY 1, 3 DESC;

SELECT type_of, rating
FROM
(
	SELECT type_of, rating, 
		   COUNT(*),
		   RANK() OVER(PARTITION BY type_of ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix_01
	GROUP BY type_of, rating
) AS t1
WHERE ranking = 1;
```


### 3. List the movies released in the year (eg. 2019)
**Objective:** Filter the dataset to show all movies that were originally released in the year 2020.

```sql
SELECT * 
FROM netflix_01
WHERE type_of = 'Movie'
	  AND release_year = 2019;
```


### 4. Find the top 5 countries with the most content on Netflix.
**Objective:** Identify the top countries contributing content to Netflix.

```sql
SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
	   count(show_id)
FROM netflix_01
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```


### 5. Identify the Longest Movie.
**Objective:** Find the single movie with the longest duration.

```sql
SELECT *
FROM netflix_01
WHERE type_of = 'Movie' 
	  AND duration IS NOT NULL
ORDER BY CAST(REGEXP_REPLACE(duration, '\smin', '') AS INTEGER) DESC
LIMIT 1;
```


### 6. Find Content Added in the Last 5 Years.
**Objective:** Analyze recent content additions to the platform in the last 5 years.

```sql
SELECT * 
FROM netflix_01
WHERE EXTRACT (YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) IN ('2021', '2020', '2019', '2018', '2017');
```


### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
**Objective:**  Identify all content associated with a specific director.

```sql
SELECT *
FROM netflix_01
WHERE director ILIKE '%Rajiv Chilaka%';
```


### 8. List All TV Shows with More Than 5 Seasons.
**Objective:**  Filter TV shows based on the number of seasons.

```sql
SELECT *
FROM netflix_01
WHERE SPLIT_PART(duration, ' ', 1) > '5 seasons'
	  AND type_of = 'TV Show';
```


### 9. Count the number of movies and TV shows under each genre.
**Objective:** Determine the content volume for each genre.

```sql
SELECT type_of,
	  UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS Genre,
	  count (show_id) AS total_content
FROM netflix_01
GROUP BY 1, 2
ORDER BY 3 DESC, 2;
```


### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!
**Objective:** Analyze the yearly content release trend for a specific country.

```sql
SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS years,
	   COUNT(*),
	   ROUND(
	   		 COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix_01 WHERE country = 'India')::numeric * 100, 2
			) AS Avg_Content_perYear
FROM netflix_01
WHERE country LIKE '%India%'
GROUP BY 1;
```


### 11. List All Movies that are Documentaries.
**Objective:** Filter movies by a specific genre.

```sql
SELECT *
FROM netflix_01
WHERE listed_in LIKE '%Documentaries%'
      AND type_of = 'Movie';
```


### 12. Find movies or TV shows without a director.
**Objective:** Identify content that has no listed director.

```sql
SELECT *
FROM netflix_01
WHERE director IS NULL;
```


### 13. Top Collaborating Director and Actor Pairs. 
**Objective:** Find the top 5 director-actor pairs that have worked together on the most titles.

```sql
WITH DA_Pairs AS
(
	SELECT director,
		   UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor_name
	FROM netflix_01
	WHERE director IS NOT NULL 
          AND casts IS NOT NULL
)
-- Count collaborations and rank to find the top 5 pairs
SELECT director,
	   actor_name,
	   count(*) AS collaboration_count
FROM DA_Pairs	
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5;
```


### 14. Find how many movies or TV shows the actor Salman Khan has appeared in the Last 15 years.
**Objective:**  Find the number of titles a specific actor appeared in within a given time frame.

```sql
SELECT *
FROM netflix_01
WHERE casts LIKE '%Salman Khan%'
      AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 15;
```


### 15. Find the top 10 actors who have appeared in the Highest number of movies Produced in India.
**Objective:** Identify the most prolific actors in a specific country's film industry on Netflix.

```sql
SELECT 
	   -- show_id,
	   -- casts,
	   UNNEST(STRING_TO_ARRAY(casts, ',')),
	   COUNT(*)
FROM netflix_01
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```


### 16. Categorize the content based on specific keywords in the description.
**Objective:** Categorize and count content based on the presence of the keywords 'Kill' and 'Violence' in the description.

```sql
WITH Category_table AS
(
	SELECT show_id,
		   type_of,
		   title,
		   description,
		   CASE
		   WHEN description ILIKE '%Kill%' OR 
		        description ILIKE '%Violence%' THEN 'Bad'
		   ELSE 'Good'
		   END Category
	FROM netflix_01
)
SELECT category,
	   COUNT(*)
FROM category_table
GROUP BY category;
```


### 17. Find all movies and TV shows that were added to Netflix more than 5 years after their original release year.
**Objective:** Identify content that was added to the platform long after its original release date.

```sql
WITH titleAge AS
(
	SELECT title,
		   type_of,
		   release_year,
		   EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year_added,
		   (EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) - release_year) AS year_differences
	FROM netflix_01
	WHERE date_added IS NOT NULL
)
SELECT title,
	   type_of,
	   release_year,
	   year_added,
	   year_differences
FROM titleAge
WHERE year_differences > 5
ORDER BY 5 DESC, 3 DESC;
```


### 18. The content mix for the top 10 countries on Netflix.
**Objective:** For the top 10 content-producing countries, determine the percentage of their total content that is movies versus TV shows.

```sql
WITH Country_Content AS
(
	SELECT country,
		   type_of,
		   COUNT(show_id) AS content_count
	FROM netflix_01
	WHERE country IN (SELECT country
					  FROM netflix_01
					  GROUP BY 1
					  ORDER BY COUNT(show_id) DESC
					  LIMIT 10)
	GROUP BY 1, 2
), 
  Total_CountryContent AS 
(  -- Calculate the total content per country for percentage calculation  
	  SELECT country,
	         type_of,
			 content_count,
			 SUM(content_count) OVER (PARTITION BY country) AS total_Content
	  FROM Country_Content
)
SELECT country,
	   type_of,
	   content_count,
	   ROUND((content_count::NUMERIC / total_content) * 100, 2) AS percentage
FROM total_CountryContent
ORDER BY 1,2;
```


### 19. Monthly Content Addition Trend with Running Total
**Objective:** Track the number of new titles added each month and the cumulative total over time to understand content acquisition trends.

```sql
 WITH MonthlyAdditions AS 
(    
    SELECT
        EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS added_year,
        EXTRACT(MONTH FROM TO_DATE(date_added, 'Month DD, YYYY')) AS added_month,
        COUNT(show_id) AS titles_added_this_month
    FROM
        netflix_01
    WHERE
        date_added IS NOT NULL
    GROUP BY 1, 2
)
-- Calculate the running total of titles added
SELECT
    added_year,
    added_month,
    titles_added_this_month,
    SUM(titles_added_this_month) OVER (ORDER BY added_year, added_month) AS cumulative_titles
FROM
    MonthlyAdditions
ORDER BY 1, 2;
```


### 20. Average Movie Duration by Genre Compared to the Overall Average.
**Objective:** For each genre, determine its average movie duration and compare it to the average duration of all movies on Netflix.

```sql
WITH movie_duration AS
(
	SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
        CAST(REGEXP_REPLACE(duration, '\smin', '') AS INTEGER) AS duration_minutes
    FROM
        netflix_01
    WHERE
        type_of = 'Movie' AND duration IS NOT NULL
),
GenreAverage  AS
(
	SELECT genre,
           ROUND(AVG(duration_minutes), 2) AS avg_genre_duration
    FROM movie_duration
    GROUP BY 1
),
OverallAverage AS 
    -- Calculate the overall average duration of all movies
(
	SELECT ROUND(AVG(duration_minutes), 2) AS overall_avg_duration
    FROM movie_duration
)
-- Final result comparing genre average with overall average
SELECT ga.genre,
       ga.avg_genre_duration,
       oa.overall_avg_duration,
       ROUND(ga.avg_genre_duration - oa.overall_avg_duration, 2) AS difference
FROM GenreAverage AS ga, OverallAverage AS oa
ORDER BY 4 DESC;
```
