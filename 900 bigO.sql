drop table if exists bigO;

select * 
into bigO
from orders o ;

alter table bigO alter column order_id set not null;
alter table bigO alter column order_id type int2; 
alter table bigO alter column order_id add generated always as identity;
alter table bigO add constraint pk_order_id primary key(order_id);

insert into bigO (customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country)	
select customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country 
from orders o ;
select count(*) from bigO;

select * from bigO;

create index ixOrderDate on bigO (order_date);