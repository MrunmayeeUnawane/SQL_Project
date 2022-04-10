select * from
['covid deaths$']
where continent is not null
order by 3,4

--select * from
--['covid vaccinations$']
--order by 3,4

--Select Data that we are going to use

select location,date,total_cases,new_cases,total_deaths,population
from dbo.['covid deaths$']
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in you country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from dbo.['covid deaths$']
where location = 'United States'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what % of population got covid
select location,date,total_cases,population,(total_deaths/population)*100 as PercentPopulationInfected
from dbo.['covid deaths$']
where continent is not null
order by 1,2

-- Looking at countries with Highest Infection rate compared to Population
select location,population,max(total_cases) as HighestInfectionCount,MAX((total_deaths/population))*100 as PercentPopulationInfected
from dbo.['covid deaths$']
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from dbo.['covid deaths$']
where continent is not null
group by location
order by TotalDeathCount desc

-- Let's break things down by Continent
--Showing continents with the highest death coungt per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from dbo.['covid deaths$']
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.['covid deaths$']
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

with PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from dbo.['covid deaths$'] death
join dbo.['covid vaccinations$'] vac
on death.location= vac.location
and death.date = vac.date
where death.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as 'Max % people vaccinated'
from PopVsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from dbo.['covid deaths$'] death
join dbo.['covid vaccinations$'] vac
on death.location= vac.location
and death.date = vac.date
--where death.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--creating View to store data for later visualizations

create View PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from dbo.['covid deaths$'] death
join dbo.['covid vaccinations$'] vac
on death.location= vac.location
and death.date = vac.date
where death.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated