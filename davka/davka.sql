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
CREATE SCHEMA myschema;
SET search_path TO myschema, uzpd18_e, public;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-- Příprava dat (pouze ukázkově, vypisovat vše pro všechny vrstvy je zbytečné)
-----------------------------------------------------------------------------------

-- Transformace z WGS-84 do JTSK
-- vytvoření nové vrstvy s novou geometrií (kopie)
CREATE TABLE vrstva_5514 AS SELECT * FROM vrstva_4326;
ALTER TABLE vrstva_5514 ADD COLUMN geom1 geometry(multipolygon, 5514);
UPDATE vrstva_5514 SET geom1 = ST_Transform(geom, 5514);
-- nebo pouze změnit geometrii vrstvy
SELECT st_transform ( geom , 5514 ) FROM vrstva_4326;

-- Orezani dat
-- pomoci intersect s polygonem Jihoceskeho kraje
CREATE TABLE new_table as (
	SELECT st_intersection (orezavana_data.geom , Kraje.geom)
	FROM orezavana_data, Kraje
	WHERE NAZ_CZNUTS3 = "Jihočeský kraj"
)

-- Uprava OSM dat 
-- odstranění přebytečných sloupců
ALTER TABLE "OSM_VyuzitiPudy" 
DROP  snatky, DROP rozvody, DROP narozeni, DROP zemreli, DROP pristehova, DROP vystehoval, 
DROP pocet_obyv, DROP muzi, DROP muzi_0_14, DROP muzi_15_64, DROP muzi_65, DROP zeny, 
DROP zeny_0_14, DROP zeny_15_64, DROP zeny_65, DROP obyv_0_14, DROP obyv_15_64, DROP obyv_65, 
DROP mira_nez_1, DROP mira_nez_2, DROP mira_nezam, DROP mzda, DROP rozdil_mzd, DROP nadeje_d_1, 
DROP nadeje_doz, DROP sx, DROP sy;

-- Uprava dat CSU po vytvoreni tabulky
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
-- Dotazy Atributové
-----------------------------------------------------------------------------------

-- V jaké obci s rozšířenou působností se nachází obec Červený Hrádek?
-- Dačice

select naz_orp from obce 
where naz_obec = 'Červený Hrádek'

-- Ktere obce Jihočeského kraje maji pocet obyvatel mezi 7 000 - 8 000?
-- Kromě názvu vypište i počet obyvatel
-- 5 obcí - Kaplice, Dačice, Vimperk, Sezimovo Ústí, Soběslav

SELECT naz_obec, pocet_obyv FROM obce
WHERE pocet_obyv > 6999 AND pocet_obyv < 8001 

----NEBO

SELECT naz_obec, pocet_obyv FROM obce
WHERE pocet_obyv between 6999 and 8001


-- Kolik vodních ploch má v názvu slovo rybník?
-- 68

select count(*) from vodni_plochy
where nazev like '%rybn%'

-- Jaká je hustota zalidnění na km^2 v okrese Strakonice? Výslednou hodnotu zaokrouhlete.
-- 68

select round(pocet_obyv/shape_area*1000000) from okresy
where naz_lau1 = 'Strakonice'

-- Vypiste všechny vodní plochy, jejichž výška je menší než 400 nebo větší než 500. 
-- Výšku uveďte také, výsledek seřaďte podle výšky.
-- 56 výsledků

select nazev, vyska  from vodni_plochy
where vyska not between 400 and 500
order by vyska 

-- NEBO

select nazev, vyska  from vodni_plochy
where vyska < 400 OR vyska > 500
order by vyska

-- Nalezněte nejvyšší bod v Jihočeském kraji
-- Plechý

select nazev from vyskove_koty
order by vyska desc
limit 1

-- Najděte výšku nejnižšího bodu v Jihočeském kraji
-- 436

select min(vyska) from vyskove_koty

-- Jaká je průměrná nezaměstnanost v okrese České Budějovice?
-- 3.7 %

select avg(mira_nezam) from obce
where naz_lau1 like '%Buděj%'

-- Jaká je plocha v km^2 maloplošných chráněných oblastí v Jihočeském kraji?
-- 262.94 

select sum(shapearea/1000000) from "maloplosna_CHU_AOPK"

-- Vypište obce, které začínají na písmo L a končí na písmo E
-- 15 obcí

select naz_obec from obce
where naz_obec like 'L%e'

-- Vypište obce, v jejichž názvu je druhé písmeno ě
-- 10 obcí

select naz_obec from obce
where naz_obec like '_ě%'

-- Jaký je poměr kaprových vod vůči lososovým vodám?
-- 0.8 ( 22 : 26)

SELECT ROUND(
(
 SELECT   count(*)
 FROM     "losos_kapr_oblasti"
 WHERE   typ_obryb like 'Kapr%'
)::numeric / (
 SELECT   count(*)
 FROM     "losos_kapr_oblasti"
 WHERE    typ_obryb like 'Loso%'
)::numeric, 1);

-----------------------------------------------------------------------------------
-- Dotazy Prostorové
-----------------------------------------------------------------------------------

-- Kolik km^2 ptačích rezervací se nachází v záplavových oblastech v Jihočeském kraji
-- 99.8 km^2
SELECT (sum(st_area(st_intersection (zaplavova_uzemi_100.geom , ptaci_oblasti.geom) ))/1000000) as rozloha
FROM zaplavova_uzemi_100, ptaci_oblasti

-- Seřaďte okresy sestupně podle velikosti farmářské půdy , výsledek zaokrouhlete na celé hektary, uvažujte plochy, které celou svoji plochou náleží příslušnému okresu
-- Tábor 52616, Jindřichův Hradec 50615, České Budějovice 49994 ,..
SELECT okresy.naz_lau1 AS okres, floor(sum(st_area(Puda.geom))*1e-4) AS suma
FROM okresy  
JOIN  "OSM_VyuzitiPudy" AS Puda
ON st_contains(okresy.geom,Puda.geom)
WHERE fclass = 'farm' --code = 7205
GROUP BY okresy.naz_lau1
ORDER BY suma
DESC;

-- Kolik obcí je v okresu s největším obvodem ?
-- 97
select count(*) as pocet_obci
from obce
join (select geom
		from okresy 
		order by st_perimeter(geom) desc limit 1) as  okres
on st_within(obce.geom, okres.geom);

-- jaké je využití půdu v Jihočeském kraji ? Uveďte rozlohu v ha pro jednotlivé typy využití a uveďte v kolika záznamech jsou jednotlivé typy využití uvedeny.
-- meadow 56711 167295ha, farm 34759 262796ha, forest 25024 405914ha,...
SELECT fclass as vyuziti, 
			count(*) as pocet_zaznamu , 
			sum(st_area(geom))*1e-4 as vymera_ha
FROM "OSM_VyuzitiPudy" 
GROUP BY fclass
ORDER BY  pocet_zaznamu
DESC


-- V kolika kilometrech řek Jihočeského kraje se vyskytují lososy ??
-- 1905 km
SELECT round(sum(shape_leng)/1000) AS delka
FROM losos_kapr_vody
WHERE typ_obryb LIKE 'Losos%'


