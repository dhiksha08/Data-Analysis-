create database students;
use students;

create table details
(
    roll integer,
    subjects varchar(200),
    marks decimal(10,2), -- No of digits before decimal place can be max of 10 and after decimal place is 2
    full_marks int eger,
    address_id varchar(200)
    primary key (roll)
);

select * from details;

insert into details(roll,subjects,marks,full_marks,address_id) VALUES
(1,'Maths',70,100,'A1'),
(2,'Science',80,100,'A2'),
(3,'Maths',80,100,'A3'),
(4,'Social',78,100,'A4'),
(5,'English',90.6,100,'A1');

select * from details;

-- Adding a new column
alter table details add phone_number1 bigint;
-- Dropping a column
alter table details drop column full_marks;

-- Truncating the table (clearing)
truncate table details;

select * from details;

-- Dropping a table
drop table details;

-- Updating a student's phone number.
insert into details (roll,subjects,marks,address_id,phone_number) VALUES
(1,'Maths',70,'A1',909999999),
(2,'Science',80,'A2',9090909090);

select * from details;

update details set phone_number=9600123456 where roll=1;

select * from details;

-- Student leaving
delete from details where roll=2;

-- Adding constraint PK . First make the column not null and then add constraint primary key
ALTER TABLE details
ALTER COLUMN roll INTEGER NOT NULL;

alter table details add constraint pk primary key(roll);
alter table details drop constraint pk;

-- Auto Increment
drop table details; 
 

create table details
(
    roll integer identity(1,1) not null,
    subjects varchar(200),
    marks decimal(10,2), -- No of digits before decimal place can be max of 10 and after decimal place is 2
    full_marks integer,
    address_id varchar(200)
    primary key (roll)
);

insert into details(subjects,marks,full_marks,address_id) VALUES
('Maths',70,100,'A1'),
('Science',80,100,'A2'),
('Maths',80,100,'A3'),
('Social',78,100,'A4'),
('English',90.6,100,'A1');

select * from details;
insert into details values(8,'English',90.6,100,'A1');

SET IDENTITY_INSERT details ON;

insert into details(roll,subjects,marks,full_marks,address_id) values(8,'English',90.6,100,'A1');

SELECT * from details;

SET IDENTITY_INSERT details OFF;

insert into details(subjects,marks,full_marks,address_id) values ('English',90.6,100,'A1');

SELECT * from details;

-- Composite key (Combination of two or more keys)
-- primary key (student_name,contact_no)

-- SQL Operators

SELECT * FROM DETAILS WHERE SUBJECTS ='Maths';
select * from details where marks>=87;
select * from details where marks<=87;
select * from details where subjects!='Maths';
select * from details where subjects='Maths' and marks>=75;
select * from details where subjects='Maths' or marks>=75;
select * from details where not(marks)=70;
select * from details where marks!=70;
select * from details where marks between 80 and 90.6;

insert into details (subjects,marks,address_id) values ('Play',87,'A8');
select * from details where full_marks is null; 
select * from details where full_marks is not null; 
select distinct subjects from details;
select avg(marks) as Average_Marks from details;
select sum(marks) as Total_marks from details;
select count(marks) as Total_count from details;
select min(marks) as minimum_marks from details;
select max(marks) as maximum_marks from details;

select * from details where subjects like 'Ma%' or subjects like '%ce';
select * from details where subjects like 'Ma_';
select * from details where subjects like 'M%s';
select * from details where subjects not like 'M%s';

select * from details where subjects like '%ia%';

select Top 3 * from details order by marks desc;
select Top 3 * from details order by marks asc;

select subjects ,len(subjects) as name_length from details;
select charindex('i','Dhikshitha');
select charindex('it','Dhikshitha');
select subjects, charindex('i',subjects) from details;
select concat(roll,' ',subjects,' ',marks) as concatenated_result from details;
select subjects,REPLACE(subjects,'at','cool') as replaced from details;
select subjects,reverse(subjects) as subjects_reversed from details;

select subjects,substring(subjects,1,3),left(subjects,3) as first3 from details;
select subjects,substring(subjects,2,3) as second2 from details;

insert into details (subjects,marks,address_id) values (' Play',87,'A8');
select subjects ,len(subjects) as name_length from details;
select subjects ,len(subjects) as name_length,trim(subjects) as trimmed,len(trim(subjects)) as length_trimmed from details;

select subjects ,len(subjects) as name_length,ltrim(subjects) as left_trimmed,len(ltrim(subjects)) as left_length_trimmed ,
rtrim(subjects) as trimmed,len(rtrim(subjects)) as right_length_trimmed from details;

select subjects,upper(subjects) as upper_,lower(subjects) as lower_ from details;

select concat(roll,' ',subjects,' ',marks) as concatenated_result from details;
select concat_ws(',',roll,subjects,marks) as concatenated_result from details;

select concatenated_result,lower(concatenated_result) from (select concat(roll,' ',subjects,' ',marks) as concatenated_result from details)a;
select lower(concat(roll,' ',subjects,' ',marks) )as concatenated_result from details;

-- DATE TIME FUNCTION

select getdate(),day(getdate()) as day,month(getdate()) as month,year(getdate()) as year,cast(getdate() as time) as time1;

select datepart(day,getdate()) as year1;

select getdate() ,dateadd(year,1,getdate()) as advanced_date ;
select getdate() ,dateadd(year,-2,getdate()) as advanced_date ;

select datediff(year,getdate(),dateadd(year,2,getdate()));
select datediff(year,getdate(),getdate()-999);
select getdate()+99;

select round(marks,0) as marks from details;
select power(marks,1.1) as marks from details;
select ceiling(marks) as marks from details;
select floor(marks) as marks from details;

use master;
select * from populations;
select state,sum(population) as total_population,sum(Area_km2) as total_area from populations group by state having sum(Area_km2)  >100000 order by state;
select state,count(District),max(population),avg(population),min(population) from populations group by state;

select state,string_agg(district,',') from populations group by state;


/*select details.name,details.marks,details1.address from details left join details1 on details.name=details1.name;
select details.name,details.marks,details1.address from details right join details1 on details.name=details1.name;
-- in the above command only student names of details table will come , but since we are performing right join
-- we need the result from details1 so spec ify details1
-- we need to be mindful about it when we perform inner join,full outer join etc
select details1.name,details.marks,details1.address from details right join details1 on details.name=details1.name;
-- here we have performed right join with details1.name
select details.name,details.marks,details1.address from details inner join details1 on details.name=details1.name;
select details.name,details.marks,details1.address from details full outer join details1 on details.name=details1.name;

-- in cross join no concept of common column
select details.name,details.marks,details1.address from details cross join details1; */



--select name from sys.databases;
--select table_name from INFORMATION_SCHEMA.TABLES where TABLE_TYPE='BASE TABLE';

CREATE DATABASE EMPLOYEE;
USE EMPLOYEE;

CREATE TABLE EmployeeDemographics
(
    EmployeeID int,
    Firstname varchar(50),
    Lastname varchar(50),
    Age INT,
    Gender varchar(50)
);

create table EmployeeSalary
(
    EmployeeID int,
    jobtitle varchar(50),
    salary INT
);

select table_name from INFORMATION_SCHEMA.TABLES where TABLE_NAME='base_table'; 

insert into EmployeeDemographics VALUES
(1001,'Jim','Halbort',30,'Male');


select * from EmployeeDemographics;
Insert into EmployeeDemographics VALUES
(1002, 'Pam', 'Beasley', 30, 'Female'),
(1003, 'Dwight', 'Schrute', 29, 'Male'),
(1004, 'Angela', 'Martin', 31, 'Female'),
(1005, 'Toby', 'Flenderson', 32, 'Male'),
(1006, 'Michael', 'Scott', 35, 'Male'),
(1007, 'Meredith', 'Palmer', 32, 'Female'),
(1008, 'Stanley', 'Hudson', 38, 'Male'),
(1009, 'Kevin', 'Malone', 31, 'Male');

INSERT INTO EmployeeSalary VALUES
(1001,'Salesman',45000);
select * from EmployeeSalary;

Insert Into EmployeeSalary VALUES
(1002, 'Receptionist', 36000),
(1003, 'Salesman', 63000),
(1004, 'Accountant', 47000),
(1005, 'HR', 50000),
(1006, 'Regional Manager', 65000),
(1007, 'Supplier Relations', 41000), (1008, 'Salesman', 48000),
(1009, 'Accountant' , 42000);


select Top 5 CONCAT(Firstname,' ',Lastname) as FullName from EmployeeDemographics;
select distinct jobtitle from EmployeeSalary;

select max(salary),min(salary),avg(salary) from EmployeeSalary;

-- Get info from any database without using 'USE'
select * from students.dbo.details;

select * from EmployeeDemographics where Firstname='Jim';
select * from EmployeeDemographics where Firstname<>'Jim';

select * from EmployeeDemographics where age<=32;

select * from EmployeeDemographics where age<=32 or Gender='Male';

select * from EmployeeDemographics where Lastname NOT like 'S%O%';

SELECT * FROM EmployeeDemographics WHERE Firstname IS NOT NULL;  

SELECT * FROM EmployeeDemographics WHERE Firstname IN ('JIM','MICHAEL');

  
-- count of male and female employees in organization
  
select gender,round(count(gender)*100.0/(select count(*) from EmployeeDemographics),2) as count1 from EmployeeDemographics group by gender;
 
select gender,count(gender) as count1 from EmployeeDemographics where age >31 group by gender order by count1 desc;

select * from EmployeeDemographics order by 3 asc,4 desc;
 

select top 1 EmployeeDemographics.EmployeeID,Firstname,Lastname,salary from EmployeeDemographics inner join EmployeeSalary on EmployeeDemographics.EmployeeID=EmployeeSalary.EmployeeID 
where Firstname<>'Michael'
order by salary desc;

select avg(salary) from EmployeeSalary where jobtitle='Salesman';

select avg(salary) from EmployeeDemographics inner join EmployeeSalary on EmployeeDemographics.EmployeeID=EmployeeSalary.EmployeeID where jobtitle='Salesman';

SELECT * from EmployeeDemographics
UNION all
SELECT * from EmployeeDemographics;

SELECT EmployeeID, Firstname,Age from EmployeeDemographics
UNION
select employeeID,JOBTITLE,SALARY FROM EmployeeSalary;

/* Case statement helps us to specify conditions and gives
us a way to return different values based on the conditions*/

select firstname,lastname,age from EmployeeDemographics
where age is not null order by age;

select firstname,lastname,age ,
case 
    when age>30 then 'Old'
    when age between 27 and 31 then 'Young'
    else 'Baby'
end
from EmployeeDemographics
where age is not null order by age;
 
select Firstname,Lastname,jobtitle,salary,
case
    when jobtitle='Salesman'  then salary+salary*0.1
    when jobtitle='Accountant' then salary+salary*0.05
    when jobtitle='HR' then salary+salary*0.0001
    else salary+salary*0.03
end as revisedsalary
from EmployeeDemographics inner join EmployeeSalary
on EmployeeDemographics.EmployeeID=EmployeeSalary.EmployeeID;

-- Having clause 
-- Used to perfrom filtering on the result of aggregation result
-- which we get from group by clause
-- say you want to get all the jobtitle where more than 1 person works.
select jobtitle,avg(salary) as avg_salary from EmployeeSalary
group by jobtitle
having avg(salary)>45000
order by avg(salary);

update EmployeeDemographics set EmployeeID=1012,age=34,gender='Female' where Firstname='Holly' and Lastname='Flax';
SELECT * from EmployeeDemographics;

delete from EmployeeDemographics where EmployeeID=1005;
select * from EmployeeDemographics;

select demo.firstname+' '+Lastname as full_name from EmployeeDemographics as demo;

select demo.firstname+' '+demo.lastname from EmployeeDemographics as demo;

select demo.employeeID,sal.salary from EmployeeDemographics as demo 
inner join EmployeeSalary as sal
on demo.EmployeeID=sal.EmployeeID;

--Partition by
-- Group by statement reduces the number of rows in the output by performing aggregation such as sum,count,max,avg etc for each group
-- whereas partition by divides the result into partitions and doesn't reduce the number of rows.

SELECT firstname,lastname,gender,salary ,
count(Gender) over (PARTITION by gender) as total_gender,
avg(salary) over (partition by gender) as avg_salary
from EmployeeDemographics as demo
inner join EmployeeSalary as sal 
on demo.EmployeeID=sal.EmployeeID;

/*  CTEs Common Table Expressions 
    Used to manipulate complex sub queries data.
    Scope is only to that query
*/
 
WITH CTE_EMPLOYEE AS (
SELECT firstname,lastname,gender,salary ,
count(Gender) over (PARTITION by gender) as total_gender,
avg(salary) over (partition by gender) as avg_salary
from EmployeeDemographics as demo
inner join EmployeeSalary as sal 
on demo.EmployeeID=sal.EmployeeID)
select Firstname,avg_salary from CTE_EMPLOYEE;

-- Temp tables are temporary tables
-- You can make use of temp table multiple times unlike subqueries and CTEs
 
CREATE TABLE #TEMP_EMPLOYEE
(
    EmployeeID int,
    JOBTITLE VARCHAR(50),
    SALARY INT
);

SELECT * FROM #TEMP_EMPLOYEE;
INSERT INTO #TEMP_EMPLOYEE VALUES
(1001,'HR',45000);

INSERT INTO #TEMP_EMPLOYEE 
SELECT * FROM EmployeeSalary;

CREATE TABLE #TEMP_EMPLOYEE2
(
    Jobtitle VARCHAR(50),
    employeesperjob int,
    avgage int,
    avgsal int
)

insert into #TEMP_EMPLOYEE2 
select sal.jobtitle,count(jobtitle),avg(salary),avg(age) from EmployeeDemographics as demo inner join EmployeeSalary as sal 
on demo.EmployeeID=sal.EmployeeID group by jobtitle;

select * from #TEMP_EMPLOYEE2;


/*
A stored procedure is a list of SQL statements that has been created and stored in the database
It can accept parameters. It will reduce network traffic and increase performance.
If we modify the stored procedure, everyone using that will get an update
*/

CREATE PROCEDURE TEST
AS
SELECT * FROM EmployeeDemographics;

EXEC TEST;


drop procedure TEMP_EMPLOYEE1;

CREATE PROCEDURE TEMP_EMPLOYEE1
@Jobtitle VARCHAR(50)
AS
BEGIN
CREATE TABLE #TEMP_EMPLOYEE2
(
    Jobtitle VARCHAR(50),
    employeesperjob int,
    avgage int,
    avgsal int
)

insert into #TEMP_EMPLOYEE2 
select sal.jobtitle,count(jobtitle),avg(salary),avg(age) from EmployeeDemographics as demo inner join EmployeeSalary as sal 
on demo.EmployeeID=sal.EmployeeID where jobtitle=@Jobtitle group by jobtitle;
SELECT * FROM #TEMP_EMPLOYEE2;
END;

EXEC TEMP_EMPLOYEE1 @Jobtitle='Salesman';

SELECT EmployeeID,salary,(select avg(salary) from EmployeeSalary) from EmployeeSalary;

select EmployeeID,salary,avg(Salary) over () as avgsal from EmployeeSalary;


select * from 
( select EmployeeID,salary,avg(Salary) over () as avgsal from EmployeeSalary)a;

select * from EmployeeSalary
where EmployeeID in 
(select EmployeeID from  EmployeeDemographics where age>30)