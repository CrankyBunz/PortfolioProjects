-- Covid-19 Data Exploration using data from https://ourworldindata.org/covid-deaths
-- Tableau Dashboard can be found at https://public.tableau.com/app/profile/riley.smith3695/viz/Covid-19Dashboard_16339902649500/Dashboard1

SELECT * 
FROM PortfolioProject..CovidDeaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths

--Displaying stats for the world

SELECT location, date, new_cases, new_deaths, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE location = 'World'

-- Total Cases vs Total Deaths. WHERE clause to avoid division by 0 error.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths
WHERE total_cases > 0 AND continent != ''

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'

-- Total Cases vs Population for % infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PopInfected
FROM PortfolioProject..CovidDeaths
WHERE population > 0 AND continent != ''

SELECT location, date, total_cases, population, (total_cases/population)*100 as PopInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'

-- Countries w/ highest infection of population

SELECT location, population, MAX(total_cases) as HighInfection,  MAX((total_cases/population))*100 as PopInfected
FROM PortfolioProject..CovidDeaths
WHERE population > 0 AND continent != ''
GROUP BY location, population
ORDER BY PopInfected DESC

-- Highest Death %

SELECT location, population, MAX(total_deaths) as DeathToll,  MAX((total_deaths/population))*100 as PopulationLoss
FROM PortfolioProject..CovidDeaths
WHERE population > 0 AND continent != ''
GROUP BY location, population
ORDER BY DeathToll DESC

--Grouped by continent
SELECT location, population, MAX(total_deaths) as DeathToll,  MAX((total_deaths/population))*100 as PopulationLoss
FROM PortfolioProject..CovidDeaths
WHERE population > 0 AND continent = '' AND location != 'World'
GROUP BY location, population
ORDER BY PopulationLoss DESC

--Joining of the two Covid tables to see Vaccine %. Limiting to top result to see the current percent when data was taken.

SELECT TOP (1) deaths.location, vaccines.people_fully_vaccinated, deaths.population, (vaccines.people_fully_vaccinated/deaths.population)*100 as percentvaccinated
FROM PortfolioProject..CovidDeaths as deaths JOIN PortfolioProject..CovidVaccinations as vaccines on deaths.location = vaccines.location AND deaths.date = vaccines.date
WHERE deaths.location = 'World'

-- Using partition to view total vaccinations in the United States and displaying in a CTE 

WITH PopVaccinated (continent, location, date, population, new_vaccinations, RollingTotal)
AS
(
	SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, SUM(CAST(vaccines.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingTotal
	FROM PortfolioProject..CovidDeaths as deaths JOIN PortfolioProject..CovidVaccinations as vaccines on deaths.location = vaccines.location AND deaths.date = vaccines.date
	WHERE deaths.location = 'United states'
)

SELECT *
FROM PopVaccinated

--Temp Table Example using above CTE example

Create Table UnitedStatesVaccinations
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_Vaccinations float,
RollingTotal float
)

INSERT INTO UnitedStatesVaccinations
	SELECT deaths.continent, deaths.location, deaths.date, deaths.population, CAST(vaccines.new_vaccinations as float), SUM(CAST(vaccines.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingTotal
	FROM PortfolioProject..CovidDeaths as deaths JOIN PortfolioProject..CovidVaccinations as vaccines on deaths.location = vaccines.location AND deaths.date = vaccines.date
	WHERE deaths.location = 'United states'

SELECT *
FROM UnitedStatesVaccinations

-- Saving for potential visualization

CREATE VIEW VaccinationsByLocation as
	SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, SUM(CAST(vaccines.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingTotal
	FROM PortfolioProject..CovidDeaths as deaths JOIN PortfolioProject..CovidVaccinations as vaccines on deaths.location = vaccines.location AND deaths.date = vaccines.date
	WHERE deaths.continent != ''


SELECT * 
FROM VaccinationsByLocation
