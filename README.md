# Employee-Leave-Pattern-Analysis 

#### Dataset source : https://www.kaggle.com/datasets/tawfikelmetwally/employee-dataset

## Tools utilized : 
- IBM DB2
- IBM Data Studio Client
- Tableau

## Objective
<p align="justify">The primary objective is to analyze employee behavior and retention patterns using preprocessed data stored in SQL DB2 and visualized through Tableau. This project aims to uncover insights related to employee satisfaction, performance evaluations, and turnover trends. These insights will support organizations in developing data-driven strategies for improving employee engagement, optimizing workforce management, and minimizing attrition rates.</p>

## Preprocessing Data Using SQL

#### Drop duplicated data rows 
```
CREATE TABLE NEW_EMPLOYEE LIKE EMPLOYEE@
INSERT INTO NEW_EMPLOYEE(SELECT DISTINCT Education, 
    JoiningYear, City, PaymentTier, 
    Age, Gender, EverBenched, ExperienceInCurrentDomain, LeaveOrNot
FROM EMPLOYEE)@
```

<p align="justify">These line of SQL code was made to drop duplicated rows of data, in total of 1,889 duplicate rows, which can be proved from the code below.</p>

```
SELECT Education, 
    JoiningYear, City, PaymentTier, 
    Age, Gender, EverBenched, 
    ExperienceInCurrentDomain, LeaveOrNot, COUNT(*) AS total
FROM EMPLOYEE

GROUP BY Education, 
    JoiningYear, City, PaymentTier, 
    Age, Gender, EverBenched, ExperienceInCurrentDomain, LeaveOrNot
HAVING COUNT(*) > 1@
```

#### Encoding categorical data
```
-- GENDER var
UPDATE EMPLOYEE
SET ENC_GENDER = CASE
	WHEN GENDER = 'Male' THEN 1
	WHEN GENDER = 'Female' THEN 0
END@

-- CITY var
UPDATE EMPLOYEE
SET ENC_CITY = CASE
	WHEN CITY = 'Bangalore' THEN 0
	WHEN CITY = 'New Delhi' THEN 1
	WHEN CITY = 'Pune' THEN 2
END@

-- EDUCATION var
UPDATE EMPLOYEE
SET ENC_EDUCATION = CASE
	WHEN EDUCATION = 'Bachelors' THEN 0
	WHEN EDUCATION = 'Masters' THEN 1
	WHEN EDUCATION = 'PHD' THEN 2
END@

-- EVERBENCHED var
UPDATE EMPLOYEE 
SET ENC_EVERBENCHED = CASE
	WHEN EVERBENCHED = 'No' THEN 0
	WHEN EVERBENCHED = 'Yes' THEN 1
END@
```
Encoding categorical variables to numerics, to help analytics process or fitting data into predicting models.

#### Create a new variable to help analysis process
```
ALTER TABLE EMPLOYEE ADD YEARSINCOMPANY INTEGER@

UPDATE EMPLOYEE E
SET E.YEARSINCOMPANY = EXTRACT(YEAR FROM CURRENT DATE) - JOININGYEAR@
```
<p align="justify">Created a new variable Years In Company to help analyticals process through knowing how long has an employee worked for the company.</p>

## Tableau Dashboard Analysis
#### Dashboard link : https://public.tableau.com/app/profile/cornelius.karel.halim/viz/Employee_Dashboard_17302271154610/Dashboard1?publish=yes


