select f.start, f.end, f.linearity, f."BMaxDiff", f."BMinDiff", 
(
 select max(delta) from alarm where id_fiber = f.id_fiber and algorithm = 1 and "IndexDelta">f.start and "IndexDelta"<f."end"
) as bmaxfromalarm,
(
select min(delta) from alarm where id_fiber = f.id_fiber and algorithm = 1 and "IndexDelta">f.start and "IndexDelta"<f."end"
),
f.summax, f.summin,
(
 select max(delta) from alarm where id_fiber = f.id_fiber and algorithm = 3 and "IndexDelta">f.start and "IndexDelta"<f."end"
),
(
select min(delta) from alarm where id_fiber = f.id_fiber and algorithm = 3 and "IndexDelta">f.start and "IndexDelta"<f."end"
)

from fiber_segments f
where f.id_fiber=5
order by f.start;