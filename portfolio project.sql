
alter table [coviddeaths] alter column [total_deaths] [float]
alter table [coviddeaths] alter column [total_cases] [float]

-- looking for the death percent
select location,date, total_cases,total_deaths, total_deaths/nullif(total_cases,0)*100 as death_percent from coviddeaths
where location like '%india%'
order by 1,2

--looking at the toal cases vs population 
--shows what percent got covid 
select location,date, total_cases,population, total_cases/nullif(population,0)*100 as infected_percent from coviddeaths
where location like '%india%'
order by 1,2

--looking for the countries with high infection rate 
select location,max(total_cases) as highest_count, max(total_cases/nullif(cast(population as bigint),0)*100) as infected_percent_by_country from coviddeaths
--where location like '%india%'
where continent not like ''
group by population,location
order by infected_percent_by_country desc


--show the countries with highest death count 
select location,max(cast(total_deaths as int)) as total_death_counts from coviddeaths
--where location like '%india%'
where continent  not like '' 
group by location
order by total_death_counts desc


-- total death count by continent 
select location,max(cast(total_deaths as int)) as total_death_counts from coviddeaths
--where location like '%india%'
where continent like '' 
group by location
order by total_death_counts desc

--join the two databases

select * from coviddeaths dea
join covidvaccination vac 
on dea.location = vac.location
and dea.date = vac.date

--total polulation vs vaccination
--CTS function
with PopvsVas (continent,location,date,population,new_vaccinations,rolling_vaccination)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location
order by dea.location, dea.date) as rolling_vaccination
from coviddeaths dea
join covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent not like ''
--order by 2,3
)

select * ,(rolling_vaccination/population)*100
from PopvsVas

--creating view for viz
create view PopvsVas as 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location
order by dea.location, dea.date) as rolling_vaccination
from coviddeaths dea
join covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent not like ''
--order by 2,3

select * from PopvsVas