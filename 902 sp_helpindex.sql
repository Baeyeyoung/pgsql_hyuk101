SELECT
    n.nspname  as "schema",
    t.relname  as "table",
    c.relname  as "index",
    pg_get_indexdef(indexrelid) as "def"
FROM pg_catalog.pg_class c
    INNER JOIN pg_catalog.pg_namespace n
        ON n.oid = c.relnamespace
    INNER JOIN pg_catalog.pg_index i
        ON i.indexrelid = c.oid
    INNER JOIN pg_catalog.pg_class t
        ON i.indrelid   = t.oid
WHERE c.relkind = 'i'
    and n.nspname not in ('pg_catalog', 'pg_toast')
    and pg_catalog.pg_table_is_visible(c.oid)
    and (1 = CASE WHEN btrim( '$SELECTION$' ) = '' THEN 1 ELSE 0 END OR t.relname = btrim( '$SELECTION$' ))
ORDER BY
    n.nspname,
    t.relname,
    c.relname;

