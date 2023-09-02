use pizza;
-- alter table pizza_sales modify order_date Date;
-- SELECT DATE_FORMAT(order_date1, "%M %d %Y") from pizza_sales;
-- SELECT DATA_TYPE from INFORMATION_SCHEMA. COLUMNS where table_schema = 'pizza' and table_name = 'pizza_sales'



select * from pizza_sales

-- CHARTS REQUIREMENTS
--  Daily trends for total orders
-- SELECT dayname(order_date1) as order_day, count(distinct order_id) as Total_Orders
-- from pizza_sales
-- group by dayname(order_date1);

-- changing order_date1 column to date formate by adding new column order_date2
-- alter table pizza_sales
-- add order_date2 Date;

-- update pizza_sales
-- set order_date2 = str_to_date(order_date1, '%Y-%m-%d')


-- dropping order_date1 column1
-- ALTER TABLE pizza_sales
-- DROP COLUMN order_date1; 

-- to chane column name
-- alter table pizza_sales
-- change order_date2 order_date date;

-- select monthname(order_date) as Month_Name, count(distinct order_id) as Total_Orders from Pizza_sales
-- group by monthname(order_date);


-- percentage of sales by pizza category

select pizza_category, sum(total_price)*100 / (select sum(total_price) from pizza_sales) as PCT
from pizza_sales
group by pizza_category;


-- we can get above data for each month suppose for januaray month is 1
select pizza_category, sum(total_price)*100 / (select sum(total_price) from pizza_sales where month(order_date) = 1) as Total_Sales
from pizza_sales
where month(order_date) = 1
group by pizza_category;

-- percentage of sales per pizza_size
select pizza_size, round(sum(total_price)*100 / (select sum(total_price) from pizza_sales), 2) as PCT
from pizza_sales
group by pizza_size
order by PCT DESC;

-- total revenue as per top 5 pizza_name
select pizza_name, sum(total_price) as Total_Revenue from pizza_sales
group by pizza_name
order by Total_Revenue DESC
limit 5;

-- total revenue as per bottom 5 pizza_name
select pizza_name, sum(total_price) as Total_Revenue from pizza_sales
group by pizza_name
order by Total_Revenue 
limit 5;

-- total rows 
select count(*) from pizza_sales;
 
 -- top 50 percent rows only