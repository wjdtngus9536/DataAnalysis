select 
	dt,
    (2 * (c_prc - min_value) / (max_value - min_value)) -1 as normalized_value
from
	nasdaq,
	(
		select 
			min(c_prc) as min_value
			,max(c_prc) as max_value
		from nasdaq
	) mn
;