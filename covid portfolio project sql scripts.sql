select * from PortfolioProject..coviddeaths
order by 3,4

--select * from PortfolioProject..covidvaccinations$ 
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1,2


--looling at total cases vs total deaths

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
where location like '%states%'
order by 1,2


--looking at total cases vs population
--shows what percentage of population got covid

select location, date, total_cases, population,(total_cases/population)*100 as deathpercentage
from PortfolioProject..coviddeaths
where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population

select location, max(total_cases) as highestinfectioncount, population, max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..coviddeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc 


--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as highestDeathcount
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
Group by location
order by highestDeathcount desc 


-- Lets Break things down by continent

--showing continents with the hightest death count

select continent, max(cast(total_deaths as int)) as highestDeathcount
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
Group by continent
order by highestDeathcount desc 


--global numbers

select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
where continent is not null and new_cases<> 0
group by date
order by 1,2


select * from PortfolioProject.dbo.covidvaccinations

--looking at total population vs vaccination

select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..newvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--use cte

with PopvsVac (continent,location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..newvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 from PopvsVac


--temp table
--lets do this to understand temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #percentpopulationvaccinated
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..newvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select * from #percentpopulationvaccinated


--creating view to store data for later visualization

create view personvaccinatedview as
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..newvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,

select * from personvaccinatedview