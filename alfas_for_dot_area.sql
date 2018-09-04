select t.id_trace, 
(
 select alfa from alfa_compare where id_alfa_compare = 
 (
 select id_alfa_compare from alfa_compare where id_trace =  t.id_trace order by id_alfa_compare limit 1
 ) + 1699
) as "1969",
(
 select alfa from alfa_compare where id_alfa_compare = 
 (
 select id_alfa_compare from alfa_compare where id_trace =  t.id_trace order by id_alfa_compare limit 1
 ) + 1698
) as "1698"
from trace t
where t.id_fiber = 3 and t.trace_date between '2018-02-13 20:00:00'::timestamp and now()::timestamp
order by t.id_trace;
