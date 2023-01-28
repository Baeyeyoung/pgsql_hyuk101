/*
	subquery
	정원혁 for pgsql 2023.01 
	
*/

/*	단순 subquery
 * 	( 온전한 쿼리 ) 
 */
select * from order_details od ;
SELECT AVG(quantity) FROM order_details;	--23.8129930394431555

select * from order_details 
where quantity > 23.8129930394431555;


WITH q AS (SELECT AVG(quantity) FROM order_details)
SELECT * FROM order_details WHERE quantity > (SELECT * FROM q);


SELECT * FROM order_details
WHERE quantity > (
	SELECT AVG(quantity) FROM order_details
);

SELECT * FROM categories WHERE category_name = 'Beverages';

SELECT product_name FROM products
WHERE category_id = (SELECT category_id FROM categories WHERE category_name = 'Beverages')
order by 1
;


/*	correlated subquery
 * 
 * 	from a 
 * 	where  ( ... from b where id = a.id ) 
 */
SELECT product_name FROM products p
WHERE exists (SELECT category_id FROM categories WHERE category_name = 'Beverages' and category_id  = p.category_id)
order by 1
;

SELECT o.order_id, o.customer_id, (	
	SELECT SUM(quantity*unit_price) 
	FROM order_details 
	WHERE order_id = o.order_id
) AS order_total
FROM orders o;

SELECT o.order_id, o.customer_id, SUM(quantity*unit_price) AS order_total 
FROM orders o
	left join order_details	od 	on od.order_id = o.order_id
group by o.order_id, o.customer_id
;

select customer_id, order_date  
from orders o 
order by 1, 2 desc
;
--각 고객별 가장 최근 주문은?

select customer_id, max(order_date)  
from orders o 
group by customer_id
order by 1
;

-- 그 상세내역까지 보여줘
select customer_id, order_date, od.*  
from orders o
	join order_details od on o.order_id  = od.order_id 
order by 1, 2 desc
;

select customer_id, order_date, od.*  
from orders o
	join order_details od on o.order_id  = od.order_id
where order_date = (
	select max(order_date)
	from orders  
	where customer_id  = o.customer_id 
)	
order by 1, 2 desc
;



--고객별 최근 주문과 바로 직전 주문 날짜를 보여줘
select customer_id, order_date 최근주문, (
	select max(order_date) 
	from orders 
	where customer_id  = o.customer_id 
		and order_date < o.order_date   
	) 하나전_주문  
from orders o	
where order_date = (
	select max(order_date)
	from orders  
	where customer_id  = o.customer_id 
)	
order by 1, 2 desc
;


WITH cte AS (
    SELECT 
        customer_id, 
        order_date as 최근주문,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date ) as 하나전_주문
    FROM orders
    ORDER BY customer_id, order_date DESC
)
SELECT customer_id, 최근주문, 하나전_주문
FROM cte o
where 최근주문 = (
	select max(최근주문)
	from cte  
	where customer_id  = o.customer_id 
)
;

