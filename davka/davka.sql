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
CREATE TABLE vrstva_5514 AS select * from vrstva_4326;
ALTER TABLE vrstva_5514 ADD COLUMN geom1 geometry(multipolygon, 5514);
UPDATE vrstva_5514 SET geom1 = ST_Transform(geom, 5514);
-- nebo pouze změnit geometrii vrstvy
select st_transform ( geom , 5514 ) from vrstva_4326;

-- Orezani dat
-- pomoci intersect s polygonem Jihoceskeho kraje
CREATE TABLE new_table as (
	select st_intersection (orezavana_data.geom , Kraje.geom)
	from orezavana_data, Kraje
	where NAZ_CZNUTS3 = "Jihočeský kraj"
)

-- Uprava dat CSU po vytvoreni tabulky
-- pridání sloupců s primárním klíčem na které se zapomělo
ALTER TABLE "CSU_OD_KAM" ADD COLUMN id SERIAL PRIMARY KEY;
ALTER TABLE "CSU_cz0316" ADD COLUMN id SERIAL PRIMARY KEY;

-----------------------------------------------------------------------------------
-- Validace dat
-----------------------------------------------------------------------------------

-- nalezení nevalidních dat
-- funkce ST_IsValid vrací pouze TRUE nebo FALSE, ST_IsValidReason vypíše přímo o jakou chybu se jedná
select id, ST_IsValidReason(geom) AS duvod from "Kraje" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "NATURA2000" where ST_IsValid(geom) = FALSE; -- 1x Ring Self-intersection 
select id, ST_IsValidReason(geom) AS duvod from "OSM_NabozenskeObjekty" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "OSM_StromyVrchy" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "OSM_Zeleznice" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "baziny_rasiliniste" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "chranena_uzemi" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "jezy" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "lesy" where ST_IsValid(geom) = FALSE; -- 1x Ring Self-intersection 
select id, ST_IsValidReason(geom) AS duvod from "losos_kapr_vod" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "losos_kapr_vody" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "maloplosna_CHU_AOPK" where ST_IsValid(geom) = FALSE; -- 1x Ring Self-intersection 
select id, ST_IsValidReason(geom) AS duvod from "obce" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "okresy" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "pamatne_stromy" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "ptaci_oblasti" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "vodni_plochy" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "vodni_toky_dibavod" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "vrstevnice" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "vyskove_koty" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "zaplavova_uzemi_100" where ST_IsValid(geom) = FALSE; --OK
select id, ST_IsValidReason(geom) AS duvod from "OSM_VyuzitiPudy" where ST_IsValid(geom) = FALSE; -- 53x Ring Self-intersection

-- oprava nevalidní geometrie
-- opravené vrstvy znovu zkontrolovány pomocí ST_IsValidReason, vše OK
UPDATE  "NATURA2000" SET geom = ST_MakeValid(geom)  where ST_IsValid(geom) = FALSE; 
UPDATE  "lesy" SET geom = ST_MakeValid(geom)  where ST_IsValid(geom) = FALSE; 
UPDATE  "maloplosna_CHU_AOPK" SET geom = ST_MakeValid(geom)  where ST_IsValid(geom) = FALSE; 
UPDATE  "OSM_VyuzitiPudy" SET geom = ST_MakeValid(geom)  where ST_IsValid(geom) = FALSE; 


-----------------------------------------------------------------------------------
-- Dotazy Atributové
-----------------------------------------------------------------------------------

-- 1. V jaké obci s rozšířenou působností se nachází obec Červený Hrádek?
--
-- Dačice

select naz_orp 
from obce 
where naz_obec = 'Červený Hrádek'

-- 2. Ktere obce Jihočeského kraje maji pocet obyvatel mezi 7 000 - 8 000?
-- Kromě názvu vypište i počet obyvatel.
--
-- 5 obcí - Kaplice, Dačice, Vimperk, Sezimovo Ústí, Soběslav

select naz_obec, pocet_obyv 
from obce
where pocet_obyv > 6999 AND pocet_obyv < 8001 

----NEBO

select naz_obec, pocet_obyv 
from obce
where pocet_obyv between 6999 and 8001


-- 3. Kolik vodních ploch má v názvu slovo rybník?
--
-- 68

select count(*) 
from vodni_plochy
where nazev like '%rybn%'

-- 4. Jaká je hustota zalidnění na km^2 v okrese Strakonice? Výslednou hodnotu zaokrouhlete.
--
-- 68

select round(pocet_obyv/shape_area*1000000) 
from okresy
where naz_lau1 = 'Strakonice'

-- 5. Vypiste všechny vodní plochy, jejichž výška je 
-- menší než 400 a větší než 500. 
-- Výšku uveďte také, výsledek seřaďte podle výšky.
--
-- 56 výsledků

select nazev, vyska  
from vodni_plochy
where vyska not between 400 and 500
order by vyska 

-- NEBO

select nazev, vyska  
from vodni_plochy
where vyska < 400 AND vyska > 500
order by vyska

-- 6. Nalezněte nejvyšší bod v Jihočeském kraji
--
-- Plechý

select nazev 
from vyskove_koty
order by vyska desc
limit 1

-- 7. Najděte výšku nejnižšího bodu v Jihočeském kraji
--
-- 436

select min(vyska) 
from vyskove_koty

-- 8. Jaká je průměrná nezaměstnanost v okrese České Budějovice?
--
-- 3.7 %

select avg(mira_nezam) 
from obce
where naz_lau1 like '%Buděj%'

-- 9. Jaká je plocha v km^2 maloplošných chráněných oblastí v Jihočeském kraji?
--
-- 262.94 

select sum(shapearea/1000000) 
from "maloplosna_CHU_AOPK"

-- 10. Vypište obce, které začínají na písmo L a končí na písmo E
--
-- 15 obcí

select naz_obec 
from obce
where naz_obec like 'L%e'

-- 11. Vypište obce, v jejichž názvu je druhé písmeno ě
--
-- 10 obcí

select naz_obec 
from obce
where naz_obec like '_ě%'

-- 12. Jaký je poměr kaprových vod vůči lososovým vodám?
--
-- 0.8 ( 22 : 26)

select round(
(
 select   count(*)
 from     "losos_kapr_oblasti"
 where   typ_obryb like 'Kapr%'
)::numeric / (
 select   count(*)
 from     "losos_kapr_oblasti"
 where    typ_obryb like 'Loso%'
)::numeric, 1);

-- 13. Kolik kilometrů řek Jihočeského kraje spadá pod lososové vody??
--
-- 1905 km
select round(sum(shape_leng)/1000) 
from losos_kapr_vody
where typ_obryb LIKE 'Losos%'

-----------------------------------------------------------------------------------
-- Dotazy Prostorové
-----------------------------------------------------------------------------------

-- 1. Kolik km^2 ptačích rezervací se nachází v záplavových oblastech v Jihočeském kraji?
-- 
-- 99.8 km^2

select (sum(st_area(st_intersection (zaplavova_uzemi_100.geom , ptaci_oblasti.geom) ))/1000000) as rozloha
from zaplavova_uzemi_100, ptaci_oblasti

-- 2. Seřaďte okresy sestupně podle velikosti farmářské půdy , 
-- výsledek zaokrouhlete na celé hektary, uvažujte plochy, 
-- které celou svoji plochou náleží příslušnému okresu
--
-- Tábor 52616, Jindřichův Hradec 50615, České Budějovice 49994 ,..

select 	okresy.naz_lau1 AS okres, 
		floor(sum(st_area(Puda.geom))*1e-4) AS suma
from okresy  
join  "OSM_VyuzitiPudy" AS Puda
on st_contains(okresy.geom,Puda.geom)
where fclass = 'farm' 
group by okresy.naz_lau1
order by suma
desc;

-- 3. Kolik obcí je v okresu s největším obvodem ?
--
--  102

select count(*) as pocet_obci
from obce
join (select geom
		from okresy 
		order by st_perimeter(geom) desc limit 1) as  okres
on st_within(obce.geom, okres.geom);

-- 4. Jaké je využití půdu v Jihočeském kraji ? Uveďte rozlohu v ha pro jednotlivé 
-- typy využití a uveďte v kolika záznamech jsou jednotlivé typy využití uvedeny.
--
-- meadow 56711 167295ha, farm 34759 262796ha, forest 25024 405914ha,...

select fclass as vyuziti, 
			count(*) as pocet_zaznamu , 
			sum(st_area(geom))*1e-4 as vymera_ha
from "OSM_VyuzitiPudy" 
group by fclass
order by  pocet_zaznamu
desc

-- 5. Kolik km^2 bazin a raselinist se nachazi v ptacich oblastech?
--
-- 27.62

select sum(shape_area/1000000)
from   baziny_rasiliniste
join   ptaci_oblasti
on     st_within(baziny_rasiliniste.geom, ptaci_oblasti.geom)

-- 6. Kolik jezů se nachází na Otavě?
-- Vzhledem k přesnosti dat uvažujte takové jezy, 
-- které se nachází do vzdálenosti 30 m od toku
-- 
-- 16

select count(*) from jezy as j
join  vodni_toky_dibavod as v
on v.naz_tok = 'Otava'
and st_dwithin (j.geom, v.geom, 30)

-- NEBO
-- 15

with otava as 
(
select st_buffer(geom, 30) as geom 
from vodni_toky_dibavod
where naz_tok = 'Otava'
)
select count(*) from jezy
where id in 
(
select distinct j.id 
from jezy as j
join otava
on st_within(j.geom, otava.geom)
)

-- NEBO
-- 15

select count(distinct j.id) 
from jezy as j
join  vodni_toky_dibavod as v
on v.naz_tok = 'Otava'
and j.geom && st_expand(v.geom, 30)
and j.geom <-> v.geom < 30


-- 7. Jaké památné stromy se nachází v obci Volyně?
--
-- 4 stromy - Lípa u sv. Ludmily, Lípa u školy v přírodě ....

select nazev from pamatne_stromy as ps
join  obce as o
on o.naz_obec = 'Volyně'
and st_intersects (ps.geom, o.geom)

-- 8. Vypište obce s množstvím památných stromů větší než 10. Počet uveďte také.
--
-- 19 obcí - Hluboká nad Vltavou 83; Chvalšiny 80; Třeboň 64 ....

select count(nazev), naz_obec from pamatne_stromy as ps
join  obce as o
on st_intersects (ps.geom, o.geom)
group by o.naz_obec
having count(nazev) > 10
order by count desc

-- 9. Vypište obce s množstvím památných stromů větší než 10 
-- a mezi něž nepatří lípa. Počet uveďte také. Berte ohled 
-- na to, že nevíte, zda slovo lípa je v databázi s diakritikou 
-- či nikoliv.
--
-- 17 obcí - Hluboká nad Vltavou 83; Chvalšiny 79; Třeboň 64 ....

select count(nazev), naz_obec from pamatne_stromy as ps
join  obce as o
on st_intersects (ps.geom, o.geom)
where ps.nazev not like '%l_pa%'
group by o.naz_obec
having count(nazev) > 10
order by count desc

-- 10. Jaké lípy se vyskytují v okrese Strakonice?
--
-- 12 líp - Tažovická lípa, Švandova lípa, Paštická lípa ....

select nazev from pamatne_stromy as ps
join  okresy as o
on st_intersects (ps.geom, o.geom)
where ps.nazev like '%l_pa%'
and o.naz_lau1 = 'Strakonice'

-- 11. V kolika obcích se nenachází žádný památný strom?
--
-- 384

select    count(*)
from      obce as o
left join pamatne_stromy as ps
on        st_intersects(o.geom, ps.geom)
where     ps.id is null;

-- 12. Kolik procent chráněných území zabírají vodní plochy??
-- Zaokrouhlete na dvě desetinná místa
--
-- 2.07 %

select round(
(
select sum(vp.shape_area)
from "vodni_plochy" as vp
join "chranena_uzemi" as ch
on st_within(vp.geom, ch.geom)
)::numeric / 
(
select sum(shape_area)
from chranena_uzemi
)::numeric *100, 2)


-- 13. Vypište, které památné stromy se nachází ve vzdálenosti 100 metrů
-- od řeky Vltavy.
--
-- 4 - Týn nad Vltavou - Buk červený, ČB - Jinan dvoulaločný ...

create temporary table stromy as 

with vlt as 
(
select st_buffer(geom, 100, 25) as geom 
from vodni_toky_dibavod 
where naz_tok = 'Vltava'
)

select nazev, geom from pamatne_stromy
where id in 
(
select ps.id from pamatne_stromy as ps 
join vlt
on st_within(ps.geom, vlt.geom)
)


select naz_obec, nazev from obce
right join stromy
on st_within(stromy.geom, obce.geom)


-- 14. Kolik procent Šumavy tvoří lesy?? (Pro zjištění oblasti Šumavy
-- použijte vrstvu chranena_uzemi)
--
-- 68 %

with chu as 
(
select geom from chranena_uzemi
where nazev = 'Šumava'
)
select round 
((sum(st_area(st_intersection(l.geom, chu.geom)))::numeric 
/ (select sum(st_area(geom)) from chu)::numeric) * 100)
from lesy as l
join chu
on l.geom && chu.geom


-- 15. Vypište název a výšku bodů, které se nacházejí do 100 m
-- od hranic chráněných území. Výsledky seřaďte vzestupně.
--
-- 3 - Plechý (1378), Trojmezná (1361), Vysoký hřeben (1341)

with chu as 
(
select st_boundary(geom) as geom from chranena_uzemi
)
select nazev, vyska 
from vyskove_koty as vk
join chu 
on st_dwithin(chu.geom, vk.geom, 100)
order by vyska desc


