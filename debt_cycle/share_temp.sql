select
	date,
	normalized_share - normalized_gdp
from
(
	select
		date,
		(2 * (d_share - min_value) / (max_value - min_value)) -1 as normalized_share,
		(2 * (n_gdp - min_gdp) / (max_gdp - min_gdp)) -1 as normalized_gdp
	from
		debt_share,
		(
			select 
				min(d_share) as min_value
				,max(d_share) as max_value
			from debt_share
		) sn,
		(
			select
				min(n_gdp) as min_gdp
				,max(n_gdp) as max_gdp
			from debt_share
		) gn
)a
;