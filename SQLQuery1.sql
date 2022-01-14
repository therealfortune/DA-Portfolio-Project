-- Data for covid death

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null
--ORDER BY 1,2;

-- Total cases vs Total death
SELECT location , date , total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location = 'nigeria'
AND continent is not Null
ORDER BY 1,2;

-- Total cases vs Population 
SELECT location , date , population, total_cases, (total_cases/population)*100 AS pop_to_cases
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent is not Null
ORDER BY 1,2;

-- Polpulation vs Total Deaths
SELECT location , date , population, total_deaths, (total_deaths/population)*100 AS pop_to_deaths
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%arab%'
AND continent is not Null
ORDER BY 1,2;

-- Highest Infection Rate by population
SELECT location , population, MAX(total_cases) AS highest_Infection_count, MAX((total_cases/population))*100 AS max_pop_to_cases
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%south%'
WHERE continent is not Null
GROUP BY location, population 
ORDER BY max_pop_to_cases DESC

-- Highest Death Count by population
SELECT location , population, MAX(cast(total_deaths AS INT)) AS highest_Death_count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not Null
GROUP BY location, population 
ORDER BY highest_Death_count DESC

-- Highest Deaths  By continent
SELECT continent, MAX(CAST(total_deaths AS INT)) AS max_death_cont
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY max_death_cont DESC

-- TOTAL NUMBER OF DEATH 
SELECT SUM(CAST(new_deaths AS INT))
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%nigeria%'

-- TOTAL NUMBER OF CASES AND DEATH BY LOCATION AND THE RATES OF CASES TO DEATHS
SELECT location,  SUM(new_cases) AS TotalCases , SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathPercent DESC

SELECT SUM(new_cases) AS TotalCases , SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY location
ORDER BY 1,2


-- VACCINATION AND DEATH SECTION

SELECT *
FROM PortfolioProject..CovidVaccinations cov
JOIN PortfolioProject..CovidDeaths cod
	ON cov.location = cod.location
	and cov.date = cov.date

-- LOOKING AT TOTAL POPULATION VS TOTAL VACCINATION
SELECT cod.continent,cod.location,cod.date, cod.population , cov.new_vaccinations
FROM PortfolioProject..CovidVaccinations cov
JOIN PortfolioProject..CovidDeaths cod
	ON cov.location = cod.location
	and cov.date = cov.date
WHERE cod.continent IS NOT NULL
ORDER BY 2,3



SELECT location, date, new_deaths, SUM(CONVERT(INT, new_deaths)) OVER (PARTITION BY location ORDER BY location , date)
FROM PortfolioProject..CovidDeaths
WHERE location ='nigeria'




WITH PopvsVac(Continent, Location, Date, Population, new_cases, new_vaccinations, RollingPeopleVaccination)
AS(
SELECT cod.continent,cod.location, cod.date, cod.population,cod.new_cases, cov.new_vaccinations
, SUM(CONVERT(FLOAT, cov.new_vaccinations)) OVER (PARTITION BY cod.location ORDER BY cod.location,
cod.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths cod
JOIN PortfolioProject..CovidVaccinations cov
	ON cov.location = cod.location
	AND cov.date = cod.date
WHERE cod.continent IS NOT NULL
AND cod.location LIKE '%united states%'
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccination/Population)*100 AS VacPop
FROM PopvsVac




--TEMP table

DROP TABLE IF EXISTS #PopulationVsVaccination
CREATE TABLE #PopulationVsVaccination(
Continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_cases NUMERIC,
new_vaccination NUMERIC,
RollingPeopleVaccination NUMERIC
)
INSERT INTO #PopulationVsVaccination
SELECT cod.continent,cod.location, cod.date, cod.population,cod.new_cases, cov.new_vaccinations
, SUM(CONVERT(FLOAT, cov.new_vaccinations)) OVER (PARTITION BY cod.location ORDER BY cod.location,
cod.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths cod
JOIN PortfolioProject..CovidVaccinations cov
	ON cov.location = cod.location
	AND cov.date = cod.date
WHERE cod.continent IS NOT NULL
--AND cod.location LIKE '%united states%'
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccination/Population)*100 AS VacPop
FROM #PopulationVsVaccination


DROP VIEW IF EXISTS PopulationVsVaccination
--Creating views for data visualization
USE [PortfolioProject]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW PopulationVsVaccination AS
SELECT cod.continent,cod.location, cod.date, cod.population,cod.new_cases, cov.new_vaccinations
, SUM(CONVERT(FLOAT, cov.new_vaccinations)) OVER (PARTITION BY cod.location ORDER BY cod.location,
cod.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths cod
JOIN PortfolioProject..CovidVaccinations cov
	ON cov.location = cod.location
	AND cov.date = cod.date
WHERE cod.continent IS NOT NULL
--AND cod.location LIKE '%united states%'
--ORDER BY 2,3

