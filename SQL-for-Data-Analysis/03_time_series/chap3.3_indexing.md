# 3.3.4 인덱싱으로 시계열 데이터 변화 이해하기

데이터 인덱싱은 시계열에어 베이스 구간(시작지점)을 기준으로 데이터의 변화량을 이해하는 방법,  
기업 운영뿐 아니라 경제 분야에서도 널리 사용됨  

유명한 인덱싱 지표로 일반 소비자가 구매하는 상품의 가격 변화를 나타내는 소비자 물가지수, CPI(consumer price index)가 있다.  

CPI는 여러 데이터와 가중치를 활용한 복잡한 통계식으로 계산하지만 기본 전제는 간단하다. 베이스 구간을 선택하고, 이를 기준으로 다음 구간마다 비율 변화를 계산한다.  


SQL로 시계열 데이터를 인덱싱 하려면 집계 함수와 윈도우 함수를 조합하거나 self_JOIN을 사용한다.  
> 예를 들어, 데이터셋의 시작 연도인 1992년을 기준으로 여성 의류업 매출을 인덱싱 해보자.

```sql
-- 1992년의 값이 인덱스로 설정됨
select
	sales_year, sales,
	first_value(sales) over (order by sales_year) as index_sales
from
(
	select date_part('year', sales_month) as sales_year, sum(sales) as sales
	from retail_sales
	where kind_of_business = 'Women''s clothing stores'
	group by 1	
)a
;

-- 이 베이스 구간을 기준으로 한 비율 변화를 알아보자
select
	sales_year, sales,
	(sales / first_value(sales) over (order by sales_year) -1) * 100 
	as pct_prom_index
from
(
	select date_part('year', sales_month) as sales_year, sum(sales) as sales
	from retail_sales
	where kind_of_business = 'Women''s clothing stores'
	group by 1	
)a
;
```