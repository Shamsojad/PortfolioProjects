Select *
from portfolioproject..covidDeaths
where continent is not null
order by 3,4

--Select *
--from portfolioproject..covidVaccinations
--order by 3,4

--select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
Select Location, date, population,  total_cases, (CAST(total_cases as float)/population*100) as PercentPopulationInfected
FROM PortfolioProject..covidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--looking at countries with highest infection rate compared to population
Select Location, population,  MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases as float)/population*100) as PercentPopulationInfected
FROM PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
Select Location, max(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

-- let's break things down by continent

Select continent, max(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

--showin continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

-- global numbers
--i put the isnull(new_cases. 0.00001) to get clos to a number that's 0 without inputing 0 bcz they give an error if u divide by 0
Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(cast(new_deaths as int))/sum(isnull(new_cases,0.000001))*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(cast(new_deaths as int))/sum(isnull(new_cases,0.000001))*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

----we added the partition by to add up new vaccinations after every day. This is done by partition by
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, sum(isnull(cast(vac.new_vaccinations as float), 0.0000001)) over (partition by dea.location)
--from PortfolioProject..covidDeaths dea
--join PortfolioProject..covidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

--all the last code of isnull was for nothing i guess, but im gonna keep it
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--in the last comment. Btetla3 error cuz u cant use a column u just created de8re in the same line

--use CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac





-- TEMP TABLE
--drop table line is for doing any alterations to the temp table without getting any error
DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated
