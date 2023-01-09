/*
Operators: https://www.postgresql.org/docs/9.0/functions.html
Operator Precedence: 4.1.6. of https://www.postgresql.org/docs/9.4/sql-syntax-lexical.html#SQL-SYNTAX-CONSTANTS-GENERIC

LOGICAL
	AND
	OR
	NOT

COMPARISION
	<	less than
	>	greater than
	<=	less than or equal to
	>=	greater than or equal to
	=	equal
	<> or !=	not equal

MATHEMATICAL
	+	addition	2 + 3	5
	-	subtraction	2 - 3	-1
	*	multiplication	2 * 3	6
	/	division (integer division truncates the result)	4 / 2	2
	%	modulo (remainder)	5 % 4	1
	^	exponentiation	2.0 ^ 3.0	8
	|/	square root	|/ 25.0	5
	||/	cube root	||/ 27.0	3
	!	factorial	5 !	120
	!!	factorial (prefix operator)	!! 5	120
	@	absolute value	@ -5.0	5
	&	bitwise AND	91 & 15	11
	|	bitwise OR	32 | 3	35
	#	bitwise XOR	17 # 5	20
	~	bitwise NOT	~1	-2
	<<	bitwise shift left	1 << 4	16
	>>	bitwise shift right	8 >> 2	2

*/

