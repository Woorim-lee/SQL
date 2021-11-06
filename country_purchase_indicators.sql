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

# 매출 top5 국가 및 매출액
# creat table db명.table명 as
# table명으로 새로운 테이블을 생성할 수 있음
# 아래는 rank를 구하기위해 stat 이라는 테이블을 새로 만든 것!

create table classicmodels.stat as
select country,
sum(priceEach * quantityOrdered) as sales
from orders o
left
join orderdetails od
on o.ordernumber = od.ordernumber
left
join customers c
on o.customerNumber = c.customerNumber
group
by 1
order
by 2 desc;

# 새로운 테이블 stat 에서 RANK를 추가하여 (dense_rank 사용) 새로운 테이블 stat_rnk 생성
create table classicmodels.stat_rnk as
select country,
round(sales, 1) as sales,
dense_rank() over(order by sales desc) as rnk
from stat;

# drop table stat_rnk; 테이블 삭제

# alter table stat_rnk
# rename column rnk to dense_rnk; 테이블의 컬럼명 변경

# 새로운 테이블 stat_rnk 에서 top5 계산
select * 
from stat_rnk
where dense_rnk between 1 and 5;

# 서브 쿼리를 이용한 국가별 top5 매출액, 순위 추출
select *
from (select country,
dense_rank() over(order by sales desc) as rnk
from (select c.country,
sum(priceEach * quantityOrdered) as sales
from orders o
left
join orderdetails od
on o.ordernumber = od.ordernumber
left
join customers c
on o.customerNumber = c.customerNumber
group
by 1
order
by 2 desc) a ) a
where rnk <= 5 ;