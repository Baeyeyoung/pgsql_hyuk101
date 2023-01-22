/*
	JOIN
	for pgsql 2023.01order_id	
*/

/*
 * 예제 테이블 만들기: 아주 작아서 이해하기 쉬운
 * study 스키마를 사용한다.
 * 충분히 공부가 되었으면 public 스키마에서 다시 해본다.
 */
create schema if not exists study;
drop table if exists study.orders;
drop table if exists study.customers;
drop table if exists study.employees;

SELECT order_id, customer_id, employee_id, order_date  into study.orders FROM public.orders limit 5;
insert into study.orders values (20253, 'VINET', 5, '1996-08-04');
SELECT customer_id, company_name into study.customers FROM public.customers 
WHERE customer_id in (SELECT customer_id  FROM study.orders) limit 4;
insert into study.customers values ('TWINK', 'Twinkle Star');
SELECT employee_id, first_name, last_name into study.employees FROM public.employees limit 5;

set search_path to study; 
--	set search_path to public;
show search_path;

--먼저 무슨 데이터가 있나 보자. 
--구글 시트/ 엑셀에 복사해서 비교하면 더 이해하기 쉽다.
SELECT * FROM orders;
SELECT * FROM customers;
SELECT * FROM employees;




/*
 * 기본 
 SELECT 
 FROM a 
 	JOIN b ON a.id = b.id
 */

--나쁜 방법. 
SELECT order_id, company_name
FROM orders, customers
WHERE orders.customer_id = customers.customer_id;

--바른 방법
SELECT 	order_id, company_name
FROM 	orders 
	INNER JOIN customers 	ON orders.customer_id = customers.customer_id; 

--INNER 생략 가능
SELECT 	order_id, company_name
FROM 	orders 
	JOIN customers 	ON orders.customer_id = customers.customer_id; 

--별명. alias
SELECT 	order_id, company_name
FROM 	orders o 
	JOIN customers c 	ON o.customer_id = c.customer_id;

--오류: 섞어 쓸 수 업다.
--SELECT 	order_id, company_name
--FROM 	orders o 
--	JOIN customers c	ON orders.customer_id = customers.customer_id; 

--사실 <테이블>.<컬럼> 이 제대로 된 이름, 생략 않고 쓴다면
SELECT 	o.order_id, c.company_name, o.customer_id 
FROM 	orders o 
	JOIN customers c	ON o.customer_id = c.customer_id;

--컬럼 이름이 고유하다면 테이블 이름은 생략가능 
SELECT 	order_id, company_name, o.customer_id 
FROM 	orders o 
	JOIN customers c	ON o.customer_id = c.customer_id;


--연결 고리만 있다면 한 없이(?) JOIN 가능
SELECT * FROM orders limit 1;
SELECT * FROM employees e2 limit 1;

SELECT 	order_id, company_name, first_name, last_name
FROM 	orders o 
	JOIN customers c	ON o.customer_id = c.customer_id
	JOIN employees e	on o.employee_id = e.employee_id 
;


/*
 * JOIN 종류
 * 
 * 1. INNER 매우 정상. INNER 키워드는 보통 생략
 * 2. OUTER	그럴만한 이유가 있을 때. OUTER 키워드도 생략 가능
 *    a) LEFT | RIGHT: 그럴만한 이유가 있을 때.
 *    b) FULL: 매우 비정상
 * 3. CROSS 매우 비정상
 */

SELECT 	order_id, company_name, o.customer_id, c.customer_id 
FROM 	orders o 
	LEFT OUTER JOIN customers c 	ON o.customer_id = c.customer_id;

SELECT 	o.*, c.* 
FROM 	orders o 
	LEFT OUTER JOIN customers c 	ON o.customer_id = c.customer_id;

--OUTER 생략
SELECT 	o.*, c.* 
FROM 	orders o 
	LEFT JOIN customers c 	ON o.customer_id = c.customer_id;

--의미: 유령 거래. 장부 조작.
SELECT 	o.*, c.* 
FROM 	orders o 
	LEFT JOIN customers c 	ON o.customer_id = c.customer_id
WHERE c.customer_id is null;

SELECT 	o.*, c.* 
FROM 	orders o 
	RIGHT JOIN customers c 	ON o.customer_id = c.customer_id
WHERE o.customer_id is null;
--의미: 단한번도 주문이 없는 고객

--FULL OUTER
SELECT 	o.*, c.* 
FROM 	orders o 
	FULL JOIN customers c 	ON o.customer_id = c.customer_id;


--CROSS
SELECT 	*
FROM 	orders o 
	CROSS JOIN customers c 	--no on....
;



/*
 * Equi JOIN / Non Equi JOIN
 * ON 에서 eqaul == 인가?
 */
-- 실제 의미는 없지만. 억지 예제.
SELECT o.order_id, o.employee_id, e.employee_id
FROM orders o
	JOIN employees e 	on o.employee_id > e.employee_id;



/*
 * Self JOIN
 * 같은 테이블끼리 JOIN
 */

--두번 주문한 고객?
SELECT o.order_id, o.customer_id,  o.order_date
FROM orders o
order by o.customer_id,  o.order_date;

--INNER JOIN 일 때는 차이 없다.
--1a
SELECT o.order_id, o.customer_id,  o.order_date, o2.order_date 
FROM orders o
	JOIN orders o2	on o.customer_id  = o2.customer_id  
		and o.order_date < o2.order_date
order by o.customer_id,  o.order_date;

--1b
SELECT o.order_id, o.customer_id,  o.order_date, o2.order_date 
FROM orders o
	JOIN orders o2	on o.customer_id  = o2.customer_id  
WHERE o.order_date < o2.order_date
order by o.customer_id,  o.order_date;


--OUTER JOIN 일 때는 다르다.
--2a
SELECT o.order_id, o.customer_id,  o.order_date, o2.order_date 
FROM orders o
	LEFT JOIN orders o2	on o.customer_id  = o2.customer_id  
		and o.order_date < o2.order_date
order by o.customer_id,  o.order_date;

--2b
SELECT o.order_id, o.customer_id,  o.order_date, o2.order_date 
FROM orders o
	LEFT JOIN orders o2	on o.customer_id  = o2.customer_id  
WHERE o.order_date < o2.order_date
order by o.customer_id,  o.order_date;


