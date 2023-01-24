/*
	PIVOT
	정원혁 for pgsql 2023.01 
*/
select * from orders;


SELECT 
    ship_via,
    y1996, y1997
(
	select
		ship_via, 
        date_part('year', order_date) as order_year, 
        freight 
    FROM 
        orders
) data
PIVOT (
    SUM(freight)
    FOR order_year IN (1996 as y1995, 1997 as y1997)
) as a;

GROUP BY ship_via;






WITH data AS (
    SELECT ship_via, date_part('year', order_date) order_year, freight 
    FROM orders
)
select	* 
FROM 	data
PIVOT (
    SUM (freight)
    FOR date_part('year', order_date) IN (1996 as y1996, 1997 as y1997) 
)
group by ship_via ;


WITH data AS (
    SELECT 
        ship_via, 
        date_part('year', order_date) as order_year, 
        freight 
    FROM 
        orders
)
SELECT 
    ship_via,
    SUM(year_2020) as year_2020,
    SUM(year_2021) as year_2021,
    SUM(year_2022) as year_2022
FROM 
    data
PIVOT (
    SUM(freight)
    FOR order_year IN (2020 as year_2020, 2021 as year_2021, 2022 as year_2022)
)
GROUP BY ship_via;
