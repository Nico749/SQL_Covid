select  
continent, date, total_cases,new_cases,total_deaths, population
from dbo.CovidDeaths
where continent is not null AND total_cases is not null
order by 1,2

/*analyzing total cases and total deaths in Italy*/
select  
location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_rate, population
from dbo.CovidDeaths
where location = 'Italy'
order by 2 desc

/* total cases vs population in Italy*/
select  
location, date, total_cases,total_deaths, (total_cases/population)*100 as infection_rate, population
from dbo.CovidDeaths
where location = 'Italy'
order by 5 desc

/* countries with highest infection and death rates excluding countries with small population */
Select 
location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as infectionRate, max((total_deaths/total_cases))*100 as death_rate
From dbo.CovidDeaths
where population > 5000000
Group by location, population
order by infectionRate desc

/* continent with highest infection and death rates excluding countries with small population */
Select 
continent,  Max((total_cases/population))*100 as infectionRate, max((total_deaths/total_cases))*100 as death_rate
From dbo.CovidDeaths
where population > 5000000 AND continent is not null
Group by continent
order by infectionRate desc
/*total cases and total deaths in the world*/
select 
location, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths
from dbo.CovidDeaths
where continent is not null 
group by location
order by 2 desc

/* add the vaccination data and the total of vaccinations */
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.new_tests,
sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.date, dea.location) as totalVac
from dbo.CovidDeaths dea
join  dbo.CovidVaccinations vac
on dea.iso_code = vac.iso_code
and dea.date = vac.date
where dea.continent is not null
order by 2

/*CTE to compare the totalVaccines vs population*/
with cte_vaccination (continent,location,date,population,new_vaccinations,new_tests,totalVac) as (
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.new_tests,
sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.date, dea.location) as totalVac
from dbo.CovidDeaths dea
join  dbo.CovidVaccinations vac
on dea.iso_code = vac.iso_code
and dea.date = vac.date
where dea.continent is not null

)
select continent,location,date,new_tests,new_vaccinations,(totalVac/population)*100 as vacRate
from cte_vaccination

/*create a view for visualize data*/
create view VacRate as 
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.new_tests,
sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.date, dea.location) as totalVac
from dbo.CovidDeaths dea
join  dbo.CovidVaccinations vac
on dea.iso_code = vac.iso_code
and dea.date = vac.date
where dea.continent is not null
