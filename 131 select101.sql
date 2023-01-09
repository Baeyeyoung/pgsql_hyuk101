/*
	전문가로 가는 지름길 1 / 개발자용
	제 3장 소스 스크립트 
	정원혁 2000.1
	for pgsql 2022.11
*/
--테이블 목록;
SELECT * FROM pg_catalog.pg_tables;

--줄 바꿈은 인간에게만 의미 있다.
SELECT * FROM orders;

SELECT * 
FROM orders;

--임의 컬럼 만들기
SELECT '주문 번호:', order_id, customer_id 
FROM orders;

SELECT '주문 번호:' as 내가만든컬럼, order_id, customer_id 
FROM orders;

SELECT '주문 번호:' 내가만든컬럼, order_id, customer_id 
FROM orders;

SELECT '주문 번호:' "특수 문자가 있을 때!", order_id, customer_id 
FROM orders;




