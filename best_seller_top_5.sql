use classicmodels;

# 미국 지역의 연도별 상위 판매 top 5 제품명 추출하기
# 보여줄 컬럼 : productName, sales(매출액), rnk(dense_rank)
# 필요한 테이블 : orders, customers, orderdetails, products

# drop table usa_car;

# USA_CAR 라는 새로운 테이블을 만들기
create table classicmodels.USA_CAR as
select p.productname,
sum(od.quantityOrdered * od.priceEach) as sales
from orders o
left
join customers c
on o.customerNumber = c.customerNumber
left
join orderdetails od
on o.orderNumber = od.orderNumber
left
join products p
on od.productcode = p.productcode
where c.country = 'USA'
group 
by 1;

# 새로 만든 테이블 확인
select * from usa_car;

# 미국의 판매 top5 차량 모델 추출

select productname,
sales,
dense_rank() over(order by sales desc) as rnk
from usa_car
order
by 2 desc
limit 5;