/*
	PROCEDURE
	정원혁 for pgsql 2023.01
*/
create temp table cust
as
SELECT customer_id, company_name, contact_name
FROM customers
limit 5;

select * from cust;

CREATE OR REPLACE PROCEDURE add_new_cust(
	in customer_id text, in company_name text, in contact_name text
) AS $$
BEGIN
    INSERT INTO cust 
    VALUES (customer_id, company_name, contact_name);
END;
$$ LANGUAGE plpgsql;

CALL add_new_cust('SQLRO', 'SQLroad', 'sales@sqlroad.com');
select * from cust;
