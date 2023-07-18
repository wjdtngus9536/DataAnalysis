## 3.4 시간 윈도우 롤링

시계열 데이터에는 흔히 노이즈가 있어, 의미 있는 패턴을 찾는 데 방해가 됩니다. 앞 절에서는 월간, 연간 데이터 집계 등 데이터에서 노이즈를 제거해 결과 데이터를 부드럽고 이해하기 쉽게 만드는 방법을 배웠습니다. 이 절에서는 또 `다른 노이즈 제거 방법`으로, 여러 구간을 설정해 트렌드를 분석하는 `시간 윈도우 롤링`을 알아봅니다. 시간 윈도우 롤링은 이동 계산 moving calculation 이라고도 합니다. 이동 계산 중에서도 이동 평균이 가장 흔히 쓰이지만 SQL을 활용하면 평균이 아니라 어떤 집계 함수든 적용할 수 있습니다. 시간 윈도우 롤링은 주가 분석, 거시경제 트렌드, 시청률 조사 등 다양한 분석에 두루 사용됩니다. 몇몇 시간 윈도우 롤링 방법은
- last twelve months(LTM)
- trailing twelve months(TTM) 
- year-to-date(YDT)  

등 축약어가 있을 정도로 널리 쓰입니다.

<br>

시계열 롤링 계산에는 몇 가지 중요한 요소가 있습니다.  

첫 번째 요소는 `윈도우 사이즈`입니다. 윈도우 사이즈는 포함할 시간 구간의 개수를 의미하며, 사이즈가 크면 더 많은 시간 구간을 포함하게 되므로 노이즈를 부드럽게 하는 효과가 있습니다. 다만 민감도가 낮아져 짧은 구간의 변동을 파악하는 일이 중요한 데이터에 사용하기엔 좋지 않습니다. 반대로, 윈도우 사이즈가 작으면 짧은 주기의 변화에 더 민감하게 대응할 수 있지만 노이즈에 약하다는 단점이 있습니다.  

두 번째는 사용할 `집계 함수` 입니다. 앞서 언급했든 이동 평균 기법이 가장 널리 쓰입니다. SQL을 활용하면 이동 합계, 이동 개수, 이동 최소, 이동 최대 등도 계산할 수 있습니다. 이동 개수는 활성 사용자 지표 등에 유용하며, 이동 최소와 이동 최대는 데이터의 극단값을 미리 확인해 분석 계획을 세우는 데 활용됩니다.

세 번째는 `윈도우 안에 포함된 데이터의 분할 또는 그룹화`입니다. 경우에 따라 연 단위로 매번 윈도우를 설정해야 하거나, 사용자 그룹 또는 데이터 값에 따라 다른 이동 계산을 사용해야 하기도 합니다.  

4장에서 사용자 그룹 코호트 분석을 자세히 다루면서 시간에 따른 인구통계별 재방문 및 소비 차이 등을 알아봅니다. 분할은 윈도우 함수와 **PARTITION BY** 절 혹은 그룹화를 통해 수행합니다.


### 3.4.1 시간 윈도우 롤링 계산
미국 소매업 매출 데이터셋을 활용해 시간 윈도우 롤링을 직접 계산  
먼저 데이터셋의 모든 시간 윈도우 구간에 레코드가 제대로 저장돼 있을 때 사용하는 간단한 계산을 알아본 뒤, 이어서 몇몇 시간 윈도우 구간에 데이터가 빠져 있을 때 사용하는 방법도 알아봅니다.

시간 윈도우 롤링을 계산하는 방법은 크게 두 가지 입니다.
하나는 self-JOIN을 사용하는 방법으로 어떤 데이터베이스에서든 사용할 수 있으며, 다른 하나는 윈도우 함수를 사용하는 방법인데 일부 데이터베이스에서는 지원되지 않습니다.  

예제 데이터가 월 단위로 집계돼 있으므로 12개월을 한 윈도우 구간으로 설정해 1년 매출 단위로 롤링해봅시다. 그리고 12개월 기준으로 이동 평균의 매출을 계산합니다. 우선 쿼리를 어떻게 작성할지 생각해봅시다. 다음 쿼리에서 별칭 `a 테이블은 닻(anchor)역할을 수행해 윈도우의 기준이 되는 날짜 (월)를 가져옵니다.` 데이터에서 시작 날짜는 2019년 12월입니다. 테이블 별칭 `b에서는 이동 평균을 계산할 월 매출 12개를 가져옵니다.` 여기서는 의도적으로 카티션 join을 수행하기 위해 아래 표현식을 사용합니다.
```sql
b.sales_month between a.sales_month - interval '11 months' and a.sales_month
```

```sql
SELECT
	a.sales_month, a.sales,
	b.sales_month as rolling_sales_month,
	b.sales as rolling_sales
FROM 
	retail_sales a
JOIN retail_sales b
	on a.kind_of_business = b.kind_of_business
	and b.sales_month between a.sales_month - interval '11 months'
	and b.sales_month
	and b.kind_of_business = 'Women''s clothing stores'
WHERE a.kind_of_business = 'Women''s clothing stores'
	and a.sales_month = '2019-12-01'
;
```

a 테이블의 sales_month와 sales는 12개월로 구성된 윈도우의 모든 행에서 반복 사용됐습니다.

> **Warning_** BETWEEN 절을 사용할 때는 명시된 두 날짜도 함께 포함돼 반환된다는 점에 주의합니다. 종종 위 코드에서 interval '11 months'가 아니라 interval '12 months'를 사용하는 실수를 합니다. 헷갈린다면 쿼리 결과를 잘 살펴보고 윈도우별 구간 개수가 원하는 수만큼인지 확인합시다.

---

다음 단계는 집계입니다. 여기서 avg 집계 함수를 사용해 평균을 구합니다. b 테이블에 레코드 개수(records_count)를 반환한 이유는 각 행이 12개 레코드의 평균을 계산한 것이 맞는지 확인하기 위함. 이처럼 추가로 열을 생성해 한 윈도우에서 계산되는 레코드 개수를 확인하면 데이터 품질을 확인하는데 유용합니다.

```sql
-- 이전 12개월간의 데이터를 이용해 노이즈 제거 & 이동평균 계산하기 위한 join 방법
select 
	a.sales_month,
	a.sales,
	avg(b.sales) as moving_avg,
	count(b.sales) as records_count
from retail_sales a
join retail_sales b on b.sales_month between a.sales_month - interval '11 months' and a.sales_month
	and a.kind_of_business = b.kind_of_business
	and b.kind_of_business = 'Women''s clothing stores'
where a.kind_of_business = 'Women''s clothing stores'
	and a.sales_month >= '1993-01-01'
group by 1, 2
order by 1
;
```

> **TIP** kind_of_business = 'Women''s clothing stores' 필터링을 각 테이블에 모두 적용할 필요는 없다. 어차피 쿼리가 INNER JOIN을 수행중이므로 둘 중 한 테이블에서만 필터링하더라도 같은 결과를 반환. 하지만 `두 테이블 모두에 필터링을 적용하면 INNER JOIN을 더 빠르게 수행`할 수 있으며, 특히 테이블의 크기가 큰 경우에 효과가 좋다.

#### 윈도우 함수를 사용해 시간 윈도우 롤링 계산
Frame 절이라는 윈도우 기본 함수 옵션을 사용해 각 윈도우에서 어떤 레코드를 포함할지 세밀하게 지정.
기본적으로 윈도우에 해당하는 모든 레코드가 포함되는데, 대부분 그대로 사용해도 충분하지만 이동계산을 위해서는 더 세밀한 범위 조정이 필요. Frame 절 문법은 처음에는 어렵게 느껴지더라도 알고 보면 간단합니다. 형식은 다음과 같습니다.


> { RANGE | ROW | GROUPS } BETWEEN frame_start AND frame_end

중괄호에 들어있는 세 가지 옵션 (RANGE, ROWS, GROUPS) 중 하나를 선택해 사용. 이 옵션으로 현재 행으로 부터 어떤 레코드를 가져올지 결정합니다.  
- ROW 옵션은 가져올 행의 정확한 개수를 지정할 때
- RANGE 옵션은 현재 행을 기준으로 지정된 범위 내에 있는 레코드를 가져올 때
- GROUP 옵션은 ORDER BY 절로 인해 정렬된 값에 중복된 레코드가 있을 때 각 중복 그룹을 가져올 때 사용

frame_start와 frame_end는 다음 값 중 하나로 지정합니다.
- UNBOUNDED PRECEDING
- offset PRECEDING
- CURRENT ROW
- offset FOLLOWING
- UNBOUNDED FOLLOWING

PRECEDING은 ORDER BY 절로 정렬된 값을 기준으로 현재 행보다 위의 행을 의미합니다.  

CURRENT ROW는 현재 행을 의미하며,  

FOLLOWING은 ORDER BY 절로 정렬된 값을 기준으로 현재 행보다 아래 행을 가리킵니다.  

UNBOUNDED 키워드는 PRECEDING과 함께 쓰이면서 해당 윈도우에서 현재 행을 기준으로 위에 있는 모든 레코드를 가리키거나, 반대로 FOLLOWING과 함께 쓰이면서 아래에 있는 모든 레코드를 가리키는 데 사용합니다.  

offset은 가져오려는 행의 숫자를 의미하는데, 여기서는 정숫값 혹은 정숫값을 의미하는 필드나 표현식을 명시합니다.  

```sql
-- Frame 절 사용 예시 (이전 12개월 이동 평균)
select sales_month, moving_avg, records_count
from (
	select sales_month
	,avg(sales) over(order by sales_month
				rows between 11 preceding and current row
				) as moving_avg
	,count(sales) over(order by sales_month
				  rows between 11 preceding and current row
				  ) as records_count
	from retail_sales
	where kind_of_business = 'Women''s clothing stores'
) as a
where a.sales_month >= '1993-01-01'
;

"sales_month"	"moving_avg"	       "records_count"
-------------   --------------------   ---------------
"1992-01-01"	1873.0000000000000000	1
"1992-02-01"	1932.0000000000000000	2
"1992-03-01"	2089.0000000000000000	3
"1992-04-01"	2233.0000000000000000	4
"1992-05-01"	2336.8000000000000000	5
"1992-06-01"	2351.3333333333333333	6
"1992-07-01"	2354.4285714285714286	7
"1992-08-01"	2392.2500000000000000	8
"1992-09-01"	2410.8888888888888889	9
"1992-10-01"	2445.3000000000000000	10
"1992-11-01"	2490.8181818181818182	11
"1992-12-01"	2651.2500000000000000	12
"1993-01-01"	2672.0833333333333333	12
```

#### 희소 데이터에서의 시간 윈도우 롤링

```sql
-- 1월 7월 데이터만 가져오기
select a.date, b.sales_month, b.sales
from date_dim a
join
(
	select sales_month, sales
	from retail_sales
	where kind_of_business = 'Women''s clothing stores'
		and date_part('month', sales_month) in (1, 7)
) b on b.sales_month between a.date - interval '11months' and a.date
where a.date = a.first_day_of_month
	and a.date between '1993-01-01' and '2020-12-01'
order by 1, 2
;
"date"	"sales_month"	"sales"
"1993-01-01"	"1992-07-01"	2373
"1993-01-01"	"1993-01-01"	2123
"1993-02-01"	"1992-07-01"	2373
"1993-02-01"	"1993-01-01"	2123
"1993-03-01"	"1992-07-01"	2373
"1993-03-01"	"1993-01-01"	2123
"1993-04-01"	"1992-07-01"	2373
"1993-04-01"	"1993-01-01"	2123
"1993-05-01"	"1992-07-01"	2373
"1993-05-01"	"1993-01-01"	2123
"1993-06-01"	"1992-07-01"	2373
"1993-06-01"	"1993-01-01"	2123
```
1월과 7월에 대해 각자 6개월씩 date_dim의 날짜가 cartesian join 되고 값들도 동일


```sql
avg 집계 함수 사용
select a.date
,avg(b.sales) as moving_avg
,count(b.sales) as records
,max(case when a.date = b.sales_month then b.sales end) as sales_in_month

FROM date_dim a
join
(
	select sales_month, sales
	from retail_sales
	where kind_of_business = 'Women''s clothing stores'
		and date_part('month', sales_month) in (1,7)
)b on b.sales_month between a.date - interval '11 months' and a.date
where a.date = a.first_day_of_month
	and a.date between '1993-01-01' and '2020-12-01'
group by 1
order by 1
;
```


### 3.4.3 누적값 계산

이동 평균 등의 윈도우 롤링 계산 시 윈도우 크기를 고정된 값으로 설정하는 것이 일반적입니다. 이동 계산 외에도 YTD(Year to date), QTD(quarter to date), MTD(month to date) 등의 '누적값'을 활용해 시계열을 분석하는 방법도 있습니다.  
누적값은 크기가 고정된 윈도우를 사용하되 시작 포인트부터 점점 윈도우 크기를 늘려가며 계산을 수행합니다.