use classicmodels;

# orders, customers, orderdetails 총 3 테이블 join 
# orders, customers = customerNumber로 연결
# orders, orderdetails = ordernumber로 연결
select *
from orders o
left
join orderdetails od
on o.ordernumber = od.ordernumber
left
join customers c
on o.customerNumber = c.customerNumber;

# 계산에 필요한 칼럼만 추출 (country, city, priceEach * quantityOrdered)
select country,
city,
(priceEach * quantityOrdered) as sales
from orders o
left
join orderdetails od
on o.ordernumber = od.ordernumber
left
join customers c
on o.customerNumber = c.customerNumber;

# 국가별, 도시별 매출액
select c.country,
c.city,
sum(priceEach * quantityOrdered) as sales
from orders o
left
join orderdetails od
on o.ordernumber = od.ordernumber
left
join customers c
on o.customerNumber = c.customerNumber
group
by 1,2
order
by 1,2;

# 북미(USA, Canada), 비북미 매출액 비교
select (case when c.country in ('USA', 'Canada') then '북미' else '비북미' end) as region,
sum(priceEach * quantityOrdered) as sales
from orders o
left
join orderdetails od
on o.ordernumber = od.ordernumber
left
join customers c
on o.customerNumber = c.customerNumber
group
by 1;