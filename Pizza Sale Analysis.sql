# create database 
create database  pizzahut;

# use database 
use pizzahut;

#check the tables data
select * from pizzahut.pizzas;
select * from pizzahut.pizza_types;
select * from orders;
select * from orders_details;


#create table 
create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) );

create table orders_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );

---------------------------------------------------- QUESTIONS -------------------------------------
#basic Questions

# Q1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

# Q2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;

#Q3. Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

#Q4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

# Q5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

#Intermediate Questions

# Q1. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
        JOIN
    orders ON orders_details.order_id = orders.order_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

#Q2. Determine the distribution of orders by hour of the day.
select hour(order_time) as hour, count(order_id) as order_count from orders
group by hour(order_time);

#Q3. Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

#Q4. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) as avg_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

#Q5. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


#Adwanced QUestions

#Q1. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    orders_details
                        JOIN
                    pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY revenue DESC;

#Q2. Analyze the cumulative revenue generated over time.
select order_date,sum(revenue) over(order by order_date) as cum_revenue from 
(select orders.order_date,sum(orders_details.quantity * pizzas.price) as revenue from orders_details 
join pizzas on orders_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = orders_details.order_id
group by order_date) as sale;

#Q3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue from
(select category,name,revenue,rank() over(partition by category order by revenue desc) as rn from 
(select pizza_types.category,pizza_types.name,sum( (orders_details.quantity) *(pizzas.price)) as revenue from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a ) as b
where rn <=3;

    
    
    


