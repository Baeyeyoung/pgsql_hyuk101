/*
	Function
	정원혁 for pgsql 2023.01
*/

CREATE OR REPLACE FUNCTION square(x INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN x * x;
END;
$$ LANGUAGE plpgsql;

SELECT square(5);

/*
PL/pgSQL: This is the most widely used procedural language for PostgreSQL. It is similar to Oracle's PL/SQL and provides constructs for control flow, exception handling, and data manipulation. It is the default language for procedures and functions in PostgreSQL.

Tcl: Tcl (Tool Command Language) is an interpreted language that is particularly well suited for writing triggers and other event-driven applications.

SQL: You can use plain SQL within a stored procedure or function, but it does not provide the control flow and exception handling capabilities of PL/pgSQL or other languages.

PL/Tcl: This is a procedural language that combines the power of Tcl with the database access capabilities of PL/pgSQL.

PL/Perl: This allows you to write stored procedures, functions and triggers using the Perl programming language.

PL/Python: This allows you to write stored procedures, functions, and triggers using the Python programming language.

C: You can also write stored procedures and functions in C, which can provide a significant performance boost for computationally intensive tasks.
*/



CREATE OR REPLACE FUNCTION lived_period(birthdate DATE)
RETURNS TABLE (years numeric, months numeric, days numeric) AS $$
BEGIN
    RETURN QUERY SELECT
        EXTRACT(YEAR FROM age(CURRENT_DATE, birthdate)) AS years,
        EXTRACT(MONTH FROM age(CURRENT_DATE, birthdate)) AS months,
        EXTRACT(DAY FROM age(CURRENT_DATE, birthdate)) AS days;
END;
$$ LANGUAGE plpgsql;

select * from lived_period('20020810');
