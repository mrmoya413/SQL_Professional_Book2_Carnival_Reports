/*

Use the Carnival ERD to identify the tables that are still missing in your database.

1.  Which tables need to be created after reviewing the ERD?*/
--VehicleBodyType
--VehicleModel
--VehicleMake


--2.  What levels of normalization will these new tables be supporting?
--3NF


--3.  Do any of these tables have a foreign key in another table? What is the child table that would hold the foreign key(s).
--FK in vehicle types table


--Consider


--1.  What needs to be created or modified? Don't just consider tables, but foriegn keys and other table modifications as well.
	--Create 3 tables
		-- VehicleBodyType, VehicleModel, VehicleMake
		-- Vehicletypes field should be replaced with FK from the new tables.
		-- VehicleTypes should have incrementing PK 'vhicle_body_type_id' (int) and 'name' (varchar (20))
		-- VehicleMake should have incrementing PK 'vehicle_make_id' (int) and 'name' (varchar(20))

SELECT *
FROM vehicletypes v 






--2.  What data needs needs to change or move? See note on Data Migration below
	-- Data should migrate from current vehicletypes table to newly created tables.
		--Keys from the new tables will migrate back to vehicletypes.


	--Duplicate phone number columns in Customers table.
	--Normalize city, state, zip in Customers table.



--3.  What needs to be deleted?
	-- Nothing needs to be delete because of the migration.


--4.  Does order matter? What order should tasks be completed in?
	-- Create new tables
	-- Migrate information to the new tables
	-- Return information to pre-existing vehicletypes tables
	-- Delete old varchar columns from the Vehicletypes table


--Creating the tables:
DROP TABLE IF EXISTS VehicleBodyType CASCADE;
DROP TABLE IF EXISTS VehicleModel CASCADE;
DROP TABLE IF EXISTS VehicleMake CASCADE;
​
CREATE TABLE VehicleBodyType (
	vehicle_body_type_id SERIAL PRIMARY KEY,
	name varchar (20)
	);
	
CREATE TABLE VehicleModel (
	vehicle_model_id SERIAL PRIMARY KEY,
	name varchar (20)
	);
	
CREATE TABLE VehicleMake (
	vehicle_make_id SERIAL PRIMARY KEY,
	name varchar (20)
	);
​
INSERT INTO VehicleBodyType (name)
SELECT DISTINCT(body_type) FROM vehicletypes;
​
INSERT INTO VehicleModel (name)
SELECT DISTINCT(model) FROM vehicletypes;
​
INSERT INTO VehicleMake (name)
SELECT DISTINCT(make) FROM vehicletypes;
		
	-- Creating vehicletypes vehicle_body_type_id column, establishing constraint, populating data.
-- Create new column on vehicletypes table

ALTER TABLE vehicletypes
ADD COLUMN vehicle_body_type_id INT;
​
-- Create constraint referencing key in newly created table
ALTER TABLE vehicletypes
ADD CONSTRAINT body_type_id FOREIGN KEY (vehicle_body_type_id) REFERENCES VehicleBodyType (vehicle_body_type_id);
​
-- Update new column on vehicletypes with appropriate values from foreign table.
UPDATE vehicletypes
SET vehicle_body_type_id = VehicleBodyType.vehicle_body_type_id
FROM VehicleBodyType
WHERE vehicletypes.body_type = VehicleBodyType.name;
​
	-- Creating vehicletypes vehicle_model_id column, establishing constraint, populating data
-- Create new column on vehicletypes table
ALTER TABLE vehicletypes
ADD COLUMN vehicle_model_id INT;
​
-- Create constraint referencing key in newly created table
ALTER TABLE vehicletypes
ADD CONSTRAINT vehicle_model_id FOREIGN KEY (vehicle_model_id) REFERENCES VehicleModel (vehicle_model_id);
​
-- Update new column on vehicletypes with appropriate values from foreign table.
UPDATE vehicletypes
SET vehicle_model_id = VehicleModel.vehicle_model_id
FROM VehicleModel
WHERE vehicletypes.model = VehicleModel.name;
​
	-- Creating vehicletypes vehicle_make_id column, establishing constraint, populating data
-- Create new column on vehicletypes table
ALTER TABLE vehicletypes
ADD COLUMN vehicle_make_id INT;
​
-- Create constraint referencing key in newly created table
ALTER TABLE vehicletypes
ADD CONSTRAINT make_id FOREIGN KEY (vehicle_make_id) REFERENCES VehicleMake (vehicle_make_id);
​
-- Update new column on vehicletypes with appropriate values from foreign table.
UPDATE vehicletypes
SET vehicle_make_id = VehicleMake.vehicle_make_id
FROM VehicleMake
WHERE vehicletypes.make = VehicleMake.name;
​

---STOPPED HERE.  THERE'S A DEPENDENCY.

ALTER TABLE vehicletypes
DROP COLUMN body_type,
DROP COLUMN make,
DROP COLUMN model;


--Run the stuff above.



--Data Migration

1. What is a data migration? It is simply moving/changing your data from one location to another.

2. A data migration will need to take place for Carnival where we will convert text to integers. The result of the script will change 
all the text words to id integers. The important thing to note is that the data migration script does not change the datatype of these 
fields. You will be respnonsible for changing the datatype in the next practice below.

Part 2: Optimizing Carnival Database

The second part of this team project is designed for your team to analyze the entire database and create a .SQL script file that will 
execute the improvements to make the database better. Consider Carnival's business as well. Are there Views, Stored Procedures or 
Triggers that will help Carnival operate more effiecently?

Discuss the improvements as a team and why they would provide a benefit to the business. Please draw on all the knowledge you have gotten from this course to implement your ideas! Once you have found some improvements, create a .Sql script to implement those improvements.

Things you might find useful
1. Creating tables
2. Altering exsiting tables
3. Drop statements
4. Views
5. Triggers (Formatting data or ensuring new related records get created)
6. Stored Procedures that group functionality
7. Transactions
8. Indexing
9. Data migrations
10. Normalizing the database further vs denormalizing*/







