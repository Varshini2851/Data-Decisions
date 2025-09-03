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

```sql
SELECT 
    type_of,
    COUNT(*)
FROM netflix_01
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH RatingCounts AS (
    SELECT 
        type_of,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.
