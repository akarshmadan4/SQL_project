CREATE database projects;
-- select *
-- FROM projects.covidvaccinations;

-- select *
-- FROM projects.coviddeaths;

select location,date,total_cases,new_cases,total_deaths,population
FROM projects.coviddeaths
ORDER BY 1,2;

-- looking at total cases vs total deaths
select location,date,total_cases,total_deaths,
	(total_deaths/total_cases)*100 as deathPercentage
FROM projects.coviddeaths
ORDER BY 1,2;

-- looking at total cases vs population
select location,date,total_cases,population,
	(total_cases/population)*100 as PercentageInfected
From projects.coviddeaths
order by 1,2;

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Projects.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount
From projects.CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as FLOAT)) as TotalDeathCount
From projects.CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths,
	SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From projects.CovidDeaths
where continent is not null 
-- Group By date
order by 1,2;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (Partition by dea.Location )
From projects.CovidDeaths dea
Join projects.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date)
	as RollingPeopleVaccinated
From projects.CovidDeaths dea
Join projects.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

DROP Table if exists PercentPopulationVaccinated;
Create Table projects.PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

use projects;
Insert into projects.PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date)
	as RollingPeopleVaccinated
From projects.CovidDeaths dea
Join projects.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3


