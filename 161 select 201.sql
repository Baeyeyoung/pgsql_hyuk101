/*
	전문가로 가는 지름길 1 / 개발자용	 
	정원혁 2022.11 for pgsql 	
*/

/*
 * 정렬 ORDER BY
 */
SELECT  *  FROM  orders;

SELECT  *  FROM  orders	
ORDER by customer_id; 

SELECT  *  FROM  orders	
ORDER by 2; 

SELECT  ship_city || ship_address as destination, *  
FROM  orders	
ORDER by  ship_city || ship_address; 

SELECT  ship_city || ship_address as destination, *  
FROM  orders	
ORDER by destination; 

SELECT  ship_city || ship_address as destination, *  
FROM  orders	
ORDER by 1; 

