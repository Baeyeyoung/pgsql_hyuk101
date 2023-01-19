/*
	UPDATE
	for pgsql 2023.01
	
	
*/
--연습용 테이블 생성
drop table if exists o;
select * into o	from orders;

select * from o;

/*
 * 기본 업데이트
 */
update o 
set order_date = now() 
where order_id = 10248;
select * from o where order_id = 10248;


update o 
set order_date = now(), customer_id = 'WILLI', freight = freight * 1.05  
where order_id = 10248;

select * from o where order_id = 10248;


select order_id::text from o where order_id = 10248;

update o 
set order_date = now(), customer_id = 'WIL' || right(order_id::text, 2) 
where order_id = 10248;
select * from o where order_id = 10248;




/*
 * 좀 더 복잡한 업데이트
*/
UPDATE o
SET shipped_date = (SELECT MAX(order_date) FROM o WHERE customer_id = o.customer_id)
WHERE employee_id = 5
AND EXISTS (SELECT 1 FROM customers WHERE customer_id = orders.customer_id AND customers.country = 'USA');

--이해를 위해서 
select * from customers;

select * from o 
WHERE employee_id = 5
	AND EXISTS (SELECT 1 FROM customers WHERE customer_id = o.customer_id AND customers.country = 'USA'); 

select o.customer_id, order_date
from o
WHERE employee_id = 5
	AND EXISTS (SELECT 1 FROM customers WHERE customer_id = o.customer_id AND customers.country = 'USA')
order by o.customer_id, order_date desc;

select o.customer_id, max(order_date)
from o
WHERE employee_id = 5
	AND EXISTS (SELECT 1 FROM customers WHERE customer_id = o.customer_id AND customers.country = 'USA')
group by o.customer_id;





/*
 * 고객의 마지막 주문일을 업데이트하자. orders를 기반으로.
 */
drop table if exists c ;
select customer_id, null::date as 마지막주문일 into c from customers c ;
select * from c;

select customer_id, max(order_date) from orders o group by customer_id ;

update c 
set 마지막주문일 = (
	select max(order_date)
	from orders 
	where customer_id = c.customer_id
)
where 마지막주문일 is null;

select * from c;


/*
 * 	다른 테이블 값을 기반으로 한 업데이트
 *  재고 수량을 주문 수량만큼 빼자
 */
drop table if exists p;
select * from products; 
select product_id , units_in_stock  into p from products;
update p set units_in_stock = 1500; 
select * from p;

select * from order_details od ;

update p 
set units_in_stock = units_in_stock - (
	select sum(quantity)
	from order_details 
	where product_id = p.product_id
);
--또는 
update p 
set units_in_stock = units_in_stock - od.qty
from (
	select product_id , sum(quantity) qty
	from order_details 
	group by product_id 
) od
where p.product_id  = od.product_id;

select * from p;
