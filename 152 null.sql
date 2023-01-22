/*
	coalesce, 연산과 null, where, patter matching, is null
	전문가로 가는 지름길 1 / 개발자용 5장 스크립트
 	정원혁 2000.1
	for pgsql 2022.11	
*/

/*
 * coalesce
 */
select coalesce(3, 1), coalesce(null, 1), coalesce(3, null);
select coalesce(null, null, 3), coalesce(null, null, 3, null);

select customer_id , city, region, coalesce (region, 'N/A') from customers;
select customer_id , city, region, coalesce (region, 'N/A') from customers where region is null;
select customer_id , city, region, coalesce (region, 'N/A') from customers where region is not null;


(select order_id , freight from orders o limit 3) 
union all
(select 11111 , null from orders o  limit 1);



/*
 * WHERE
 * 
 * select 컬럼
 * from 테이블
 * where 컬럼 = 값
*/

select * from customers c ;

select * from customers c where city = 'Berlin';

select * from customers c where country = 'Mexico';
select * from customers c where country = 'Mexico' and contact_title = 'Owner';
select * from customers c where country = 'Mexico' or contact_title = 'Owner';

select * from customers c where region is null;
select * from customers c where region is not null;



select * from orders o;
select * from orders o where freight < 1;
select * from orders o where freight < 1 and order_date <= '19961231';

-- 정규식 Regualar Expression
-- https://www.postgresql.org/docs/15/functions-matching.html
-- 이것만 공부하는데 하루 걸린다
-- 공부해 두면 수 만 시간의 '헛수고|삽질|노.가.다' 를 줄일 수 있다.
-- 더 공부하려면 
-- https://ahkscript.github.io/ko/docs/misc/RegEx-QuickRef.htm
-- https://regexr.com/
-- https://regexr.com/3d0tf
select ship_name from orders o order by ship_name;
select ship_name from orders o where ship_name like '%Restaurant%';
select ship_name from orders o where ship_name like 'Lone%';
select ship_name from orders o where ship_name like 'Lone%';

select ship_name from orders o where ship_name like 'Al%' or ship_name like 'Ar%' 	order by ship_name;
select ship_name from orders o where ship_name similar to 'A(l|r)%'	order by ship_name;

select ship_name from orders o where ship_name >= 'B' order by ship_name;
select ship_name from orders o where ship_name !~ '^(A|a)' order by ship_name;




