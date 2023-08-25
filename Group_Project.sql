/*Creating Carnival Reports

Carnival would like to harness the full power of reporting. Let's begin to look further at querying the data in our tables. 
Carnival would like to understand more about thier business and needs you to help them build some reports.

## Goal
- Below are some desired reports that Carnival would like to see. Use your query knowledge to find the following metrics.

<br>

## Employee Reports
### Best Sellers

1. Who are the top 5 employees for generating sales income?
2. Who are the top 5 dealership for generating sales income?
3. Which vehicle model generated the most sales income?

### Top Performance
ls
1. Which employees generate the most income per dealership?

<br>

## Vehicle Reports

### Inventory
1. In our Vehicle inventory, show the count of each Model that is in stock.
2. In our Vehicle inventory, show the count of each Make that is in stock.
3. In our Vehicle inventory, show the count of each BodyType that is in stock.

### Purchasing Power

1. Which US state's customers have the highest average purchase price for a vehicle?
2. Now using the data determined above, which 5 states have the customers with the highest average purchase price for a vehicle?*/


-------------------------------------------------------------------------------------------------------------------------------------

--Employee Reports

--1.  Who are the top 5 employees for generating sales income?

SELECT 
	concat(e.first_name , ', ', e.last_name) AS EmployeeName,
	sum(s.price) AS SalesIncome
FROM 
	sales s
JOIN 
	employees e ON s.employee_id = e.employee_id
GROUP BY 
	EmployeeName
ORDER BY
	SalesIncome DESC
LIMIT 5;

--2. Who are the top 5 dealership for generating sales income?

--junes auto -- fix this --

SELECT 
	d2.business_name AS DealershipName,
	sum(s.price) AS SalesIncome
FROM 
	employees e 
JOIN 
	sales s ON e.employee_id = s.employee_id
JOIN 
	salestypes s2 ON s.sales_type_id  = s.sales_type_id 
JOIN 
	dealershipemployees d ON e.employee_id = d.employee_id 
JOIN 
	dealerships d2 ON d.dealership_id = d2.dealership_id
GROUP BY 
	DealershipName
ORDER BY
	SalesIncome DESC
LIMIT 5;
	

--3. Which vehicle model generated the most sales income?

SELECT 
	v2.model,
	sum(s.price) AS SalesIncome
FROM 
	employees e 
JOIN 
	sales s ON e.employee_id = s.employee_id
JOIN 
	vehicles v ON s.vehicle_id = v.vehicle_id 
JOIN
	vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
GROUP BY 
	v2.model
ORDER BY
	SalesIncome DESC
LIMIT 1;

--Top Performance

--1. Which employees generate the most income per dealership?
        
 WITH RankedEmployees AS (
    SELECT
        d.dealership_id,
        d.business_name,
        e.employee_id,
        e.first_name,
        e.last_name,
        SUM(s.price) AS income,
        RANK() OVER (PARTITION BY d.dealership_id ORDER BY sum(s.price) DESC) AS sales_income_rank
    FROM
        dealerships d
    JOIN
        sales s ON d.dealership_id = s.dealership_id
    JOIN
        employees e ON s.employee_id = e.employee_id
    GROUP BY
        d.dealership_id, d.business_name, e.employee_id, e.first_name, e.last_name
)
SELECT
    dealership_id,
    business_name,
    employee_id,
    first_name,
    last_name,
    income
FROM
    RankedEmployees
WHERE
    rankedemployees.sales_income_rank = 1
ORDER BY business_name;


--Vehicle Reports

-- Inventory
--1. In our Vehicle inventory, show the count of each Model that is in stock.
   
SELECT
	v2.model,
	count(v.vehicle_id) AS inventory_count
FROM 
 	vehicles v 
JOIN	
 	vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
WHERE
	v.is_sold = FALSE 
GROUP BY 
	v2.model
ORDER BY
	inventory_count desc

--2. In our Vehicle inventory, show the count of each Make that is in stock.
   
SELECT
	v2.make,
	count(v.vehicle_id) AS inventory_count
FROM 
 	vehicles v 
JOIN	
 	vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
WHERE
	v.is_sold = FALSE 
GROUP BY 
	v2.make
ORDER BY
	inventory_count DESC 

SELECT DISTINCT v.make
FROM vehicletypes v 
   
--3. In our Vehicle inventory, show the count of each BodyType that is in stock.

SELECT
	v2.body_type,
	count(v.vehicle_id)
FROM 
 	vehicles v 
JOIN	
 	vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
WHERE
	v.is_sold = FALSE 
GROUP BY 
	v2.body_type
ORDER BY
	v2.body_type
	
--Purchasing Power

--1. Which US state's customers have the highest average purchase price for a vehicle?
	
SELECT 
	c.state,
	round(avg(s.price),2) AS amt
FROM 
	sales s 
LEFT JOIN 
	customers c ON c.customer_id  = s.customer_id 
LEFT JOIN 
	salestypes s2 ON s.sales_type_id = s2.sales_type_id 
WHERE s2.sales_type_name  = 'Purchase'
GROUP BY
	c.state
ORDER BY
	amt DESC;

	
--2. Now using the data determined above, which 5 states have the customers with the highest average purchase price for a vehicle?*/


SELECT 
	round(avg(s.price),2),
	v2.make,
	c.state
FROM 
	sales s 
JOIN 
	customers c ON c.customer_id = s.customer_id 
JOIN 
	vehicles v ON v.vehicle_id = s.vehicle_id 
JOIN 
	vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
WHERE 
	v.is_sold = TRUE 
GROUP BY
	v2.make, c.state
LIMIT 5;

--note:  Watch when you're joining tables.  the joined the table below to itself "s.customer id = s.customer id" and it didn't correct you!




