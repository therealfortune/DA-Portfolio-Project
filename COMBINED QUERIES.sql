-- CREATING AND UPDATING TABLES 

USE sales;
CREATE TABLE IF NOT EXISTS Sales
(
	Purchase_number 	INT PRIMARY KEY AUTO_INCREMENT,
    date_of_purchase 	DATE NOT NULL,
    customer_id 		INT,
    item_code 			INT
);

CREATE TABLE IF NOT EXISTS Customers
(
	customer_id 			INT PRIMARY KEY AUTO_INCREMENT,
    first_name 				VARCHAR(15),
    last_name 				VARCHAR(15),
    email_address 			VARCHAR(30) UNIQUE NOT NULL,
    number_of_complaints 	INT
);
CREATE TABLE IF NOT EXISTS Items (
    item_code 		INT,
    item 			VARCHAR(30),
    unit_price 		INT NOT NULL,
    company_id 		INT,
PRIMARY KEY (item_code)
);

CREATE TABLE IF NOT EXISTS Companies
(
	company_id 						INT PRIMARY KEY AUTO_INCREMENT,
    company_name 					VARCHAR(30) NOT NULL,
    headquaters_phone_number 		INT
);

ALTER TABLE Sales
ADD FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
ADD FOREIGN KEY(item_code) REFERENCES Items(item_code) ON DELETE CASCADE;

ALTER TABLE items
ADD FOREIGN KEY(company_id) 	REFERENCES companies(company_id) 	ON DELETE CASCADE;

ALTER TABLE Customers
CHANGE COLUMN number_of_complaints number_of_complaints 	INT DEFAULT 0;

ALTER TABLE Customers
ADD COLUMN gender 	ENUM('M','F') 	NOT NULL 	AFTER last_name;

ALTER TABLE companies
MODIFY company_name 	VARCHAR(255) NULL;

SELECT * FROM Customers;

INSERT INTO Customers (first_name, last_name, gender, email_address )
VALUES ('Fortune', 'Nwankwo' , 'M' , 'fortune.nwankwo@email.com');


-- UNION

CREATE TABLE emp_manager (
    employee_ID INT,
    department_code CHAR(4),
    manager_ID INT
);

INSERT INTO emp_manager(
	employee_ID,
    department_code,
    manager_ID
)
SELECT 
    A.*
FROM
    (SELECT 
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS department_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110022) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no < 10021
    GROUP BY e.emp_no
    ORDER BY e.emp_no
    LIMIT 20) AS A 
UNION SELECT 
    B.*
FROM
    (SELECT 
        e.emp_no AS employees_ID,
            MIN(dept_no) AS department_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110039) AS manager_ID
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no < 10041 AND e.emp_no > 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no
    LIMIT 20) AS B;
    
    
SELECT * FROM emp_manager;


-- STORED PROCEDURE

USE employees;

DROP PROCEDURE IF EXISTS select_employees;

DELIMITER $$
CREATE PROCEDURE select_employees()
BEGIN 
	SELECT * FROM employees
    LIMIT 1000;
END $$

DELIMITER ;

CALL employees.select_employees();

		-- STORED PROCEDURE WITH IN
USE employees;

DROP PROCEDURE IF EXISTS avg_emp_salaries;

DELIMITER $$
CREATE PROCEDURE avg_emp_salaries(IN p_emp_no INTEGER)
BEGIN
	SELECT 
    e.first_name, e.last_name, ROUND(AVG(s.salary), 2) AS Average_salary
FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.emp_no = p_emp_no;
END $$

DELIMITER ;

CALL avg_emp_salaries(23456);

		-- STORED PROCEDURE WITH BOTH IN AND OUT 
USE employees; 

DROP PROCEDURE IF EXISTS out_avg_emp_salary;

DELIMITER $$

CREATE PROCEDURE out_avg_emp_salary(in p_emp_no integer, out p_avg_salary decimal(10,2))
BEGIN
SELECT 
    AVG(s.salary)
INTO p_avg_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.emp_no = p_emp_no;
END$$

DELIMITER ;

		-- CALLING STORED PROCEDURE 
SET @v_avg_salary = 0 ;
CALL employees.out_avg_emp_salary(11310, @v_avg_salary);
SELECT @v_avg_salary;



-- SUBQUERY

INSERT INTO emp_manager(employee_ID, department_code, manager_ID)
VALUES
(110022, 'd001', 110039),
(110039, 'd001', 110022);

SELECT 
    *
FROM
    emp_manager
ORDER BY emp_manager.employee_ID;


SELECT 
    e1.*
FROM
    emp_manager e1
        JOIN
    emp_manager e2 ON e1.employee_ID = e2.manager_ID
WHERE
    e2.employee_ID IN (SELECT 
            e1.manager_ID
        FROM
            emp_manager);
            

-- VIEWS 

SELECT 
    *
FROM
    dept_emp;

SELECT 
    emp_no, from_date, to_date, COUNT(emp_no) AS num
FROM
    dept_emp
GROUP BY emp_no
HAVING COUNT(emp_no) > 1;

-- DROP VIEW IF EXISTS v_dept_emp_latest_date;
CREATE OR REPLACE VIEW v_dept_emp_latest_datecurrent_dept_emp AS 
SELECT emp_no , MAX(from_date) AS from_date, MAX(to_date) AS to_date
FROM dept_emp
GROUP BY emp_no;



-- CREATING FUNCTIONS 

USE employees;
DROP FUNCTION IF EXISTS f_emp_avg_salary;

DELIMITER $$
CREATE FUNCTION f_emp_avg_salary(p_emp_no INTEGER) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

DECLARE v_avg_salary DECIMAL(10,2);

SELECT 
    AVG(s.salary)
INTO v_avg_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE e.emp_no = p_emp_no;

RETURN v_avg_salary;
END$$
DELIMITER ;

SELECT F_EMP_AVG_SALARY(11310);


		-- CALLING FUNCTIONS 
        
SET @v_emp_no = 11310;

SELECT 
	e.emp_no,
	e.first_name,
    e.last_name,
    f_emp_avg_salary(@v_emp_no) AS Avg_salary
FROM 
	employees e
WHERE 
	e.emp_no = @v_emp_no;
    
    
    
-- USING VARIABLES 

SET @s_var1 = 3;
SELECT @s_var1;
SET GLOBAL max_connections = 1000;



-- USING INDEXES

SELECT 
    *
FROM
    employees
WHERE
    hire_date > '2000-01-01';
    
CREATE INDEX i_hire_date ON employees(hire_date);

-- SELECT ALL EMPLYEES BY THE NAME 'GEORGI FACELLO'

SELECT 
    *
FROM
    employees
WHERE
    first_name = 'Georgi'
        AND last_name = 'facello';

CREATE INDEX i_name ON employees(first_name, last_name);

CREATE INDEX i_employees ON employees(emp_no, birth_date, first_name, last_name, gender , hire_date);
SELECT 
    *
FROM
    employees;

SHOW INDEX FROM employees FROM employees;



-- USING CASE STATEMENTS 

SELECT 
    emp_no,
    first_name,
    last_name,
    CASE gender
        WHEN 'm' THEN 'Male'
        ELSE 'Female'
    END AS gender
FROM
    employees;
    
    
SELECT 
	e.emp_no, e.first_name, e.last_name,
CASE 
	WHEN dm.emp_no IS NOT NULL THEN  'Manager'
    ELSE 'Employee'
END AS is_manager
FROM employees e
LEFT JOIN dept_manager dm
	ON 	e.emp_no = dm.emp_no
WHERE e.emp_no > 109990;
    
    
    
    
    
    
    
    
    
    
    

    




            

