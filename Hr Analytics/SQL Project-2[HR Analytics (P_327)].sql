create schema HR_Analyst;

use hr_analyst;
desc hr_1;
desc hr_2;
show tables;
select * from hr_1;
select * from hr_2;

#KPI 1:- Average Attrition Rate for All Department
select Department,count(attrition) `Number of Attrition`from hr_1
where attrition = 'yes'
group by Department;
create view Dept_average as
select department, round(count(attrition)/(select count(employeenumber) from hr_1)*100,2)  as attrtion_rate
from hr_1
where attrition = "yes"
group by department;

select * from dept_average;

drop view Dept_average;


#KPI 2:- Average Hourly Rate for Male Research Scientist
select JobRole, format(avg(hourlyrate),2) as Average_HourlyRate,Gender
from hr_1
where upper(jobrole)= 'RESEARCH SCIENTIST' and upper(gender)='MALE'
group by jobrole,gender;

#KPI 3:-  AttritionRate VS MonthlyIncomeStats against department
create view Attrition_Vs_AvgMonthlyincome as
select h1.Department,
round(count(h1.Attrition)/(select count(h1.employeenumber) from hr_1 h1)*100,2) 'Attrition rate',
round(avg(h2.MonthlyIncome),2) avg_income from hr_1 h1 join hr_2 h2
on h1.EmployeeNumber = h2.EmployeeID
where Attrition = 'Yes'
group by h1.Department;

select * from Attrition_Vs_AvgMonthlyincome;

drop view Attrition_Vs_AvgMonthlyincome;

#KPI 4:- Average Working Years for Each Department 
select hr_1.Department, round(avg(hr_2.TotalWorkingYears),2) as Average_Working_Year
from hr_1 inner join hr_2
on hr_1.EmployeeNumber = hr_2.`EmployeeID`
group by hr_1.Department;

#KPI 5:- Job Role VS Work Life Balance
select a.JobRole,
sum(case when PerformanceRating = 1 then 1 else 0 end) as '1-Poor',
sum(case when PerformanceRating = 2 then 1 else 0 end) as '2-Average',
sum(case when PerformanceRating = 3 then 1 else 0 end) as '3-Good',
sum(case when PerformanceRating = 4 then 1 else 0 end) as '4-Excellent', 
format(avg(b.WorkLifeBalance),2) as Average_WorkLifeBalance
from hr_1 as a
inner join hr_2 as b on b.EmployeeID = a.EmployeeNumber
group by a.jobrole;

#KPI 6:- Attrition Rate Vs Year Since Last Promotion Relation Against Job Role 
select a.JobRole,concat(format(avg(a.attrition_rate)*100,2),'%') as Average_Attrition_Rate,
format(avg(b.YearsSinceLastPromotion),2) as Average_YearsSinceLastPromotion
from ( select JobRole,attrition,employeenumber,
case when attrition = 'yes' then 1
else 0
end as attrition_rate from hr_1) as a
inner join hr_2 as b on b.employeeid = a.employeenumber
group by a.JobRole;