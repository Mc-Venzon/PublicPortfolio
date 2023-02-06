--Select *
--From PortfolioProject..CovidDeaths
--Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date,	total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2 

--Search for Total deaths to total cases

Select location, date,	total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like 'Philippines'
Order by 1,2 

--Search for Total cases to total cases

Select location, date,	population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Where Location like 'Philippines'
Order by 1,2 


--sort countries by infection rate

Select location, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100 )as InfectionPercentage
From PortfolioProject..CovidDeaths
--Where Location like 'Philippines'
Where continent is not null
Group by location, population
Order by InfectionPercentage desc


--Show countries with highest death percentage

Select location, MAX(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
--Where Location like 'Philippines'
Where continent is not null
Group by location, population
Order by TotalDeaths desc

--Group by continent
Select location, MAX(cast(total_deaths as int)) as "Total Deaths"
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by "Total Deaths" desc

--Global numbers by date
Select Sum(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/Sum(new_cases)*100 as "Death Percentage"
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--joins and cte
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

with Popandvac( Continent, Location, Date, Population, New_Vaccines, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from Popandvac

--Using Temporary Table
Drop Table if exists #PercentofPopulationVaccinated
Create Table	#PercentofPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_vaccinations Numeric,
RollingPeopleVaccinated Numeric
)
Insert into #PercentofPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentofPopulationVaccinated



--Creating views for data visualization
Drop view if exists PercentPopulationVaccinated 
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3

Select * 
from PercentPopulationVaccinated