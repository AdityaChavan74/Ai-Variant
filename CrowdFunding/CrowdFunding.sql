create database crowdfundingProject;
use crowdfundingProject;

DROP TABLE IF EXISTS calenderFile;
create table if not exists calenderFile(
   `created_atID` int primary key,
   `created_at` int,
   `Cretaed_At2` date,
   `Year` int,
   `Month_no` int,
   `Month_name` varchar(20),
   `Quarter` varchar(20),
   `YYYY-MMMM` varchar(20),
   `Weekday_no` int,
   `Weekday_name` varchar(30),
   `Financial_month` varchar(20),
   `Financial_quarter` varchar(20)
);

DROP TABLE IF EXISTS CategoryFile;
create table if not exists CategoryFile(
  id int primary key,
  name varchar(1000) 
);

DROP TABLE IF EXISTS Location;
create table if not exists Location(
  `id` int primary key,
  `displayable_name` varchar(250),
  `type` varchar(250),
  `state` varchar(250),
  `country` varchar(250)
);


DROP TABLE IF EXISTS creator;
create table if not exists creator(
  `id` int primary key,
  `First_name` varchar(500),
  `Last_name` varchar(500)
);

DROP TABLE IF EXISTS project;
create table if not exists project(
  `id` int primary key,
  `state` varchar(50),
  `name` varchar(250),
  `creator_id` int,
  `location_id` int,
  `category_id` int, 
  `created_atID` int,
  `suuccessfulDate` date,
  `LauncedDate` date,
  `goal` decimal,
  `usd_pledged` decimal,
  `static_usd_rate` decimal,
   `backers_count` int,
  foreign key(creator_id) references creator(id),
  foreign key(location_id) references Location(id),
  foreign key(category_id) references CategoryFile(id),
  foreign key(created_atID) references CalenderFile(created_atID)  
);

-- Import the File1. CSV file
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CalenderFile.csv' 
INTO TABLE calenderFile
FIELDS TERMINATED BY ','
lines terminated by '\n'
IGNORE 1 LINES;

select count(*) from calenderFile;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CategoryFile.csv' 
INTO TABLE CategoryFile
FIELDS TERMINATED BY ','
lines terminated by '\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/crowdfundingproject/location.csv' 
INTO TABLE location
FIELDS TERMINATED BY ','
Enclosed by '"'
lines terminated by '\n'
IGNORE 1 LINES;

ALTER TABLE location MODIFY displayable_name VARCHAR(255) CHARACTER SET utf8mb4;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/creator.csv' 
INTO TABLE creator
FIELDS TERMINATED BY ','
Enclosed by '"'
Escaped by '\\'
lines terminated by '\n'
IGNORE 1 LINES;
ALTER TABLE creator MODIFY COLUMN First_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/project.csv'
INTO TABLE project
FIELDS TERMINATED BY ','
Enclosed by '"'
Escaped by '\\'
lines terminated by '\n'
IGNORE 1 LINES;

-- Total Number of Projects based on outcome 
select state, concat(format(count(id)/1000,2),"K") as 'Total Project'  
from project
group by state;

-- Total Number of Projects based on Locations
SELECT l.displayable_name as 'Location', COUNT(p.id) as 'Total Project'
FROM Location l
JOIN project p ON l.id = p.location_id
GROUP BY l.displayable_name
ORDER BY `Total Project` DESC;

-- Total Number of Projects based on  Category

select c.name as 'CategoryFile', count(p.id) as 'Total Project'
from project p
join CategoryFile c
on c.id= p.category_id
group by c.name
order by `Total Project` desc;

-- Total Number of Projects created by Year , Quarter , Month

select c.Year, c.Quarter, c.Month_name , count(p.id) as "Total Project"
from CalenderFile c
join Project p
on c.created_atID = p.created_atID
group by c.Year,c.Quarter, c.Month_name
order by `Total Project` desc;


-- Successful Projects Amount Raised 
SELECT concat(format(SUM(usd_pledged)/1000000,2),'M') AS TotalAmountRaised
FROM project
WHERE state = 'successful';


-- Successful Projects Number of Backers
select concat(format(sum(backers_count)/1000,0),'K') as "No Of Backers"
from project
where state='successful';

-- Successful Projects Avg NUmber of Days for successful projects
SELECT AVG(DATEDIFF(suuccessfulDate, LauncedDate)) AS AvgDaysForSuccessfulProjects
FROM project
WHERE state = 'successful';

-- Top Successful Projects Based on Number of Backers
SELECT id, concat(format(sum(backers_count)/1000,2),'k') as "Number of backers"
FROM project
WHERE state = 'successful'
group by id
ORDER BY `Number of backers` DESC
LIMIT 10;


-- Top Successful Projects Based on Amount Raised.
SELECT id, concat(format(sum(usd_pledged)/1000,2),"K") as "Amount Raised"
FROM project
WHERE state = 'successful'
group by id
ORDER BY `Amount Raised` DESC
LIMIT 10;

-- Top Successful projects Percentage of Successful Projects overall

SELECT
    (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS 'Successful Project Percentage'
FROM
    project;

-- Top Successful Projects Percentage of Successful Projects  by Category

SELECT c.name, (SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS 'Successful Projects Percentage'
FROM categoryFile c
join project p
on c.id= p.category_id
GROUP BY c.name;

-- Top Successful projects Percentage of Successful Projects by Year , Month etc..

SELECT YEAR(suuccessfulDate) AS `Year`, MONTH(suuccessfulDate) AS `Month`,
    (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS `Successful Projects Percentage`
FROM project
GROUP BY `Year`, `Month`
ORDER BY `Successful Projects Percentage` desc;


-- Top Successful projects Percentage of Successful projects by Goal Range ( decide the range as per your need )

SELECT GoalRange,
    (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS 'Successful Projects Percentage'
FROM (
    SELECT
        CASE
            WHEN goal <= 1000 THEN '$0 - $1000'
            WHEN goal <= 5000 THEN '$1001 - $5000'
            WHEN goal <= 10000 THEN '$5001 - $10000'
            WHEN goal <= 20000 THEN '$10001 - $20000'
            ELSE 'Over $20000'
        END AS GoalRange,
        state
    FROM
        project
) AS GoalCategories
GROUP BY GoalRange
ORDER BY GoalRange;
