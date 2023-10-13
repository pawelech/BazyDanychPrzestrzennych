--TWORZENIE TABEL
create table buildings (id int primary key not null, geometry geometry, name varchar(20));

create table roads (id int primary key not null, geometry geometry, name varchar(20));

create table poi (id int primary key not null, geometry geometry, name varchar(20));

--UZUPELNIANIE TABEL
insert into buildings (id, geometry, name) values 
(1, 'POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', 'BuildingA'),
(2, 'POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', 'BuildingB'),
(3, 'POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 'BuildingC'),
(4, 'POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 'BuildingD'),
(5, 'POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', 'BuildingF');

insert into roads (id, geometry, name) values
(1, 'LINESTRING(7.5 0, 7.5 10.5)', 'RoadY'),
(2, 'LINESTRING(0 4.5, 12 4.5)', 'RoadX')

insert into poi (id, geometry, name) values
(1, 'POINT(6 9.5)', 'K'),
(2, 'POINT(6.5 6)', 'J'),
(3, 'POINT(9.5 6)', 'I'),
(4, 'POINT(5.5 1.5)', 'H'),
(5, 'POINT(1 3.5)', 'G')

-- ZAD 6
--a
select sum(ST_Length(geometry)) from roads;
--b
select ST_AsText(geometry) as Text, ST_Area(geometry) as area, ST_Perimeter(geometry) as perimeter from buildings where name = 'BuildingA';
--c
select name, ST_Area(geometry) as pole_pow from buildings order by name;
--d
select name, ST_Perimeter(geometry) as obw from buildings order by ST_Area(geometry) desc limit 2;
--e
select ST_Distance(b.geometry, p.geometry) as dist
from buildings b 
cross join poi p
where p.name = 'K'
	and b.name = 'BuildingC';
--f
select ST_Area(b.geometry) - ST_Area(ST_Intersection(b.geometry, ST_Buffer(b2.geometry, 0.5))) as pole_pow
from buildings b 
cross join buildings b2
where b.name = 'BuildingC'
	and b2.name = 'BuildingB';
--g
select b.name
from buildings b
cross join roads r
where ST_Y(ST_Centroid(b.geometry)) > ST_YMax(r.geometry)
	and r.name = 'RoadX';
--8
select ST_Area(geometry) + ST_Area('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))') - 2*ST_Area(ST_Intersection(geometry, 'POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')) as pole
from buildings 
where name = 'BuildingC';
