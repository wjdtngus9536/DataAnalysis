select 
	*
	,b.debt / a.total_gdp as share
from
(
	select 
		date_trunc('year', date)::date as year
		,sum(gdp) as total_gdp
	from 
		gdp
	where 
		date < '2018-01-01'
	group by year
	order by year
) a
join debt b on b.date = a.year
;