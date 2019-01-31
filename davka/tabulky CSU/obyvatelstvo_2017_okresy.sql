CREATE TABLE IF NOT EXISTS "obyvatelstvo_2017_okresy" (
    "Okresy" TEXT,
    "Stav" INT,
    "Snatek" INT,
    "Rozvody" INT,
    "Zive_Narozeni" INT,
    "Potraty" INT,
    "Zemrely" INT,
    "Prirozeny_pr" INT,
    "Pristehovani" INT,
    "Vystehovani" INT,
    "Prirustek_stehovani" TEXT,
    "Celkem_prirustek" INT,
    "Stredni_Stav" INT
);
INSERT INTO "obyvatelstvo_2017_okresy" VALUES
    ('České Budějovice',193337,980,444,2159,623,1917,242,3212,2062,'1150',1392,192561),
    ('Český Krumlov',61187,312,147,662,245,625,37,1039,1044,'-5',32,61091),
    ('Jindřichův Hradec',90835,424,219,905,276,989,-84,1150,1356,'-206',-290,90936),
    ('Písek',71067,317,165,724,232,766,-42,1245,1006,'239',197,70911),
    ('Prachatice',50700,281,124,553,160,548,5,762,762,' - ',5,50735),
    ('Strakonice',70760,329,164,784,236,792,-8,1009,938,'71',63,70668),
    ('Tábor',102310,502,235,1093,359,1115,-22,1255,1218,'37',15,102278);