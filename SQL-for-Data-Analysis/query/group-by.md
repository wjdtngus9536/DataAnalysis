# GROUP BY

group by 문은 동일한 값을 가진 컬럼을 기준으로 그룹별 연산을 적용

```sql
select
  kind,
  count(*) 
from beberage
group by kind;

```

having 문은 group by 절에 의해 생성된 결과 값 중 원하는 조건에 부합하는 데이터만 보고자 할 때 사용

```sql
select
  kind,
  count(*)
from beverage
group by kind
having count(kind) >= 10;

```


Q. group by가 없을 때 작동 안되는 이유

> A. SUM(COL2) 집계합수를 사용하기 위해 그룹화 필요
> 오류: column "b.col3" 는 반드시 GROUP BY 절내에 있어야 하던지 또는 집계 함수 내에서 사용되어져야 한다.  
SQL state: 42803  
SELECT 또는 HAVING절의 컬럼 참조는 컬럼이 그룹화 컬럼이 아니므로, 유효하지 않습니다. 또는 GROUP BY절의 컬럼 참조가 유효하지 않습니다.
```sql
WITH Sample AS (
    SELECT 'A' AS COL1, 1 AS COL2
    UNION ALL SELECT 'B', 2
	UNION ALL SELECT 'C', 3
)
SELECT
    CASE b.COL3 
		WHEN 1 THEN COL1
		WHEN 2 THEN '합계'
	END AS COL1,
	SUM(COL2) as COL2
FROM Sample
CROSS JOIN
	(SELECT 1 as COL3 
	 UNION ALL SELECT 2) b
GROUP BY
	CASE b.COL3 
		WHEN 1 THEN COL1
		WHEN 2 THEN '합계'
	END
ORDER BY COL1
;
```


## programmers 
---

### 성분으로 구분한 아이스크림 총 주문량
```SQL
SELECT
    INGREDIENT_TYPE,
    SUM(h.TOTAL_ORDER)
from first_half h, icecream_info i
where h.flavor = i.flavor
group by INGREDIENT_TYPE
order by TOTAL_ORDER;
```

### 식품분류별 가장 비싼 식품의 정보 조회하기
```SQL

```