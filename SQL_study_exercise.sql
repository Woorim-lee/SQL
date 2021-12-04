use classicmodels;

select country, count(*) '평균 고객수'
from customers
group by country
order by 2 desc;

with temp as 
(select country '국가', count(*) '고객수'
from customers
group by country)
select round(avg(고객수),2) '평균 고객수'
from temp;

select productline '상품라인', count(*) '상품수'
from products
group by productline
having productline in ('ships', 'trains');

select productline '상품라인', count(*) '상품수'
from products
where productline in ('ships', 'trains')
group by productline;


-- 주문에서 상태(status)별 주문수를 검색하세요.
-- 단, 주문일(orderDate)의 7일 내에 배송(shippedDate)이 이루어진 주문만 주문수에 포함합니다.
-- 출력 컬럼은 status, 주문수 순으로 합니다.

select * from orders;

SELECT status, count(*) 주문수
from orders
where DATEDIFF(shippedDate, orderDate) <= 7
group by status;

-- 틀린거...!
SELECT status, count(*) 주문수
from orders
where shippedDate - orderDate <= 7
group by status;


-- 15개 이상의 상품이 포함된 주문에 대해, 포함된 상품 주문액의 합계를 검색하세요.
-- 상품 주문액은 주문단가(priceEach)와 주문개수(quantity)의 곱으로 계산합니다.
-- 출력 컬럼은 orderNo, 상품수, 주문액합계 순으로 합니다.




-- 주문에 포함된 상품수의 평균, 그리고 주문에 포함된 모든 상품 주문액 합계의 평균을 계산하세요.
-- 출력 컬럼은 주문수, 상품수의 평균, 주문액 합계의 평균 순으로 합니다.
-- 단, 주문에 포함된 각 상품의 주문액은 주문단가(priceEach)와 주문개수(quantity)의 곱으로 계산합니다.
-- 또한, 상품수의 평균과 주문액 합계의 평균은 모두 소수 세째자리에서 반올림하여 소수 둘째자리까지 구합니다.

select * from orderdetails;

with temp as(
select count(productCode) '상품수', sum(priceEach * quantityOrdered) '주문액합계'
from orderdetails)
select avg(주문액합계)
from temp;


with temp as
(select orderNumber, count(productCode) '상품수',
sum(priceEach * quantityOrdered) '주문액 합계'
from orderdetails
group by orderNumber)
select *
from temp
where 상품수 >= 15;


select orderNumber '주문', count(productCode) '상품수', sum(priceEach * quantityOrdered) '주문액 합계'
from orderdetails
group by 1;



with temp as
(select orderNumber '주문', count(productCode) '상품수', sum(priceEach * quantityOrdered) '주문액합계'
from orderdetails
group by orderNumber)
select count(주문) '주문수', round(avg(상품수),2) '상품수의 평균', round(avg(주문액합계),2) '주문액 합게의 평균'
from temp;



-- 한 종류의 상품라인(productLine)에 속하는 상품으로만 이루어진 주문을 검색하세요.
-- 이 때, 하나의 상품만 포함된 주문은 제외하세요.
-- 출력 컬럼은 orderNo, 상품수, productLine 순으로 합니다.
-- 결과는 상품수의 내림차순, orderNo의 오름차순으로 정렬합니다.

select * from products;

select od.orderNumber, od.productCode, p.productLine
from orderdetails od
left
join products p
on od.productCode = p.productCode
order by 2 desc, 1;


select od.orderNumber, od.productCode, p.productLine
from orderdetails od
left
join products p
on od.productCode = p.productCode
where p.productLine;


with temp as
(select od.orderNumber orderNo, od.productCode productCode, p.productLine productLine
from orderdetails od
left
join products p
on od.productCode = p.productCode
)
select orderNo, count(productCode) '상품수', productLine
from temp
group by 3, 1
having 상품수 > 1
order by 2 desc, 1;

select * from products;

select orderNumber, orderDate, shippedDate, requiredDate
from orders
where datediff(requiredDate, shippedDate) < 0
order by orderDate;


SELECT productline, avg(buyPrice) '평균구매단가', avg(MSRP) '평균권장소비자가'
from products
group by productline;


SELECT row_number() over(order by MSRP desc) 'no', productCode, productname, TRUNCATE(MSRP,0) MSRP, rank() over(order by MSRP desc) 순위
from products, (SELECT @rownum:=0) TMP
order by 4 desc, 3
limit 25;

SELECT * FROM PRODUCTS;

select max(productscale)
from products;

select * from orderdetails;

with temp as
(
select orderNumber, productCode, priceEach, quantityOrdered, TRUNCATE(priceEach*quantityOrdered,0) '주문액'
from orderdetails
where orderNumber = 10127
)
select orderNumber, productCode, priceEach, quantityOrdered, 주문액
from temp
where 주문액 >= 5000
order by 5 desc;

