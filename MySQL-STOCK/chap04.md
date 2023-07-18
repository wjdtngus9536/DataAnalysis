# 4. 종목 테이블 이해하기

### 1) STOCK 테이블의 정체
```sql
DESC STOCK;
[결과]
Field      Type          Null   Key   Default Extra
========== ============= ====== ===== ======= =====
STK_CD     varchar(40)   NO   PRI       
STK_NM     varchar(200)  YES        
EX_CD      varchar(40)   YES        
NAT_CD     varchar(40)   YES        
SEC_NM     varchar(200)  YES
STK_TP_NM  varchar(200)  YES

```

- stk_cd(종목코드) : 종목을 식별하는 코드 값
- stk_nm(종목명) : 종목의 명칭
- EX_CD(거래소코드): 코스피와 코스닥을 구분하는 코드(KP = 코스피, KD = 코스닥)
- NAT_CD(국가코드): 종목이 상장된 거래소의 국가를 나타내는 코드(KR = 한국)
- SEC_NM(섹터명): 종목이 속하는 섹터(업종, 분류)
- STK_TP_NM(종목유형명): 우선주, ETF, ETN, 스팩주와 같은 종목 유형을 관리

### 2) 관계형 데이터 모델
기본적인 관계형 데이터 모델 개념, 데이터를 저장할 테이블 구조를 설계한 것.  
테이블을 설계한다는 것은 테이블을 구성할 컬럼을 정의하는 것이기도 하다. 

관계형 데이터 모델은 개념설계, 논리설계, 물리설계 순으로 진행한다.  
개념설계는 시스템을 구축하는데 필요한 주요 테이블을 찾아내고, 주요 테이블의 핵심적인 개념만 잡아서 간단히 정리하는 단계다.  
논리설계는 개념설계를 바탕으로 시스템 구축에 필요한 모든 테이블과 필요한 테이블의 모든 속성을 찾아내 설계하는 단계다.  
물리설계는 논리설계의 내용을 특정 DBMS에서 구현할 수 있도록 설계하는 단계다.

개념, 논리설계 단계에서는 테이블이 아닌 개체(Entity)라는 용어를 사용한다.
그러므로 개념, 논리 단계는 정의하고 설계하는 과정이며, 물리설계 단계는 개체를 테이블로 구체화하는 과정이다.

### 3) 날짜 조건 처리하기
```
SELECT  
-- 	T1.*
 	T1.STK_CD ,T1.DT ,T1.O_PRC ,T1.H_PRC ,T1.L_PRC ,T1.C_PRC ,T1.VOL ,T1.CHG_RT
FROM    HISTORY_DT T1
WHERE   T1.STK_CD = '005930' # 삼성전자의 종목코드
AND     T1.DT = STR_TO_DATE('20190108','%Y%m%d');
```
STR_TO_DATE() 함수, 문자를 날짜 형태로 변환하는 MySQL 내부 함수
parameter 1 : 날짜를 표현하는 문자 값
parameter 2 : 첫 번째 값의 문자 각각이 날짜의 어떤 부분을 나타내는지를 패턴으로 알려주는 값
- %Y : 네 자리 연도
- %m : 두 자리 월 (2월 = 02)
- %d : 두 자리 일

```
# 삼성전자의 2019년 1월 일변 주가를 모두 조회
select
  t1.stk_cd, 
  t1.dt, 
  t1.o_prc, 
  t1.h_prc, 
  t1.l_prc, 
  t1.c_prc, 
  t1.vol, 
  t1.chg_rt
from
  history_dt t1
where
  t1.stk_cd = '005930'
  and t1.dt >= STR_TO_DATE('20190301', '%Y%m%d')
  and t1.dt < str_to_date('20190401', '%Y%m%d')
order by t1.dt desc;
```

### 04) 날짜 관련 함수
- STR_TO_DATE('문자열', '패턴 문자') : 문자열을 날짜 대이터로 변환한다.
- DATE_FORMAT(날짜 값, '패턴 문자') : 날짜 값을 문자로 변환한다.
- DATE_ADD(<날짜 값>, interval <값> <값 구분>) : 날짜 값에 대한 연산을 처리하는 함수. 

```sql
-- date_format()
SELECT T1.DT
       ,DATE_FORMAT(T1.DT, '%Y%m') STR_YM1
       ,DATE_FORMAT(T1.DT, '%Y-%m') STR_YM2
       ,DATE_FORMAT(T1.DT, '%Y/%m/%d') STR_YMD1
       ,DATE_FORMAT(T1.DT, '%Y-%m-%d') STR_YMD2
FROM   HISTORY_DT T1
WHERE  T1.STK_CD = '005930'
AND    T1.DT = STR_TO_DATE('20190131','%Y%m%d');
[결과]
DT           STR_YM1   STR_YM2   STR_YMD1     STR_YMD2     
============ ========= ========= ============ ============ 
2019-01-31   201901    2019-01   2019/01/31   2019-01-31
```

 
```sql
-- date_add()
SELECT T1.DT
       ,DATE_ADD(T1.DT, interval +2 day) AF2_DT
       ,T1.DT + 2 AF2_DT_ADD
FROM   HISTORY_DT T1
WHERE  T1.STK_CD = '005930'
AND    T1.DT = STR_TO_DATE('20190131','%Y%m%d');
[결과]
DT           AF2_DT       AF2_DT_ADD   
============ ============ ============ 
2019-01-31   2019-02-02   20190133
```

SQL에 조건 값으로 줄 수 있는 값은 문자 또는 숫자 밖에 없다.
날짜 값을 조건으로 사용해야 한다면 STR_TO_DATE()를 사용해 문자를 날짜로 바꾸어서 처리해야 한다.
하지만 아래와 같이 DT(일자)에 문자 값을 조건으로 주어도 SQL은 정상적으로 실행된다.
MySQL 내부적으로 '자동 형변환'이 일어난다.


### 8) GROUP BY
SELECT절에는 GROUP BY에서 정의한 항목만 사용할 수 있다.   
(GROUP BY에 없는 컬럼은 뒤에서 설명할 집계함수로 처리해야 한다.)

- group by와 집계함수
  - group by는 집계함수와 함께 데이터를 그룹별로 분석하기 위해 주로 사용한다. 단순히 같은 값을 한 건으로 만들기 위해서 group by를 사용하는 경우는 많지 않다.
  - 대표적인 집계 함수
    - sum : 그룹별로 합계를 구하는 집계함수
    - min/max : 그룹별로 최소, 최댓값을 구하는 집계 함수
    - count : 그룹별로 건수를 카운트하는 집계함수
    - avg : 그룹별로 평균을 구하는 집계함수

```sql
-- 섹터별로 데이터 건수를 구하는 sql
select
  T1.sec_nm,
  count(*) CNT
from stock T1
where T1.stk_nm like '동일%'
group by T1.sec_nm
order by T1.sec_nm
;
```


### 9) GROUP BY의 확장
group by에 컬럼을 지정할 때, 컬럼을 변형해서 사용하거나 여러 개의 컬럼을 사용할 수도 있다.  
다양한 응용 방법을 살펴보자.

SUBSTR(문자열, 시작위치, 길이) : 문자열에서 시작 위치부터 길이만큼 출력합니다.


```sql
-- 4.09 종목명이 삼성 or 현대로 시작하는 종목 group
select 
	substr(T1.stk_nm, 1, 2) STL_SUB_NAME, 
	count(*) CNT
from stock T1
where (T1.STK_NM like '삼성%' or T1.stk_nm like '현대%')
group by substr(T1.stk_nm, 1, 2)
order by substr(T1.stk_nm, 1, 2)
;

-- 일자를 연월로 변형한 후에 group by
select
	date_format(T1.dt, '%Y%m') YM, count(*)CNT
from history_dt T1
where T1.stk_cd = '005930'
group by date_format(T1.dt, '%Y%m')
order by YM asc
;

-- 여러 컬럼 group by
SELECT  T1.EX_CD ,T1.SEC_NM ,COUNT(*) CNT
FROM    STOCK T1
WHERE   T1.STK_NM LIKE '동일%'
GROUP BY T1.EX_CD ,T1.SEC_NM
ORDER BY T1.EX_CD ,T1.SEC_NM;
```

#### 9.4 GROUP BY 사용 규칙
GROUP BY는 GROUP BY에 정의한 내용(컬럼 또는 변형된 컬럼)만 SELECT절에 그대로 사용할 수 있다. GROUP BY에 정의하지 않은 컬럼을 SELECT절에서 사용하려면 반드시 집계함수 처리를 해야 한다.