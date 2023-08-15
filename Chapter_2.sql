Book 2 Carnival Reports

--Selecting All Vehicles
--Start off with a query to view all vehicles in your database.

SELECT * FROM Vehicles;
Using the askterisk (*) 

 /* returns all columns in the query. It is fine to use * in the intitial phases of development, but important to be specific about the columns you want to view as you build your query. The query will run much faster and there's a lower risk of accidently exposing data unitentionally.

You should also start getting into the habit immediately of using a table alias. Here is a query to view the engine size, floor price, and manufacturer price of all vehicles.

Note that the Vehicle table was aliased with the letter v, and all columns used that alias.

Practice: Dealers
Write a query that returns the business name, city, state, and website for each dealership. Use an alias for the Dealerships table.

Practice: Customers
Write a query that returns the first name, last name, and email address of every customer. Use an alias for the Customers table. */


--1.

SELECT
	v.engine_type,
	v.floor_price,
	v.msr_price
FROM vehicles  v

--2.

SELECT
	d.business_name,
	d.city,
	d.state,
	d.website
FROM dealerships d 
ORDER BY business_name ASC ;

--3.

SELECT
	c.first_name,
	c.last_name,
	c.email
FROM customers c 



--Practice - Filtering Data
--1.Get a list of sales records where the sale was a lease.

--ANSWER:
SELECT *
FROM sales s 
WHERE sales_type_id  = 2

SELECT *
FROM salestypes

--2. Get a list of sales where the purchase date is within the last five years.

--ANSWER:
SELECT *
FROM sales s 
WHERE purchase_date BETWEEN '2018-01-01' AND '2023-12-31'
ORDER BY purchase_date  DESC;


--3. Get a list of sales where the deposit was above 5000 or the customer payed with American Express.

--ANSWER:
SELECT *
FROM sales s 
WHERE deposit > 5000 OR payment_method = 'American Express'
ORDER BY deposit  asc;

--4. Get a list of employees whose first names start with "M" or ends with "d".

--ANSWER:
SELECT *
FROM employees e 
WHERE first_name LIKE 'M%' OR first_name LIKE '%d';


--5. Get a list of employees whose phone numbers have the 604 area code.'

--ANSWER:
SELECT *
FROM employees e 
WHERE phone LIKE '604%';

----------------------------------------------------------------------------
Chapter 3

--Practice - Joining Data

--1. Get a list of the sales that were made for each sales type.

--ANSWER:
select *
from sales s
left join salestypes t
	on s.sales_type_id = t.sales_type_id;


--2. Get a list of sales with the VIN of the vehicle, the first name and last name of the customer, first name and last name of the employee who made the sale and the name, 
city and state of the dealership.

--which tables should i use?

/* customers - customer first and last name - customer_id
vehicles - VIN - vehicle id */

sales - employee id, customer id, vehicle id, dealership id
employees - employee first and last name
dealership - city and state

-- ANSWER:
select v.vin, c.first_name AS customer_first, c.last_name as customer_last, e.first_name as employee_first, e.last_name as employee_last, s.sale_id, d.city as dealership_city, 
d.state as dealership_state
from sales s
left join vehicles v
on s.vehicle_id = v.vehicle_id
left join employees e
on s.employee_id = e.employee_id
left join dealerships d
on s.dealership_id = d.dealership_id
left join customers c
on s.customer_id = c.customer_id;


--3. Get a list of all the dealerships and the employees, if any, working at each one.

--ANSWER:
select *
from dealershipemployees d
left join employees e
on d.employee_id = e.employee_id
left join dealerships dd
on d.dealership_id = dd.dealership_id;


--4. Get a list of vehicles with the names of the body type, make, model and color.

--ANSWER:
select v.body_type, v.make, v.model, vv.exterior_color
from vehicletypes v
left join vehicles vv
on v.vehicle_type_id = vv.vehicle_type_id;

---------------------------------------------------------------------------------------

--Chapter 5 Complex Joins

/* Practice: Sales type by dealership
 * Produce a report that list every dealership, the number of purchases done by each,
 * and the number of leases done by each.
 */ 

SELECT d. business_name ,  s2.sales_type_name AS Sale_Type, count(s.sale_id) AS sales_count
FROM dealerships d 
INNER Join Sales s ON d.dealership_id = s.dealership_id 
INNER JOIN salestypes s2 ON s.sales_type_id = s2.sales_type_id 
--WHERE s2.sales_type_name = 'Lease'
GROUP BY d.business_name, s2.sales_type_name 
ORDER BY business_name desc;

---------------------------------------------------------------------------

/* Practice: Leased Types
 * Produce a report that determines the most popular vehicle model that is leased.
 */


SELECT v2.model, count(s.sales_type_id)
FROM vehicles v 
	LEFT JOIN vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
	LEFT JOIN sales s ON v.vehicle_id = s.vehicle_id 
	INNER JOIN salestypes s2 ON s.sales_type_id = s2.sales_type_id 
WHERE s.sales_type_id = 2
GROUP BY v2.model 
ORDER BY count DESC;


/* Practice: Who Sold What
 * What is the most popular vehicle make in terms of number of sales?
 * Which employee type sold the most of that make?
 */

SELECT v2.model, e2. employee_type_name, count(s.sales_type_id)
FROM vehicles v 
	LEFT JOIN vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
	LEFT JOIN sales s ON v.vehicle_id = s.vehicle_id 
	INNER JOIN salestypes s2 ON s.sales_type_id = s2.sales_type_id 
	INNER JOIN employees e ON s.employee_id = e.employee_id 
	INNER JOIN employeetypes e2 ON e.employee_type_id = e2.employee_type_id 
WHERE s.sales_type_id = 1
GROUP BY v2.model, e2.employee_type_name 
ORDER BY count DESC;


--CHAPTER 7:
/* Practice:
 * For the top 5 dealerships, which employees made the most sales? - employee name
 * For the top 5 dealerships, which vehicle models were the most popular in sales?
 * For the top 5 dealerships, were there more sales or leases?
 */

Answer:
--THIS DIDNT WORK
/*SELECT max(e.sales_type_id)
FROM (
SELECT s.dealership_id, s.sales_type_id, count(s.sale_id) AS car_sales
FROM sales s 
GROUP BY s.dealership_id , s.sales_type_id 
ORDER BY car_sales DESC
LIMIT 5 ) AS top5
FROM sales s
JOIN s.*/

/* internal analysis:
DEALERSHIP HAS DEALERSHIP ID AND BUSINESS NAME
ALSO NEED DEALERSHIPEMPLOYEES TO TIE TO DEALERSHIP_ID TO GET THE EMPLOYEE ID.
NEED EMPLOYEES FOR THE EMPLOYEE_TYPE_ID
NEED EMPLOYEE TYPES FOR THE TYPE OF EMPLOYEE
AND NEED SALES FOR THE TYPE OF SALE AND THE COUNT ON SALE ID */

/* I was able to put together the actual CTE with "Tablescombined", but im having trouble
 * with the next select statement to just give me the top performing salesmen by the location 
 * 
 * I LEFT HERE! WE'RE STILL WORKING ON PUTTING TOGETHER THIS DAMN CTE! 
 * */

WITH TablesCombined AS (

SELECT 
	d.business_name, count(*) AS Transactions
FROM sales s 
	LEFT JOIN dealerships d ON d.dealership_id = s.dealership_id 
GROUP BY 
	d.business_name 
ORDER BY 
	Transactions DESC
LIMIT 5

)

SELECT 
	e.first_name, e.last_name, d2.business_name, count(s.sale_id) AS Trans
FROM 
	employees e
JOIN 
	sales s ON s.employee_id = e.employee_id
JOIN	
	dealershipemployees d2 ON d2.employee_id  = s.employee_id 	
GROUP BY e.first_name , e.last_name , d2.business_name
ORDER BY Trans DESC


--Used Cars
/* 1. For all used cars, which states sold the most? The least?
 * 2. For all used cars, which model is greatest in the inventory? Which make is greatest inventory?
 * 3. Talk with your teammates and think of another scenario where you can use a CTE to answer multiple 
 * business questions about employees, inventory, sales, deealerships or customers.
 */


WITH salescount AS (
	SELECT s.sales_type_id , count(sale_id) AS total_sales
	FROM sales s
	INNER JOIN salestypes se ON se.sales_type_id = s.sales_type_id
	WHERE se.sales_type_name = 'Purchase'
	GROUP BY sales_type_id
	)
SELECT employee_id 


SELECT *
FROM salestypes s 



