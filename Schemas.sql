create database MondayCoffee_db;

use MondayCoffee_db;

=======Creating schemas========

create table city
( city_id int primary key,
city_name varchar(15),
population int,
estimated_rent float,
city_rank int
);

create table customers
(customer_id int primary key,
customer_name varchar(15),
city_id int,
constraint FOREIGN KEY (city_id) references city(city_id)
);

create table products
(product_id int primary key,
product_name varchar(35),
price float
);

create table sales
( sale_id int primary key,
  sale_date date,
  product_id int,
  customer_id int,
  total float,
  rating int,
  constraint FOREIGN KEY (product_id) references products(product_id),
  constraint FOREIGN KEY (customer_id) references customers(customer_id)
);

