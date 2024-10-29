CREATE TABLE Employee(
	Education VARCHAR(50), -- Educational qualifications of employee.
	JoiningYear INT, -- Year where each employee joined.
	City VARCHAR(100), -- Location of employee.
	PaymentTier INT, -- Salary tier for employee.
	Age INT, -- Age of each employee.
	Gender VARCHAR(10), -- Employee's gender
	EverBenched VARCHAR(5), -- If an employee has ever been temporarily without assigned work.
	ExperienceInCurrentDomain INT, -- Number of years of experience employees have in current field.
	LeaveOrNot INT -- Target column
)@

-- Check head/first 5 data of dataset
SELECT * FROM EMPLOYEE FETCH FIRST 5 ROWS ONLY@

-- Check total rows
SELECT COUNT(*) AS TotalRows
FROM EMPLOYEE@

/* 
Delete first row of data, 
where first row is the original column of the data.
*/

DELETE FROM Employee WHERE EDUCATION='Education'@

-- Check if there are any missing values in the dataset.
SELECT
    COUNT(CASE WHEN EDUCATION IS NULL THEN 1 END) AS missing_EDUCATION,
    COUNT(CASE WHEN JOININGYEAR IS NULL THEN 1 END) AS missing_JOININGYEAR,
    COUNT(CASE WHEN CITY IS NULL THEN 1 END) AS missing_CITY,
    COUNT(CASE WHEN PAYMENTTIER IS NULL THEN 1 END) AS missing_PAYMENTTIER,
    COUNT(CASE WHEN AGE IS NULL THEN 1 END) AS missing_AGE,
    COUNT(CASE WHEN GENDER IS NULL THEN 1 END) AS missing_GENDER,
    COUNT(CASE WHEN EVERBENCHED IS NULL THEN 1 END) AS missing_EVERBENCHED,
    COUNT(CASE WHEN EXPERIENCEINCURRENTDOMAIN IS NULL THEN 1 END) AS missing_EXPERIENCEINCURRENTDOMAIN,
    COUNT(CASE WHEN LEAVEORNOT IS NULL THEN 1 END) AS missing_LEAVEORNOT  
FROM Employee@

-- Check if there are any duplicated data in the dataset.

SELECT Education, 
    JoiningYear, City, PaymentTier, 
    Age, Gender, EverBenched, 
    ExperienceInCurrentDomain, LeaveOrNot, COUNT(*) AS total
FROM EMPLOYEE

GROUP BY Education, 
    JoiningYear, City, PaymentTier, 
    Age, Gender, EverBenched, ExperienceInCurrentDomain, LeaveOrNot
HAVING COUNT(*) > 1@

-- Create a cleaned dataset from duplicated rows.
CREATE TABLE NEW_EMPLOYEE LIKE EMPLOYEE@
INSERT INTO NEW_EMPLOYEE(SELECT DISTINCT Education, 
    JoiningYear, City, PaymentTier, 
    Age, Gender, EverBenched, ExperienceInCurrentDomain, LeaveOrNot
FROM EMPLOYEE)@

-- Cleaned dataset total rows
SELECT COUNT(*) AS TOTAL_ROWS FROM NEW_EMPLOYEE@

-- Altering table name 
DROP TABLE EMPLOYEE@
RENAME TABLE NEW_EMPLOYEE TO EMPLOYEE@


-- City name analysis before deciding on encoding it
SELECT E.CITY, COUNT(*) AS TOTAL FROM EMPLOYEE E
GROUP BY E.CITY@

-- Education analysis before deciding on encoding it
SELECT E.EDUCATION, COUNT(*) AS TOTAL FROM EMPLOYEE E
GROUP BY E.EDUCATION@

-- Variable Encoding
/*
	The idea here is too create a duplicate column for the encoded data,
	why? because having the original categorical (pre-encoded) helps 
	user understand visualization better on charts
*/

-- Create new columns to store encoded variables in
ALTER TABLE EMPLOYEE ADD ENC_GENDER INTEGER@
ALTER TABLE EMPLOYEE ADD ENC_CITY INTEGER@
ALTER TABLE EMPLOYEE ADD ENC_EDUCATION INTEGER@
ALTER TABLE EMPLOYEE ADD ENC_EVERBENCHED INTEGER@


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

-- Create a new variable to exactly know how long has an employee worked for the company.
ALTER TABLE EMPLOYEE ADD YEARSINCOMPANY INTEGER@

UPDATE EMPLOYEE E
SET E.YEARSINCOMPANY = EXTRACT(YEAR FROM CURRENT DATE) - JOININGYEAR@

-- Check head/first 5 data of cleaned dataset
SELECT * FROM EMPLOYEE FETCH FIRST 5 ROWS ONLY@

-- Export preprocessed data back to csv using DB2 Command Windows

/*
db2 connect to DBName user Uname using Password
db2 "EXPORT TO 'C:/Users/cornelius/Downloads/cleaned_employee.csv' OF DEL 
SELECT 1 AS id, 
       CAST('Education' AS VARCHAR(50)) AS COL1, 
       CAST('JoiningYear' AS VARCHAR(50)) AS COL2, 
       CAST('City' AS VARCHAR(50)) AS COL3, 
       CAST('PaymentTier' AS VARCHAR(50)) AS COL4, 
       CAST('Age' AS VARCHAR(50)) AS COL5, 
       CAST('Gender' AS VARCHAR(50)) AS COL6, 
       CAST('EverBenched' AS VARCHAR(50)) AS COL7, 
       CAST('ExperienceInCurrentDomain' AS VARCHAR(50)) AS COL8, 
       CAST('LeaveOrNot' AS VARCHAR(50)) AS COL9, 
       CAST('ENC_Gender' AS VARCHAR(50)) AS COL10, 
       CAST('ENC_City' AS VARCHAR(50)) AS COL11, 
       CAST('ENC_Education' AS VARCHAR(50)) AS COL12, 
       CAST('ENC_EverBenched' AS VARCHAR(50)) AS COL13, 
       CAST('YearsInCompany' AS VARCHAR(50)) AS COL14 
FROM SYSIBM.SYSDUMMY1 
UNION ALL 
(SELECT 2 AS id, 
        CAST(Education AS VARCHAR(50)), 
        CAST(JoiningYear AS VARCHAR(50)), 
        CAST(City AS VARCHAR(50)), 
        CAST(PaymentTier AS VARCHAR(50)), 
        CAST(Age AS VARCHAR(50)), 
        CAST(Gender AS VARCHAR(50)), 
        CAST(EverBenched AS VARCHAR(50)), 
        CAST(ExperienceInCurrentDomain AS VARCHAR(50)), 
        CAST(LeaveOrNot AS VARCHAR(50)), 
        CAST(ENC_Gender AS VARCHAR(50)), 
        CAST(ENC_City AS VARCHAR(50)), 
        CAST(ENC_Education AS VARCHAR(50)), 
        CAST(ENC_EverBenched AS VARCHAR(50)), 
        CAST(YearsInCompany AS VARCHAR(50)) 
 FROM EMPLOYEE) 
ORDER BY id"
*/

-- Drop the unused table, after exporting the data back to csv
DROP TABLE Employee@