--Book 2 Carnival Reports 

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

-------------------------------------------------------------------------------------------

--CHAPTER 7:
--Practice:
--	1. For the top 5 dealerships, which employees made the most sales? - employee name*/

Answer:

/* Results below.  I'm not confident that the employees are correct, but I did the best I could. */

WITH TopPerformingDealerships AS (

	SELECT 
		d.business_name,
		s.dealership_id, 
		count(s.sale_id) AS total_sales
	FROM dealerships d 
	JOIN sales s ON d.dealership_id = s.dealership_id 
	GROUP BY d.business_name, s.dealership_id 
	ORDER BY total_sales DESC
	LIMIT 5

)

, RankedEmployees AS (
	SELECT
		e.first_name,
		e.last_name,
		tpd.dealership_id,
		s.sale_id,
		ROW_NUMBER() OVER (PARTITION BY tpd.dealership_id ORDER BY tpd.total_sales DESC) AS employee_rank
	FROM
		employees e
	JOIN
		sales s ON e.employee_id = s.employee_id 
	JOIN
		TopPerformingDealerships tpd ON s.dealership_id = tpd.dealership_id
)

SELECT
	re.first_name,
	re.last_name,
	tpd.business_name,
	--re.sale_id,
	re.employee_rank,
	tpd.total_sales AS dealership_total_sales --used this INSTEAD OF r.sale_id--
FROM 
	RankedEmployees re
JOIN 
		TopPerformingDealerships tpd ON re.dealership_id = tpd.dealership_id
WHERE
    	re.employee_rank = 1
ORDER BY 
	tpd.total_sales DESC, re.sale_id;


--2.	For the top 5 dealerships, which vehicle models were the most popular in sales?

still need the top 5 dealerships, lets amend this AND INCLUDE the car details INSTEAD.
dealerships, sales, vehicles, vehicletypes CONTAINS the make AND the vihicle_type_id

vehicletypes - vehicle_type_id
+
vehicles - vehicle_type_id


vehicles - vehicle_id
+
sales - vehicle_id


WITH TopPerformingDealerships AS (

	SELECT 
		d.business_name,
		s.dealership_id, 
		count(s.sale_id) AS total_sales
	FROM dealerships d 
	JOIN sales s ON d.dealership_id = s.dealership_id 
	GROUP BY d.business_name, s.dealership_id 
	ORDER BY total_sales DESC
	LIMIT 5

)

, RankedCars AS (
	SELECT
		e.first_name,
		e.last_name,
		tpd.dealership_id,
		s.sale_id,
		ROW_NUMBER() OVER (PARTITION BY tpd.---- ORDER BY tpd.--- DESC) AS Car_Rank
	FROM
		vehicles v
	JOIN
		vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id 
	JOIN
		TopPerformingDealerships tpd ON s.dealership_id = tpd.dealership_id
)



















--3.	For the top 5 dealerships, were there more sales or leases?*/



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

--Chapter 8

/*Let's say your customer wants a list of total sales per employee in the database.

A SUM() with a GROUP BY would give us this*/


select
	sales.employee_id,
	sum(sales.price) total_employee_sales
from
	employees
join
	sales
on
	sales.employee_id = employees.employee_id
group by
	sales.employee_id
ORDER BY sales.employee_id 

/*The issue with this, is that you can't put names with the employees using a group by. You could put the select in a CTE or a subquery, or you could use a window function.

The OVER() function is what makes this a windows function. The default for OVER() is the entire rowset. It will apply the function--SUM()--to the entire dataset, in this case total sales. If we want to break the data into parts, we partition it by the data we want to group it by. In this query, we are partitioning by the employee id so get total sales per employee.

By running a windows function, we can get the employee's name, as well as aggregate queries all in one query.*/


select distinct
	employees.last_name || ', ' || employees.first_name AS employee_name,
	sales.employee_id,
	sum(sales.price) over() AS total_sales,
	sum(sales.price) over(partition by employees.employee_id) AS total_employee_sales
from
	employees
join
	sales
on
	sales.employee_id = employees.employee_id
order by employee_name

-------

/* Final Notes for 8/15 - We finished the top 5 dealerships and the top selling employees.  We're working on the second
 * question asking for the top selling cars, but having issues replicating something similar to employees top rank.  William 
 * put in our slack channel what he did to put together this list.  Lets try to pull this apart and compare to how we would
 * do this statement differently...if possible...
 */




