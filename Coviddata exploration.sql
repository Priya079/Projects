select * From coviddata.dbo.coviddeaths
order by 3,4
select * From coviddata.dbo.[covid vaccinations]
order by 3,4
-- Selecting required data
select location, date, total_cases, new_cases, total_deaths, population
From coviddata.dbo.coviddeaths
order by 1,2
--Looking at total_cases vs total_deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From coviddata.dbo.coviddeaths
order by 1,2
--Looking death rate for specfic country
--Shows likelihood of dying on contraction of covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From coviddata.dbo.coviddeaths
where location = 'India'
order by 1,2
--Looking at total_cases vs population
-- shows what percentage of population got affected
select location, date, population, total_cases, (total_cases/population)*100 as percentageaffected
From coviddata.dbo.coviddeaths
order by 1,2
--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as Infectioncount, Max((total_cases/population))*100 as infectedrate
From coviddata.dbo.coviddeaths
group by location, population
order by infectedrate desc
--countries with highest death count per population
select location, max(cast(total_deaths as int)) as deathcount
From coviddata.dbo.coviddeaths
where continent is not null
group by location
order by deathcount desc
--breakdown by continent
select continent , max(cast(total_deaths as int)) as deathcount
From coviddata.dbo.coviddeaths
where continent is not null
group by continent
order by deathcount desc
--continent with highedst death count per population
select continent , max(cast(total_deaths as int)) as deathcount
From coviddata.dbo.coviddeaths
where continent is not null
group by continent
order by deathcount desc
--Global Numbers
select date, sum(new_cases)as casescount, sum(cast(new_deaths as int)) as deathcount, sum(cast(new_deaths as int))/sum(new_cases) as deathrate
From coviddata.dbo.coviddeaths
where continent is not null
group by date
order by 1,2
--Total count
select sum(new_cases)as casescount, sum(cast(new_deaths as int)) as deathcount, sum(cast(new_deaths as int))/sum(new_cases) as deathrate
From coviddata.dbo.coviddeaths
where continent is not null
order by 1,2


select * From coviddata.dbo.[coviddeaths] dea
join coviddata.dbo.[covid vaccinations] vac 
on dea.location = vac.location  and dea.date = vac.date
--Looking at Total Population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From coviddata.dbo.[coviddeaths] dea
join coviddata.dbo.[covid vaccinations] vac 
on dea.location = vac.location  and dea.date = vac.date
where dea.continent is not null
order by 2,3
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
From coviddata.dbo.[coviddeaths] dea
join coviddata.dbo.[covid vaccinations] vac 
on dea.location = vac.location  and dea.date = vac.date
where dea.continent is not null
order by 2,3
--use CTE
with popvsvac (continent,location,date, population, new_vaccinations, peoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
From coviddata.dbo.[coviddeaths] dea
join coviddata.dbo.[covid vaccinations] vac 
on dea.location = vac.location  and dea.date = vac.date
where dea.continent is not null
)
Select *, (peoplevaccinated/population)*100 as PercentPeopleVaccinated
From PopvsVac

--Temp Table
drop table if exists #percentpeoplevaccinated
create table #percentpeoplevaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
PeopleVaccinated numeric
)
Insert into #percentpeoplevaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
From coviddata.dbo.[coviddeaths] dea
join coviddata.dbo.[covid vaccinations] vac 
on dea.location = vac.location  and dea.date = vac.date
--where dea.continent is not null
order by 2,3
Select *, (peoplevaccinated/population)*100 as PercentPeopleVaccinated
From #percentpeoplevaccinated

-- Creating view to store data for later visualizations

create view percentpeoplevaccinated as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
From coviddata.dbo.[coviddeaths] dea
join coviddata.dbo.[covid vaccinations] vac 
on dea.location = vac.location  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpeoplevaccinated
