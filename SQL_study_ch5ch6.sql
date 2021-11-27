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


-- ch6.2번
-- scale이 가장 큰 상품을 검색 검색하세요.
-- 출력 컬럼은 productCode, name, scale 순으로 합니다.
-- 결과는 scale의 내림차순, name의 오름차순으로 정렬합니다.
-- scale 형식을 보면, varchar 형식으로, 비교 할때는 형식을 바꿔주어야함!!

select productCode, productname, productscale
from products
order by cast(substring(productscale, locate(':', productscale) +1) as unsigned) desc, productname;


-- 아래 방법은 트릭! (scale 데이터가 모두 1:~ 으로 시작한다는 것을 알고 쓴 것..)
-- substring() + 0 을 붙여줘서 숫자로 변환함 (수치 비교가 가능하게 해줌)
-- 그런데.. 왠만하면 이렇게 사용하지 않았으면 함.. 
-- 쿼리를 짤 때는 모든 데이터에 적용이 가능한.. general하게 짜는게 좋음
-- 그리고 sql문은 모든사람이 봤을 때 최대한 쉽게 이해할 수 있도록 짜는게 좋음
select productCode, productname, productscale
from products
order by substring(productscale, 3) + 0 desc, productname;

-- ch6.3번
-- orderNo 10127에 포함된 상품 중, 주문액이 5,000불 이상인 상품을 검색하세요.
-- 상품의 주문액은 주문단가(priceEach)와 주문개수(quantity)의 곱으로 계산하며, 계산 결과에서 소수점 이하 숫자는 버립니다.
-- 출력 컬럼은 orderNo, productCode, priceEach, quantity, 주문액 순으로 합니다.
-- 이때 결과는 주문액의 내림차순으로 정렬합니다.

select ordernumber, productcode, priceeach, quantityordered, priceeach*quantityordered 주문액
from orderdetails
where ordernumber = 10127 and priceeach*quantityordered >= 5000
order by 5 desc;


-- ch6.4번 "어려운 문제!!" 이 칼럼은 s_employees 에만 있으므로 로컬 sql 에서는 작동 X
-- 오늘부터 1달 안에 생일(birthDate)을 맞을 직원을 검색하세요. (오늘이 09월 14일이면, 10월 13일까지 포함함)
-- 출력 컬럼은 성명, birthDate 순으로 합니다.
-- 단, 성명은 firstName과 lastName으로 구성하며, 사이에 공백 문자(space)가 하나 들어갑니다.
-- 이때 결과는 생일의 오름차순으로 정렬합니다.

select concat(firstname, ' ', lastname) 성명, birthdate
from employees
where (month(now()) = month(birthdate) and day(now()) <= day(birthdate)) or
(month(now() + interval 1 month) = month(birthdate) and day(birthdate) < day(now() + interval 1 month))
order by birthdate;

select * from employees;

-- ch6.5번
-- 직원의 성명과 생일(birthDate)을 검색하세요.
-- 성명은 firstName과 lastName으로 구성되며, 사이에 공백 문자(space)가 하나 들어갑니다.
-- 생일은 월, 일, 4자리 년도 순서로 나오고 사이사이에 점(.)이 들어갑니다. (USA 스타일)
-- 출력 컬럼은 성명, 생일 순으로 합니다.
-- 이때 결과는 생일의 오름차순으로 정렬합니다.

SELECT concat(firstname, ' ', lastname) 성명,
date_format(birthdate, get_format(date, 'USA')) as 생일
from s_employees
order by birthdate;


-- ch6.8번
-- 직원 이메일에서 아이디, 회사명, 도메인명을 분리하세요.
-- 예를 들어, id@company.com에서 아이디는 id, 회사명은 company, 도메인명은 com입니다.
-- 출력 컬럼은 직원의 성명, email, 아이디, 회사명, 도메인명 순으로 합니다.
-- 성명은 firstName과 lastName으로 구성되며, 사이에 공백 문자(space)가 하나 들어갑니다.
-- 결과는 성명의 오름차순으로 정렬합니다.
-- 질의 작성시 다음 내장함수를 사용할 수 있습니다.

-- REGEXP_SUBSTR(expr, pattern[, pos[, occurrence]]) : exp)의 
-- 문자열 내에 정규식 pattern과 일치하는 부분 문자열을 리턴함. pos는 검사의 시작 위치, 
-- occurrence는 일치하는 몇 번째 부분 문자열인지를 나타냄. 

select concat(firstname, ' ', lastname) as 성명,
		regexp_substr(email, '[^@]+') as 아이디,
        regexp_substr(regexp_substr(email, '[^@]+'), '[^\\.]+') as 회사명,
        regexp_substr(email, '[^\\.]+',1,2) as 도메인
from employees
order by 1;