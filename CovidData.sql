/* 
COVID 19 Data Exploration 
 I'd like to preface and state that although this is a brief and high level overview of COVID deaths and vaccinations, 
 the numbers were still very much astonishing. I'd like to acknowledge those that have lost a loved one to this relentless disease. 
 These aren't simply data points but actual lives. May you each find solace in any way possible. 
*/

-- BRIEF BACKGROUND 
-- For my analysis I'll be working with two tables, global covid_deaths(deaths) and global covid_vax(vaccinations). 
-- Both datasets were pulled from the 'Our World In Data' website: https://ourworldindata.org/covid-deaths. 
-- The data for both table range from February 2020 to January 2022. 

-- GENERAL OVERVIEW 
-- How many observations are in each table ?
SELECT COUNT(*)
FROM covid_data.vax;

SELECT COUNT(*)
FROM covid_data.deaths;

-- There are 157,248 observations within the covid_deaths and covid_vaccs data sets

-- CHECK FOR NULLS 
-- Noted that the 'continet' column has some null values. I filtered out the null values to see the number of observations available. 
SELECT COUNT(*)
FROM covid_data.deaths
WHERE continent IS NOT NULL;

SELECT COUNT(*)
FROM covid_data.vax
WHERE continent IS NOT NULL;

-- There are each 147,799 observations left for both tables, which I deem sufficient enough to gather for reasonable insight. 

-- Select Data that we are going to be using
SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM covid_data.deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2;

-- Total Cases Vs. Total Deaths 
-- Shows the liklihood of dying if an individual contracts COVID in the United States on a daily basis. 
WITH cte AS 
(
SELECT location,
       date,
       total_cases,
       total_deaths,
       ROUND((total_deaths/total_cases)*100,3) AS death_percentage
FROM covid_data.deaths
WHERE continent IS NOT NULL 
AND location LIKE '%United States%'
ORDER BY 1,2
) 
SELECT AVG(death_percentage),
       MIN(death_percentage),
       MAX(death_percentage)
FROM cte;

-- A summation of this information resulted in the following: 
-- On averagge the daily death rate of those in the United States infected with COVID is 2.574%.
-- The minumum daily death rate is 1.207%.
-- The maximum daily death rate is 10.909%.

-- Total Cases Vs Overall Population
-- Shows what percentage of the population in the United States contracted COVID on a daily basis. 
WITH cte AS 
(
SELECT location,
       date,
       population,
       total_cases,
       ROUND((total_cases/population)*100,3) AS contraction_percentage
FROM covid_data.deaths
WHERE continent IS NOT NULL 
AND location like '%United States%'
ORDER BY 1,2
) 
SELECT AVG(contraction_percentage),
       MIN(contraction_percentage),
       MAX(contraction_percentage)
FROM cte;

-- A summation of this information resulted in the following: 
-- On average people in the United States contracted COVID at a daily rate of 6.778% of the population.
-- The minimum daily contraction rate in the US was at 3.004%.
-- The maximum daily contraction rate in the US was at 21.704%.

-- Let's move away from the US and perform the same global analysis. 
SELECT location,
       population,
       MAX(total_cases)AS highest_infection_count,
       ROUND(MAX((total_cases/population)*100),2) AS contracted_percentage
FROM covid_data.deaths
WHERE continent IS NOT NULL 
GROUP BY 1,2
ORDER BY 4 DESC
LIMIT 3; 

-- The 3 countries with the highest infection rate in comparison to their overall population are:
-- 1. Andorra
-- 2. Seychelles
-- 3. Gibraltar 

-- Let's determine countries with the highest overall deaths. 
SELECT location,
       MAX(total_deaths)AS total_death_count
FROM covid_data.deaths
WHERE continent IS NOT NULL 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- The 3 countries with the highest deaths are: 
-- 1. United States
-- 2. Brazil 
-- 3. India

-- Continents with the highest deaths
SELECT continent,
       MAX(total_deaths)AS total_death_count
FROM covid_data.deaths
WHERE continent IS NOT NULL 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- The 3 continents with the highest deaths are:  
-- North America
-- South America
-- Asia 

-- Overall Global new infections and deaths as of the end of January 2022
SELECT SUM(new_cases) AS totaL_new_cases,
       SUM(new_deaths) AS total_new_deaths,
       ROUND((SUM(new_deaths)/SUM(new_cases))*100,3) AS death_percentage
FROM covid_data.deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2; 
-- Total new cases: 358,086,048 (358M)
-- Total_new deaths: 5,590,584 (5.59M)  
-- Globally those newly infected with COVID are dying at a rate of: 1.561%. I'd like to point out that this percentage seems small but as you can see above 5.59 million deaths is no trivial matter. 


-- Daily global death rate 
WITH cte AS
(
SELECT date,
       SUM(new_cases) AS totaL_new_cases,
       SUM(new_deaths) AS total_new_deaths,
       ROUND((SUM(new_deaths)/SUM(new_cases))*100,3) AS death_percentage
FROM covid_data.deaths
WHERE continent IS NOT NULL 
GROUP BY 1
ORDER BY 1,2
) 
SELECT AVG(death_percentage),
       MIN(death_percentage),
       MAX(death_percentage)
FROM cte;
 
-- A summation of this information resulted in the following: 
-- On average the daily death rate of people newly infected with COVID is 2.569%. 
-- The minimum daily death rate of newly infected people was at 0.188%
-- The maximum daily death rate of newly infected people was at 28.169%


-- A LOOK AT VACCINATIONS
-- Let's introduce the covid vaccination table into our analysis 
SELECT * 
FROM covid_data.vax;

-- Joining the two tables for analysis on vaccinations alongside COVID deaths 
SELECT * 
FROM covid_data.deaths AS death
JOIN covid_data.vax AS vax
ON death.location = vax.location
AND death.date = vax.date; 

-- Population vaccinated per location
-- The query below looks at a daily accumulation of total vaccinations segmeneted by each location/country.  
SELECT death.date,
       death.continent, 
       death.location, 
       death.population, 
       SUM(vax.new_vaccinations) OVER(PARTITION BY death.location ORDER BY death.location,death.date) AS rolling_vax_count
FROM covid_data.deaths AS death
JOIN covid_data.vax AS vax
ON death.location = vax.location
AND death.date = vax.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3; 
 
-- Overall Population Vs. Percentage vaccinated
-- The query below also looks at a daily accumulation of total vaccinations percentages segmeneted by each location/country. 
WITH pop_vaxxed AS
(
SELECT death.date AS date, 
       death.continent AS continent, 
       death.location AS location, 
       death.population AS population, 
       SUM(vax.new_vaccinations) OVER(PARTITION BY death.location ORDER BY death.location,death.date) AS rolling_vax_count
FROM covid_data.deaths AS death
JOIN covid_data.vax AS vax
ON death.location = vax.location
AND death.date = vax.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3
) 
SELECT date, 
       continent, 
       location, 
       population, 
       rolling_vax_count, 
       ROUND((rolling_vax_count/population)*100,2) AS percent_vax
FROM pop_vaxxed
ORDER BY 2,3;



