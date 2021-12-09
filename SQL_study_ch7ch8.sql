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


-- 각 지점(s_offices.city) 별로, 소속 직원이 담당하는 고객수를 고객의 국가별로 검색하세요.
-- 출력 컬럼은 city (s_offices.city), country (s_customers.country), 고객수 순으로 합니다.
-- 결과는 city의 오름차순, country의 오름차순으로 정렬합니다.
-- customers, employees, office 테이블 필요
select * from offices;

with temp as
(
select O.city, C.country, customerNumber
from customers C
join employees E
on C.salesRepEmployeeNumber = E.employeeNumber
join offices O
using (officeCode)
)
select city, country, count(customerNumber)
from temp
group by country, city
order by city, country;


-- 각 직원에 대해, 본인이 관리하는 고객의 2004년 주문액의 합계를 검색하세요
-- 고객의 2004년 주문액은 orderDate 기준입니다
-- 상품의 주문액은 주문단가(priceEach)와 주문개수(quantity)의 곱으로 계산합니다
-- 출력 컬럼은 직원의 근무지점(s_offices.city), 성명, 주문액합계 순으로 합니다
-- 성명은 firstName과 lastName으로 구성되며, 사이에 공백 문자(space)가 하나 들어갑니다
-- 결과는 주문액합계의 내림차순으로 정렬합니다
-- orderDetails, orders, customers, employees, offices 테이블 필요

with temp as
(
select offices.city, salesRepEmployeeNumber, sum(quantityOrdered * priceEach) 주문액합계, lastName, firstName
from customers C
join orders O using (customerNumber)
join orderDetails OD using (orderNumber)
join employees E on C.salesRepEmployeeNumber = E.employeeNumber
join offices using (officeCode)
where year(orderDate) = 2004
group by salesRepEmployeeNumber
)
select city 근무지, concat(firstName, ' ', lastName) 성명, 주문액합계
from temp
order by 3 desc;


-- 각 직원에 대해, 본인이 관리하는 고객의 2004년 주문액 합계를 검색하세요.
-- 단, 관리하는 고객사가 없는 직원도 결과에 포함합니다.
-- 고객사의 2004년 주문액은 orderDate 기준입니다.
-- 상품의 주문액은 주문단가(priceEach)와 주문개수(quantity)의 곱으로 계산합니다.
-- 출력 컬럼은 직원의 근무지점(s_offices.city), 성명, 주문액합계 순으로 합니다.
-- 성명은 firstName과 lastName으로 구성되며, 사이에 공백 문자(space)가 하나 들어갑니다.
-- 결과는 주문액합계의 내림차순으로 정렬합니다.
-- left join을 쓰면서 where 조건을 정할때는 조심해야함..!!

with temp as
(
select *
from orders join orderdetails using (orderNumber)
where year(orderDate) = 2004
)
select O.city 근무지점, concat(firstName, ' ', lastName) 성명, sum(quantityOrdered * priceEach) 주문액합계
from offices O right join employees E using (officeCode)
			  left join customers C on E.employeeNumber = C.salesRepEmployeeNumber
              left join temp using (customerNumber)
group by employeeNumber
order by 3 desc;


-- orderDate 기준으로 2004년에, 주문회수가 많은 상위 50위까지의 상품을 검색하세요.
-- 출력 컬럼은 productCode, name, 주문회수, 순위 순으로 합니다.
-- 결과는 순위의 오름차순으로 정렬합니다.

select * from orders;

-- 내가 푼 것.. 순위 전체가 나옴!
with temp as
(
select *
from orders
where year(orderDate) = 2004
)
select orderdetails.productCode, productName, count(productCode) 주문회수, rank() over(order by count(productCode) desc) 순위
from temp left join orderdetails using (orderNumber)
		  left join products using (productCode)
group by productCode
order by 4;

-- 순위 50위까지만 출력
-- 별칭으로는 where 절 조건으로 사용할 수 없기 때문에, with 문으로 temp 테이블을 생성하여 사용
with temp as
(
select productCode, productName, count(productCode), rank() over(order by count(productCode) desc) 순위
from products join orderdetails using (productCode)
			  join orders using (orderNumber)
where year(orderDate) = 2004
group by productCode
)
select *
from temp
where 순위 <= 50
order by 4;

-- 고객의 담당직원(salesRepId) 성명과 결재액을 검색하세요.
-- 단, 담당직원이 없는 고객도 결과에 포함합니다.
-- 또, 결재액이 없는 고객도 결과에 포함하며, 이 경우 결재액은 0.00으로 출력합니다.
-- 출력 컬럼은 고객명(name), 담당직원의 성명, 결재액 순으로 합니다.
-- 담당직원 성명은 firstName과 lastName으로 구성하며, 사이에 공백 문자(space)가 하나 들어갑니다.
-- 결과는 고객명의 오름차순으로 정렬합니다.

select * from payments;

-- 내 풀이
with temp as
(
select customerName, sum(amount) 결재액, salesRepEmployeeNumber
from payments right join customers using (customerNumber)
group by customerName, salesRepEmployeeNumber
)
select customerName 고객명, concat(firstName, ' ', lastName) 담당직원성명, ifnull(결재액, 0.00)
from temp
left join employees on employees.employeeNumber = temp.salesRepEmployeeNumber
order by 1;

-- 추천 정답
-- coalesce 를 사용하는 것을 추천!! 가능하면 표준함수를 사용하는 것이 좋다
select customerName 고객명, concat(firstName, ' ', lastName) 담당직원성명, coalesce(sum(amount), 0.00) 결재액
from employees right join customers on employeeNumber = salesRepEmployeeNumber
			   left join payments using (customerNumber)
group by customerNumber
order by customerName;

-- 고객의 담당직원 성명과 2004년도 결재액을 검색하세요.
-- 단, 담당직원이 없는 고객도 결과에 포함합니다.
-- 또, 결재액이 없는 고객도 결과에 포함하며, 이 경우 결재액은 0.00으로 출력합니다.
-- 출력 컬럼은 고객명(name), 담당직원의 성명, 결재액 순으로 합니다.
-- 담당직원의 성명은 firstName과 lastName으로 구성하며, 사이에 공백 문자(space)가 하나 들어갑니다.
-- 결과는 고객명의 오름차순으로 정렬합니다.
-- 조인 먼저 실행하고 WHERE 절에서 조건을 주면, 결재가 없는 고객은 모두 제거됨.

select * from payments;

with temp as
(
select *
from payments
where year(paymentDate) = 2004
)
select customerName 고객명, concat(firstName, ' ', lastName) 판매담당직원성명, coalesce(sum(amount), 0.00) 결재액
from employees right join customers on employeeNumber = salesRepEmployeeNumber
			   left join temp using (customerNumber)
group by customerNumber
order by customerName;


-- self join (동일한 테이블을 논리적으로만 두 테이블이라고 가정하여 조인하는 것, 개념이 정확해야함 주의필요!!)
-- 직원과 직원의 상급자를 검색, 단, 상급자가 없는 직원도 포함.
select em.employeeNumber, concat(em.firstName, ' ', em.lastName) employee, em.jobtitle, 
	   mg.employeeNumber managerId, concat(mg.firstName, ' ', mg.lastName) manager
from employees em 
left join employees mg on em.reportsTo = mg.employeeNumber;


-- 직원 자신이 직접 관리하는 부하 직원수를 검색하세요.
-- 예를 들어, 사장이 직접 관리하는 부하 직원은 부사장만 해당됩니다.
-- 부하 직원이 없는 말단 직원도 모두 출력에 포함하며, 이때 부하 직원수는 0으로 출력합니다.
-- 출력 컬럼은 직원의 성명, jobTitle, 부하직원수 순으로 합니다.
-- 성명은 firstName과 lastName으로 구성되며, 사이에 공백 문자(space)가 하나 들어갑니다.
-- 결과는 성명의 오름차순으로 정렬합니다.
select concat(mg.firstName, ' ', mg.lastName) 성명, mg.jobTitle, count(em.employeeNumber) 부하직원수
from employees mg
left join employees em on mg.employeeNumber = em.reportsTo
group by mg.employeeNumber
order by 1;