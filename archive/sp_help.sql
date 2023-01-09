create [or replace] procedure sp_help(nspname)
language plpgsql
as $$
declare
-- variable declaration
begin
-- stored procedure body


SELECT  Quote_ident(nspname)  || '.'  || Quote_ident(relname) AS table_name,
 Quote_ident(attname)  AS field_name,
 Format_type(atttypid, atttypmod)  AS field_type,
 CASE  WHEN attnotnull THEN ' NOT NULL'  ELSE '' END AS null_constraint,
 CASE  WHEN atthasdef THEN 'DEFAULT '    ||   (
    SELECT Pg_get_expr(adbin, attrelid)
    FROM   pg_attrdef
    WHERE  adrelid=attrelid
    AND adnum = attnum )::text
  ELSE '' END AS dafault_value,
 CASE
  WHEN NULLIF(confrelid, 0) IS NOT NULL THEN confrelid::regclass::text    || '( '    || array_to_string( array
   (
   select   quote_ident( fa.attname )
   FROM  pg_attribute AS fa
   WHERE fa.attnum = ANY ( confkey )
   AND   fa.attrelid = confrelid
   ORDER BY fa.attnum ), ',' )
    || ' )'
  ELSE '' END AS references_to
FROM pg_attribute
 LEFT OUTER JOIN pg_constraint
  ON conrelid = attrelid
   AND attnum = conkey[1]
   AND array_upper( conkey,1) = 1
 INNER JOIN pg_class
  ON pg_class.oid = pg_attribute.attrelid
 INNER JOIN pg_namespace
  ON pg_namespace.oid = pg_class.relnamespace
WHERE (
  1 = CASE WHEN btrim( '$SELECTION$' ) = '' THEN 1 ELSE 0 END
 OR  pg_class.oid = btrim( '$SELECTION$' )::regclass::oid
) AND (
  1 = CASE WHEN btrim( '$SELECTION$' ) = '' THEN 0 ELSE 1 END
 OR  attrelid > 1262
) AND attnum > 0
AND NOT attisdropped
AND Quote_ident(nspname) NOT IN ('pg_catalog', 'pg_toast')
ORDER BY attrelid, attnum;

end; $$

call sp_help;