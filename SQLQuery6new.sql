select *
from PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases , new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- shows chances of dying if you c0ntract the virus
select location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 AS deathperc
FROM PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2

--Looking at total cases vs population

select location, date, total_cases , population, (total_cases/population)*100 AS casepercentage
FROM PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, MAX(total_cases) AS highestinfectioncount, MAX(total_cases/population)*100 AS PERCENTPOPULATIONINFECTED
FROM PortfolioProject..CovidDeaths
--where location like 'india'
Group by Location, Population
order by PERCENTPOPULATIONINFECTED desc

-- showing countries with highest death count per population

select location, MAX(cast(total_deaths as bigint)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths
--where location like 'india'
WHERE continent is not null
Group by location
order by totaldeathcount desc

select location, MAX(cast(total_deaths as bigint)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths
--where location like 'india'
WHERE continent is null
Group by location
order by totaldeathcount desc


--break things by continent

select continent, MAX(cast(total_deaths as bigint)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths
--where location like 'india'
WHERE continent is null
Group by continent
order by totaldeathcount desc

-- Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as bigint)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths
--where location like 'india'
WHERE continent is not null
Group by continent
order by totaldeathcount desc

-- GLOBAL NUMBERS
select * from PortfolioProject..CovidDeaths

SELECT location, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathchance
FROM PortfolioProject..CovidDeaths
--where location like 'india'
where continent is not null
order by 1,2

SELECT date, SUM(new_cases)--, total_deaths, (total_deaths/total_cases)*100 as deathchance
FROM PortfolioProject..CovidDeaths
--where location like 'india'
where continent is not null
group by date
order by 1,2

SELECT  SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
FROM PortfolioProject..CovidDeaths
--where location like 'india'
where continent is not null
--group by date
order by 1,2

select * from PortfolioProject..CovidVaccinations

-- JOIN 2 TABLES

select * from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date


--looking at total population vs vaccinations

select dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations,
SUM(CONVERT(int ,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--here----


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

