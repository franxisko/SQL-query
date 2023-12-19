Looking at Likelihood of Dying from COvid in Different COuntries

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where location like '%states%'
Order by 1,2

Lookign at WHat eprcentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as Prevalence
From CovidDeaths$
Where location like '%states%'
Order by 1,2


What COuntries have the highest infection rate compared to population 

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Prevalence
From CovidDeaths$
Group by location, population
Order by Prevalence desc


-- What countries have highest death rate per population

 Select location, MAX(cast(total_deaths as int)) as DeathCount, MAX(total_deaths/population)*100 as deathrate
From CovidDeaths$
where continent is not null
Group by location
Order by DeathCount desc


continenst witht the highest deathcount

Select continent, MAX(cast(total_deaths as int)) as DeathCount
From CovidDeaths$
where continent is not null
Group by continent
Order by DeathCount desc


GLOBAL NUMBERS BY DATE


select Date, SUM(new_cases) as totalcases,SUM(Cast(New_deaths as int)) as totaldeaths
From CovidDeaths$
where continent is not null
Group by Date
Order by 1,2

Removing the date to see ovevrall number
select SUM(new_cases) as totalcases,SUM(Cast(New_deaths as int)) as totaldeaths
From CovidDeaths$
where continent is not null
Order by 1,2


LOOKING AT VACCINATION.
Join the 2 tables

Select * from CovidDeaths$ as deaths
Join CovidVaccinations$ as vacced
on deaths.location = vacced.location
and deaths.date = vacced.date



Select Deaths.continent, deaths.location, deaths.date, deaths.population, vacced.new_vaccinations
from CovidDeaths$ as deaths
Join CovidVaccinations$ as vacced
on deaths.location = vacced.location
and deaths.date = vacced.date
where deaths.continent is not null
order by 2,3

Select Deaths.continent, deaths.location, deaths.date, deaths.population, vacced.new_vaccinations, SUM(cast(vacced.new_vaccinations as int)) OVER (Partition by Deaths.location order by deaths.location, deaths.date) as rollingvacccount
from CovidDeaths$ as deaths
Join CovidVaccinations$ as vacced
on deaths.location = vacced.location
and deaths.date = vacced.date
where deaths.continent is not null
order by 2,3

--To compare percentage population vacinated versus population, We should do (rolling vacc count/population)*100. but we cant do the function off of a column created off of an alias, so we will create  a CTE that has the alias as a column


With PopVSVaccinated (Continent, Location, Date, Population, new_vaccinations, rollingVaccCount)
as (Select Deaths.continent, deaths.location, deaths.date, deaths.population, vacced.new_vaccinations, SUM(cast(vacced.new_vaccinations as int)) OVER (Partition by Deaths.location order by deaths.location, deaths.date) as rollingvacccount
from CovidDeaths$ as deaths
Join CovidVaccinations$ as vacced
on deaths.location = vacced.location
and deaths.date = vacced.date
where deaths.continent is not null
)

Select * from PopVSVaccinated

-- so RollingVaccCount is now a column and a function can be oerformed from it.

With PopVSVaccinated (Continent, Location, Date, Population, new_vaccinations, rollingVaccCount)
as (Select Deaths.continent, deaths.location, deaths.date, deaths.population, vacced.new_vaccinations, SUM(cast(vacced.new_vaccinations as int)) OVER (Partition by Deaths.location order by deaths.location, deaths.date) as rollingvacccount
from CovidDeaths$ as deaths
Join CovidVaccinations$ as vacced
on deaths.location = vacced.location
and deaths.date = vacced.date
where deaths.continent is not null 
)

Select *, (rollingVaccCount/population)*100 
from PopVSVaccinated


Another way to do the same thing is to create a --TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVacccount numeric
)

Insert into #PercentPopulationVaccinated
Select Deaths.continent, deaths.location, deaths.date, deaths.population, vacced.new_vaccinations, SUM(cast(vacced.new_vaccinations as int)) OVER (Partition by Deaths.location order by deaths.location, deaths.date) as rollingvacccount
from CovidDeaths$ as deaths
Join CovidVaccinations$ as vacced
on deaths.location = vacced.location
and deaths.date = vacced.date
where deaths.continent is not null
order by 2,3

Select *, (rollingVacccount/population)*100 
from #PercentPopulationVaccinated

 

 --creating view to store data for later

 create view PercentPopulationVacinated as
 Select Deaths.continent, deaths.location, deaths.date, deaths.population, vacced.new_vaccinations, SUM(cast(vacced.new_vaccinations as int)) OVER (Partition by Deaths.location order by deaths.location, deaths.date) as rollingvacccount
from CovidDeaths$ as deaths
Join CovidVaccinations$ as vacced
on deaths.location = vacced.location
and deaths.date = vacced.date
where deaths.continent is not null
