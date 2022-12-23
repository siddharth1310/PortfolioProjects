Select * from PortfolioProject.dbo.CovidDeaths where continent is not null order by 3,4;
Select * from PortfolioProject.dbo.CovidVaccinations order by 3,4;

-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject.dbo.CovidDeaths order by 1, 2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths where  location like '%states%' order by 1, 2;


-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths where  location like '%states%' order by 1, 2;


-- Looking at coutries with highest infection rate compare to population
Select location, population, 
MAX(total_cases) as Highest_Infection_Count, 
MAX((total_cases/population))*100 as Percent_Population_Infected
from PortfolioProject.dbo.CovidDeaths 
--where location = 'India'
Group by location, population
order by Percent_Population_Infected desc;


-- Showing countries with highest Death Count Per Population
Select location,
MAX(cast(total_deaths as int)) as Total_Death_Count 
from PortfolioProject.dbo.CovidDeaths 
where continent is not null
Group by location
order by Total_Death_Count desc;


-- LET'S BREAK THINGS DOWN BY CONTINENT
Select location,
MAX(cast(total_deaths as int)) as Total_Death_Count 
from PortfolioProject.dbo.CovidDeaths 
where continent is null
Group by location
order by Total_Death_Count desc;


-- Showing continents with the highest death count per population
Select continent,
MAX(cast(total_deaths as int)) as Total_Death_Count 
from PortfolioProject.dbo.CovidDeaths 
where continent is not null
Group by continent
order by Total_Death_Count desc;


-- Global Numbers
Select 
--date,
sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths 
where continent is not null 
--group by date
order by 1, 2;


-- Exploring Vacination table
-- Looking at total population vs vaccinations

-- USE CTE

with Pop_Vs_Vac ( Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as (
select Death.continent, Death.location, Death.date, Death.population, Vacination.new_vaccinations,
SUM(Cast(Vacination.new_vaccinations as int)) over (Partition by  Death.location order by Death.location, Death.date) as Rolling_People_Vaccinated
from PortfolioProject.dbo.CovidDeaths Death 
join PortfolioProject.dbo.CovidVaccinations Vacination on
Death.location = Vacination.location and Death.date = Vacination.date
where Death.continent is not null
--order by 2, 3
)

select *, (Rolling_People_Vaccinated/Population) * 100 as Vaccination_Percentage from Pop_Vs_Vac;


-- Finding Maximum Vaccination Percentage
with Pop_Vs_Vac ( Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as (
select Death.continent, Death.location, Death.date, Death.population, Vacination.new_vaccinations,
SUM(Cast(Vacination.new_vaccinations as int)) over (Partition by  Death.location order by Death.location, Death.date) as Rolling_People_Vaccinated
from PortfolioProject.dbo.CovidDeaths Death 
join PortfolioProject.dbo.CovidVaccinations Vacination on
Death.location = Vacination.location and Death.date = Vacination.date
where Death.continent is not null
--order by 2, 3
)

select Continent, Location, Population, MAX((Rolling_People_Vaccinated/Population)) * 100 as Vaccination_Percentage from Pop_Vs_Vac 
where New_Vaccinations is not null and Rolling_People_Vaccinated is not null
group by Continent, Location, Population
order by Location;

-- Straight Forward Calculation
select Death.continent, Death.location, Death.date, Death.population, Vacination.new_vaccinations,
SUM(Cast(Vacination.new_vaccinations as int)) over (Partition by  Death.location order by Death.location, Death.date) as Rolling_People_Vaccinated,
SUM(Cast(Vacination.new_vaccinations as int)) over (Partition by  Death.location order by Death.location, Death.date)/population * 100 as Vaccination_Percentage
from PortfolioProject.dbo.CovidDeaths Death 
join PortfolioProject.dbo.CovidVaccinations Vacination on
Death.location = Vacination.location and Death.date = Vacination.date
where Death.continent is not null order by 2, 3;


-- Creating View to store data for later visulizations

Go
Create View Percent_Population_Vaccinated as
select Death.continent, Death.location, Death.date, Death.population, Vacination.new_vaccinations,
SUM(Cast(Vacination.new_vaccinations as int)) over (Partition by  Death.location order by Death.location, Death.date) as Rolling_People_Vaccinated
from PortfolioProject.dbo.CovidDeaths Death 
join PortfolioProject.dbo.CovidVaccinations Vacination on
Death.location = Vacination.location and Death.date = Vacination.date
where Death.continent is not null
--order by 2, 3
Go

select * from Percent_Population_Vaccinated;

Drop view Percent_Population_Vaccinated;
