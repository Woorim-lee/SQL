use classicmodels;

# 일별 매출액 조회 
select o.orderDate, priceEach * quantityOrdered
from orders o
left join orderdetails d
on o.orderNumber = d.orderNumber;

# 월별 매출액 조회
select substr(o.orderDate,1,7) mm, sum(priceEach * quantityOrdered) sales
from orders o
left join orderdetails d
on o.orderNumber = d.orderNumber
group by 1
order by 1;

# 연도별 매출액 조회
select substr(o.orderDate,1,4) year, round(sum(priceEach * quantityOrdered)) sales
from orders o
left join orderdetails d
on o.orderNumber = d.orderNumber
group by 1
order by 1;