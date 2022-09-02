Select *
From PortfolioProject..CovidDeaths
Where Continent is not null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where Continent is not null
Order by 1,2


--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
and Where Continent is not null
Order by 1,2


--Looking at the Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
From PortfolioProject..CovidDeaths
Where location like '%States%'
and Where Continent is not null
Order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as percentpopulationinfected
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by location, population
Order by percentpopulationinfected desc


--Showing Countries with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by location, population
Order by totaldeathcount desc


--Let's break things down by continent


--Showing Continents with the Highest Death Count

Select continent, MAX(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by continent 
Order by totaldeathcount desc


--Global Numbers

Select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Order by 1,2

Select *
From PortfolioProject..CovidVaccinations
Where Continent is not null
Order By 3,4


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE

With popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (rollingpeoplevaccinated/population)*100
From popvsvac

--Temp table

Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (rollingpeoplevaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated