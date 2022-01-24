--1. Global numbers
SELECT SUM(new_cases) as New_Total_Cases, SUM(cast(new_deaths as int)) as New_Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where continent is not null
--Group by Date
order by 1,2

--2. Continent numbers
Select location, SUM(CAST(new_deaths as int)) as TotalDeaths
From CovidProject..CovidDeaths
where continent is null
and location not in ('World','European Union','International')
and location not LIKE '%income'
Group by location
Order by TotalDeaths Desc

--3. Infected percentage of country
SELECT Location,Population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/Population))*100 as InfectedPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by location,Population
order by InfectedPercentage desc

--4. Highest Infected percentage of country by date
SELECT Location,Population,Date, Max(total_cases) as HighestInfectionCount,  Max((total_cases/Population))*100 as InfectedPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by location,Population,Date
order by InfectedPercentage desc


--5. Death percentage on certain country
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--6. Country with highest Death Count per population 
SELECT Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by Location,Population
Order by TotalDeathCount Desc

--7. Death count of Continents 
SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount Desc

--8.Vaccinated rate
--Create CTE for new created column Rolling_vaccinations	
With PopulationToVaccination (Continent, Location, Date, Population, new_people_vaccinated_smoothed, Rolling_vaccinations)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed
,SUM(Convert(bigint , vac.new_people_vaccinated_smoothed)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as Rolling_vaccinations
From CovidProject..CovidDeaths Dea
Join CovidProject..CovidVaccinations Vac
	On Dea.location=Vac.location
	and Dea.date=Vac.date
where dea.continent is not null
)

Select *, (Rolling_vaccinations/Population)*100
From PopulationToVaccination

--9.Vaccinated rate of continent done in TEMP table
Drop Table if exists VaccinatedRate
Create Table VaccinatedRate(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rolling_vaccinations numeric
)
Insert into VaccinatedRate
Select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed
,SUM(Convert(bigint , vac.new_people_vaccinated_smoothed)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as Rolling_vaccinations
From CovidProject..CovidDeaths Dea
Join CovidProject..CovidVaccinations Vac
	On Dea.location=Vac.location
	and Dea.date=Vac.date
Where dea.continent is null

Select *, (Rolling_vaccinations/Population)*100
From VaccinatedRate

--10. Create View to store data for Data Visualization
Drop View if exists VaccinationRate

Create View VaccinationRate as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed
,SUM(Convert(bigint , vac.new_people_vaccinated_smoothed)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as Rolling_vaccinations
From CovidProject..CovidDeaths Dea
Join CovidProject..CovidVaccinations Vac
	On Dea.location=Vac.location
	and Dea.date=Vac.date
where dea.continent is not null

Select *
From VaccinationRate


