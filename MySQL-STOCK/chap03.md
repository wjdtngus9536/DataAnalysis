```sql
SELECT * from stock
where stk_cd >= '000100'
order by 1; # 특수문자, 문자형숫자, 알파벳, 한글 순으로 정렬

# 특수조건
## 1) like
-- 성이 '김'씨인 모든 회원 조회, '삼성'으로 시작하는 모든 종목 찾기 *'_'  한 글자의 아무 문자를 허용
select stk_cd, stk_nm, sec_nm
from stock
where sec_nm = '증권'
and stk_nm not like '%투자%'
order by stk_cd asc;

## 2) in
-- 여러 개의 조건 값을 하나의 조건으로 처리할 수 있게 해준다. where sec_nm in ('담배', '주류제조업', '문구류') == 로 이은 것과 같음
SELECT  STK_CD ,STK_NM ,SEC_NM
FROM    STOCK
WHERE   SEC_NM not IN ('보험','금융','증권') AND STK_NM like '삼성%'
ORDER BY STK_NM ASC;

## 3) between
select *
from stock
where stk_nm between '삼성' and '삼아'
and sec_nm in ('보험', '제약바이오')
order by stk_nm;

```