Select *
from PortfolioProject1..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from PortfolioProject1..CovidVaccinations
--order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject1..CovidDeaths
order by 1,2

--total cases vs total deaths
--shows likelihood dying if you contact covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where location like '%india%'
order by 1,2

--Looking at total cases vs population 
--shows % of populations got covid

Select location,date,total_cases,population,(total_cases/population)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
--where location like '%india%'
order by 1,2

--looking at countries with highest infection rate compared to population 
Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentageInfected
from PortfolioProject1..CovidDeaths
--where location like '%india%'
Group by location,population
order by PercentageInfected desc

--Lets break things down by continent
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--showing countries with highest death count
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc

--
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
--where location like '%india%'
where continent is null
Group by location
order by TotalDeathCount desc

--showing continents with highest death count
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
Select SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as Total_deaths,SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.date) as RollingPeopleVaccinated,
 --(RollingPeopleVaccinated/Population)*100
From PortfolioProject1..CovidDeaths dea 
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/Population)*100
From PortfolioProject1..CovidDeaths dea 
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

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
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/Population)*100
From PortfolioProject1..CovidDeaths dea 
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View For visuals
Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/Population)*100
From PortfolioProject1..CovidDeaths dea 
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated