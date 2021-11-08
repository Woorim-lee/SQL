use classicmodels;

# 연도별 재구매율
# 재구매율이란 특정기간 구매자 중 특정기간에 연달아 구매한 구매자의 비중
select o.customerNumber,
o.orderdate,
o2.customerNumber,
o2.orderdate
from orders o
left
join  orders o2
on o.customerNumber = o2.customerNumber 
and substr(o.orderdate,1,4) = substr(o2.orderdate,1,4) -1;

# 국가별 2004, 2005 retention rate(%) 구하기
select c.country,
substr(o.orderdate,1,4) yy,
count(distinct o.customerNumber) buy_1,
count(distinct o2.customerNumber) buy_2,
count(distinct o2.customerNumber) / count(distinct o.customerNumber) retention_rate
from orders o
left
join orders o2
on o.customerNumber = o2.customerNumber
and substr(o.orderdate,1,4) = substr(o2.orderdate,1,4) -1
left
join customers c
on o.customerNumber = c.customerNumber
group
by 1,2;

# 미국의 판매 top5 차량 모델 추출
create table classicmodels.USA_CAR as
select o.ordernumber, c.country, od.productcode, od.quantityOrdered
from orders o
left
join customers c
on o.customerNumber = c.customerNumber
left
join orderdetails od
on o.orderNumber = od.orderNumber
where c.country = 'USA';