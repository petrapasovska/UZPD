
/*
* --------------------------------------------------------------------------------- *
* semestralni projekt
* zimni semestr 2018/2019
* autor: Petra Pasovská, Michal Janovský
* schema: uzpd18_e
* --------------------------------------------------------------------------------- *
*/
-----------------------------------------------------------------------------------
-- nastavení cesty, když se SQL nezapne přímo z schémata
SET search_path TO myschema, uzpd18_e, public;

-----------------------------------------------------------------------------------
-- Příprava dat
-----------------------------------------------------------------------------------

-- Transformace z WGS do JTSK
-- vytvoření nové vrstvy s novou geometrií (kopie)
CREATE TABLE vrstva_5514 AS SELECT * FROM vrstva_4326;
ALTER TABLE vrstva_5514 ADD COLUMN geom1 geometry(multipolygon, 5514);
UPDATE vrstva_5514 SET geom1 = ST_Transform(geom, 5514);
-- nebo pouze změnit geometrii vrstvy
SELECT st_transform ( geom , 5514 ) FROM vrstva_4326;

-- Uprava OSM dat 
-- odstranění přebytečných sloupců
ALTER TABLE "OSM_VyuzitiPudy" 
DROP  snatky, DROP rozvody, DROP narozeni, DROP zemreli, DROP pristehova, DROP vystehoval, 
DROP pocet_obyv, DROP muzi, DROP muzi_0_14, DROP muzi_15_64, DROP muzi_65, DROP zeny, 
DROP zeny_0_14, DROP zeny_15_64, DROP zeny_65, DROP obyv_0_14, DROP obyv_15_64, 
DROP obyv_65, DROP mira_nez_1, DROP mira_nez_2, DROP mira_nezam, DROP mzda, DROP rozdil_mzd, 
DROP nadeje_d_1, DROP nadeje_doz, DROP sx, DROP sy;

-- Uprava dat CSU
-- pridání sloupců s primárním klíčem
ALTER TABLE "CSU_OD_KAM" ADD COLUMN id SERIAL PRIMARY KEY;
ALTER TABLE "CSU_cz0316" ADD COLUMN id SERIAL PRIMARY KEY;

-----------------------------------------------------------------------------------
-- Validace dat
-----------------------------------------------------------------------------------

-- nalezení nevalidních dat
-- funkce ST_IsValid vrací pouze TRUE nebo FALSE, ST_IsValidReason vypíše přímo o jakou chybu se jedná
SELECT id, ST_IsValidReason(geom) AS duvod FROM "Kraje" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "NATURA2000" WHERE ST_IsValid(geom) = FALSE; -- 1x Ring Self-intersection 
SELECT id, ST_IsValidReason(geom) AS duvod FROM "OSM_NabozenskeObjekty" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "OSM_StromyVrchy" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "OSM_Zeleznice" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "baziny_rasiliniste" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "chranena_uzemi" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "jezy" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "lesy" WHERE ST_IsValid(geom) = FALSE; -- 1x Ring Self-intersection 
SELECT id, ST_IsValidReason(geom) AS duvod FROM "losos_kapr_vod" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "losos_kapr_vody" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "maloplosna_CHU_AOPK" WHERE ST_IsValid(geom) = FALSE; -- 1x Ring Self-intersection 
SELECT id, ST_IsValidReason(geom) AS duvod FROM "obce" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "okresy" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "pamatne_stromy" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "ptaci_oblasti" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "vodni_plochy" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "vodni_toky_dibavod" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "vrstevnice" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "vyskove_koty" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "zaplavova_uzemi_100" WHERE ST_IsValid(geom) = FALSE; --OK
SELECT id, ST_IsValidReason(geom) AS duvod FROM "OSM_VyuzitiPudy" WHERE ST_IsValid(geom) = FALSE; -- 53x Ring Self-intersection

-- oprava nevalidní geometrie
-- opravené vrstvy znovu zkontrolovány pomocí ST_IsValidReason, vše OK
UPDATE  "NATURA2000" SET geom = ST_MakeValid(geom)  WHERE ST_IsValid(geom) = FALSE; 
UPDATE  "lesy" SET geom = ST_MakeValid(geom)  WHERE ST_IsValid(geom) = FALSE; 
UPDATE  "maloplosna_CHU_AOPK" SET geom = ST_MakeValid(geom)  WHERE ST_IsValid(geom) = FALSE; 
UPDATE  "OSM_VyuzitiPudy" SET geom = ST_MakeValid(geom)  WHERE ST_IsValid(geom) = FALSE; 


-----------------------------------------------------------------------------------
-- Příklady
-----------------------------------------------------------------------------------

-- Kolik km^2 ptačích rezervací se nachází v záplavových oblastech v Jihočeském kraji
-- 99.8 km^2
SELECT (sum(st_area(st_intersection (zaplavova_uzemi_100.geom , ptaci_oblasti.geom) ))/1000000) as rozloha
FROM zaplavova_uzemi_100, ptaci_oblasti







