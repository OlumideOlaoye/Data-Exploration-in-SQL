

--Data Source: ourworldindata.org/covid-deaths

/*
Covid-19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



Select *
From PortfolioProject..CovidDeaths
Where Continent is not null
Order By 3, 4


Select *
From PortfolioProject..CovidVaccinations
Where Continent is not null
Order By 3, 4


-- Select Data that we are going to be starting with


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where Continent is not null
Order By 1, 2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid-19 virus in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percent_Death
From PortfolioProject..CovidDeaths
--Where Location = 'Nigeria'
Where Continent is not null
Order By 1, 2

Select Continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percent_Death
From PortfolioProject..CovidDeaths
--Where Location = 'Canada'
Where Continent is not null
Order By 1, 2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percent_Death
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent is not null
Order By 1, 2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percent_Death
From PortfolioProject..CovidDeaths
--Where Location = 'United States'
Where Continent is not null
Order By 1, 2


-- Total Cases vs Population
-- Shows what percentage of population have been infected with Covid-19

Select Location, date, Population, total_cases, (total_cases/Population)*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths
Where Location = 'Nigeria' 
and Continent is not null
Order By 1, 2

Select Location, date, Population, total_cases, (total_cases/Population)*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths
Where Location = 'Canada' 
and Continent is not null
Order By 1, 2

Select Location, date, Population, total_cases, (total_cases/Population)*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths
Where Location = 'United States' 
and Continent is not null
Order By 1, 2


Select Location, date, Population, total_cases, (total_cases/Population)*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths
--Where Location = 'United States'
Where Continent is not null
Order By 1, 2


Select Location, date, Population, total_cases, (total_cases/Population)*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths
--Where Location = 'United States'
Where Continent is null
Order By 1, 2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/Population))*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths
--Where Location = 'United States'
Where Continent is null
Group By Location, Population
Order By Percent_Population_Infected DESC


-- Countries with Highest Death Count per Population

Select Location, MAX(CAST(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
Where Continent is not null
Group By Location
Order By Total_Death_Count DESC

Select Location, MAX(CAST(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
Where Continent is null
Group By Location
Order By Total_Death_Count DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select Continent, MAX(CAST(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
Where Continent is not null
Group By continent
Order By Total_Death_Count DESC


Select Continent, MAX(CAST(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
Where Continent is null
Group By continent
Order By Total_Death_Count DESC

-- GLOBAL NUMBERS

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order By 1, 2

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
Order By 1, 2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid-19 Vaccine

Select * 
From PortfolioProject..CovidVaccinations
Order by 2, 3

Select *
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2, 3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_People_Vacinnated_Population_Percent
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_People_Vacinnated_Population_Percent 
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From PercentPopulationVaccinated









