/*
	ROLLUP, CUBE with GRUOP
	for pgsql 2023.01 
	Á¤¿øÇõ 2023.01

	https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-group-by/
*/
SELECT customer_id, ship_via, sum(freight)
FROM orders	
where customer_id < 'C'
group by customer_id, ship_via 
order by customer_id, ship_via;


SELECT customer_id, ship_via, sum(freight)
FROM orders	
where customer_id < 'C'
group by rollup (customer_id, ship_via)	
order by customer_id, ship_via;


SELECT customer_id, ship_via, sum(freight)
FROM orders	
where customer_id < 'C'
group by cube (customer_id, ship_via)	
order by customer_id, ship_via;

