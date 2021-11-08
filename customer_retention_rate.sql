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