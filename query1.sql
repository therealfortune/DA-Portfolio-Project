CREATE TABLE Employee(
	emp_id INT PRIMARY KEY,
    First_name VARCHAR(25),
    Last_name VARCHAR(25),
    Birth_day DATE,
    Sex VARCHAR(1),
    Salary INT,
    Super_id INT, 
    Branch_id  INT
);
SELECT * FROM Employee;

CREATE TABLE Branch (
	PRIMARY KEY(Branch_id),
	Branch_id INT,
    Branch_name VARCHAR(25),
    mgr_id INT,
	mgr_start_date DATE,
    FOREIGN KEY(mgr_id) REFERENCES Employee(Emp_id) ON DELETE SET NULL
);
SELECT * FROM branch;

ALTER TABLE Employee
ADD FOREIGN KEY(Branch_id)
REFERENCES Branch(Branch_id)
ON DELETE SET NULL;

ALTER TABLE Employee
ADD FOREIGN KEY(Super_id) 
REFERENCES Employee(Emp_id)
ON DELETE SET NULL;

CREATE TABLE Client(
	Client_id INT PRIMARY KEY,
    Client_name VARCHAR(25),
    Branch_id INT,
    FOREIGN KEY(Branch_id) REFERENCES Branch(Branch_id) ON DELETE SET NULL
);

CREATE TABLE Works_With(
	Emp_id INT,
    Client_id INT,
    Total_sales INT,
    PRIMARY KEY(Emp_id, Client_id),
    FOREIGN KEY(Emp_id) REFERENCES Employee(Emp_id) ON DELETE CASCADE,
    FOREIGN KEY(Client_id) REFERENCES Client(Client_id) ON DELETE CASCADE
);

CREATE TABLE Branch_supllier(
	Branch_id INT,
    Supplier_name VARCHAR(40),
    Supplier_type VARCHAR(40),
    PRIMARY KEY (Branch_id, Supplier_name),
    FOREIGN KEY(Branch_id) REFERENCES Branch(Branch_id)
);







