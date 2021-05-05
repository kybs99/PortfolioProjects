Select *
From PortfolioProject..CovidDeaths
Order by 3, 4;

Select *
From PortfolioProject..CovidVaccinations
Order by 3, 4

Select * 
From PortfolioProject..CovidPatientInfo
Order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

----- Looking at total cases vs total deaths 
----- Shows chance of dying of COVID in country

Select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as Deaths_percentage
From PortfolioProject..CovidDeaths
Where Location = 'United States'
Order by 1, 2


-----  Looking at Total cases vs Population
----- Shows proportion of population who contracted COVID
Select Location, date, population, total_cases, (total_cases / population) * 100 as PercentInfected
From PortfolioProject..CovidDeaths
Where Location = 'United States'
Order by 1, 2


----- Country with largest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases / population) * 100) AS PercentInfected
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location, population
Order by PercentInfected DESC

-- County with highest death count per population
-- Needed cast since total_deaths was brought in as nvarchar and world and continent were also in location so got rid of it 
Select location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location
Order by TotalDeathCount DESC


-- Broken down by continent but continent field for NA only included USA not canada or mexico
Select location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
Group by location
Order by TotalDeathCount DESC

-- This version works for visualization later
Select continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--- Continent with largest infection rate 
Select continent, MAX(total_cases) as HighestInfectedCount, MAX((total_cases / population) * 100) AS PercentInfected
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
Order by PercentInfected DESC


-- Global numbers
Select date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS Deaths_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by date, TotalCases

--- Overall numbers
Select SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS Deaths_percentage
From PortfolioProject..CovidDeaths
Where continent is not null


-- Looking at Total population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

-- Using CTE to obtain percentage of people vaccinated with at least 1 dose

With PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) AS(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
From PopVsVac
Order by 2, 3


-- Same thing but with a temp table

Drop Table if exists #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
INTO #PercentPopulationVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
From #PercentPopulationVaccinated
Order by 2, 3



-- Making a view to store data for visualization later

Create View ContinentDeathCount AS 
Select location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
Group by location;

Create View RollingPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null;

Create View GlobalDeathNumbers AS
Select date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS Deaths_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date

Create View CountryDeathCount AS
Select location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location

