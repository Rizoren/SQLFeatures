/* 
Using listagg + distinct in Oracle 11g as wm_concat(distinct ...),
distinct not supported into listagg, but can use custom sep.
*/

select distinct listagg(t.field_name, ', ') within group (order by t.sort_field_name) over (partition by 1) sorted_array_as_str
from table_name t 
--where ...
group by t.field_name
