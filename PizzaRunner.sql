-- CASE STUDY #2 - Pizza Runner

-- Creating the table 
CREATE SCHEMA pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
-- Checking to see if table created. 
SELECT * 
FROM pizza_runner.runners;

-- Inserting values 
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
  
  DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
  
  DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');
  
  DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');
  
  DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  /* --------------------
   Case Study Questions
   --------------------*/

/* --------------------
   This case study has LOTS of questions - they are broken up by area of focus including:

* Part A: Pizza Metrics
* PART B: Runner and Customer Experience
* PART C: Ingredient Optimisation
* PART D: Pricing and Ratings
* PART E: Bonus DML Challenges (DML = Data Manipulation Language)
   --------------------*/
   
   -- There are null values in some of the tables, so let's do some data cleaning prior to any analysis. 
   
DESCRIBE pizza_runner.customer_orders; -- noted null values  
SELECT *
FROM pizza_runner.customer_orders; -- need to clean up the null values in the 'exclusion' and 'extras' columns

CREATE TEMPORARY TABLE pizza_runner.new_customer_orders
SELECT order_id, customer_id, pizza_id,
CASE 
WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ' '
ELSE exclusions
END AS exclusions,
CASE 
WHEN extras IS NULL OR extras LIKE 'null' THEN ' '
ELSE extras 
END AS extras, 
order_time
FROM pizza_runner.customer_orders;

-- Nulls have been removed. 
DESCRIBE pizza_runner.new_customer_orders;
DESCRIBE pizza_runner.new_runner_orders;
SELECT * 
FROM pizza_runner.new_customer_orders;

-- Now let's clean up the runners orders table 
DESCRIBE pizza_runner.runner_orders; -- noted null values 
SELECT *
FROM pizza_runner.runner_orders; -- need to clean up the null values in the 'pickup_time','distance', 'duration', and 'cancellation' columns

CREATE TEMPORARY TABLE pizza_runner.new_runner_orders
SELECT order_id, runner_id,
CASE 
WHEN pickup_time IS NULL OR pickup_time LIKE 'null' THEN ' '
ELSE pickup_time 
END AS pickup_time,
CASE 
WHEN distance IS NULL OR distance LIKE 'null' THEN ' '
WHEN distance LIKE '%km' THEN TRIM('km' from distance) 
ELSE distance END AS distance,
CASE 
WHEN duration IS NULL OR duration LIKE 'null' THEN ' ' 
WHEN duration LIKE '%mins' THEN TRIM('mins' from duration) 
WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)        
WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)       
ELSE duration END AS duration,
CASE 
WHEN cancellation IS NULL OR cancellation LIKE 'null' THEN ''
ELSE cancellation END AS cancellation
FROM pizza_runner.runner_orders;

-- Spot check to see that changes have been made. 
SELECT *
FROM pizza_runner.new_runner_orders; 

-- Great! Now that we've cleaned up these two tables, let's begin our analysis. 

USE pizza_runner; 

-- PART A: Pizza Metrics 

-- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS no_of_pizzas_ordered
FROM new_customer_orders;

-- A total of 14 pizza have been ordered so far. 

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS no_of_distinct_customer_orders
FROM new_customer_orders;

-- There have been 10 unique customer orders made. 

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, 
       COUNT(order_id) AS no_of_sucessful_deliveries
FROM new_runner_orders
WHERE cancellation NOT LIKE '%cancellation%'
GROUP BY 1; 

-- Runner 1 made 4 sucessful deliveries. 
-- Runner 2 made 3 sucessful deliveries.
-- Runner 3 made 1 sucessful delivery.   

-- 4. How many of each type of pizza was delivered?
SELECT pn.pizza_name,
	   COUNT(co.order_id)AS quantity_delivered 
FROM pizza_names AS pn
LEFT JOIN pizza_runner.new_customer_orders AS co
ON pn.pizza_id = co.pizza_id 
LEFT JOIN new_runner_orders AS ro
ON co.order_id = ro.order_id
WHERE ro.cancellation NOT LIKE '%cancellation%'
GROUP BY 1;

-- A total of 9 Meatlovers and 3 Vegetarian pizzas were delivered. 

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT co.customer_id, 
       pn.pizza_name,
	   COUNT(co.order_id) AS no_of_orders
FROM new_customer_orders AS co
INNER JOIN pizza_names as pn
ON co.pizza_id = pn.pizza_id
GROUP BY 1,2
ORDER BY 1,2;

SELECT DISTINCT *
FROM pizza_names;

SELECT co.customer_id, 
	   SUM(CASE WHEN co.pizza_id = 1 THEN 1 ELSE 0 END) AS meatlovers_orders,
	   SUM(CASE WHEN co.pizza_id = 2 THEN 1 ELSE 0 END) AS vegetarian_orders
FROM new_customer_orders AS co
INNER JOIN pizza_names as pn
ON co.pizza_id = pn.pizza_id
GROUP BY 1
ORDER BY 1;

-- Customer 101 ordered 2 Meatlovers and 1 Vegetarian pizza. 
-- Customer 102 ordered 2 Meatlovers and 1 Vegetarian pizza.
-- Customer 103 ordered 3 Meatlovers and 1 Vegetarian pizza. 
-- Customer 104 ordered 3 Meatlovers pizzas.  
-- Customer 105 ordered 1 Vegetarian pizza. 

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT order_id, 
       COUNT(order_id) no_of_orders
FROM new_customer_orders
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 3 pizzas was the maximum number of pizzas delievered in a single order (order_id = 4). 

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

-- Note: Used CAST to first convert values in the 'exclusion' and 'extras' column from string to numeric values.
SELECT co.customer_id,
       SUM(CASE WHEN CAST(co.exclusions AS UNSIGNED) IN (1,2,3,4,5,6,7,8,9,10,11,12) OR CAST(co.extras AS UNSIGNED) IN (1,2,3,4,5,6,7,8,9,10,11,12) THEN 1 ELSE 0 END) at_least_1_change,
       SUM(CASE WHEN CAST(co.exclusions AS UNSIGNED) = 0  AND CAST(co.extras AS UNSIGNED) = 0 THEN 1 ELSE 0 END) no_change       
FROM new_customer_orders AS co
LEFT JOIN new_runner_orders AS ro
ON co.order_id = ro.order_id
WHERE cancellation NOT LIKE '%cancellation%'
GROUP BY 1;

-- Customer 101 had no changes for all 2 pizza delivered
-- Customer 102 had no changes for all 3 pizzas delivered
-- Customer 103 had 3 pizzas delivered that required at least 1 change. 
-- Customer 104 had 2 pizzas delivered that required at least 1 change.  
-- Customer 105 had 1 pizzas delivered that required at least 1 change.. 


-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT  SUM(CASE WHEN CAST(co.exclusions AS UNSIGNED) IN (1,2,3,4,5,6,7,8,9,10,11,12) AND CAST(co.extras AS UNSIGNED) IN (1,2,3,4,5,6,7,8,9,10,11,12) THEN 1 ELSE 0 END) both_exclusion_extras
FROM new_customer_orders AS co
LEFT JOIN new_runner_orders AS ro
ON co.order_id = ro.order_id
WHERE cancellation NOT LIKE '%cancellation%';

-- 1 pizza was delivered that had both exclusions and extras. 

-- 9. What was the total volume of pizzas ordered for each hour of the day?

WITH cte AS
(
SELECT order_id, 
       customer_id,
       pizza_id, 
       DATE(order_time) AS order_date, 
       HOUR(order_time) AS order_hour	   
FROM new_customer_orders
) 
SELECT COUNT(order_id) AS quantity,
       order_date, 
       order_hour
FROM cte
GROUP BY 2,3
ORDER BY 2,3;

-- On 01-01-2020 1 pizza was ordered in the 18th hour and 1 pizza in the 19th hour of the day. 
-- On 01-02-2020 2 pizzas were ordered in the 23rd hour of the day. 
-- On 01-04-2020 3 pizzas were ordered in the 13th hour of the day. 
-- On 01-08-2020 3 pizzas were ordered in the 21st hour of the day
-- On 01-09-2020 1 pizza was ordered in the 23rd hour of the day. 
-- On 01-10-2020 1 pizza was ordered in the 11th hour of the day.
-- On 01-11-2020 2 pizzas were ordered in the 18th hour of the day. 
-- The most number of pizza ordere were on in the 13th and 21st hours of the day. 

-- 10. What was the volume of orders for each day of the week?
SELECT  DAYNAME(DATE(order_time)) AS day_of_week,
        COUNT(order_id) AS no_of_pizzas_ordered
FROM new_customer_orders
GROUP BY 1;

-- 5 pizzas were ordered each on Wednesday and Saturday.  
-- 3 pizzas were ordered on Thursday. 
-- 1 pizza was ordered on a Friday.

-- That completes my analysis of part A. Pizza metrics!! 



 
   