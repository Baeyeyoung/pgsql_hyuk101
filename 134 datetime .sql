/*
 * 날짜 시간 처리 방법
 * https://www.postgresql.org/docs/current/datatype-datetime.html
 * https://www.devkuma.com/docs/postgresql/날짜/시간-형식-timestamp-interval-data-등/ 
 * for pgsql 정원혁 2023.01
 */


-- 1. 현재 시간
select now(), CURRENT_TIMESTAMP, timeofday(), timestamp 'now';
-- now와 current_timestamp의 자료형?
select now(), pg_typeof(now()), CURRENT_TIMESTAMP, pg_typeof(CURRENT_TIMESTAMP);

select current_date, current_time;
select now()::time, now()::date;


-- 2. 조건문에 사용
select * from public.orders o 
where order_date between '1996-07-04' and '1996-07-14';

select * from orders o 
where order_date between '1996-07-04' and now();

--주의
explain ANALYZE
select * from public.bigO o 
where order_date between '1996-07-04' and '1996-07-14';

explain ANALYZE
select * from public.bigO o 
where to_char(order_date, 'yyyy-mm-dd') between '1996-07-04' and '1996-07-14';


--3. 시간 연산: interval
select now() + time '03:00', CURRENT_TIMESTAMP + time '03:00' ;
select now() + interval '24' hours;
select date '2001-09-28' + integer '7';
SELECT date_trunc('month', now()) - INTERVAL '6 month';

-- 오류
-- select now() + integer '7';
-- 숫자 연산은 date 형일때만 가능하다. now 를 date형으로 변환해야 한다.
select now()::date + integer '7', now()::date + 7;
select now() + interval '24' hours;




--4. 포맷
select now(), to_char(now(), 'mm/dd/yy'), to_char(now(), 'YYYY-MM-DD HH24:MI:SS.MS'), to_char(now(), 'yyyymmdd');
select to_date('20200101', 'yyyymmdd');


--5. 부분 추출 extract, date_part
select extract(dow from now());	--일=0, 월=1, ...
select extract(week from now()), extract(month from now());
select date_part('year', timestamp '20201125'), date_part('year', timestamp 'now'), date_part('year', now());
select date_trunc('year', timestamp '20201125'), date_trunc('month', timestamp '20201125'), date_trunc('day', timestamp '20201125');
SELECT order_date, date_part('year', order_date) FROM orders;


/*
Unix TimeStamp == Epoch == posix time: 잊자
1970년~2038년 범위만 표현할 수 있는 얄팍하고 구시대적인 시간 형식이다. 
4바이트 정수, 최소 단위는 1초.
*/


--6. timestamp,timestamptz (timeZone)
 show timezone;
 ALTER DATABASE northwind SET timezone = 'Asia/Seoul';
--must restart postgresql server

select now(), now() at time zone 'HKT', now() at time zone 'America/Denver', now() at time zone 'PST';
 