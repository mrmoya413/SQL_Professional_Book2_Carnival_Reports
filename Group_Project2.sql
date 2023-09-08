/*Creating Carnival Reports

As Carnival grows, we have been asked to help solve two issues:

1.  It has become more and more difficult for the accounting department to keep track of the all the records in the sales table and how much 
money came in from each sale.

2.  HR currently has an overflowing filing cabinet with files on each employee. There's additional files for each dealership. Sorting 
through all these files when new employees join Carnival and current employees leave is a process that needs to be streamlined. All 
employees that start at Carnival are required to work shifts with at least two dealerships.

--------------------------------
Goals
*Using CREATE to add new tables
*Using triggers
*Using stored procedures
*Using transactions

-------------------------------- */
/*Practice
Provide a way for the accounting team to track all financial transactions by creating a new table called Accounts Receivable. The table 
should have the following columns: credit_amount, debit_amount, date_received as well as a PK and a FK to associate a sale with each 
transaction.*/

DROP TABLE Accounts_Receivable;

CREATE TABLE Accounts_Receivable (
    AR_ID SERIAL PRIMARY KEY,
    credit_amount NUMERIC(15,2),
    debit_amount NUMERIC(15,2),
    date_received DATE DEFAULT CURRENT_DATE,
    sale_id INT,
    FOREIGN KEY (sale_id) REFERENCES Sales(sale_id)
);

SELECT *
FROM accounts_receivable 

SELECT *
FROM sales s 
ORDER BY sale_id asc;

--testing the data
BEGIN;

	INSERT INTO Accounts_Receivable(credit_amount, sale_id)
	VALUES ('9696','1');

COMMIT;

--removing it
--DELETE FROM accounts_receivable WHERE sale_id = 1


--Ok we've created a table with that information.



/*1.  Set up a trigger on the Sales table. When a new row is added, add a new record to the Accounts Receivable table with the deposit as 
credit_amount, the timestamp as date_received and the appropriate sale_id.*/

SELECT *
FROM sales 


CREATE OR REPLACE FUNCTION new_sale()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN 
	INSERT INTO Accounts_Receivable (credit_amount, sale_id)
	VALUES (NEW.deposit, NEW.sale_id);
	RETURN NEW;
END;
$$


CREATE OR REPLACE TRIGGER sales_insert_trigger
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION new_sale();


INSERT INTO sales (sales_type_id, vehicle_id, employee_id, customer_id,dealership_id, price, deposit, purchase_date, pickup_date, 
invoice_number, payment_method, sale_returned)
VALUES (2, 69, 34, 44, 4, 23442, 3224, current_date, current_date , '2232323233', 'mastercard', false);

SELECT *
FROM accounts_receivable ar 

--DONE!!


/*2. Set up a trigger on the Sales table for when the sale_returned flag is updated. Add a new row to the Accounts Receivable table with 
the deposit as debit_amount, the timestamp as date_received, etc.*/


CREATE OR REPLACE FUNCTION sale_return()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN 
	UPDATE accounts_receivable 
	SET debit_amount = sales.deposit
	FROM sales
	WHERE accounts_receivable.sale_id = sales.sale_id;
	RETURN NEW; 
END
$$
;

CREATE OR REPLACE TRIGGER returning_sale
AFTER UPDATE  
ON sales
FOR EACH ROW
EXECUTE FUNCTION sale_return();

UPDATE sales 
SET sale_returned = TRUE 
WHERE sale_id = '5003'

SELECT * FROM accounts_receivable ar 


--------------------------------
/*Practice
Help out HR fast track turnover by providing the following:

1. Create a stored procedure with a transaction to handle hiring a new employee. Add a new record for the employee in the Employees table 
and add a record to the Dealershipemployees table for the two dealerships the new employee will start at.*/


--this was a failed attempt--
/*CREATE OR REPLACE PROCEDURE add_employee_to_dealerships(
	IN first_name varchar(50),
	IN last_name varchar(50),
	IN email_address varchar(100),
	IN phone varchar(20),
	IN employee_type_id INT,
	IN dealership_id INT
	)
LANGUAGE plpgsql
AS $$
DECLARE
    dealership_id1 INT;
    dealership_id2 INT;
BEGIN
    -- Generate two random dealership IDs
    SELECT dealership_id FROM dealerships ORDER BY RANDOM() LIMIT 2 INTO dealership_id1, dealership_id2;

    -- Start a transaction
    BEGIN

    -- Insert the employee into the "employees" table
    INSERT INTO employees (first_name, last_name, email_address, phone, employee_type_id)
    VALUES (first_name, last_name, email_address, phone, employee_type_id)
    RETURNING employee_id;

    -- Insert the employee into the "dealershipemployees" table for the first dealership
    INSERT INTO dealershipemployees (dealership_id, employee_id)
    VALUES (dealership_id1, employee_id);

    -- Insert the employee into the "dealershipemployees" table for the second dealership
    INSERT INTO dealershipemployees (dealership_id, employee_id)
    VALUES (dealership_id2, employee_id);

    -- Commit the transaction
    COMMIT;
END;
$$*/

SELECT *
FROM employees 


CREATE OR REPLACE PROCEDURE add_employee_to_dealerships()
LANGUAGE plpgsql
AS $$
DECLARE 
  NewEmployeeID integer;
BEGIN
	INSERT INTO employees (first_name, last_name, email_address, phone, employee_type_id)
    VALUES ('John', 'Doe', 'johndoe@example.com', '123-456-7890', 1)
    	RETURNING employee_id INTO NewEmployeeID;

COMMIT;
	
	INSERT INTO dealershipemployees (dealership_id, employee_id)
	VALUES (1, NewEmployeeID),
			(2, NewEmployeeID);
COMMIT;
	
END;
$$;

CALL add_employee_to_dealerships();


SELECT * FROM dealershipemployees d  ORDER BY dealership_employee_id DESC;
SELECT * FROM employees ORDER BY employee_id DESC; 


/*2. Create a stored procedure with a transaction to handle an employee leaving. The employee record is removed and all records associating 
the employee with dealerships must also be removed.*/



CREATE OR REPLACE PROCEDURE remove_employee(IN EmployeeId INT)
LANGUAGE plpgsql
AS $$
  
BEGIN
    DELETE FROM dealershipemployees de WHERE de.employee_id = EmployeeId;
   
    DELETE FROM accounts_receivable WHERE sale_id IN (SELECT sale_id FROM sales WHERE employee_id = EmployeeId);

    DELETE FROM sales s WHERE s.employee_id = EmployeeId;
    
    DELETE FROM employees e WHERE e.employee_id = EmployeeId;
    
COMMIT;

END;
$$;

--1010 employee_id 


--CALL remove_employee(1010); -- Replace 1010 with the employee_id you want to remove

SELECT * FROM dealershipemployees d ORDER BY dealership_employee_id DESC;
SELECT * FROM employees e ORDER BY e.employee_id DESC;
SELECT * FROM sales s ORDER BY s.sale_id DESC;


---COMPLETE!!!!
