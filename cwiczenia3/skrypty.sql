--cw1

select 
	b9.polygon_id  
from buildings_2019 b9 
left join buildings_2018 b8
	on b9.polygon_id = b8.polygon_id 
where 
	b8.polygon_id is null
	or st_astext(b8.geom) <> st_astext(b9.geom)

--cw2

create view budynki_nowe as 
select 
	b9.polygon_id
	,b9.geom
from buildings_2019 b9 
left join buildings_2018 b8
	on b9.polygon_id = b8.polygon_id 
where 
	b8.polygon_id is null
	or st_astext(b8.geom) <> st_astext(b9.geom)
	
create view poi_nowe as
select  
	p9.poi_id
	,p9.poi_name
	,p9.geom
	,p9.type
from pois_2019 p9
left join pois_2018 p8
	on p8.poi_id = p9.poi_id
where 
	p8.poi_id is null
	or st_astext(p8.geom) <> st_astext(p9.geom)  
	
select 
	count(p.poi_name) ile_nowych
	,p.type
from budynki_nowe b
cross join poi_nowe p
where 
	ST_intersects(ST_buffer(p.geom, 0.005), b.geom) = true 
group by p.type

--cw3
create table streets_reprojected as
select 
	gid, 
	link_id, 
	st_name, 
	ref_in_id, 
	nref_in_id,
	func_class, 
	speed_cat, 
	fr_speed_l, 
	to_speed_l, 
	dir_travel, 
	st_transform(st_setsrid(geom, 4326), 3785) 
from streets_2019 s  

--cw4
create table input_points (id serial primary key, geom geometry)

insert into input_points (geom) values ('POINT(8.36093 49.03174)'), ('POINT(8.39876 49.00644)')

--5
update input_points set geom = st_transform(st_setsrid(geom, 4326), 3785) 

--6
update street_node_2019 set geom = st_transform(st_setsrid(geom, 4326), 3785)

select * from street_node_2019 sn 

with node_contain as
(
select 
	sn.node_id
	,sn.link_id 
	,sn.geom 
	,ST_Contains(st_buffer(st_makeline(ip.geom), 0.002), sn.geom) as contain
from input_points ip
cross join street_node_2019 sn 
group by sn.node_id, sn.link_id, sn.geom
)
select 
	node_id
	,link_id
	,geom
	,contain
from node_contain
where contain = true

--7
select 
	lu.type,
	count(p.poi_name)
from pois_2019 p 
cross join land_use_2019 lu
where 
	lu.type like 'Park %'
	and p.type = 'Sporting Goods Store'
	and st_intersects(lu.geom, st_buffer(p.geom, 0.003)) = true
group by lu.type
	

--8
create table T2019_KAR_BRIDGES as
select
	ST_Intersection(wl.geom, r.geom) bridge
from water_lines_2019 wl
cross join railways_2019 r
where not st_isempty(ST_Intersection(wl.geom, r.geom))

select * from t2019_kar_bridges 
