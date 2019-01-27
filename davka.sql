SET search_path TO myschema, uzpd18_e, public;

-- Transformace z WGS do JTSK
-- 

CREATE TABLE vrstva_5514 AS SELECT * FROM vrstva_4326;
ALTER TABLE vrstva_5514 ADD COLUMN geom1 geometry(multipolygon, 5514);
UPDATE vrstva_5514 SET geom1 = ST_Transform(geom, 5514);

-- nebo

SELECT st_transform ( geom , 5514 ) FROM vrstva_4326;


-- Validace dat
-- nalezení nevalidních dat
SELECT * FROM vrstva
WHERE ST_IsValid(geom) = false;

-- další postup je individuální
-- smazání ploch s výměrou = 0

-- smazání linií s délkou = 0

-- 

