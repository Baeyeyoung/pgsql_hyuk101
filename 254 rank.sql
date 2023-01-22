/*
	rank와 관련함수 
	for pgsql 2023.01 
	정원혁 2023.01
*/


SELECT customer_id, round( sum(freight)::numeric, 0) as sumFreight
FROM orders	
group by customer_id 
order by sum(freight)  desc;

SELECT customer_id, round( sum(freight)::numeric, -2) as sumFreight
	, rank() over (order by round( sum(freight)::numeric, -2) desc) as rank
	, dense_rank() over (order by round( sum(freight)::numeric, -2) desc) as denseRank
FROM orders	
group by customer_id 
order by sum(freight)  desc;

create temp table o as 
SELECT customer_id, round( sum(freight)::numeric, -2) as sumFreight
FROM orders	
group by customer_id 
order by sum(freight)  desc;

select * from o;

SELECT customer_id, sumFreight
	, ROW_NUMBER() over (order by sumFreight desc) as rowNumber
	, rank() over (order by sumFreight desc) as rank
	, dense_rank() over (order by sumFreight desc) as denseRank
	, ntile(2) over (order by sumFreight desc) as ntile2
	, ntile(3) over (order by sumFreight desc) as ntile3
FROM o
order by sumfreight  desc;


/*
 * PARTION BY
 */

SELECT customer_id, round(freight::numeric, 0) freight
FROM orders	
order by customer_id, freight desc;


SELECT customer_id, round(freight::numeric, 0) freight
	, rank() over (order by freight desc  ) as rank
	, rank() over (partition by customer_id order by freight desc) as patitionedRank
FROM orders
order by customer_id, freight  desc;
