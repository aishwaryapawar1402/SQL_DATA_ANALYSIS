
CREATE DATABASE pizza_hut;

use pizza_hut;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE orders_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- 1) -- RETRIVED THE TOTAL NUMBER OF ORDER PLACED?

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- 2) -- Calculate the total revenue genreted from pizza sales?

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;


-- 3) -- Identify the highest-priced pizza.?

SELECT
pizza_types.name,
t.price,
t.highest_price_pizza
FROM
(SELECT
pizza_type_id,
price,
row_number() OVER( order by price desc ) AS highest_price_pizza
FROM
pizzas )AS t
JOIN
pizza_types
ON 
t.pizza_type_id = pizza_types.pizza_type_id
WHERE
highest_price_pizza = 1;


-- 4) -- Identify the most common pizza size ordered?

SELECT * from pizzas;

SELECT 
    pizzas.size,
    pizzas.price,
    orders_details.quantity,
    COUNT(orders_details.order_details_id) AS ORDER_COUNT
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size , pizzas.price , orders_details.quantity
ORDER BY ORDER_COUNT DESC;


-- 5) -- List the top 5 most ordered pizza types along with their quantities.

use pizza_hut;

SELECT 
    pt.name, SUM(od.quantity) AS total_sum
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_sum DESC
LIMIT 5;


-- 6) -- Join the necessary tables to find the total quantity of each pizza category ordered?

SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

-- 7) -- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS total_count
FROM
    orders
GROUP BY HOUR(order_time);

-- 8) -- Join relevant tables to find the category-wise distribution of pizzas.?

SELECT
pizza_types.category,
count(pizza_types.name) total_count_pizza
FROM
pizza_types
group by
pizza_types.category;

select *from pizza_types;

use pizza_hut;

-- 9) -- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(t.total_quantity), 0) AS total_quantity
FROM
    (SELECT 
        orders.order_date,
            SUM(orders_details.quantity) AS total_quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS t
GROUP BY t.order_date;

-- 10) -- DETERMINE The TOP 3 Most Ordered pizza types based on revenue?

SELECT
pizza_types.name,
sum(orders_details.quantity * pizzas.price) AS revenue -- total revenue
FROM
orders_details
JOIN
pizzas
ON
orders_details.pizza_id = pizzas.pizza_id
JOIN
pizza_types
ON
pizza_types.pizza_type_id = pizzas.pizza_type_id
group by
pizza_types.name
order by revenue desc
limit 3;

-- 11) -- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    SUM(orders_details.quantity * pizzas.price)
                FROM
                    pizzas
                        JOIN
                    orders_details ON pizzas.pizza_id = orders_details.pizza_id) * 100,
            2) AS total_revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_revenue DESC;


-- 12) -- Analyze the cumulative revenue generated over time? -- cumulative revenue means runtime total revenue

USE pizza_hut;

SELECT
order_date,
sum(total_revenue) over (order by order_date)
from
(SELECT
 orders.order_date,
 sum(orders_details.quantity * pizzas.price) AS total_revenue
 FROM
 pizzas
 JOIN 
 orders_details
 ON
 pizzas.pizza_id = orders_details.pizza_id
 JOIN
 orders
 ON
 orders_details.order_id = orders.order_id
 GROUP BY 
 orders.order_date) AS t ;
 
 -- 13) -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
 
  SELECT
  category,
   name,
   total_revenue,
   rk
   FROM
 (SELECT
  category,
   name,
   t.total_revenue,
   RANK() OVER (partition by category order by total_revenue desc )AS rk
   FROM
 (SELECT
 pizza_types.category,
  pizza_types.name,
 SUM(orders_details.quantity * pizzas.price) AS total_revenue
 FROM
 pizzas
 JOIN
 pizza_types
 ON
 pizzas.pizza_type_id = pizza_types.pizza_type_id
 JOIN
 orders_details
 ON
 pizzas.pizza_id = orders_details.pizza_id
 GROUP BY 
  pizza_types.category,
    pizza_types.name
  order by  pizza_types.category desc) As t ) AS x
  where rk <= 3;
  
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 








