--Book 3

--Chapter 1
/*Practice: Employees
Kristopher Blumfield an employee of Carnival has asked to be transferred to a different 
dealership location. She is currently at dealership 9. She would like to work at dealership 20. 
Update her record to reflect her transfer.*/

--employeeid = 9 FOR Kristopher Blumfield
SELECT *
FROM employees
ORDER BY last_name asc;

--ANSWER:
UPDATE dealershipemployees 
SET dealership_id = '20'
WHERE employee_id = 9

SELECT *
FROM dealershipemployees d 
WHERE employee_id = 9

/*Practice: Sales
A Sales associate needs to update a sales record because her customer wants to pay with a Mastercard 
instead of JCB. Update Customer, Ernestus Abeau Sales record which has an invoice number of 9086714242.*/


SELECT *
FROM sales s 
WHERE invoice_number = '9086714242'

--Answer: 
UPDATE sales 
SET payment_method = 'Mastercard'
WHERE invoice_number = '9086714242'

---------------------------------------------------------------------

--Chapter 2
--Practice - Employees
/*
1.  A sales employee at carnival creates a new sales record for a sale they are trying to close. The customer, 
last minute decided not to purchase the vehicle. Help delete the Sales record with an invoice number of '2436217483'.*/

SELECT *
FROM sales s 
WHERE invoice_number = '2436217483'

Answer:
DELETE FROM sales WHERE invoice_number = '2436217483'


/*2.  An employee was recently fired so we must delete them from our database. Delete the employee with employee_id of 35. 
What problems might you run into when deleting? How would you recommend fixing it?*/


SELECT *
FROM employees e 
WHERE employee_id = '35'

Answer:

--DELETE FROM employees WHERE employee_id  = '35'
--This errors out.

/*This could create problems with other tables where this is the fk.  Setting an "ON DELETE Set NULL" or cascade in the table creation, should 
 * then remove the employee id FROM other TABLES, but NOT remove the ROW entirely.*/

---------------------------------------------------------------------

--Chapter 3
--This chapter was just a review in stored proceedures.

---------------------------------------------------------------------

--Chapter 4
/*Stored Procedures Practice
Carnival would like to use stored procedures to process valuable business logic surrounding their business. 
Since they understand that procedures can hold many SQL statements related to a specific task they think it 
will work perfectly for their current problem.

Inventory Management
Selling a Vehicle
Carnival would like to create a stored procedure that handles the case of updating their vehicle inventory 
when a sale occurs. They plan to do this by flagging the vehicle as is_sold which is a field on the Vehicles 
table. When set to True this flag will indicate that the vehicle is no longer available in the inventory. 
Why not delete this vehicle? We don't want to delete it because it is attached to a sales record.

Returning a Vehicle
Carnival would also like to handle the case for when a car gets returned by a customer. When this occurs they 
must add the car back to the inventory and mark the original sales record as sale_returned = TRUE.

Carnival staff are required to do an oil change on the returned car before putting it back on the sales 
floor. In our stored procedure, we must also log the oil change within the OilChangeLogs table.

Goals
Use the story above and extract the requirements.
Build two stored procedures for Selling a car and Returning a car. Be ready to share with your class or 
instructor your result.*/

--1. Deleting a vehicle stored proceedure:

/*
 * CREATE PROCEDURE Removesoldvehicle
AS
BEGIN
    -- Delete row(s) from the vehicles table where is_sold is true
    DELETE FROM vehicles
    WHERE is_sold = 1; 
END;

To run the stored proceedure:

EXEC Removesoldvehicle;

After discussing this with the tutors and classmates, I see what they're trying to create is a stored procedure that marks the vehicle as sold
by simplying calling the store procedure and referencing the vehicle id that's getting updated.  That's completely different from what I
understood the question being asked.  I was debating WHY they wanted to have this stored procedure.  I believed the question was asking to remove
the vehicle information entirely, if the is_sold column was true.*/

--Below is an example of the procedure based on what they interepreted the question to be.

CREATE PROCEDURE vehicle_sold (IN vehicleid int)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE vehicles 
	SET is_sold = TRUE
	WHERE vehicle_id = vehicleid;
	
	COMMIT;
END
$$;

CALL vehicle_sold(1)

SELECT *
FROM vehicles v 
ORDER BY vehicle_id asc; 

UPDATE vehicles 
SET is_sold = FALSE 
WHERE vehicle_id = 1


--here is the update for when a car is returned:


/*2.  Need additional information here.  Because according to the requested stored proceedure above,
I would've deleted the vehicle details that were sold.  How would I bring this back?  Unless I created a new
table to store the sold vehicle details.  ORRR never delete the sold vehicles in the first place.  That's why
the column "is_sold" was created. */

CREATE PROCEDURE vehicle_returned (IN vehicleid int)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE vehicles 
	SET is_sold = false
	WHERE vehicle_id = vehicleid;
	
	UPDATE sales 
	SET sale_returned = TRUE 
	WHERE vehicle_id = vehicleid;

	COMMIT;
END
$$;

CALL vehicle_returned(1)


---------------------------------------------------------------------

--Chapter 5:

/*1.  Create a trigger for when a new Sales record is added, set the purchase date to 3 days from the current date.*/







/*2.  Create a trigger for updates to the Sales table. If the pickup date is on or before the purchase date, set the pickup date to 7 days after 
the purchase date. If the pickup date is after the purchase date but less than 7 days out from the purchase date, add 4 additional days to 
the pickup date.*/




 
