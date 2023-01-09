drop table if exists post;

CREATE TABLE post (
	post_id SERIAL PRIMARY KEY,
	thread_id INTEGER NOT NULL,
	account_id INTEGER NOT NULL,
	created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
	visible BOOLEAN NOT NULL DEFAULT TRUE,
	comment TEXT NOT NULL
);


INSERT INTO post (thread_id, account_id, created, visible, comment)
SELECT
	RANDOM() * 999 + 1,
	RANDOM() * 99 + 1,
	NOW() - ('1 days' :: interval* random() * 1000), 
	CASE WHEN RANDOM() > 0.1 THEN TRUE ELSE FALSE END,
	'comment'
FROM generate_series(1, 100000) AS s(n)
;
select * from post;
