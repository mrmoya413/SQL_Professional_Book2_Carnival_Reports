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

--------------------------------------

--Chapter 9
--Purchase Income by Dealership

--1. Write a query that shows the total purchase sales income per dealership.

Answer:

SELECT DISTINCT 
d.business_name, 
sum(s.price) over() AS overall_sales,
sum(s.price) over(partition by d.business_name) AS total_dealership_sales
FROM dealerships d 
JOIN sales s ON d.dealership_id = s.dealership_id 
ORDER BY business_name  ASC ;

--2. Write a query that shows the purchase sales income per dealership for July of 2020.

SELECT DISTINCT 
d.business_name, 
sum(s.price) over(partition by d.business_name) AS total_dealership_sales
FROM dealerships d 
JOIN sales s ON d.dealership_id = s.dealership_id 
WHERE s.sales_type_id  = 1 AND s.purchase_date BETWEEN '7/1/2020' AND '7/31/2020'
ORDER BY business_name  ASC ;

--3. Write a query that shows the purchase sales income per dealership for all of 2020.

SELECT DISTINCT 
d.business_name, 
sum(s.price) over(partition by d.business_name) AS total_dealership_sales
FROM dealerships d 
JOIN sales s ON d.dealership_id = s.dealership_id 
WHERE s.sales_type_id  = 1 AND s.purchase_date BETWEEN '1/1/2020' AND '12/31/2020'
ORDER BY business_name  ASC ;

--Lease Income by Dealership

--1. Write a query that shows the total lease income per dealership.

SELECT DISTINCT 
d.business_name, 
sum(s.price) over(partition by d.business_name) AS total_dealership_leases
FROM dealerships d 
JOIN sales s ON d.dealership_id = s.dealership_id 
WHERE s.sales_type_id  = 2 --AND s.purchase_date BETWEEN '1/1/2020' AND '12/31/2020'
ORDER BY total_dealership_leases  ASC ;


--2. Write a query that shows the lease income per dealership for Jan of 2020.

SELECT DISTINCT 
d.business_name, 
sum(s.price) over(partition by d.business_name) AS total_dealership_leases
FROM dealerships d 
JOIN sales s ON d.dealership_id = s.dealership_id 
WHERE s.sales_type_id  = 2 AND s.purchase_date BETWEEN '1/1/2020' AND '1/31/2020'
ORDER BY total_dealership_leases  ASC ;


--3. Write a query that shows the lease income per dealership for all of 2019.

SELECT DISTINCT 
d.business_name, 
sum(s.price) over(partition by d.business_name) AS total_dealership_leases
FROM dealerships d 
JOIN sales s ON d.dealership_id = s.dealership_id 
WHERE s.sales_type_id  = 2 AND s.purchase_date BETWEEN '1/1/2019' AND '12/31/2019'
ORDER BY total_dealership_leases  ASC ;

--Total Income by Employee

--1. Write a query that shows the total income (purchase and lease) per employee.

SELECT DISTINCT 
e.last_name || ', ' || e.first_name AS employee_name,
sum(s.price) over(partition by e.business_name) AS employee_leases_sales
FROM dealerships d 
JOIN sales s ON d.dealership_id = s.dealership_id 
JOIN employee e ON s.employee_id = e.employee_id 
ORDER BY employee_leases_sales  ASC ;


------------------------------------------------------------

-Chapter 10

--Available Models

--1. Which model of vehicle has the lowest current inventory? This will help 
--dealerships know which models the purchase from manufacturers.

--Answer: the model with the lowest current inventory is the MX-5 Miata

SELECT DISTINCT
v2.model,
count(NULLIF(v.is_sold = FALSE,true)) AS unsold_car_count,
count(NULLIF(v.is_sold = true, true)) AS sold_car_count
FROM vehicles v 
JOIN vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
GROUP BY v2.model 
ORDER BY unsold_car_count ASC;


--2.  Which model of vehicle has the highest current inventory? This will help 
--dealerships know which models are, perhaps, not selling.

--Answer: Highest unsold CURRENT inventory IS the Maxima.
SELECT DISTINCT 
v2.model,
count(v.vehicle_type_id) over(partition by v2.model) AS vehicle_inventory
FROM 
	vehicles v 
JOIN 
	vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
WHERE 
		v.is_sold = FALSE
ORDER BY vehicle_inventory DESC;

--testing the data to see if im getting a match on the count for the top vehicle that hasnt sold--
SELECT *
FROM vehicles v 
JOIN vehicletypes v2 ON v.vehicle_type_id =v2.vehicle_type_id 
WHERE v2.model = 'Maxima' AND v.is_sold = FALSE 

--Here's another way of pulling the information: 

SELECT DISTINCT
v2.model,
count(NULLIF(v.is_sold = FALSE,true)) AS unsold_inventory,
count(NULLIF(v.is_sold = true, true)) AS sold_cars
FROM vehicles v 
JOIN vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
GROUP BY v2.model 
ORDER BY unsold_inventory desc

--Diverse Dealerships

--1. Which dealerships are currently selling the least number of vehicle models? This will 
--let dealerships market vehicle models more effectively per region.


SELECT
    s.dealership_id, d.business_name ,
    v2.make ,
    SUM(s.price) AS total_sales_amount,
    RANK() OVER (ORDER BY SUM(s.price)) AS sales_rank
FROM
    sales s
JOIN	
	vehicles v ON s.vehicle_id = v.vehicle_id 
JOIN
	vehicletypes v2 ON v.vehicle_type_id = v.vehicle_id
JOIN 
	dealerships d ON s.dealership_id = d.dealership_id 
GROUP BY
    s.dealership_id, d.business_name, v2.make
ORDER BY
    sales_rank;


--2.Which dealerships are currently selling the highest number of vehicle models? This will 
--let dealerships know which regions have either a high population, or less brand loyalty.


SELECT
    s.dealership_id, d.business_name ,
    v2.make ,
    SUM(s.price) AS total_sales_amount,
    DENSE_RANK() OVER (ORDER BY SUM(s.price)) AS sales_rank
FROM
    sales s
JOIN	
	vehicles v ON s.vehicle_id = v.vehicle_id 
JOIN
	vehicletypes v2 ON v.vehicle_type_id = v.vehicle_id
JOIN 
	dealerships d ON s.dealership_id = d.dealership_id 
GROUP BY
    s.dealership_id, d.business_name, v2.make
ORDER BY
    sales_rank DESC;

------------------------------
   
--Chapter 11
--Carnival Sales Reps
   
   
/* Quick Note: question 3 chapter 1   
-- go back to chapter one and enter in some information that's requested because Kennie should show up at 3 locations. */
   
 --1.  How many emloyees are there for each role?
   
--Answer:   
   
SELECT 
e2.employee_type_name  as Department_name,
count(e.employee_id) AS Employee_Count
FROM employees e 
JOIN employeetypes e2 ON e.employee_type_id  = e2.employee_type_id 
GROUP BY e2.employee_type_name
ORDER BY e2.employee_type_name DESC;

--2.  How many finance managers work at each dealership?

--Answer:

SELECT  
e2.employee_type_name  as Department_name, d2.dealership_id,
d2.business_name,
count(e.employee_id) AS Employee_Count
FROM employees e 
JOIN employeetypes e2 ON e.employee_type_id  = e2.employee_type_id 
JOIN dealershipemployees d ON e.employee_id = d.employee_id 
JOIN dealerships d2 ON d.dealership_id = d2.dealership_id 
WHERE e2.employee_type_name = 'Finance Manager'
GROUP BY e2.employee_type_name, business_name, d2.dealership_id
ORDER BY d2.business_name  ASC

---Double checking the numbers and the table below confirms the data I'm getting above.

SELECT *
FROM employees e
JOIN dealershipemployees d ON e.employee_id = d.employee_id 
WHERE employee_type_id = 2 AND dealership_id = 23
   
--3.  Get the names of the top 3 employees who work shifts at the most dealerships?

--I first located the employees that come up more than once on the dealershipemployees table.

SELECT *
FROM
    dealershipemployees
--WHERE employee_id = 35
ORDER BY employee_id asc;

   
SELECT employee_id
FROM dealershipemployees
GROUP BY 1
HAVING count(*) > 1
ORDER BY 1


SELECT *
FROM employeetypes e 



----

SELECT
    employee_id
FROM
    (
        SELECT
            employee_id
        FROM
            dealershipemployees
        GROUP BY
            employee_id
        HAVING
            COUNT(*) > 1
    ) AS employees_with_duplicates
LIMIT 3;

/*I looked and couldnt determine what might single out the top 3 employees.  My results came up WITH
multiple employees that worked at another dealership, but not more than 2.*/

   
--4.  Get a report on the top two employees who has made the most sales through leasing vehicles.
   
Answer:

SELECT s.employee_id, concat(e.last_name, ', ', e.first_name) AS Employee_Name,
count(s.sale_id) AS Lease_Sales
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id 
JOIN salestypes s2 ON s.sales_type_id = s2.sales_type_id
WHERE s2.sales_type_name = 'Lease'
GROUP BY s.employee_id, Employee_name
ORDER BY Lease_Sales DESC 
LIMIT 2;

------------------------------------------------------------------

--Chapter 12

--States With Most Customers

/* 1. What are the top 5 US states with the most customers who have purchased a 
vehicle from a dealership participating in the Carnival platform?*/

--Answer:

WITH Top_5_States AS (

SELECT d.business_name, count(s.sale_id) AS Purchases, d.state
FROM sales s 
JOIN dealerships d ON s.dealership_id = d.dealership_id 
JOIN salestypes s2 ON s.sales_type_id = s2.sales_type_id 
WHERE s2.sales_type_name = 'Purchase'
GROUP BY d.business_name, d.state

)

SELECT t5.business_name, t5.Purchases, t5.state
FROM Top_5_States t5
ORDER BY t5.Purchases DESC 
LIMIT 5


/*2. What are the top 5 US zipcodes with the most customers who have purchased a 
vehicle from a dealership participating in the Carnival platform?*/

Answer: 

WITH Top_5_Zips AS (

SELECT c.zipcode, count(s.sale_id) AS Purchases
FROM sales s 
JOIN customers c ON s.customer_id = c.customer_id 
JOIN salestypes s2 ON s.sales_type_id = s2.sales_type_id 
WHERE s2.sales_type_name = 'Purchase'
GROUP BY c.zipcode 

)

SELECT t5z.zipcode, t5z.Purchases
FROM Top_5_Zips t5z
ORDER BY t5z.Purchases DESC 
LIMIT 5


--3. What are the top 5 dealerships with the most customers?

--Answer:

WITH Top_5_dealerships AS (

SELECT d.business_name, count(s.customer_id) AS Customers
FROM sales s 
JOIN dealerships d ON s.dealership_id = d.dealership_id 
JOIN salestypes s2 ON s.sales_type_id = s2.sales_type_id 
--WHERE s2.sales_type_name = 'Purchase'
GROUP BY d.business_name, d.state

)

SELECT t5.business_name, t5.Customers
FROM Top_5_dealerships t5
ORDER BY t5.Customers DESC 
LIMIT 5

-------------------------------------------------------------

--Chapter 13
--Practice: Carnival
--1.  Create a view that lists all vehicle body types, makes and models.


CREATE VIEW Vehicledetails AS 
	SELECT v.body_type, v.make, v.model 
	FROM vehicletypes v 


SELECT *
FROM vehicledetails 


--2.  Create a view that shows the total number of employees for each employee type.

CREATE VIEW Employeedetails AS
	SELECT e2.employee_type_name, count(e.employee_id)
	FROM employees e 
	JOIN employeetypes e2 ON e.employee_type_id = e2.employee_type_id 
	GROUP BY e2.employee_type_name 
	
SELECT *
FROM employeedetails 


--3.  Create a view that lists all customers without exposing their emails, phone numbers and street address.

CREATE VIEW CustomerDetails AS 
	SELECT c.customer_id, c.first_name, c.last_name, c.city, c.state, c.zipcode, c.company_name
	FROM customers c 

SELECT *
FROM CustomerDetails


--4.  Create a view named sales2018 that shows the total number of sales for each sales type for the year 2018.

CREATE VIEW sales2018 AS 
	SELECT s2.sales_type_name, count(s.sale_id)
	FROM sales s 
	JOIN salestypes s2 ON s.sales_type_id = s2.sales_type_id 
	WHERE purchase_date BETWEEN '1/1/2018' AND '12/31/2018'
	GROUP BY s2.sales_type_name 
	
	SELECT *
	FROM sales2018

--5.  Create a view that shows the employee at each dealership with the most number of sales.

CREATE VIEW Topdealershipemployee AS

WITH RankedEmployees AS (
    SELECT
        d.dealership_id,
        e.employee_id,
        e.first_name,
        e.last_name,
        COUNT(s.sale_id) AS total_sales,
        RANK() OVER (PARTITION BY d.dealership_id ORDER BY COUNT(s.sale_id) DESC) AS sales_rank
    FROM
        dealerships d
    JOIN
        sales s ON d.dealership_id = s.dealership_id
    JOIN
        employees e ON s.employee_id = e.employee_id
    GROUP BY
        d.dealership_id, e.employee_id, e.first_name, e.last_name
)
SELECT
    dealership_id,
    employee_id,
    first_name,
    last_name,
    total_sales
FROM
    RankedEmployees
WHERE
    sales_rank = 1;
	
	
--double checking the numbers because im getting ties with the top selling salesman by each location.
--looks like the information is correct.
	
SELECT s.employee_id, s.dealership_id, count(sale_id)
FROM sales s 
WHERE dealership_id  = '1'
GROUP BY s.employee_id, s.dealership_id
ORDER BY s.count desc;
	
SELECT *
FROM Topdealershipemployee
 
   