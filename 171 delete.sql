/*
	트랜잭션
	for pgsql 2023.01
	정원혁 2023.01
	
	https://www.postgresql.org/docs/current/transaction-iso.html
*/

/*
 * 기본 DELETE
 */
drop table if exists o;
SELECT * into o FROM orders;

select * from o where order_id = 10248;

DELETE from o 
where order_id = 10248;

select * from o where order_id = 10248;


/*
 * 좀 더 복잡한 DELETE
*/
select * from o 
WHERE employee_id = 5
	AND EXISTS (SELECT 1 FROM customers WHERE customer_id = o.customer_id AND customers.country = 'USA'); 

delete from o
WHERE employee_id = 5
AND EXISTS (SELECT 1 FROM customers WHERE customer_id = o.customer_id AND customers.country = 'USA');

select * from o 
WHERE employee_id = 5
	AND EXISTS (SELECT 1 FROM customers WHERE customer_id = o.customer_id AND customers.country = 'USA'); 

