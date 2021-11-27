use classicmodels;

-- ch5.1번
-- 고객의 국가(country) 별 고객수를 검색하세요.
-- 출력 컬럼은 country, 고객수 순으로 합니다.

select country, count(customernumber)
from customers
group by country;

-- ch.2번
-- 주문에서 상태(status)별 주문수를 검색하세요.
-- 단, 주문일(orderDate)의 7일 내에 배송(shippedDate)이 이루어진 주문만 주문수에 포함합니다.
-- 출력 컬럼은 status, 주문수 순으로 합니다.

select status, count(orderNumber)
from orders
where shippedDate <= orderDate + interval 7 day
group by status;


-- ch5.3번
-- 15개 이상의 상품이 포함된 주문에 대해, 포함된 상품 주문액의 합계를 검색하세요.
-- 상품 주문액은 주문단가(priceEach)와 주문개수(quantity)의 곱으로 계산합니다.
-- 출력 컬럼은 orderNo, 상품수, 주문액합계 순으로 합니다.
-- 결과는 삼품수의 내림차순, 주문액합계의 내림차순으로 정렬합니다.

select orderNumber, count(productcode), sum(priceEach*quantityordered)
from orderdetails
group by ordernumber having count(productcode) >= 15
order by 2 desc, 3 desc;


-- ch5.4번
-- 주문에 포함된 상품수의 평균, 그리고 주문에 포함된 모든 상품 주문액 합계의 평균을 계산하세요.
-- 출력 컬럼은 주문수, 상품수의 평균, 주문액 합계의 평균 순으로 합니다.
-- 단, 주문에 포함된 각 상품의 주문액은 주문단가(priceEach)와 주문개수(quantity)의 곱으로 계산합니다.
-- 또한, 상품수의 평균과 주문액 합계의 평균은 모두 소수 세째자리에서 반올림하여 소수 둘째자리까지 구합니다.

with temp as 
(select orderNumber, count(productcode) '상품수', sum(priceEach*quantityordered) '주문액합계'
from orderdetails
group by ordernumber)
select count(orderNumber) '주문수', round(avg(상품수),2) '상품수평균', round(avg(주문액합계),2) '주문액평균'
from temp;

-- ch5.6번
-- 완료예정일(requiredDate)을 포함하여 그 이후에 배송(shippedDate)된 주문을 검색하세요.
-- 출력 컬럼은 orderNo, orderDate, shippedDate, requiredDate 순으로 합니다.
-- 이때 결과는 orderDate의 오름차순으로 정렬합니다.
select orderNumber, orderDate, shippedDate, requiredDate
from orders
where shippedDate >= requiredDate
order by orderDate;


-- ch5.9번
-- 권장소비자가(MSRP)가 가장 큰 25개 상품을 검색하세요.
-- 단, MSRP는 소수점 이하를 버리고 비교 및 출력하세요.
-- 출력 컬럼은 행번호, productCode, name, MSRP 순으로 합니다.
-- 이 때 결과는 MSRP의 내림차순, name의 오름차순으로 정렬합니다.

select row_number() over(order by floor(msrp) desc) as 행번호,
productcode, productname, floor(msrp)
from products
limit 25;

with temp as
(
select row_number() over(order by floor(msrp) desc, productname) as 행번호,
productcode, productname, floor(msrp) as msrp
from products
)
select 행번호, productcode, productname, msrp
from temp
where 행번호 >= 25;


SELECT @rownum:=@rownum+1 as no,
        productCode,
        productname,
        floor(MSRP) as MSRP
from products, (SELECT @rownum:=0) TMP
order by 4 desc, 3
limit 25;