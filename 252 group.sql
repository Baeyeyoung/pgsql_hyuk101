/*
	GRUOP
	for pgsql 2023.01 
	정원혁 2023.01

	https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-group-by/
*/

SELECT * FROM orders;

SELECT customer_id, freight FROM orders	order by customer_id ;

SELECT customer_id, sum(freight), avg(freight)
FROM orders	
group by customer_id 
order by customer_id ;

SELECT customer_id, sum(freight), avg(freight), max(order_date) 마지막주문일, min(order_date) 첫주문일
	, max(order_date) - min(order_date) 주문기간_일
FROM orders	
group by customer_id 
order by customer_id ;


/* 
 * 아주 흔한 오류
 * group by에 나오지 않는 컬럼은 select에 나타날 수 없다. 오직 aggregate 함수와 함께 나타날 수 있다.
 */

--SQL Error [42803]: ERROR: column "orders.order_date" must appear in the GROUP BY clause or be used in an aggregate function
SELECT customer_id, order_date
	, sum(freight), avg(freight)
FROM orders	
group by customer_id 
order by customer_id ;

--해결 방법1: gruop by에 없는 컬럼 제거
SELECT customer_id
	, sum(freight), avg(freight)
FROM orders	
group by customer_id 
order by customer_id ;

--해결 방법2: group by 에 컬럼 추가. 오류는 안나지만, 의미가 있을까?
SELECT customer_id, order_date
	, sum(freight), avg(freight)
FROM orders	
group by customer_id, order_date 
order by customer_id, order_date ;




/*
 * WHERE 와 HAVING 차이
 * WHERE: 예선 탈락
 * HAVING: 본선 탈락
 */
--1 
SELECT customer_id, sum(freight)
	, max(order_date) - min(order_date) 주문기간_일
FROM orders	
group by customer_id 
	having SUM(freight) > 2000
order by customer_id ;

--2
SELECT customer_id, sum(freight)
	, max(order_date) - min(order_date) 주문기간_일
FROM orders	
where freight > 500
group by customer_id 
order by customer_id ;

--3
SELECT customer_id, sum(freight)
	, max(order_date) - min(order_date) 주문기간_일
FROM orders	
where freight > 500
group by customer_id 
	having SUM(freight) > 2000
order by customer_id ;


