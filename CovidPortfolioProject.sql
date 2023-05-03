SELECT *
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PORTFOLIOPROJECT..CovidVaccinations
ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you contract COVID 19 in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercantage
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--- Shows the likelyhood of dying if you contact COVID 19 in the United Kingdom

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercantage
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE Location LIKE '%Kingdom%'
ORDER BY 1,2

-- Looking at the Total Cases vs Population
-- Shows what percantage of the population got COVID 19

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with the Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY InfectedPercentage DESC

-- Showing Countries with the Highest Death Count Per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

-- Global Cases, Deaths and Death Percantage per Date

SELECT date,SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS int )) AS TotalDeaths, SUM(CAST(new_deaths AS int ))/SUM(new_cases)*100 AS DeathPercantage
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Global Cases, Deaths and Death Percantage 

SELECT SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS int )) AS TotalDeaths, SUM(CAST(new_deaths AS int ))/SUM(new_cases)*100 AS DeathPercantage
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using a CTE to find Rolling Percantage Count of Vaccinations against Population

WITH PopVsVac (continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

-- Using a TEMP TABLE to find the Rolling Percantage Count of [ep[;e Vaccinated against Population

DROP TABLE if Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations int,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating VIEW to store date for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- Selecting from VIEW

SELECT *
FROM PercentPopulationVaccinated

-- Viewing the Percentage of People Vaccinated per Country using a VIEW

SELECT location,MAX((RollingPeopleVaccinated/Population)*100)
FROM PercentPopulationVaccinated
GROUP BY location
