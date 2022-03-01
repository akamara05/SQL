-- CASE STUDY #1 - Danny's Diner 

-- Creating the table 
CREATE SCHEMA dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);
-- Checking to see if table created. 
SELECT * 
FROM dannys_diner.sales;

-- Inserting values 

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

SELECT * 
FROM dannys_diner.menu;


INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

SELECT * 
FROM dannys_diner.members;

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id,
       SUM(m.price) total_amount_spent 
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m 
ON s.product_id = m.product_id 
GROUP BY 1
ORDER BY 2 DESC;

-- Customer A spent the most, an amount of $76.
-- Customer B spent $74.
-- Customer C spent less than half of what customer A and B spent, spending $36.
       
-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,
	   COUNT(DISTINCT order_date) customer_visits
FROM dannys_diner.sales
GROUP BY 1
ORDER BY 2 DESC;
-- Customer A visted the store 4 times. 
-- Customer B visited the store the most, a total of 6 visits. 
-- Customer C visted the store the least, a total of 2 visits.

-- 3. What was the first item from the menu purchased by each customer?
WITH purchasing_ranking AS
(
SELECT s.customer_id AS customer_id,
	   RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS purchase_order,
       m.product_name AS first_purchased_item 
FROM dannys_diner.sales AS s 
INNER JOIN dannys_diner.menu AS m 
ON s.product_id = m.product_id 
) 
SELECT customer_id,
       first_purchased_item 
FROM purchasing_ranking 
WHERE purchase_order = 1;
-- Customer A purchased sushi and curry the first time they ordered.
-- Customer B purchased curry the first time they ordered.
-- Customer C purchased ramen the first time they ordered.

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name,
       COUNT(s.product_id) purchase_frequency 
FROM dannys_diner.sales AS s 
LEFT JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id 
GROUP BY 1
ORDER BY 2 DESC;
-- The most purchased menu item is ramen. It was puchased a total of 8 times by all customers. 

SELECT s.customer_id, 
       m.product_name,
       COUNT(s.product_id) purchase_frequency 
FROM dannys_diner.sales AS s 
LEFT JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id 
WHERE m.product_name LIKE '%ramen%'
GROUP BY 1,2
ORDER BY 3 DESC;
-- Both customers A and C bought ramen 3 times each and customer B bought it twice. 


-- 5. Which item was the most popular for each customer?
WITH cte AS 
(
SELECT s.customer_id, 
       m.product_name,
       COUNT(s.product_id) purchase_frequency,
       RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(s.product_id) DESC) AS ranking 
FROM dannys_diner.sales AS s 
LEFT JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id 
GROUP BY 1,2
) 
SELECT customer_id, 
	   product_name,
       purchase_frequency
FROM cte
WHERE ranking = 1
ORDER BY 1;
-- Ramen was the most popular item for customers A and C.
-- Customer B liked all three menu items equally according to the results. They purchased ramen, curry, and sushi twice each.


-- 6. Which item was purchased first by the customer after they became a member?
SELECT *
FROM dannys_diner.members;
-- According to the members table, only customers A and B have officially become members. Let's continue with this information in mind. 
WITH cte AS 
( 
SELECT s.customer_id,
       s.order_date, 
	   s.product_id, 
       m.join_date 
FROM dannys_diner.sales AS s 
INNER JOIN dannys_diner.members AS m 
ON s.customer_id = m.customer_id
) 
SELECT c.customer_id,
       c.join_date, 
       c.order_date, 
	   c.product_id, 
       menu.product_name 
FROM cte as c 
INNER JOIN dannys_diner.menu  
ON c.product_id = menu.product_id
WHERE c.order_date >= c.join_date
ORDER BY 1,3;

-- Customer A joined on 01-07-2021 and purchased curry as their first item that same day. 
-- Customer B joined on 01-09-2021 and purchased sushi on 01-11-2021 as their first item as an official member.

-- 7. Which item was purchased just before the customer became a member?
WITH cte AS 
( 
SELECT s.customer_id,
       s.order_date, 
	   s.product_id, 
       m.join_date 
FROM dannys_diner.sales AS s 
INNER JOIN dannys_diner.members AS m 
ON s.customer_id = m.customer_id
) 
SELECT c.customer_id,
       c.join_date, 
       c.order_date, 
	   c.product_id, 
       menu.product_name 
FROM cte as c 
INNER JOIN dannys_diner.menu  
ON c.product_id = menu.product_id
WHERE c.order_date < c.join_date
ORDER BY 1,3 DESC;
-- Customer A bought both curry and sushi on 01-01-2021 just before becoming a member on 01-07-2021.
-- Customer B bought sushi on 01-04-2021 just before becoming a memeber on 01-09-2021.

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT * 
FROM dannys_diner.members;
-- According to the members table, only customers A and B have officially become members. Let's continue with this information in mind. 
WITH full_table AS 
(
SELECT menu.product_name, 
       menu.price,
       s.*,
       m.join_date
FROM dannys_diner.menu 
LEFT JOIN dannys_diner.sales as s
ON menu.product_id = s.product_id
LEFT JOIN dannys_diner.members as m
ON s.customer_id = m.customer_id
)
SELECT customer_id,
       COUNT(product_id) AS total_items,
       SUM(price) AS total_spent
FROM full_table
WHERE order_date < join_date
GROUP BY 1;

-- Customer A spent $25 on 2 items prior to becoming a member on 01-07-2021.
-- Customer B spent $40 on 3 items prior to becoming a member on 01-09-2021.

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH menu_sales AS
(
SELECT menu.product_name, 
       menu.price,
       s.customer_id, 
       s.order_date, 
       s.product_id 
FROM dannys_diner.menu 
LEFT JOIN dannys_diner.sales as s
ON menu.product_id = s.product_id
),
rewards_table AS
(
SELECT customer_id,
      CASE 
	  WHEN product_name = 'sushi'
      THEN price * 2 * 10
	  ELSE price * 10
      END AS rewards_points
FROM menu_sales
)
SELECT customer_id,
       SUM(rewards_points) total_rewards
FROM rewards_table
GROUP BY 1
ORDER BY 1 ;
-- Customer A earned 860 points
-- Customer B earned 940 points
-- Customer C earned 360 points

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH full_table AS 
(
SELECT menu.product_name, 
       menu.price,
       s.*,
       m.join_date,
	   DATE_ADD(m.join_date, interval 6 day) AS first_week 
FROM dannys_diner.menu 
LEFT JOIN dannys_diner.sales as s
ON menu.product_id = s.product_id
LEFT JOIN dannys_diner.members as m
ON s.customer_id = m.customer_id
WHERE s.customer_id = m.customer_id
),
jan_rewards_table AS 
(
SELECT customer_id,
       order_date,
       CASE 
       WHEN product_name = 'sushi' THEN price * 2 * 10 
       WHEN order_date BETWEEN join_date AND first_week THEN price * 2 * 10
       ELSE price * 10
       END AS first_week_points
FROM full_table
WHERE order_date < '2021-01-31' 
) 
SELECT customer_id,
       SUM(first_week_points) jan_total_rewards
FROM jan_rewards_table
GROUP BY 1;

-- Customer A earned a total of 1370 points by the end of January.
-- Customer B earned a total of 820 points by the end of January.

/* --------------------
   Bonus Questions
   --------------------*/
-- Join All The Things 
SELECT s.customer_id, 
       s.order_date, 
       m.product_name, 
       m.price,
       CASE 
       WHEN s.order_date < mem.join_date THEN 'N'
       WHEN s.order_date >= mem.join_date THEN 'Y'
       ELSE 'N'
       END AS member
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id 
LEFT JOIN dannys_diner.members As mem
ON s.customer_id = mem.customer_id
ORDER BY 1,2,4 DESC; 


-- Rank All Things 

WITH cte AS
( 
SELECT s.customer_id, 
       s.order_date, 
       m.product_name, 
       m.price,
       CASE 
       WHEN s.order_date < mem.join_date THEN 'N'
       WHEN s.order_date >= mem.join_date THEN 'Y'
       ELSE 'N'
       END AS member,
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id 
LEFT JOIN dannys_diner.members As mem
ON s.customer_id = mem.customer_id
ORDER BY 1,2,4 DESC
) 
SELECT *,
       CASE 
       WHEN member = 'N' THEN 'null'
       WHEN member = 'Y' THEN RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date) 
       END AS ranking
FROM cte;


  