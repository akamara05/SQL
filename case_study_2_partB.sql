-- PART B: Runner and Customer Experience


USE pizza_runner;

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
	   WEEK(registration_date) AS registration_week,
       MIN(DATE(registration_date)) date_start_of_week,
	   COUNT(DISTINCT runner_id) AS no_of_runners
FROM runners
GROUP BY 1;

-- 1 runner signed up on Jan 1st, week 0
-- 2 runners signed up in week 1
-- 1 runner signed up in week 2

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT ro.runner_id,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE,co.order_time,ro.pickup_time)),2) AS arrival_time
FROM new_runner_orders AS ro
LEFT JOIN new_customer_orders AS co
ON ro.order_id = co.order_id
WHERE distance != 0
GROUP BY 1;

-- It took runner 1 15.33 minutes on average to arrive at Pizza Runner HQ to pickup their orders. 
-- It took runner 2 23.40 minutes on average to arrive at Pizza Runner HQ to pickup their orders. 
-- It took runner 3 10.00 minutes on average to arrive at Pizza Runner HQ to pickup their orders. 

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH cte AS 
(
SELECT ro.order_id,
       COUNT(co.pizza_id)no_of_pizzas_per_order, 
       TIMESTAMPDIFF(MINUTE,co.order_time,ro.pickup_time) AS prep_time
FROM new_runner_orders AS ro
LEFT JOIN new_customer_orders AS co
ON ro.order_id = co.order_id
GROUP BY 1,3
ORDER BY 2 DESC
)
SELECT no_of_pizzas_per_order,
       ROUND(AVG(prep_time)) AS avg_prep_time
FROM cte 
GROUP BY 1
ORDER BY 1;

-- On average it takes 12 minutes to prep 1 pizza. 
-- On average it takes 18 minutes to prep 2 pizzas. 
-- On average it takes 29 minutes to prep 3 pizzas. 


-- 4. What was the average distance travelled for each customer?
SELECT co.customer_id,
       ROUND(AVG(ro.distance),2) AS avg_distance_km
FROM new_runner_orders AS ro
LEFT JOIN new_customer_orders AS co
ON ro.order_id = co.order_id
WHERE distance != 0
GROUP BY 1
ORDER BY 1;

-- The average distance travelled for customer 101 was 20km
-- The average distance travelled for customer 102 was 16.73km
-- The average distance travelled for customer 103 was 23.40km
-- The average distance travelled for customer 104 was 10km (nearest)
-- The average distance travelled for customer 105 was 25km (farthest) 


-- 5. What was the difference between the longest and shortest delivery times for all orders?
WITH cte AS 
(
SELECT ro.order_id,
       ro.duration
FROM new_runner_orders AS ro
LEFT JOIN new_customer_orders AS co
ON ro.order_id = co.order_id
WHERE distance != 0 
)
SELECT (MAX(duration)- MIN(duration))AS difference_delivery_time
FROM cte; 

-- There was a difference of 30 minutes bewteen the longest and shortest delivery orders.     
        
-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id,
       ROUND(SUM(distance)/SUM(duration)*60,2) AS avg_speed 
FROM new_runner_orders 
WHERE distance != 0 
GROUP BY 1
ORDER BY 1;


-- Runner 1's average speed is 42.74km/h 
-- Runner 2's average speed is 53.85km/h -- Speedy Gonzalez over here. 
-- Runner 3's average speed is 40.00km/h

-- 7. What is the successful delivery percentage for each runner?
SELECT runner_id, 
       ROUND((SUM(CASE WHEN distance != 0  THEN 1 ElSE 0 END)/COUNT(order_id)*100),0) AS successful_delivery_pct
FROM runner_orders
GROUP BY 1;

-- Runner 1 successfully delivered 100% of their non-cancelled orders. 
-- Runner 2 successfully delivered 75% of their non-cancelled orders. 
-- Runner 3 successfully delivered 50% of their non-cancelled orders. 

-- This completes my analysis for PART B!

