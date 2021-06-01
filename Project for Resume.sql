Select *
From PortfolioProject..Covid_Deaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..Covid_Vaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_Deaths
order by 1,2

-- Comparing Total Cases vs Total Deaths
--Shows likeihood of dying if you contract Covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
order by 1,2

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
Where location like '%states%'
order by 1,2

--Total Cases vs Population
--% of population of obtained Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as Percentofpop
From PortfolioProject..Covid_Deaths
Where location like '%states%'
order by 1,2

Select Location, date, total_cases, population, (total_cases/population)*100 as Percentofpop
From PortfolioProject..Covid_Deaths
Where location like '%uk%'
order by 1,2

--Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofHighestInfection
From PortfolioProject..Covid_Deaths
Group by Location, population
order by PercentofHighestInfection desc



--Percetage of Highest Mortality Rate per Population

Select Location, MAX(cast(total_deaths as int)) as TotalMortalityCount
From PortfolioProject..Covid_Deaths
Where continent is not null
Group by Location, population
order by TotalMortalityCount desc

Select Location, date, total_cases,  total_deaths as TotalMortalityCount
From PortfolioProject..Covid_Deaths
Where location like '%uk%'
order by 1,2

--Sorting Total Deaths by Continent

Select location, MAX(cast(total_deaths as int)) as TotalMortalityCount
From PortfolioProject..Covid_Deaths
Where continent is null
Group by location
order by TotalMortalityCount desc

--Showing Global Mortality % by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
Where continent is not null
Group By date
order by 1,2

--Showing Global Mortality overall

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
Where continent is not null
order by 1,2

--Total Pop vs Vaccinations

Select D.continent, D.location, D.date, D.population, V.new_vaccinations 
From PortfolioProject..Covid_Deaths D
Join PortfolioProject..Covid_Vaccinations V
	On D.location = V.location 
	and D.date = V.date
	Where D.continent is not null
order by 2,3


Select D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.location Order by D.location, D.date) as Growing#ofVaccinations
--, (Growing#ofVaccinations/population)*100
From PortfolioProject..Covid_Deaths D
Join PortfolioProject..Covid_Vaccinations V
	On D.location = V.location 
	and D.date = V.date
	Where D.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, Growing#ofVaccinations)
as 
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.location Order by D.location, D.date) as Growing#ofVaccinations
--, (Growing#ofVaccinations/population)*100
From PortfolioProject..Covid_Deaths D
Join PortfolioProject..Covid_Vaccinations V
	On D.location = V.location 
	and D.date = V.date
	Where D.continent is not null
)

Select *, (Growing#ofVaccinations/population) *100
From PopvsVac

--TEMP TABLE

DROP Table if exists Growing#ofVaccinations
Create Table Growing#ofVaccinations
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Growing#ofVaccinations numeric
)

Insert into Growing#ofVaccinations
Select D.continent, D.location, D.date, D.population, V.new_vaccinations 
,SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.location Order by D.location, D.date) as Growing#ofVaccinations
From PortfolioProject..Covid_Deaths D
Join PortfolioProject..Covid_Vaccinations V
	On D.location = V.location 
	and D.date = V.date
--Where D.continent is not null
--order by 2,3

Select *, (Growing#ofVaccinations/population) *100
From Growing#ofVaccinations

--Creating View to store for later data visualizations

Create View PercentPopVac as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations 
,SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.location Order by D.location, D.date) as Growing#ofVaccinations
From PortfolioProject..Covid_Deaths D
Join PortfolioProject..Covid_Vaccinations V
	On D.location = V.location 
	and D.date = V.date
Where D.continent is not null
--order by 2,3


