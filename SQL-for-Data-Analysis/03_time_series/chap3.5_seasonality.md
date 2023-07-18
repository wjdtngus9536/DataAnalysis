## 3.5 계절성 분석

데이터에서 계절성은 다른 노이즈와 달리 예측이 가능합니다.  
계절성은 꼭 계절뿐 아니라 연 단위 혹은 분 단위로 나타나기도 합니다. 대통령 선거는 5년마다 실시되며 미디어 보도는 선거 주기에 따라 확연한 패턴을 보입니다. 직장이나 학교 생활은 월요일부터 금요일까지, 교회나 여가 활동은 주로 주말에 이뤄지는 등 요인별로 반복되는 패턴도 흔히 보이며, 식당은 점심 시간과 저녁 시간에 바쁘고 그 사이에는 한가하듯 시간 단위로도 계절성이 나타납니다.

시간, 일간, 주간, 월간 등 여러 주기로 집계를 수행해봅시다.
데이터셋에 대한 배경지식도 갖출 필요가 있습니다. 데이터셋의 개체 또는 게체가 표현하는 의미를 이해하고, 이에 기반한 패턴을 찾을 줄 알아야 합니다.

계절성은 여러 패턴으로 나타나지만, 이와 상관없이 분석에 주로 사용되는 방법이 있습니다. 한 가지는 데이터를 더 작은 단위의 시간 구간으로 집계하거나, 앞 절에서 배운 시간 윈도우 롤링을 사용하는 방법입니다. 혹은 현재 시간 구간과 이전 시간 구간의 차이를 비교하는 방법도 있습니다.

### 3.5.1 구간비교: YoY과 MoM
**구간비교**period-over-period는 여러 형태가 있는데, 주로 현재 시간 구간의 값을 이전 시간 구간의 값과 비교하는 방법이 많이 사용됩니다. 비교하려는 집계 단위에 따라 전년 대비 증감률(Year-over-Year), 전월 대비 증감률(Month-over-Month), 전일 대비 증감률(day-over-day)등이 있습니다.

윈도우 함수 lag를 사용해 계산해봅시다. lag 함수는 데이터에서 이전 행의 값을 반환하며, 다음과 같이 사용합니다
> lag(return_value [,offset [,default]])  

return_value에는 반환할 필드를 지정하며, 어떤 타입이든 상관없습니다. offset옵션으로는 해당 윈도우에서 몇 행 이전의 값을 반환할지 지정합니다.

```sql
SELECT kind_of_business, sales_month, sales
,lag(sales_month) over (partition by kind_of_business order by sales_month) as prev_month
,lag(sales) over (partition by kind_of_business order by sales_month) as prev_month_sales
FROM retail_sales
WHERE kind_of_business = 'Book stores'
;
```