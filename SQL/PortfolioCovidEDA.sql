create database PortfolioProject;
use PortfolioProject;

/*For the Covid project we will be making use of two datasets. One is the CovidDeaths and the another is CovidVaccination
The main columns that we will be making use of in CovidDeaths dataset is continent,location,new deaths,total dearhs,new cases,total cases,population.
First we are finding the death rate because of covid that is deaths/infected cases(For each location(country) day wise). Some days there might not be any infected days during which the value would be 0
to avoid exception of divide by 0 we use case.That is when the number of infected cases is 0 we set the death rate 0 else we use the death*100.0/infected

Then we are further drilling it down to identify the death rate day wise of country India alone.

In the next step we are trying to understand the infection rate (total_cases_until_date/population) day wise for India alone

Next we are finding the country with highest infection rate. 

Another thing is when the continent is NULL the location stores the continent wise data so we are specifying the condition where continent is not null.
First group by location identify maximum value of population(Just to extract population we use max, no significance of max) and maximum value of total cases 
then we divide by totalcases/population. Specify order by desc
Add top 1 to get the first record

Then we are doing the same thing for death rate (death/cases). That is identifying the location with highest death rate

Next is we are identifying the country with highest death count
And also we are finding the continent wise death count. For this specify condition where continent is NULL we will get continent data. 
Another way is to group by continent and find sum(new_cases) also specify where continent is not NULL

The next step is finding the country with highest death count continent wise

First we are identifying continent and max(total_deaths) as d1 this gives us the count of deaths in country with max death
Then we are grouping by continent location and max(total_deaths) as d2 and extracting all the records having d2 in d1.

This can be done using partition as well.

First we identify location wise death count  and do a window function to identify maximum death continent wise 
and give an equal to condition.

One thing to remember is when we use sum we need to make sure the records is not NULL, or we won't get correct result.

Finally we are identifying the worldwide death rate, total deaths/total cases as well as 
date wise death rate group by date.


Now we are considering the CovidVaccinations dataset

For performing analysis we first join with coviddeaths on the location and date

1) Identifying the country wise vaccination rate
2) Next we are identifying country wise day wise vaccination count
3) Then we are doing a rolling sum to identify the vaccinated count until that day instead of that day alone
4) Then we are storing the result in temp table as well in a view
5) Using the temp table we identify vaccination_percentage until that date.
*/


select top 5 * from dbo.CovidDeaths order by 3,4;
select Top 5 * from dbo.CovidVaccinations order by 3,4;

-- Order by 3,4 means order by 3rd and 4th column

-- Selecting the data that we are going to use
select location,date,total_cases,new_cases,total_deaths,population from dbo.CovidDeaths order by 1,2;

-- Looking at total cases vs total deaths
-- Percentage of people who died because of covid until that date

-- total deaths is total deaths till date
select location,date,total_cases,total_deaths,case
    when total_cases=0 then 0
    else total_deaths*100.0/total_cases
end as death_percentage
from dbo.CovidDeaths
WHERE LOCATION='India'
order by date;

-- total cases v/s population
select location,date,population,total_cases,(total_cases*100.0)/population as infected_by_covid from dbo.CovidDeaths
where location='India' 
order by 2;

-- Country with highest covid infection 
-- Covid infection rate doesn't decrease as date passes by

select location,population,max(total_cases),max((total_cases*100.0)/population) as country_wise_infection_rate
from dbo.CovidDeaths 
where continent is not null 
group by location,population
order by max((total_cases*100.0)/population) desc;

-- Grouping by population along with location doesn't make any difference as the population is considered same 
-- To find the country with highest infection rate give top 1 and select from it

select location from
(select top 1 location,max((total_cases*100.0)/population) as country_wise_infection_rate
from dbo.CovidDeaths 
where continent is not null 
group by location,population
order by max((total_cases*100.0)/population) desc)a;
 
-- Country with highest death rate vs infected

select location,(maxi_2*100.0/maxi_1) as death_rate
from
(select location,max(total_cases) as maxi_1,max(total_deaths) as maxi_2 from dbo.CovidDeaths 
where continent is not null 
group by location )a
order by death_rate desc;

-- we are getting records of asia as well and we know that asia is a continent and not a country
-- so there's an issue there so let's try to see what's causing this

-- When we normally see the data what we can notice is where the location is Asia the
-- the continent is null
-- So let's extract all the locations where the continent is NULL

select distinct location from dbo.CovidDeaths 
where continent is NULL
order by location;

-- This is giving data like Low income,World etc which are not technically correct locations
-- So while performing analysis we should make sure we ignore them

-- Just add it to all queries
select location,(maxi_2*100.0/maxi_1) as death_rate
from
(select location,max(total_cases) as maxi_1,max(total_deaths) as maxi_2 from dbo.CovidDeaths
where continent is not null 
group by location )a
order by death_rate desc;

-- Country with highest death count
select location,max(total_deaths) as deaths from dbo.CovidDeaths
where continent is not null
group by location
order by deaths desc;

-- Continent with highest death count
-- Looks like wherever continent is null, the locations are filled with continent's data
-- Also there are irrelevant locations like low income, avg income etc
select location,max(total_deaths) as deaths
from dbo.CovidDeaths
where continent is NULL and location not like '%income%' and location<>'World'
group by location
order by location desc;

-- Oceania includes australia
-- Country with highest death count continent wise

SELECT continent,max(total_deaths) as deaths 
from dbo.CovidDeaths
where continent is not null
group by continent
order by deaths desc;

-- The above gives us the continent and max death count of the country within continent
-- Let's try to extract the country as well

WITH CTE1 AS 
(
    SELECT max(total_deaths) as deaths 
    from dbo.CovidDeaths
    where continent is not null
    group by continent
)
select continent,location,max(total_deaths) as deaths1
from dbo.CovidDeaths
group by continent,location
having max(total_deaths) in (select deaths from cte1)
order by continent;


-- Let's try to do the same using partition

select continent,location,max(total_deaths) as country_deaths from dbo.CovidDeaths
where continent is not NULL
group by continent,location ;
--Above gives us location wise death count

with cte1 as
(select continent,location,max(total_deaths) as country_deaths
from dbo.CovidDeaths
where continent is not NULL
group by continent,location)
select continent,location,country_deaths,conti_deaths
from
(select continent,location,country_deaths,
max(country_deaths) over(partition by continent) as conti_deaths
from cte1)a
where country_deaths=conti_deaths;

-- This gives country with highest death count continent wise



-- Continent wise death count but do it by grouping
-- Let's try to do the same but with the help of new deaths
select continent,sum(new_deaths) from dbo.CovidDeaths
where new_cases is not null and continent is not null 
group by continent
order by continent desc;

select location,sum(new_deaths) as deaths
from dbo.CovidDeaths
where continent is NULL and location not like '%income%' and location<>'World'
group by location
order by location desc;

-- both queries are giving almost the same result. First one using regular grouping
-- second one is the table itself.
-- the results are little different 




-- GLOBAL NUMBERS
-- Identify the new cases and new deaths date wise
select date,sum(new_cases) as total_cases,sum(new_deaths) as total_deaths
from dbo.CovidDeaths
where continent is not null
group by date
order by date;

select * from dbo.CovidDeaths where date<='2020-01-05' and continent is not null;

-- It's interesting to notice that the total cases reported until 5th is 2 but total deaths is 3 
-- There might be some error.

-- Identifying the death rate with respect to infected cases by date

select date,total_cases,total_deaths,case 
    when total_cases<>0 then (total_deaths*100.0)/total_cases 
    else 0
end as death_percentage from
(select date,sum(new_cases) as total_cases,sum(new_deaths) as total_deaths
from dbo.CovidDeaths
where continent is not null
group by date)a
order by date;

-- Identifying the death rate with respect to infected cases worldwide totally

select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,(sum(new_deaths)*100.0/sum(new_cases)) as worldwide_death_percentage from dbo.CovidDeaths
where continent is not null;


select * from dbo.CovidDeaths as death
inner join dbo.CovidVaccinations as vaccine
on death.date=vaccine.date and death.location=vaccine.location;

-- Identifying the total population and population that have been vaccinated country wise
-- Extract percentage as well
 
with cte1 as
(select death.location as dealoc,max(death.population) as population,sum(vaccine.new_vaccinations) as vaccination from dbo.CovidDeaths as death
inner join dbo.CovidVaccinations as vaccine
on death.date=vaccine.date and death.location=vaccine.location 
where death.continent is not null and vaccine.new_vaccinations is not null
group by death.location)
select dealoc,population,vaccination,(vaccination*100.0)/population as vaccinated_percentage from cte1
;

-- Be conscious to check if the attribute's value is not NULL when you are summing

-- Looking at population and new vaccinations day wise for each country
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations from dbo.CovidDeaths as death
inner join dbo.CovidVaccinations as vaccine
on death.date=vaccine.date and death.location=vaccine.location
where death.continent is not null;

-- We have new_vaccination per day. Let's do a rolling sum to get total vaccinations until that particular day
-- First let's try to add total_vaccinations for each row by location
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(vaccine.new_vaccinations) over (PARTITION by vaccine.LOCATION) as total_vaccinations
from dbo.CovidDeaths as death
inner join dbo.CovidVaccinations as vaccine
on death.date=vaccine.date and death.location=vaccine.location
where death.continent is not null 
order by location,date;

-- Now let's do rolling sum.
-- We will consider the above query along with that we will use ORDER BY INSIDE THE PARTITION
-- This helps us do rolling sum instead of normal sum.

select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(vaccine.new_vaccinations) over (PARTITION by vaccine.LOCATION order by vaccine.date) as total_vaccinations
from dbo.CovidDeaths as death
inner join dbo.CovidVaccinations as vaccine
on death.date=vaccine.date and death.location=vaccine.location
where death.continent is not null  ;  

-- Now we've seen the vaccination ,how it progressing day by day
-- That is vaccination count until certain day
-- Let's store it in temp tables

drop table if exists #vaccination_count_until_date
create table #vaccination_count_until_date
(
    continent varchar(50),
    LOCATion varchar(50),
    date datetime,
    population NUMERIC,
    new_vaccinations numeric,
    total_vaccinations numeric
)
insert into #vaccination_count_until_date
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(vaccine.new_vaccinations) over (PARTITION by vaccine.LOCATION order by vaccine.date) as total_vaccinations
from dbo.CovidDeaths as death
inner join dbo.CovidVaccinations as vaccine
on death.date=vaccine.date and death.location=vaccine.location
where death.continent is not null  ;  

select *,total_vaccinations*100.0/population as vaccination_percent_until_date from #vaccination_count_until_date
order by  location,date;

-- Creating views for data visualizations
create view vaccination_count_until_date as
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(vaccine.new_vaccinations) over (PARTITION by vaccine.LOCATION order by vaccine.date) as total_vaccinations
from dbo.CovidDeaths as death
inner join dbo.CovidVaccinations as vaccine
on death.date=vaccine.date and death.location=vaccine.location
where death.continent is not null  ; 

-- The difference between views and temp tables is that
-- temp tables scope is only to the session and not persistent
-- whereas views are persistent and the way they differ from table is that you need not specify the colum attributes and datatypes.
-- Views will just store a result 