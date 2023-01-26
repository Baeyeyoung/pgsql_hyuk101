/*
	PIVOT2: CROSSTAB 심화
	정원혁 for pgsql 2023.01 
	https://stackoverflow.com/questions/3002499/postgresql-crosstab-query
*/

/*
 * CORSSTAB: aggregated input을 사용해야 한다. (group by 된 결과를 사용해야한다.) 
 * CROSSTAB ( base table, pivot 쿼리 with DISTINCT) AS (컬럼목록)
 * 
 * extension을 설치해야한다.
 */
CREATE EXTENSION IF NOT EXISTS tablefunc;

drop table if exists tbl;

CREATE temp TABLE tbl (
   section   text
 , status    text
 , ct        integer  -- "count" is a reserved word in standard SQL
);

INSERT INTO tbl VALUES 
  ('A', 'Active', 1), ('A', 'Inactive', 2)
, ('B', 'Active', 4), ('B', 'Inactive', 5)
                    , ('C', 'Inactive', 7);  -- ('C', 'Active') is missing
select * from tbl;

/*
 * 잘못된 방법
 * CROSSTAB ( base table ) AS (컬럼목록) *
 */
--이건 데이터 오류! 뭐가 잘 못되었나 찾기
select * from crosstab(
	'select * from tbl'
)
as (SECTION text, active int, inactive int)
;


/*
 * 올바른 방법	
 * CROSSTAB ( base table, pivot 쿼리 with DISTINCT) AS (컬럼목록) 	 
 */
select * from tbl order by 1,2;

select * FROM   crosstab(
	'select * from tbl order by 1,2'
,	$$VALUES ('Active'::text), ('Inactive')$$	--(정확한 행의 값. 대소문자 구분::자료형), (두번째값_자료형은 첫번째것과 동일하므로 생략가능)
	--인용을 쉽게 하기 위해 $ 인용사용
)
as (섹션 text, 활성 int, 비활성 int)	--컬럼 제목이므로 임으로 설정
;

select * FROM   crosstab(
	'select * from tbl order by 1,2'
,	'select distinct status from tbl order by 1'	--이게 더 편할 수도 있다.
)
as (섹션 text, 활성 int, 비활성 int)	--컬럼 제목이므로 임으로 설정
;
