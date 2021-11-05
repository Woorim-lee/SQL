use classicmodels;

select sum(amount), count(checknumber)
from payments;

select productName, productLine
from products;

select count(productCode) n_products
from products;

select distinct(ordernumber)
from orderdetails;

select *
from orderdetails
where priceeach between 30 and 50;

select * 
from orderdetails
where priceeach >= 30;

select customernumber
from customers
where country not in ('USA', 'Canada');

select employeenumber
from employees
where reportsTo is null;

select addressline1
from customers
where addressline1 like '%ST%';

select country, city, count(customernumber) n_customer
from customers
group
by country, city;

select sum(case when country = 'USA' then 1 else 0 end) N_USA,
sum(case when country = 'USA' then 1 else 0 end) / count(*) USA_PORTION
from customers;

select o.ordernumber, c.country
from customers c
left
join orders o
on c.customerNumber = o.customerNumber;

select o.ordernumber, c.country
from customers c
left
join orders o
on c.customerNumber = o.customerNumber
where c.country = 'USA';

select o.ordernumber, c.country
from customers c
inner
join orders o
on c.customerNumber = o.customerNumber
where c.country = 'USA';

select country, 
(case when country in ('USA', 'Canada') then '북미' else '비북미' end) region
from customers;

select (case when country in ('USA', 'Canada') then '북미' else '비북미' end) region, count(customernumber) n_customernumber
from customers
group
by 1;

select buyprice,
row_number() over(order by buyprice) 'row_number',
rank() over(order by buyprice) 'rank',
dense_rank() over(order by buyprice) 'dense_rank'
from products;

select buyprice,
row_number() over(partition by productline order by buyprice) 'row_number',
rank() over(partition by productline order by buyprice) 'rank',
dense_rank() over(partition by productline order by buyprice) 'dense_rank'
from products;

select ordernumber
from orders
where customerNumber in (select customerNumber from customers where city = 'NYC');

select customerNumber
from (select customerNumber 
from customers 
where city = 'NYC') A;

select ordernumber
from orders
where customerNumber in (select customerNumber 
from customers 
where country = 'USA');

