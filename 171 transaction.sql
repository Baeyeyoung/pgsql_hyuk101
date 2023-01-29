/*
	트랜잭션
	for pgsql 정원혁 2023.01
	
	https://www.postgresql.org/docs/current/transaction-iso.html
*/

--세션1
START TRANSACTION ISOLATION LEVEL REPEATABLE READ;

begin;
	--이 날짜가 그대로 유지되어야 한다 
	SELECT max(order_date)
	FROM bigo b 
	WHERE ship_via = 3;
	
		--세션2: 새로운 쿼리를 열어 실행한다.		
		update bigo 
		set order_date = now()
		where ship_via = 3
			and order_id = (SELECT order_id FROM bigo ORDER BY random() LIMIT 1);
		
		--여기서는 오늘 날짜가 보인다.
		SELECT max(order_date)
			FROM bigo b 
			WHERE ship_via = 3;		
		--끝. 세션2	
			
	--세션1
	SELECT max(order_date)
	FROM bigo b 
	WHERE ship_via = 3;
	
COMMIT;


/*
 *	save transaction 
 */
--실험1
--혹시 모를 경우를 대비 한 rollback;
rollback;
update bigo set order_date = '1996-07-04' where order_id  = 10248;

begin;
	select order_id, order_date from bigo where order_id = 10248;
	update bigo set order_date = date_trunc('month', now()) - INTERVAL '6 month' where order_id = 10248;
	select order_id, order_date from bigo where order_id = 10248;
	
	SAVEPOINT six_month_ago;	
	--여러번 savepoint 를 다른 이름으로 지정하는 것도 가능하다.

	update bigo set order_date = date_trunc('month', now()) - INTERVAL '3 month'  where order_id = 10248;
	select order_id, order_date from bigo where order_id = 10248;
	SAVEPOINT three_month_ago;

--ROLLBACK TO: 전체 트랜잭션이 종료된다. 
ROLLBACK TO six_month_ago;
--결과는?
select order_id, order_date from bigo where order_id = 10248;



--실험2
--혹시 모를 경우를 대비 한 rollback;
rollback;
update bigo set order_date = '1996-07-04' where order_id  = 10248;

begin;
	select order_id, order_date from bigo where order_id = 10248;
	update bigo set order_date = date_trunc('month', now()) - INTERVAL '6 month' where order_id = 10248;
	select order_id, order_date from bigo where order_id = 10248;
	
	SAVEPOINT six_month_ago;	
	--여러번 savepoint 를 다른 이름으로 지정하는 것도 가능하다.

	update bigo set order_date = date_trunc('month', now()) - INTERVAL '3 month'  where order_id = 10248;
	select order_id, order_date from bigo where order_id = 10248;
	SAVEPOINT three_month_ago;

--ROLLBACK TO: 전체 트랜잭션이 종료된다. 
ROLLBACK TO three_month_ago;
--결과는?
select order_id, order_date from bigo where order_id = 10248;




--실험3
--혹시 모를 경우를 대비 한 rollback;
rollback;
update bigo set order_date = '1996-07-04' where order_id  = 10248;

begin;
	select order_id, order_date from bigo where order_id = 10248;
	update bigo set order_date = date_trunc('month', now()) - INTERVAL '6 month' where order_id = 10248;
	select order_id, order_date from bigo where order_id = 10248;
	
	SAVEPOINT six_month_ago;	
	--여러번 savepoint 를 다른 이름으로 지정하는 것도 가능하다.

	update bigo set order_date = date_trunc('month', now()) - INTERVAL '3 month'  where order_id = 10248;
	select order_id, order_date from bigo where order_id = 10248;
	SAVEPOINT three_month_ago;

	release three_month_ago;
	release six_month_ago;
commit;
--결과는?
select order_id, order_date from bigo where order_id = 10248;



--실험4
--혹시 모를 경우를 대비 한 rollback;
rollback;
update bigo set order_date = '1996-07-04' where order_id  = 10248;

begin;
	select order_id, order_date from bigo where order_id = 10248;
	update bigo set order_date = date_trunc('month', now()) - INTERVAL '6 month' where order_id = 10248;
	select order_id, order_date from bigo where order_id = 10248;
	
	SAVEPOINT six_month_ago;	
	--여러번 savepoint 를 다른 이름으로 지정하는 것도 가능하다.

	update bigo set order_date = date_trunc('month', now()) - INTERVAL '3 month'  where order_id = 10248;
	select order_id, order_date from bigo where order_id = 10248;
	SAVEPOINT three_month_ago;

	release six_month_ago;
	release three_month_ago;
commit;
--결과는?
select order_id, order_date from bigo where order_id = 10248;
