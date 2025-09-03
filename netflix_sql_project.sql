-- Netflix Project

CREATE TABLE netflix_01
(
	Show_id	VARCHAR(10),
	type_of	VARCHAR(10),
	Title	VARCHAR(150),
	Director VARCHAR(220),
	Cast	VARCHAR(1000),
	Country	VARCHAR(150),
	Date_added	VARCHAR(50),
	Release_year INT,
	Rating	VARCHAR(10),
	Duration	VARCHAR(25),
	listed_in	VARCHAR(50),
	Description VARCHAR(300)
);

SELECT * FROM netflix_01;

SELECT COUNT(*) AS total_content
FROM netflix_01;

SELECT DISTINCT(type_of) 
FROM netflix_01;

-- Business Problems

-- 1. Count of Movies & Tv Shows

SELECT type_of, COUNT(*)
FROM netflix_01
GROUP BY type_of;

-- 2. Find the most common rating for movies and TV shows. 

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

-- 3. List the movies released in the year (eg. 2019)

SELECT * 
FROM netflix_01
WHERE type_of = 'Movie'
	  AND release_year = 2019;

-- 4. Find the top 5 countries with the most content on Netflix.	  

SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
	   count(show_id)
FROM netflix_01
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--5. Identify the longest movie.

SELECT *
FROM netflix_01
WHERE type_of = 'Movie' 
	  AND duration IS NOT NULL
ORDER BY CAST(REGEXP_REPLACE(duration, '\smin', '') AS INTEGER) DESC
LIMIT 1;
		
-- 6. Find movies or TV shows added in the last 5 years.	  

SELECT * 
FROM netflix_01
WHERE EXTRACT (YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) IN ('2021', '2020', '2019', '2018', '2017');

-- 7. Find all the movies and TV shows directed by Rajiv Chilaka.

SELECT *
FROM netflix_01
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all the TV shows with more than 5 seasons.

SELECT *
FROM netflix_01
WHERE SPLIT_PART(duration, ' ', 1) > '5 seasons'
	  AND type_of = 'TV Show';
	  
-- 9. Count the number of movies and TV shows under each genre.

SELECT type_of,
	  UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS Genre,
	  count (show_id) AS total_content
FROM netflix_01
GROUP BY 1, 2
ORDER BY 3 DESC, 2;

-- 10. Find the average number of content released in India on Netflix. 
-- Return top 5 year With the highest average content Release

SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS years,
	   COUNT(*),
	   ROUND(
	   		 COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix_01 WHERE country = 'India')::numeric * 100, 2
			) AS Avg_Content_perYear
FROM netflix_01
WHERE country LIKE '%India%'
GROUP BY 1;

-- 11. List all the movies that are documentaries.

SELECT *
FROM netflix_01
WHERE listed_in LIKE '%Documentaries%'
      AND type_of = 'Movie';

-- 12. Find movies or TV shows Without a director.

SELECT *
FROM netflix_01
WHERE director IS NULL;

-- 13. Top Collaborating Director and Actor Pairs. 
-- The top 5 director-actor pairs that have worked together on the most titles?

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

-- 14. Find how many movies or TV shows the actor Salman Khan has appeared in Last 15 years

SELECT *
FROM netflix_01
WHERE casts LIKE '%Salman Khan%'
      AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 15;

-- 15. Find the top 10 actors who have appeared in the Highest number of movies Produced in India.

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

/* 16. Categorize the content based on the presence of the keywords 'Kill' and 'Violence' in the description field. 
Label content containing these keywords as 'Bad' and all other contents as 'Good'. 
Count how many items fall under each category. */

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

-- 17. Find all movies and TV shows that were added to Netflix more than 5 years after their original release year.

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

/* 18. The content mix for the top 10 countries on Netflix. For each of these countries, 
what is the percentage of total content that is movies versus TV shows? */

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

/* 19. Monthly Content Addition Trend with Running Total
 the number of new titles added each month and the cumulative (running) total
 of all titles added up to that point. */

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

/* 20. Average Movie Duration by Genre Compared to the Overall Average
 For each genre, what is the average movie duration, 
 and how does it compare to the average duration of all movies on Netflix? */
 
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
