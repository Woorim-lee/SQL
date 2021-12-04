use classicmodels;

-- where절 조인
select employees.employeeNumber,
concat(employees.firstName, ' ',employees.lastName) name,
employees.jobtitle, offices.city
from employees, offices
where employees.officeCode = offices.officeCode;

-- from절 조인 (on절)
select employees.firstName, employees.lastName, offices.city
from employees join offices
on employees.officeCode = offices.officeCode;

-- from절 조인 (using절)
select employees.firstName, employees.lastName, offices.city
from employees join offices using (officeCode);


-- productLevel 칼럼을 새로 생성하고, 기존 products 테이블과 where 조인 및 level을 입력하는 쿼리문 작성
create table productLevels (
level ENUM('premium', 'high-end', 'mid-price', 'entry-level') NOT null,
low DECIMAL(10, 2) NOT null,
high DECIMAL(10,2) NOT null,
constraint pk_productLevel PRIMARY KEY(level)
);

select * from productLevels;

insert into productLevels values
('premium', 100.00, 300.00),
('high-end', 80.00, 99.99),
('mid-price', 50, 79.99),
('entry-level', 0.00, 49.99);

SELECT P.productname, P.MSRP, L.level
FROM products P, productLevels L
WHERE P.MSRP BETWEEN L.low AND L.high
ORDER BY 1;

-- 'USA'에 있는 지점에서 팔린 상품의 상품명과 개수를 검색
-- 1) 팔린 상품의 상품코드, 상품이름, 갯수 (가장 많이 팔린 상품)
select productCode, productName, sum(quantityOrdered) as cnt
from orderdetails join products using (productCode)
group by productCode
order by 3 desc;

-- 2) 'USA' 지점에서 팔린 상품의 상품명과 개수를 가장 많이 팔린 순서대로 검색
select productCode, productName, sum(quantityOrdered) as cnt
from offices O join employees using (officeCode)
	join customers on employeeNumber = salesRepEmployeeNumber
    join orders using (customerNumber)
    join orderdetails using (orderNumber)
    join products using (productCode)
where O.country = 'USA'
group by productCode
order by 3 desc;

-- 2004년도 결재한 모든 고객을 출력하라 단, 결재액이 없어도 0원으로 출력하게 해라
with paymentstemp as
(
select *
from payments
where year(paymentDate) = 2004
)
select customername 고객명, coalesce(sum(amount),0) 결재액
from customers left join paymentstemp using (customerNumber)
group by customerNumber
order by customername;


select orderNumber, count(products.productcode) 상품수, productline
from orderdetails, products
where orderdetails.productcode = products.productcode
group by orderNumber having count(products.productcode) >= 2 and count(distinct productline) = 1
order by 2 desc, 1;


-- 할인을 해주지 않고, 권장소비자가(MSRP)를 그대로 주문단가(priceEach)로 주문한 상품을 검색하세요.
-- where 조인을 사용하여!
-- 출력 컬럼은 상품의 productCode, name, 주문회수, priceEach, MSRP 순으로 합니다.
-- 결과는 주문회수의 내림차순, MSRP의 내림차순으로 정렬합니다.
select products.productCode, productName, count(*) 주문회수, priceEach, MSRP
from products, orderdetails
where products.productCode = orderdetails.productCode
and priceEach = MSRP
group by products.productCode
order by 3 desc, 5 desc;


-- 15개 이상의 상품이 포함된 주문에 대해, 포함된 상품 주문액의 합계를 검색하세요.
-- 단, 주문 상태(status)가 'Cancelled'인 주문은 제외합니다.
-- 상품의 주문액은 주문단가(priceEach)와 주문개수(quantity)의 곱으로 계산합니다.
-- 출력 컬럼은 orderNo, status, 상품수, 주문액합계 순으로 합니다.
-- 결과는 상품수의 내림차순, 주문액합계의 내림차순으로 정렬합니다.
select * from orderdetails;
select * from orders;

with temp as 
(
select orderNumber, count(productCode) 상품수, sum(priceEach*quantityOrdered) 주문액합계
from orderdetails
group by orderNumber having count(productCode) >= 15
)
select orderNumber, status, 상품수, 주문액합계
from temp
left join orders using (orderNumber)
where status <> 'Cancelled'
order by 3 desc, 4 desc;


-- 고객의 총 주문액을 검색하세요.
-- 상품의 주문액은 주문단가(priceEach)와 주문개수(quantity)의 곱으로 계산합니다.
-- 출력 컬럼은 customerId, name(고객명), 총주문액 순으로 합니다.
-- 결과는 customerId의 오름차순으로 정렬합니다.
-- 필요한 테이블 customers, orders, orderdetails
select * from customers;

select customerNumber, customerName, sum(priceEach*quantityOrdered) 총주문액
from customers join orders using (customerNumber)
			   join orderdetails using (orderNumber)
group by customerNumber
order by 1;

-- 총주문액과 총결재액이 같은 고객을 검색하세요.
-- 출력 컬럼은 customerId, name(고객명), 총주문액, 총결재액 순으로 합니다.
-- 결과는 customerId의 오름차순으로 정렬합니다.
-- 필요한 테이블 customers, orders, orderdetails, payments
select * from payments;

with temp as
(
select customerNumber, customerName, sum(priceEach*quantityOrdered) 총주문액
from customers join orders using (customerNumber)
			   join orderdetails using (orderNumber)
group by customerNumber
)
select customerNumber, customerName, 총주문액, sum(amount) 총결재액
from temp
join payments using (customerNumber)
group by customerNumber having 총주문액 = sum(amount)
order by 1;