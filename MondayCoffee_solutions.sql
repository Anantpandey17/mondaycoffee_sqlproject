======MondayCoffee -------Data Ananlysis------

select * from city;
select * from products;
select * from customers;
select * from sales;

=====Report & Data Ananlysis=====
1) Coffee Consumers Count
How many people in each city are estimated to consume coffee, given that 25% of the population does?

select city_name,
round(
(population*0.25)/1000000,2) as CoffeeConsumer_millions,
city_rank
from city
order by population desc;

2) Total Revenue from Coffee Sales
What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select city_name,
sum(total) as total_revenue
from sales as s
join customers as c on c.customer_id = s.customer_id
join city as ci on ci.city_id = c.city_id
where year(sale_date) = 2023 and quarter(sale_date) = 4
group by city_name
order by sum(total) desc;

3) Sales Count for Each Product
  How many units of each coffee product have been sold?
  
  select p.product_name, 
  count(s.sale_id) as totalorders
  from products p
  left join sales s
  on s.product_id = p.product_id
  group by product_name
  order by totalorders desc;

4) Average Sales Amount per City
   What is the average sales amount per customer in each city?
   
   select city_name,
sum(total) as total_revenue,
count(distinct s.customer_id) as total_cx,
round(sum(total)/count(distinct s.customer_id),2) as avg_sale_pr_cx
from sales as s
join customers as c on c.customer_id = s.customer_id
join city as ci on ci.city_id = c.city_id
group by city_name
order by total_revenue desc;

5) City Population and Coffee Consumers (25%)
 Provide a list of cities along with their populations and estimated coffee consumers.
 
 with city_table as
 ( Select city_name,
 round(population * 0.25/1000000,2) as coffee_consumers_mln
 from city ), 
 customers_table as
(select ci.city_name,
 count(distinct c.customer_id) as unique_cx
 from sales s
 join customers c
 on c.customer_id = s.customer_id
 join city ci
 on ci.city_id = c.city_id
 group by city_name)
 select customers_table.city_name, 
 city_table.coffee_consumers_mln,
 customers_table.unique_cx
 from city_table 
 join customers_table
 on city_table.city_name = customers_table.city_name
 
 6) Top Selling Products by City
 What are the top 3 selling products in each city based on sales volume?
 
WITH temp
   AS
  (select ci.city_name ,
 p.product_name,
 count(s.sale_id) as total_order,
 dense_rank() over(partition by city_name order by count(sale_id) desc) rnk
 from sales s
 join products p on s.product_id = p.product_id
 join customers c on c.customer_id = s.customer_id
 join city ci on ci.city_id = c.city_id
 group by city_name , product_name 
 order by city_name, total_order) 
 select city_name,product_name,total_order,rnk from temp
 where rnk <=3
 order by city_name,total_order desc;

 7) Customer Segmentation by City
  How many unique customers are there in each city who have purchased coffee products?
  
  select ci.city_name,
  count(distinct(c.customer_id)) as unique_cx
  from city ci
  join customers c
  on c.city_id = ci.city_id
  join sales s
  on s.customer_id = c.customer_id
  where s.product_id between 1 and 14
  group by city_name;
   
8) Average Sale vs Rent
 Find each city and their average sale per customer and avg rent per customer
 
  WITH city_table as
  (   select ci.city_name, sum(s.total) as total_revenue,
count(distinct s.customer_id) as total_cx,
round(sum(total)/count(distinct s.customer_id),2) as avg_sale_pr_cx
from sales as s
join customers as c on c.customer_id = s.customer_id
join city as ci on ci.city_id = c.city_id
group by city_name
order by total_cx desc  ),
city_rent as
( select city_name,
estimated_rent 
from city )
select cr.city_name,
cr.estimated_rent, ct.total_cx,
ct.avg_sale_pr_cx, round(cr.estimated_rent/ct.total_cx,2) as avg_rent_prcx
from city_rent cr
join city_table ct on cr.city_name = ct.city_name
order by avg_sale_pr_cx desc;

9) Monthly Sales Growth
   Sales growth rate: Calculate the percentage growth (or decline) in sales over different 
   time periods (monthly), by each city 
   
	   with monthly_sale as
	   ( select ci.city_name,
	   month(s.sale_date) as month,
	   year(s.sale_date) as year,  sum(s.total) as total_sale from sales s
	   join customers c on c.customer_id = s.customer_id
	   join city ci
	   on ci.city_id = c.city_id
	   group by city_name,  month, year
	   order by city_name,  year,  month asc ),
	   growth_ratio as (select city_name,
	   month,  year,  total_sale as cr_monthly_sale,
	   lag(total_sale,1) over(partition by city_name order by year, month asc) as last_month_sale
	   from monthly_sale )
	   select city_name,  month, year,  cr_monthly_sale, last_month_sale,
	   round((cr_monthly_sale-last_month_sale)/last_month_sale*100,2) as growth_ratio
	   from growth_ratio
       where cr_monthly_sale is not null;
       
10) Market Potential Analysis
    Identify top 3 city based on highest sales, return city name, total sale, 
    total rent, total customers, estimated coffee consumer.
    
    WITH city_table as
  (   select ci.city_name, sum(s.total) as total_revenue,
count(distinct s.customer_id) as total_cx,
round(sum(total)/count(distinct s.customer_id),2) as avg_sale_pr_cx
from sales as s
join customers as c on c.customer_id = s.customer_id
join city as ci on ci.city_id = c.city_id
group by city_name
order by total_cx desc  ),
city_rent as
( select city_name,
estimated_rent , round(population*0.25/1000000,3) as coffee_consumers_mlns
from city )
select cr.city_name, total_revenue,
cr.estimated_rent as total_rent, ct.total_cx,coffee_consumers_mlns,
ct.avg_sale_pr_cx, round(cr.estimated_rent/ct.total_cx,2) as avg_rent_prcx
from city_rent cr
join city_table ct on cr.city_name = ct.city_name
order by total_revenue desc;
   











