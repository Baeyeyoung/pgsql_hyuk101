/* 제약 CONSTRAINT
 * for pgsql 정원혁 2022.12
 * 142 identity.sql 에 이어진다
 */

--데이터 들여다 보기
SELECT * FROM 사람;
SELECT * FROM 판매;
SELECT * FROM 판매상세;


--판매 상세 >> 판매 참조키 생성
ALTER TABLE 판매상세 ADD CONSTRAINT fk_판매 FOREIGN KEY (판매번호) REFERENCES 판매 (판매번호)	on update cascade on delete restrict;


--판매 >> 사람 참조키 생성
ALTER TABLE 판매 ADD CONSTRAINT fk_사람 FOREIGN KEY (고객번호) REFERENCES 사람(번호);

/*
 * 위반하는 데이터가 있으면 이런 오류가 생긴다.
 * 
 * SQL Error [23503]: ERROR: insert or update on table "판매" violates foreign key constraint "fk_사람"
 *   Detail: Key (고객번호)=(11) is not present in table "사람".
 * 
 * 이럴땐 어쩔 수 없다. 위반하는 데이터를 삭제해야만 제약생성을 할 수 있다.
 */

select * from 판매 
where 고객번호 not in (select 번호 from 사람);


begin;
	delete from 판매
	where 고객번호 not in (select 번호 from 사람);

	--실패: 판매 상세>> 판매 에 해당하는 데이터가 있어서
	--SQL Error [23503]: ERROR: update or delete on table "판매" violates foreign key constraint "fk_판매" on table "판매상세"
	--  Detail: Key (판매번호)=(5) is still referenced from table "판매상세".
rollback;


--판매 상세를 지우고 오면 되지만 제약을 변경해서 자동 삭제가 되도록 해보자.
ALTER TABLE 판매상세 drop CONSTRAINT fk_판매;
ALTER TABLE 판매상세 add CONSTRAINT fk_판매 FOREIGN KEY (판매번호) REFERENCES 판매 (판매번호)	on update cascade on delete cascade;
-- 다시 시도
begin;
	delete from 판매
	where 고객번호 not in (select 번호 from 사람);

	SELECT * FROM 사람;
	SELECT * FROM 판매;
	SELECT * FROM 판매상세;
commit;




