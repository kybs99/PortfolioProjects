--SELECT * 
--FROM PortfolioProject..CovidPatientInfo


---- Seeing if life expectancy appears to correlate with total deaths
--SELECT pat.location, pat.life_expectancy, SUM(CAST(dea.total_deaths as INT)) AS TotalDeaths
--FROM PortfolioProject..CovidPatientInfo pat
--Join PortfolioProject..CovidDeaths dea
--ON pat.location = dea.location and pat.date = dea.date
--Where dea.continent is not null
--Group by pat.location, pat.life_expectancy
--Order by 2,  3


---- Seeing if gdp appears to correlate with total deaths
--SELECT pat.location, pat.gdp_per_capita, SUM(CAST(dea.total_deaths as int)) AS TotalDeaths
--FROM PortfolioProject..CovidPatientInfo pat
--Join PortfolioProject..CovidDeaths dea
--ON pat.location = dea.location and pat.date = dea.date
--Where dea.continent is not null
--Group by pat.location, pat.gdp_per_capita
--Order by 2



---- Seeing if diabetes prevalence has affect on death percentage using Case and temp table had to use text wording to order it correctly
--Drop table if exists #DiabetesInfo
--Select pat.location,
--Case
--	WHEN pat.diabetes_prevalence < 5 THEN 'Between 0 and 5'
--	WHEN pat.diabetes_prevalence BETWEEN 5 and 10 THEN 'Between Five and Ten'
--	WHEN pat.diabetes_prevalence BETWEEN 10 and 15 THEN 'Between Ten and Fifteen'
--	WHEN pat.diabetes_prevalence > 15 THEN 'Greater than Fifteen'
--END AS DiabetesPrevalence,
--MAX((CAST(dea.total_deaths as int)) / dea.total_cases * 100) AS DeathPercentage
--Into #DiabetesInfo
--From PortfolioProject..CovidPatientInfo pat 
--Join PortfolioProject..CovidDeaths dea
--On pat.location = dea.location and pat.date = dea.date
--Where pat.continent is not null
--Group by pat.diabetes_prevalence, pat.location

--Select DiabetesPrevalence, AVG(DeathPercentage) AS AverageDeathPercentage
--From #DiabetesInfo
--Group by DiabetesPrevalence


---- Seeing if extreme poverty has impact on percentage of death for population, does not appear so 
--Drop table if exists #ExtremePovertyInfo
--Select pat.location, pat.population, MAX((CAST(dea.total_deaths as int)) / dea.total_cases * 100) AS DeathPercentage,
--CASE
--	When CAST(pat.extreme_poverty AS float) < 10 THEN 'Between 0 and 10'
--	When CAST(pat.extreme_poverty AS float) BETWEEN 10 and 20 THEN 'Between 10 and 20'
--	When CAST(pat.extreme_poverty AS float) BETWEEN 20 and 30 THEN 'Between 20 and 30'
--	When CAST(pat.extreme_poverty AS float) BETWEEN 30 and 40 THEN 'Between 30 and 40'
--	When CAST(pat.extreme_poverty AS float) BETWEEN 40 and 50 THEN 'Between 40 and 50'
--	When CAST(pat.extreme_poverty AS float) > 50 THEN 'Greater than 50'
--END as ExtremePoverty
--INTO #ExtremePovertyInfo
--From PortfolioProject..CovidPatientInfo pat
--Join	PortfolioProject..CovidDeaths dea
--On pat.location = dea.location and pat.date = dea.date
--Where pat.continent is not null
--Group by pat.location, pat.population, pat.extreme_poverty

--Select ExtremePoverty, AVG(DeathPercentage) AS AverageDeathPercentage
--From #ExtremePovertyInfo
--Group by ExtremePoverty
