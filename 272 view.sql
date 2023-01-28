/*
	view
	정원혁 for pgsql 2023.01
	
	CREATE VIEW 뷰이름
	AS
	SELECT ... 
	
*/


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


DROP VIEW IF exists v최근주문;

create view v최근주문
as 
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
--order by 1, 2 desc
;
select * from v최근주문
order by 1, 2 desc;



DROP VIEW IF exists v직전주문;

create view v직전주문
as 
select customer_id, order_date 최근주문, (
	select max(order_date) 
	from orders 
	where customer_id  = o.customer_id 
		and order_date < o.order_date   
	) 하나전_주문  
from orders o	
;

DROP VIEW IF exists v최근주문2;
create view v최근주문2
as
select * from v직전주문 o
where 최근주문 = (
	select max(최근주문)
	from v직전주문 
	where customer_id  = o.customer_id 
)	
order by 1, 2 desc
;
select * from v최근주문2
order by 1, 2 desc;
