/*
	전문가로 가는 지름길 1 / 개발자용
	제 3장 소스 스크립트 
	정원혁 2000.1
	for pgsql 2022.11
*/


SELECT * FROM titles

SELECT * 
FROM titles


EXEC sp_help titles
EXEC sp_columns titles

SELECT title_id, title, price, pub_id 
FROM titles

SELECT title_id, pub_id, price, title 
FROM titles


SELECT '책 번호:', title_id, pub_id, price, title 
FROM titles


SELECT 	title_id AS Title_no
	, pub_id AS [출판사 번호]  
	, price
	, title 
FROM titles


SELECT 	title_id AS Title_no , pub_id AS [출판사 번호] , price, title 
FROM titles


SELECT title_id AS Title_no, pub_id AS '출판사 번호', price, title 
FROM titles
---
SELECT title_id AS Title_no, pub_id AS (출판사 번호), price, title 
FROM titles


SELECT 	title_id Title_no, pub_id [출판사 번호] , price, title 
FROM titles
------
SELECT 	Title_no = title_i, [출판사 번호] = pub_id, price, title 
FROM titles

--//연습2

SELECT  *  FROM  publishers

--3. 
sp_help publishers
sp_columns publishers

--5.
SELECT  *  FROM  sales

--6.
SELECT  title_id, stor_id, ord_date, '수량:', qty
FROM  sales



--//변수
DECLARE @id INT, @name CHAR(10)
SET @id = 0
SET @name = '윤석빈'
SELECT @id, @name




--// 자료형
--날짜
declare @a datetime
set @a = '2002.8.10'
select @a

declare @a smalldatetime
set @a = '2002.8.10'
select @a

declare @a datetime
set @a = '2002.8.10 13:34:28.999'
select @a

declare @a datetime
set @a = '02.8.10 13:34:28.999'
select @a

declare @a datetime
set @a = '8/10/02'
select @a

set dateformat mdy
declare @a datetime
set @a = '8/10/02'
select @a
set dateformat ymd

--char vs varchar
declare @a char(10), @b varchar(10)
set @a  = 'a'
set @b = 'b'
select @a + '*' 
select @b + '*'


sp_addtype tProdID,	'CHAR(6)'
sp_addtype tEmpNo,	'CHAR(5)'
sp_addtype tPrice, 	'SMALLINT'

--//SELECT에서의 자료형 바꾸기

select 1 + 3 
select 'a' + 'b'
select 1 + '4'
select 'a' + 'b'  + 4
select 'a' + 'b'  + convert(char(1), 4)

select 10/ 3
select 10.0 / 3
select 10. / 3
select convert(decimal(10, 8) , 10) / 3

--1)
SELECT 	title_id AS Title_no
	, pub_id AS '출판사 번호'  
	, price
	, CONVERT(char(30), title) AS '줄인 제목'
	, convert(varchar(10), price) + '원'
FROM titles

--2)
SELECT 	title_id AS Title_no
	, pub_id AS '출판사 번호'  
	, price
	, SUBSTRING(title, 1, 30) AS '줄인 제목'
FROM titles

SELECT 	title_id AS Title_no
	, pub_id AS '출판사 번호'  
	, price * 1.1 AS '가격(부가세 포함)'
	, SUBSTRING(title, 1, 30) AS '줄인 제목'
FROM titles

SELECT 	title_id AS Title_no
	, pub_id AS '출판사 번호'  
	, price * 1.1 AS '가격(부가세 포함)'
	, CAST ( title AS char(30) ) AS [줄인 제목]
FROM titles





SELECT 	CONVERT( float, '32.2')
SELECT 	CONVERT( int, '32.2')
SELECT 	CONVERT( int, '32')
SELECT 	CONVERT( varchar(5), 32.2)
SELECT 	CONVERT( varchar(3), 32.2)
SELECT 	CONVERT( float, 32 )


SELECT title_id, price
, FLOOR(price) as floor, CEILING(price) as ceiling, ROUND(price, 0) as round
from titles


SELECT SUBSTRING('abcdef', 1, 2)  
SELECT SUBSTRING('한글abcd데이타', 1, 2)  --1)
SELECT SUBSTRING('한글abcd데이타', 3, 3)  --2)


--SELECT SOUNDEX('한글')
SELECT DIFFERENCE('Smithers', 'Smothers')
SELECT DIFFERENCE('한글', '한글')
SELECT DIFFERENCE('한글', '한글의')
SELECT DIFFERENCE('한글', '희망')
SELECT DIFFERENCE('한글', '가나다')

SELECT REPLICATE('반복', 10)
SELECT REVERSE('한ab글')

SELECT STUFF('123456', 3, 2, 'abcde')
SELECT replace('123456', '34', 'abcde')

select title 
from titles

SELECT QUOTENAME('abc[]def')
SELECT QUOTENAME('abc[]def', '"')	-- '  "  ' 를 붙여쓴 것.


-- UNICODE
DECLARE @nStr nchar(12)
SET @nStr = N'한글'
SELECT UNICODE(@nStr), NCHAR(UNICODE(@nStr))





SELECT GETDATE()
SELECT year(GETDATE()), month (getdate()), day(getdate())
SELECT year(GETDATE())+1, getdate() + 1
2002년 8월 12일 
SELECT year(GETDATE()) + '년'--, month (getdate()), day(getdate())
SELECT CONVERT( varchar(30), GETDATE(), 9)

SELECT CONVERT( varchar(30), GETDATE(), 2)
SELECT CONVERT( varchar(30), GETDATE(), 102)
select dateadd( m, 10, getdate())
select datediff(d, '76.2.5', getdate())





SELECT DATEPART(mm, GETDATE())
SELECT MONTH(GETDATE())

SELECT DATEADD(mm, 20, GETDATE())

SELECT DATEADD(dd, 100, GETDATE())
SELECT GETDATE() + 100

SELECT DATEDIFF(dd, GETDATE(), '3000.1.1')

SELECT DATENAME(dw, GETDATE()), DATENAME(mm, GETDATE())

SELECT APP_NAME()






SELECT title_id, qty FROM sales

SELECT title_id, qty 
FROM sales
WHERE qty >= 20

SELECT title_id, qty FROM sales
WHERE title_id = 'BU1032'




SELECT title_id, price
FROM titles
WHERE price IS NULL

SELECT title_id, price
FROM titles
WHERE price = NULL

--- <> NOT NULL은 IS NOT NULL과 같지 않다.
SELECT title_id, price
FROM titles
WHERE price <> NULL

SELECT title_id, price
FROM titles
WHERE price IS NOT NULL




SET ANSI_NULLS OFF 
SET ANSI_NULLS ON



--//정렬

SELECT title_id, qty 
FROM sales
ORDER BY qty 

SELECT title_id, qty
FROM sales
ORDER BY qty DESC

SELECT title_id, qty
FROM sales
ORDER BY title_id, qty

SELECT title_id, qty
FROM sales
ORDER BY title_id, qty DESC

SELECT title_id, qty
FROM sales
ORDER BY title_id DESC, qty DESC

SELECT title_id, qty
FROM sales
ORDER BY 1 DESC, 2 DESC

SELECT TOP 6 title_id, qty 
FROM sales 


SELECT TOP 6 title_id, qty 
FROM sales 
ORDER BY qty DESC 


SELECT TOP 6 WITH TIES title_id, qty 
FROM sales 
ORDER BY qty DESC

SELECT TOP 25 PERCENT title_id, qty 
FROM sales 
ORDER BY qty DESC

SELECT TOP 25 PERCENT WITH TIES title_id, qty 
FROM sales 
ORDER BY qty DESC

--//범위
SELECT title_id, qty
FROM sales
WHERE qty BETWEEN 10 AND 20
ORDER BY qty

SELECT title_id, qty
FROM sales
WHERE qty >= 10 AND qty <= 20
ORDER BY qty

--//목록

SELECT title_id, qty
FROM sales
WHERE title_id IN ('BU1032', 'BU1111', 'MC3021')


SELECT title_id, qty
FROM sales
WHERE title_id = 'BU1032'  OR  'BU1111'  OR  'MC3021'

--문자열
SELECT title_id, title
FROM titles
WHERE title LIKE '%computer%'

SELECT title_id, title
FROM titles
WHERE title LIKE 'computer%'


SELECT PATINDEX('%Mi%', 'James Mike')
SELECT PATINDEX('M[^c]%', 'McAthur')
SELECT PATINDEX('M[^c]%', 'Mike')
SELECT PATINDEX('M[^c]%', 'M') 	-- 주의! 틀리기 쉽다.


--중복된 행

SELECT title_id
FROM sales
ORDER BY title_id


SELECT DISTINCT title_id
FROM sales
ORDER BY title_id


SELECT title_id, price
FROM titles
WHERE price * 1.1 < 20.00
ORDER BY price

---
SELECT title_id, price
FROM titles
WHERE price < 20.00 / 1.1
ORDER BY price

SELECT title_id, pubdate, DATEPART(yy, pubdate) AS [연도]
FROM titles
WHERE DATEPART(yy, pubdate) = 1991


SELECT title_id, pubdate, YEAR (pubdate) AS [연도]
FROM titles
WHERE YEAR (pubdate)  = 1991


SELECT title_id, pubdate, YEAR (pubdate) AS [연도]
FROM titles
WHERE pubdate BETWEEN '1991.1.1' AND '1991.12.31'

SET DATEFORMAT 'ymd'
go
SELECT title_id, pubdate, DATEPART(yy, pubdate)
FROM titles
WHERE pubdate BETWEEN '1991.1.1' AND '1991.12.31'

--1)
SELECT title_id, price, pub_id
FROM titles
WHERE title_id LIKE 'BU%' 
	OR ( pub_id = '1389'	AND price = 19.99 )

--2)
SELECT title_id, price, pub_id
FROM titles
WHERE (title_id LIKE 'BU%' OR 	pub_id = '1389' )
	AND price = 19.99

--3)
SELECT title_id, price, pub_id
FROM titles
WHERE title_id LIKE 'BU%'  OR 	pub_id = '1389' 
	AND price = 19.99

--//연습 1

--1.
create table #t1
(
	t	datetime
)
go

insert #t1 values ('91.1.1')



insert #t1 values ('1/1/91')




set dateformat  mdy
insert #t1 values ('1/1/91')

set dateformat  ymd

--//연습 3
--1
select 10 / 4 + 10 % 3 * 5

--2	
declare @i tinyint	-- 변수를 선언한다.
set @i = 254		-- 변수를 초기화 한다.
select @i + 2		-- 결과는?

--3. 
declare @f float
set @f = 	0.00001
select @f + 	0.99999

set @f = 	0.00000000000000000000001
select @f + 	0.99999999999999999999999

--4. 
declare @f numeric (28, 26)
set @f = 	0.00000000000000000000001
select @f + 	0.99999999999999999999999

--5. 
set dateformat mdy	
declare @d datetime
set @d =  '4/27/99'
select @d
------
declare @d datetime
set @d = '99.4.27'	-- 무슨 오류가 발생하는가?
select @d		-- 값은 얼마인가?
------
set dateformat ymd
declare @d datetime
set @d = '99.4.27'	-- 원하는 결과인가?
select @d





--//연습 5
--1

USE pubs
SELECT *
FROM authors
ORDER BY au_lname ASC, au_fname ASC


--3

SELECT stor_id AS 서점번호, ord_date, qty, title_id
FROM dbo.sales
WHERE stor_id NOT between  '7067' and '7131'


