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
select substr(o.orderDate,1,4) year,
round(sum(priceEach * quantityOrdered)) sales
from orders o
left join orderdetails d
on o.orderNumber = d.orderNumber
group by 1
order by 1;

# order 번호가 중복되는 값이 있는지 확인 (정확히는 테이블 컬럼 속성을 보고 PK로 중복을 허용하지 않는지 확인하면 됨!)
select count(ordernumber) N_orders,
count(distinct ordernumber) N_orders_distinct
from orders;

# 일별 구매자수 조회
select orderdate,
count(distinct customerNumber) as N_purchaser,
count(ordernumber) as N_orders
from orders
group
by 1
order
by 1;

# 월별 구매자수 조회
select substr(orderDate,1,7) mm,
count(distinct customerNumber) as N_purchaser,
count(ordernumber) as N_orders
from orders
group
by 1
order
by 1;

# 연도별 구매자수 조회
select substr(orderDate,1,4) year,
count(distinct customerNumber) as N_purchaser,
count(ordernumber) as N_orders
from orders
group
by 1
order
by 1;

# 연도별 인당 매출액 (고객 1명이 우리 서비스에 얼마를 지불하는지 그 변화를 파악)
select substr(o.orderDate, 1, 4) year,
count(distinct o.customerNumber) as N_purchaser,
round(sum(priceEach * quantityOrdered)) as sales,
round(sum(priceEach * quantityOrdered) / count(distinct o.customerNumber), 2) as amv
from orders o
left 
join orderdetails d
on o.orderNumber = d.orderNumber
group 
by 1
order 
by 1;

# 연도별 건당 구매금액 (ATV, Average Transaction Value)
# 1건의 거래는 평균 얼마의 매출을 발생시키는가!?
select substr(o.orderDate, 1, 4) year,
count(distinct o.ordernumber) as N_purchaser,
round(sum(priceEach * quantityOrdered)) as sales,
round(sum(priceEach * quantityOrdered) / count(distinct o.ordernumber), 2) as ATV
from orders o
left 
join orderdetails d
on o.orderNumber = d.orderNumber
group 
by 1
order 
by 1;