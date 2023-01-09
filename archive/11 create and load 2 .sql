drop table if exists post;
drop table if exists thread;
drop table if exists account;

CREATE TABLE account (
	account_id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	dob DATE
);

CREATE TABLE thread (
	thread_id SERIAL PRIMARY KEY,
	account_id INTEGER NOT NULL REFERENCES account (account_id),
	title TEXT NOT NULL
);

CREATE TABLE post (
	post_id SERIAL PRIMARY KEY,
	--GENERATED ALWAYS AS IDENTITY,
	thread_id INTEGER NOT NULL, --REFERENCES thread (thread_id),
	account_id INTEGER NOT NULL REFERENCES account (account_id),
	created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
	visible BOOLEAN NOT NULL DEFAULT TRUE,
	comment TEXT NOT NULL
);


Create or replace function random_string(length integer) returns text as
$$
declare
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
begin
  if length < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;
select random_string(15);
select ceil(RANDOM() * 1000);
select cast(ceil(RANDOM() * 1000) as int);
select random_string( cast(ceil(RANDOM() * 1000) as int));


-- CREATE TABLE words (word TEXT);
-- \copy words (word) FROM '/usr/share/dict/words';

INSERT INTO account (name, dob)
SELECT
	substring('AEIOU', (random()*4)::int + 1, 1) || 
	substring('ctdrdwftmkndnfnjnknsntnyorpsrdrorkrmrnrzslstwl', (random()*22*2 +1)::int, 2) ||
	substring('aeiou', (random()*4 + 1)::int, 1) ||
	substring('ctdrdwftmkndnfnjnknsntnyorpsrdrorkrmrnrzslstwl', (random()*22*2 +1)::int, 2) ||
	substring('aeiou', (random()*4 + 1)::int, 1) ,
	Now () + ('1 days'::interval * random()* 365) 
FROM generate_series(1, 100)
;

-- select initcap(string_agg(random_string( cast(ceil(RANDOM() * 1000) as int)), ' '));
INSERT INTO thread (account_id, title)
SELECT
	RANDOM() * 99 + 1,
-- 	random_string( cast(ceil(RANDOM() * 1000) as int))
	initcap(string_agg(random_string( cast(ceil(RANDOM() * 5) as int)), ' '))
-- 	(	SELECT initcap(string_agg (word, ' ' ))
-- 		FROM (TABLE words ORDER BY random() *n LIMIT 5) AS words (word)
-- 	) 
FROM generate_series(1, 1000) AS s(n)
;

INSERT INTO post (thread_id, account_id, created, visible, comment)
SELECT
	RANDOM() * 999 + 1,
	RANDOM() * 99 + 1,
	NOW() - ('1 days' :: interval* random() * 1000), 
	CASE WHEN RANDOM() > 0.1 THEN TRUE ELSE FALSE END,
	string_agg(random_string( cast(ceil(RANDOM() * 20) as int)), ' ')
-- 	(	SELECT string_agg(word,'') 
-- 		FROM (TABLE words ORDER BY random() * n LIMIT 20) AS words (word)
-- 	)
FROM generate_series(1, 100000) AS s(n)
;











drop table if exists post;
drop table if exists thread;
drop table if exists account;

CREATE TABLE account (
	account_id SERIAL PRIMARY KEY,
	name char(3000) default 'name',
	dob DATE
);

CREATE TABLE thread (
	thread_id SERIAL PRIMARY KEY,
	account_id INTEGER NOT NULL REFERENCES account (account_id),
	title char(3000) default 'title'
);

CREATE TABLE post (
	post_id SERIAL PRIMARY KEY,
	thread_id INTEGER NOT NULL, --REFERENCES thread (thread_id),
	account_id INTEGER NOT NULL REFERENCES account (account_id),
	created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
	visible BOOLEAN NOT NULL DEFAULT TRUE,
	comment TEXT NOT NULL
);


INSERT INTO account (name, dob)
SELECT
	substring('AEIOU', (random()*4)::int + 1, 1) || 
	substring('ctdrdwftmkndnfnjnknsntnyorpsrdrorkrmrnrzslstwl', (random()*22*2 +1)::int, 2) ||
	substring('aeiou', (random()*4 + 1)::int, 1) ||
	substring('ctdrdwftmkndnfnjnknsntnyorpsrdrorkrmrnrzslstwl', (random()*22*2 +1)::int, 2) ||
	substring('aeiou', (random()*4 + 1)::int, 1) ,
	Now () + ('1 days'::interval * random()* 365) 
FROM generate_series(1, 100)
;

-- select initcap(string_agg(random_string( cast(ceil(RANDOM() * 1000) as int)), ' '));
INSERT INTO thread (account_id, title)
SELECT
	RANDOM() * 99 + 1,
	'title'
FROM generate_series(1, 1000) AS s(n)
;

INSERT INTO post (thread_id, account_id, created, visible, comment)
SELECT
	RANDOM() * 999 + 1,
	RANDOM() * 99 + 1,
	NOW() - ('1 days' :: interval* random() * 1000), 
	CASE WHEN RANDOM() > 0.1 THEN TRUE ELSE FALSE END,
	'comment'
FROM generate_series(1, 100000) AS s(n)
;
select * from account;
select * from thread;
select * from post;
