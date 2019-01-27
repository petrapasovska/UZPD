-- nastavení cesty, když se SQL nezapne přímo z schémata
SET search_path TO myschema, uzpd18_e, public;

-- Transformace z WGS do JTSK
-- vytvoření nové vrstvy s novou geometrií (kopie)
CREATE TABLE vrstva_5514 AS SELECT * FROM vrstva_4326;
ALTER TABLE vrstva_5514 ADD COLUMN geom1 geometry(multipolygon, 5514);
UPDATE vrstva_5514 SET geom1 = ST_Transform(geom, 5514);
-- nebo pouze změnit geometrii vrstvy
SELECT st_transform ( geom , 5514 ) FROM vrstva_4326;

-- Uprava OSM dat 
--(po intersection s Kraji zde zbyyl prebytecne sloupce)
-- odstranění přebytečných sloupců
ALTER TABLE "OSM_VyuzitiPudy" 
DROP  snatky, DROP rozvody, DROP narozeni, DROP zemreli, DROP pristehova, DROP vystehoval, 
DROP pocet_obyv, DROP muzi, DROP muzi_0_14, DROP muzi_15_64, DROP muzi_65, DROP zeny, 
DROP zeny_0_14, DROP zeny_15_64, DROP zeny_65, DROP obyv_0_14, DROP obyv_15_64, 
DROP obyv_65, DROP mira_nez_1, DROP mira_nez_2, DROP mira_nezam, DROP mzda, DROP rozdil_mzd, 
DROP nadeje_d_1, DROP nadeje_doz, DROP sx, DROP sy;

-- Validace dat
-- nalezení nevalidních dat, další postup je individuální
SELECT * FROM table_name
WHERE ST_IsValid(geom) = false;
-- smazání ploch s výměrou < 1m
DELETE FROM table_name WHERE area < 1;
-- smazání linií s délkou < 1cm
DELETE FROM table_name WHERE lenght < 0.01;
-- jiné kritérium ..
DELETE FROM table_name WHERE condition; 
