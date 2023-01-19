/*
	UPDATE with TRANSACTION
	for pgsql 2023.01
	
	
*/
--연습용 테이블 생성
drop table if exists o;
select * into o	from orders;

select * from o;

BEGIN;
	update o 	set order_date = now() 	where order_id = 10248;
	select * from o where order_id = 10248;
COMMIT;
select * from o where order_id = 10248;


BEGIN;
	update o 	set order_date = now();
	select * from o ;	--으악!!!
ROLLBACK;
select * from o;	---휴~~~
