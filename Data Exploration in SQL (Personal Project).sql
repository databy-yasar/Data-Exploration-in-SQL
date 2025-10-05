/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select *
from PortfolioProjects..CovidDeaths
where continent is not null
order by 3,4


-- Step 1: Exploring the CovidDeaths table to inspect data and identify relevant columns for analysis

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2


-- Step 2: Looking at total cases vs total deaths to analyze the likelihood of dying from COVID in each country


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2

-- Step 3: Looking at total cases vs population to analyze the percentage of the population infected by COVID in each country


select location, date, population, total_cases,  (total_cases/population)*100 as Percent_Population_Infected
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2


-- Step 4: Looking at countries with the highest infection rate compared to population


select location, population, MAX(total_cases) as Highest_Infection_Count,  MAX((total_cases/population))*100 as Percent_Population_Infected
from PortfolioProjects..CovidDeaths
where continent is not null
group by location, population
order by Percent_Population_Infected desc


-- Step 5: Showing countries with the highest death count per population

select location, MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProjects..CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc


-- Step 6: Breaking down the data by continent to show highest death count per population


select location, MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProjects..CovidDeaths
where continent is null
group by location
order by Total_Death_Count desc


-- Step 7: Showing global numbers for total cases, total deaths, and overall death percentage

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from PortfolioProjects..CovidDeaths
where continent is not null
group by date
order by 1,2


select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from PortfolioProjects..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Step 8: Looking at total population vs vaccinations to analyze vaccination progress across countries



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location,
dea.date) as Rolling_People_Vaccinated,
--(Rolling_People_Vaccinated/population)*100
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With populationVSvaccinations (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From populationVSvaccinations


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3