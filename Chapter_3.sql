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


CREATE FUNCTION set_pickup_date() 
  RETURNS TRIGGER 
  LANGUAGE PlPGSQL
AS $$
BEGIN
  -- trigger function logic
  UPDATE sales
  SET pickup_date = NEW.purchase_date + integer '3'
  WHERE sales.sale_id = NEW.sale_id;
  
  RETURN NULL;
END;
$$

CREATE TRIGGER new_sale_made
  AFTER INSERT
  ON sales
  FOR EACH ROW
  EXECUTE PROCEDURE set_pickup_date();


/*2.  Create a trigger for updates to the Sales table. If the pickup date is on or before the purchase date, set the pickup date to 7 days after 
the purchase date. If the pickup date is after the purchase date but less than 7 days out from the purchase date, add 4 additional days to 
the pickup date.*/


/*This is a an attempt to creat a function and trigger for the dates requested above.  I'm not
 * having much success unfortunately.. 
 */


CREATE FUNCTION AdjustPickupDate(purchase_date DATE, pickup_date DATE) 
	RETURNS DATE 
	AS $$
	BEGIN
    	IF pickup_date <= purchase_date THEN
        RETURN purchase_date + INTERVAL '7 days';
    ELSE
        RETURN pickup_date + INTERVAL '4 days';
    END IF;
END;
$$ LANGUAGE plpgsql;


--I'M GETTING AN ERROR HERE.  LETS CIRCLE BACK TO THIS.

CREATE TRIGGER UpdatePickupDateTrigger
BEFORE INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION AdjustPickupDate(purchase_date);

---------------------------------------------------------------------

--Chapter 6:

/*1. Because Carnival is a single company, we want to ensure that there is consistency in the data 
 provided to the user. Each dealership has it's own website but we want to make sure the website 
 URL are consistent and easy to remember. Therefore, any time a new dealership is added or an existing 
 dealership is updated, we want to ensure that the website URL has the following format: 
 http://www.carnivalcars.com/{name of the dealership with underscores separating words}.*/

CREATE FUNCTION UpdateWebsiteURL(dealership_name VARCHAR(50)) RETURNS VARCHAR(1000) AS $$
BEGIN
    RETURN 'http://www.carnivalcars.com/' || REPLACE(dealership_name, ' ', '_');
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER UpdateWebsiteTrigger
	BEFORE INSERT OR UPDATE 
	ON dealerships
	FOR EACH ROW
	EXECUTE FUNCTION UpdateWebsiteURL();

--I KEEP GETTING AN ERROR WHEN TRYING TO EXECUTE THE TRIGGER.

/*2. If a phone number is not provided for a new dealership, set the phone number to the default 
 customer care number 777-111-0305.*/

CREATE OR REPLACE FUNCTION SetDefaultPhoneNumber()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.phone IS NULL OR NEW.phone = '' THEN
        NEW.phone = '777-111-0305';
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER SetDefaultPhoneNumberTrigger
BEFORE INSERT ON dealerships
FOR EACH ROW
EXECUTE FUNCTION SetDefaultPhoneNumber();

-- Insert a dealership with a phone number
INSERT INTO dealerships (business_name, phone, city, state, website, tax_id)
VALUES
  ('Sample Dealership 1', '123-456-7890', 'Sample City 1', 'Sample State 1', 'http://www.sample1.com', 'ABC123');

-- Insert a dealership without a phone number
INSERT INTO dealerships (business_name, city, state, website, tax_id)
VALUES
  ('Sample Dealership 2', 'Sample City 2', 'Sample State 2', 'http://www.sample2.com', 'XYZ456');

SELECT *
FROM dealerships


/*3. For accounting purposes, the name of the state needs to be part of the dealership's tax id. For 
example, if the tax id provided is bv-832-2h-se8w for a dealership in Virginia, then it needs to be 
put into the database as bv-832-2h-se8w--virginia. */



CREATE OR REPLACE FUNCTION updatetaxid()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
	NEW.tax_id = NEW.tax_id ||'--'||NEW.state;
	RETURN NEW;
END;
$$

CREATE TRIGGER updatetaxidtrigger
BEFORE INSERT OR UPDATE ON dealerships
FOR EACH ROW 
EXECUTE FUNCTION updatetaxid();

---lets test this out:

INSERT INTO dealerships (business_name, phone, city, state, website, tax_id)
VALUES
  ('Sample Dealership 3', '123-456-7890', 'Sample City 3', 'Sample State 3', 'http://www.sample1.com', 'ABC123');

SELECT *
FROM dealerships d 

--SUCCESS!

---------------------------------------------------------------------

--Chapter 7:


/*1.  Write a transaction to:
Add a new role for employees called Automotive Mechanic
Add five new mechanics, their data is up to you
Each new mechanic will be working at all three of these dealerships: Meeler Autos of San Diego, Meadley Autos of California and Major 
Autos of Florida.*/

--Lets first add a new employee_type_name into the employeetypes table:

SELECT *
FROM employeetypes

BEGIN;

INSERT INTO employeetypes(employee_type_name)
VALUES('Automotive Mechanic');

COMMIT;

---now lets look to add these employee details to the employees table:

/*first i need to look at some examples of employees that work at multiple locations.  we'll then go into finding the dealership
 * details because it looks like they want us to add these mechanics to all 3 locations.  i'll need to add 5 employee id's for each
 * location.*/

SELECT *
FROM dealershipemployees d 
ORDER BY employee_id asc;
--employee id 4 is an example of multiple locations employee.


--find the dealership ids by location

SELECT *
FROM dealerships d 
WHERE business_name LIKE '%Meeler%'
--dealership_id = 50

SELECT *
FROM dealerships d 
WHERE business_name LIKE '%Meadley%'
--dealership_id = 36

SELECT *
FROM dealerships d 
WHERE business_name LIKE '%Major%'
--dealership_id = 20

--automotive mechanic type id = 8


SELECT *
FROM employees e 


BEGIN;

INSERT INTO employees(first_name, last_name, email_address, phone, employee_type_id)
VALUES ('Justin', 'Fields', 'Justin.Fields@gmail.com', '951-555-5551', '8'),
  ('DJ', 'Moore', 'DJ.Moore@gmail.com', '951-555-5552', '8'),
  ('Bijan', 'Robinson', 'Bijan.Robinson@gmail.com', '951-555-5553', '8'),
  ('Najee', 'Harris', 'Najee.Harris@gmail.com', '951-555-5554', '8'),
  ('James', 'Cook', 'James.Cook@gmail.com', '951-555-5555', '8');
 
COMMIT;

--ok so im having a problem where the transaction statement isnt working unless i close the app and reopen.
--now lets add the employees to the 3 dealerships.  it'll need to be 15 total inserts.

SELECT *
FROM dealershipemployees
ORDER BY employee_id DESC;


BEGIN;
INSERT INTO dealershipemployees (dealership_id, employee_id)
VALUES ('50','1002'),
('36','1002'),
('20','1002'),
('50','1003'),
('36','1003'),
('20','1003'),
('50','1004'),
('36','1004'),
('20','1004'),
('50','1005'),
('36','1005'),
('20','1005'),
('50','1006'),
('36','1006'),
('20','1006');
COMMIT;

--Done!



/*2.  Create a transaction for:
Creating a new dealership in Washington, D.C. called Felphun Automotive
Hire 3 new employees for the new dealership: Sales Manager, General Manager and Customer Service.
All employees that currently work at Nelsen Autos of Illinois will now start working at Cain Autos of Missouri instead.*/

BEGIN; --adding a NEW dealership
	INSERT INTO dealerships(business_name, phone, city, state, website, tax_id)
	VALUES ('Felphun Automotive', '555-751-8359', 'Washington','District of Columbia', 'http://www.felphunautomotive.com', 'te-809-uz-txsc');
COMMIT;


SELECT *
FROM dealerships d 
ORDER BY state 
--done dealership id 57

SELECT *
FROM employeetypes e 
--- i found employee ids 3, 6, and 4.


BEGIN;

INSERT INTO employees(first_name, last_name, email_address, phone, employee_type_id)
VALUES ('Cooper', 'Kupp', 'Cooper.Kupp@gmail.com', '951-555-5556', 3),
  ('Breece', 'Hall', 'Breece.Hall@gmail.com', '951-555-5557', 6),
  ('David', 'Montgomery', 'David.Montgomery@gmail.com', '951-555-5558', 4);
 
COMMIT;

SELECT *
FROM employees e 
ORDER BY employee_id DESC;
--done
--now add the employees to that dealership


BEGIN;

INSERT INTO dealershipemployees (dealership_id, employee_id)
VALUES ('57','1007'),
		('57','1008'),
		('57','1009');
	
COMMIT;


SELECT *
FROM dealershipemployees d 
WHERE dealership_id  = 57
--done



--last request, move employees from the Nelsen location to Cain Autos of Missouri.

SELECT *
FROM dealerships d 
WHERE business_name LIKE '%Cain Autos%'
--dealership id 17 = 'nelsen'
--dealership id 3 = cain

SELECT *
FROM dealershipemployees d 
WHERE dealership_id = '3'


UPDATE dealershipemployees 
SET dealership_id = '3'
WHERE dealership_id = '17'

--done


---------------------------------------------------------------------
--CIRCLE BACK TO THIS.  LEARN CHAPTER 9 FIRST
--Chapter 8:

/*Write transactions to handle the following scenarios:

1.  Adding 5 brand new 2021 Honda CR-Vs to the inventory. They have I4 engines and are classified as a Crossover SUV or CUV. All of them 
have beige interiors but the exterior colors are Lilac, Dark Red, Lime, Navy and Sand. The floor price is $21,755 and the MSR price 
is $18,999.*/

SELECT *
FROM vehicles v 
WHERE 

SELECT *
FROM vehicletypes v 
--WHERE make  = 'Honda'
ORDER BY make 


/*2.  For the CX-5s and CX-9s in the inventory that have not been sold, change the year of the car to 2021 since we will be updating our stock 
of Mazdas. For all other unsold Mazdas, update the year to 2020. The newer Mazdas all have red and black interiors.*/






/*3.  The vehicle with VIN KNDPB3A20D7558809 is about to be returned. Carnival has a pretty cool program where it offers the returned vehicle 
to the most recently hired employee at 70% of the cost it previously sold for. The most recent employee accepts this offer and will 
purchase the vehicle once it is returned. The employee and dealership who sold the car originally will be on the new sales transaction.*/





---------------------------------------------------------------------

--Chapter 9:
/*This is just an overview on stored procedures and commits.  It essentially shows how data is handled in the real world.  It seems
that insert, delete, and update are done differently in these scenarios.  We do this in case we want to rollback some data OR if
we can ROLLBACK ALL the DATA if one error occurs.*/






















