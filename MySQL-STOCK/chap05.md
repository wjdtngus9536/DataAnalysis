# 5. 테이블 간의 관계 이해하기

### 1) 테이블간의 관계와 Foreign Key

주문 테이블에 회원ID를 추가 해야만 어느 회원의 주문인지를 관리할 수 있다.  
회원의 ID가 어디서 오는 것인지 명확하게 하기 위해 회원과 주문 사이의 `관계(Relationship)선을` 표시해 주는 것이 좋다.

- FK : 참조키라고 하며, 테이블A(주문)가 테이블B(회원)를 참조한다는 관계를 설정한 것.

FK는 참조키 또는 외래키라고 부른다. 관계를 살펴볼 때는 관계선과 함께 어느 컬럼이 FK인지도 잘 살펴봐야 한다.  

관계(Relationship)를 데이터베이스에 실제 구현할 때는 FK 제약(Foreign Key Constraint)을 생성한다. FK 제약을 만드는 SQL은 일반적으로 아래와 같다.  
```sql
ALTER TABLE 주문 ADD CONSTRAINT FK_주문_1 FOREIGN KEY(회원ID) REFERENCES 회원(회원ID);  
```

위와 같은 SQL을 통해, 주문 테이블에는 FK 제약(FK_주문_1)이 만들어진다. 'REFERENCES' 부분에서 회원 테이블의 회원ID를 참조하고 있음을 정의한다.

FK 제약을 데이터베이스에 실제로 설정하는 것에 대해서는 찬반 논쟁이 끊이지 않는다. FK가 없으면 잘못된 데이터가 만들어질 수 있으며 이로 인해 시스템 전반적인 신뢰도를 잃을 가능성이 있다. 그렇다고 무조건 FK를 만들자고 주장할 수는 없다. FK를 과도하게 설정하면 개발 및 테스트 진행에 어려움이 있을 수 있다. 또한, 데이터의 생성과 변경이 빈번한 테이블에서는 성능 저하가 발생할 수도 있다. (반대로 FK 설정이 성능에 도움이 되는 예도 있다.) 그러므로 FK를 실제 생성할지는 프로젝트에 맞게 유연하게 결정하는 것이 좋다고 생각한다. FK 제약을 실제 구현할지는 유연하게 결정해야겠지만, ERD 상에 관계선은 최대한 그려주는 것이 옳다. 관계선이 있어야 데이터 간의 관계를 파악하고 제대로 데이터를 분석할 수 있다.


### 7) SELECT절 서브쿼리
서브쿼리는 다양한 위치에 사용할 수 있다. SELECT절이나 WHERE절에서 사용할 수 있으며, FROM절에서도 사용할 수 있다.

#### 5.7.1 기초코드
기초코드는 시스템에서 전반적으로 사용하는 코드와 코드명을 관리하는 테이블이다.  
대부분의 시스템에는 기초코드 테이블이 있다. 기초코드 테이블은 시스템이나 프로젝트에 따라 공통코드, 마스터코드, 기본코드 등 다양한 이름으로 사용된다.  

기초코드의 코드 값은 '001', '002'와 같은 무의미한 문자형 숫자로 구성하거나, 'COMP(완료)','WAIT(대기)'와 같이 유의미한 단축어로 구성할 수도 있다. 구성 방법에 따라 장단점이 있는데, 이 책에서 논의할 내용은 아니다. 코드 값의 형태보다는 `코드를 데이터화해서 제대로 관리하는지가 더욱 중요하다.`

코드를 기초코드와 같은 테이블로 제대로 관리하지 않으면 데이터 분석에 큰 어려움이 있다. 실제로 코드를 프로그램 소스 레벨에서 임의로 정의해 개발한 사이트도 있다. 이 경우 데이터 분석을 하려면 소스를 뒤져서 코드의 의미를 찾아내야 하고, 코드가 추가되거나 변경되면 프로그램 전체를 대대적으로 변경해야 하는 어려움이 있다.


```sql
-- 5.07 기초코드
desc basecode_dv;

select * from basecode order by bas_cd_dv, srt_od;
```

#### 5.7.2 기초코드 명칭 가져오기 - SELECT절 서브쿼리

보고서용 SQL을 만들다 보면 코드 명칭이 필요한 경우가 많다, 이때, SELECT절 서브쿼리를 사용하면 SQL 작성이 쉽다.

```sql
-- stock을 조회하면서 거래소코드(ex_cd)와 국가코드(nat_cd)의 명칭을 가져오기 위해 basecode와 조인을 사용한 sql이다.
select 
    T1.ex_cde, T2.bas_cd_nm EX_CD_NM
    ,T1.nat_cd, T3.bas_cd_nm NAT_CD_NM
    ,T1.stk_cd, T1.stk_nm
from 
    stock T1
    left outer join basecode T2
      on (T2.bas_cd_dv = 'EX_CD' and T2.bas_cd = T1.ex_cd)
    left outer join basecode T3
      on (T3.base_cd_dv = 'NAT_CD' and T3.bas_cd = T1.nat_cd)
where T1.stk_nm in ('삼성전자', '서울반도체');

-- select절의 서브쿼리로 변형
select
	  T1.ex_cd,
    (select a.bas_cd_nm from basecode A where A.bas_cd_dv = 'ex_cd' and a.bas_cd = T1.ex_cd) EX_CD_NM,
    t1.nat_cd,
    (select a.bas_cd_nm from basecode A where a.bas_cd_dv = 'nat_cd' and a.bas_cd = t1.nat_cd) NAT_CD_NM,
    t1.stk_cd,
    t1.stk_nm
from stock T1
where T1.STK_NM in ('삼성전자', '서울반도체')
;
```

괄호를 사용해 SQL 안에 또 다른 SQL을 추가하는 것이 바로 서브쿼리다. 그중에서도 SELECT절에 사용한 서브쿼리를 'SELECT절 서브쿼리' 또는 '스칼라(Scalar) 서브쿼리'라고 한다.  

스칼라(Scalar)는 하나의 수치만으로 표시되는 단일 값(One-Row, One-Column)을 뜻한다. 그러므로 `SELECT절 서브쿼리는 단 하나의 값만을 리턴 하도록 작성`해야 한다.