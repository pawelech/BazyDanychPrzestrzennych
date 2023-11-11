CREATE EXTENSION postgis;

create table obiekt (nazwa varchar(20) primary key, geom geometry);

--1a
insert into obiekt (nazwa, geom) values
('obiekt1', st_collect(array['LINESTRING(0 1, 1 1)', 'CIRCULARSTRING(1 1, 2 0, 3 1)','CIRCULARSTRING(3 1, 4 2, 5 1)', 'LINESTRING(5 1, 6 1)']));
--1b
insert into obiekt (nazwa, geom) values
('obiekt2', ST_Collect(array['LINESTRING(10 6, 14 6)', 'CIRCULARSTRING(14 6, 16 4, 14 2)', 'CIRCULARSTRING(14 2, 12 0, 10 2)', 'LINESTRING(10 2, 10 6)', 'CIRCULARSTRING(11 2, 13 2, 11 2)']));
--1c
insert into obiekt (nazwa, geom) values
('obiekt3', 'POLYGON((10 17, 12 13, 7 15, 10 17))');
--1d
insert into obiekt (nazwa, geom) values
('obiekt4',  'LINESTRING (20.5 19.5, 22 19, 26 21, 25 22, 27 24, 25 25, 20 20)');
--1e
insert into obiekt (nazwa, geom) values
('obiekt5', ST_collect(array['POINT(30 30 59)', 'POINT(38 32 234)']));
--1f
insert into obiekt (nazwa, geom) values
('obiekt6', ST_collect(array['LINESTRING(1 1, 3 2)', 'POINT(4 2)']));


select * from obiekt;

--2
select ST_Area(ST_Buffer(ST_ShortestLine(geom, (select geom from obiekt where nazwa = 'obiekt3')), 5))
from obiekt
where nazwa = 'obiekt4';

--3
--obiekt aby byl poligonem musi byc zamkniety, punkt poczatkowy i koncowy to ten sam punkt
update obiekt set geom = st_makepolygon(st_linemerge(st_addpoint(geom, st_makepoint(20.5, 19.5)))) where nazwa = 'obiekt4';


--4
insert into obiekt (nazwa, geom) values ('obiekt7', (select st_collect((select geom from obiekt where nazwa = 'obiekt3'),
						(select geom from obiekt where nazwa = 'obiekt4'))));
						
--5
select st_area(st_buffer(geom, 5)) 
from obiekt 
where not ST_hasarc(geom);