
-- Selecting the Data that is going to be used.

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..covidDeaths
WHERE continent IS NOT null
Order by 1,2

-- Looking at toatal cases versus total deaths.
-- Shows likelihood of death if you contract the virus by country. (ex. United States)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..covidDeaths
Where location Like '%States' AND continent IS NOT null
Order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population contracted the virus by country (ex. United States)

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From PortfolioProjects..covidDeaths
Where location Like '%States' AND continent IS NOT null
Order by 1,2

-- Looking at countries with highest infection rate compared to their population by country 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProjects..covidDeaths
Where continent IS NOT null
Group by Location, Population
Order by InfectedPercentage Desc

-- Showing the countries with the highest death count by population.

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..covidDeaths
Where continent IS NOT null
Group by Location
Order by TotalDeathCount Desc

-- Looking at death count by continent.
-- Showing the continents with the highest death count.

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..covidDeaths
Where continent IS NOT null
Group by continent
Order by TotalDeathCount Desc

-- Looking at the Global death percentage.

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths
, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProjects..covidDeaths
Where continent IS NOT null
Order by 1,2

-------- Starting to look at vaccination data and joining it to the deaths table. -------- 

Select *
From PortfolioProjects..covidDeaths deaths
Join PortfolioProjects..covidVaccinations vaccs
	On deaths.location = vaccs.location
	And deaths.date = vaccs.date

-- Looking at total population versus vaccinations.

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations
, Sum(cast(vaccs.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location,deaths.date) As TotalVaccinated
From PortfolioProjects..covidDeaths deaths
Join PortfolioProjects..covidVaccinations vaccs
	On deaths.location = vaccs.location
	And deaths.date = vaccs.date
Where deaths.continent IS NOT null
Order by 2,3

-- Using Common Table Expressions aka. CTE.

With PopulationVsVaccinations (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinated)
AS
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations
, Sum(cast(vaccs.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location,deaths.date) As TotalVaccinated
From PortfolioProjects..covidDeaths deaths
Join PortfolioProjects..covidVaccinations vaccs
	On deaths.location = vaccs.location
	And deaths.date = vaccs.date
Where deaths.continent IS NOT null
)
Select *, (TotalVaccinated/Population)*100 As PercentVaccinated
From PopulationVsVaccinations

-- Using a temp table.

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, NewVaccinations numeric, TotalVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations
, Sum(cast(vaccs.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location,deaths.date) As TotalVaccinated
From PortfolioProjects..covidDeaths deaths
Join PortfolioProjects..covidVaccinations vaccs
	On deaths.location = vaccs.location
	And deaths.date = vaccs.date
Where deaths.continent IS NOT null

Select *, (TotalVaccinated/Population)*100 As PercentVaccinated
From #PercentPopulationVaccinated

-- Creating a view for visualization.

Create View PercentPopulationVaccinated As
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations
, Sum(cast(vaccs.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location,deaths.date) As TotalVaccinated
From PortfolioProjects..covidDeaths deaths
Join PortfolioProjects..covidVaccinations vaccs
	On deaths.location = vaccs.location
	And deaths.date = vaccs.date
Where deaths.continent IS NOT null




