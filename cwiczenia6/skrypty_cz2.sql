CREATE TABLE lech.porto_ndvi AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, 1,
r.rast, 4,
'([rast2.val] - [rast1.val]) / ([rast2.val] +
[rast1.val])::float','32BF'
) AS rast
FROM r;


select * from lech.porto_ndvi pn;

CREATE INDEX idx_porto_ndvi_rast_gist ON lech.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('lech'::name,
'porto_ndvi'::name,'rast'::name);

create or replace function lech.ndvi(
value double precision [] [] [],
pos integer [][],
VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value
[1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE lech.porto_ndvi2 AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, ARRAY[1,4],
'lech.ndvi(double precision[],
integer[],text[])'::regprocedure, --> This is the function!
'32BF'::text
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON lech.porto_ndvi2
USING gist (ST_ConvexHull(rast));


SELECT AddRasterConstraints('lech'::name,
'porto_ndvi2'::name,'rast'::name);


SELECT ST_AsTiff(ST_Union(rast))
FROM lech.porto_ndvi;

SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
FROM lech.porto_ndvi;

SELECT ST_GDALDrivers();

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
 ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
 ) AS loid
FROM lech.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'C:\Users\pawel\OneDrive\Pulpit\BazyDanychPrzestrzennych\cwiczenia6\myraster.tiff') --> Save the file in a place where the user postgres have access. In windows a flash drive usualy works fine.
 FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
 FROM tmp_out; --> Delete the large object.
 
