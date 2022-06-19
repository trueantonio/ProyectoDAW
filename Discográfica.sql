--BORRADO DE TABLAS:
/*Se recomienda utilizar el borrado de las tablas para evitar conflictos con otras tablas creadas posteriormente que se llamen de igual manera.*/
DROP TABLE ciudad CASCADE CONSTRAINTS;
DROP TABLE artista CASCADE CONSTRAINTS;
DROP TABLE contrato CASCADE CONSTRAINTS;
DROP TABLE noticias CASCADE CONSTRAINTS;
DROP TABLE tienda CASCADE CONSTRAINTS;
DROP TABLE escenario CASCADE CONSTRAINTS;
DROP TABLE evento CASCADE CONSTRAINTS;
DROP TABLE compositor CASCADE CONSTRAINTS;
DROP TABLE album   CASCADE CONSTRAINTS;
DROP TABLE cancion CASCADE CONSTRAINTS;
DROP TABLE evento_artista CASCADE CONSTRAINTS;
DROP TABLE album_tienda CASCADE CONSTRAINTS;

--CREACION DE TABLAS:

CREATE TABLE ciudad(
cod_ciudad      VARCHAR(10) CONSTRAINT pk_ciudad        PRIMARY KEY,
nombre_ciudad   VARCHAR(30) CONSTRAINT un_nombre_ciudad UNIQUE,
pais            VARCHAR(30) CONSTRAINT nn_pais_ciudad   NOT NULL
);

CREATE TABLE artista(
  dni			    VARCHAR(9)		CONSTRAINT 	pk_artista		PRIMARY KEY,
  nombre_artistico  VARCHAR(20)	    CONSTRAINT  un_artista      UNIQUE,
  nombre			VARCHAR(20),
  apellidos		    VARCHAR(30),
  ciudad_natal      VARCHAR(30)     CONSTRAINT fk_artista REFERENCES ciudad(nombre_ciudad),
  telefono		    NUMBER(9),
  f_nacimiento		DATE
);

CREATE TABLE contrato(
cod_contrato	  VARCHAR(8)	 CONSTRAINT pk_contrato                 PRIMARY KEY	
                                 CONSTRAINT nn_cod_contrato	            NOT NULL,
dni_artista       VARCHAR(9)     CONSTRAINT fk_dni_artista_contrato     REFERENCES artista(dni),
nombre_artista    VARCHAR(20)    CONSTRAINT fk_nombre_artista_contrato  REFERENCES artista(nombre_artistico),
fecha_inicio      DATE           CONSTRAINT nn_fecha_inicio_contrato	NOT NULL,
fecha_fin         DATE
);

CREATE TABLE noticias(
    web        VARCHAR(200)  CONSTRAINT pk_noticias         PRIMARY KEY,
    titular    VARCHAR(300),
    artista    VARCHAR(20)   CONSTRAINT fk_artista_noticias REFERENCES artista(nombre_artistico),
    fecha      DATE     
);

CREATE TABLE tienda(
	cif			    VARCHAR(9) 		CONSTRAINT 	pk_tienda 	     PRIMARY KEY,
  nombre_tienda   VARCHAR(20),
  direccion		VARCHAR(30),
  ciudad          VARCHAR(30)     CONSTRAINT  fk_ciudad_tienda REFERENCES ciudad(nombre_ciudad),
  telefono		NUMBER(9)
);

CREATE TABLE escenario(
nombre_escenario  VARCHAR(30) CONSTRAINT pk_escenario        PRIMARY KEY,
ciudad            VARCHAR(30) CONSTRAINT fk_ciudad_escenario REFERENCES ciudad(nombre_ciudad),
aforo             NUMBER(6)   CONSTRAINT ck_aforo_escenario  CHECK(aforo > 0)
);

CREATE TABLE evento(
    cod_evento	        VARCHAR(3) 	  CONSTRAINT pk_eventos		                PRIMARY KEY,
    tipo_evento         VARCHAR(15)   CONSTRAINT ck_tipo_evento_evento          CHECK(tipo_evento IN('Concierto','Festival','Firma de discos')),
    nombre_evento       VARCHAR(30)   CONSTRAINT un_evento                      UNIQUE,
    escenario           VARCHAR(30)   CONSTRAINT fk_escenario_evento            REFERENCES escenario(nombre_escenario),
    precio			        NUMBER(8,2),
    fecha_evento		    DATE
);

CREATE TABLE compositor(
	dni			          VARCHAR(9)		CONSTRAINT 	pk_compositor		PRIMARY KEY,
	nombre_compositor	VARCHAR(30)     CONSTRAINT  un_compositor       UNIQUE,
	telefono		      NUMBER(9),
	f_nacimiento		  DATE
);

CREATE TABLE album(	
	nombre_album    VARCHAR(30)   CONSTRAINT    pk_album            PRIMARY KEY,
	nombre_artista	VARCHAR(20)	  CONSTRAINT 	fk_artista_album	REFERENCES artista(nombre_artistico),
    pistas        NUMBER(30)    CONSTRAINT    nn_pistas_album     NOT NULL,
	f_lanzamiento   DATE
);

CREATE TABLE cancion(	
  titulo	   VARCHAR(30),   	
  artista      VARCHAR(20)    CONSTRAINT    fk_artista_cancion    REFERENCES artista(nombre_artistico),
  compositor   VARCHAR(30)    CONSTRAINT    fk_compositor_cancion REFERENCES compositor(nombre_compositor),
  nombre_album VARCHAR(30)	  CONSTRAINT 	fk_album_cancion      REFERENCES album(nombre_album),
  genero	   VARCHAR(10) 	    CONSTRAINT 	ck_genero_cancion 	  CHECK(genero IN ('ROCK','POP','TRAP','JAZZ','FOLK','METAL','PUNK', 'REGGAETON')),
  duracion	   NUMBER(3,2)    CONSTRAINT 	nn_duracion_cancion	  NOT NULL,
CONSTRAINT pk_cancion PRIMARY KEY(titulo,artista)
);

--Contrataciones de artistas
CREATE TABLE evento_artista(
cod_evento		VARCHAR(3) 		CONSTRAINT 	    fk_cod_evento_artista	REFERENCES evento,
dni_artista     VARCHAR(20)		CONSTRAINT 	    fk_dni_evento_artista   REFERENCES artista(dni),
CONSTRAINT pk_evento_artista    PRIMARY KEY(cod_evento,dni_artista)
);

--Venta de albumes
CREATE TABLE album_tienda(
	cif			    VARCHAR(9) 		CONSTRAINT 	fk_cif_album_tienda		REFERENCES tienda(cif),
	nombre_album    VARCHAR(30)		CONSTRAINT 	fk_nombre_album_tienda	REFERENCES album(nombre_album),
	precio			NUMBER(5,2)		CONSTRAINT	nn_precio_album_tienda  NOT NULL,
CONSTRAINT pk_album_tienda          PRIMARY KEY(cif,nombre_album)
);

--Visualizaciones de las tablas:
SELECT * FROM ciudad;
SELECT * FROM artista;
SELECT * FROM contrato;
SELECT * FROM noticias;
SELECT * FROM tienda;
SELECT * FROM escenario;
SELECT * FROM evento;
SELECT * FROM compositor;
SELECT * FROM album;
SELECT * FROM cancion;
SELECT * FROM evento_artista;
SELECT * FROM album_tienda;

--VISTAS

--1.Vista con con todos los compositores y sus respectivas canciones

CREATE OR REPLACE VIEW compositor_cancion(compositor,titulo) AS 
    SELECT c.compositor,c.titulo
    FROM cancion c, compositor m
    WHERE c.compositor=m.nombre_compositor
WITH CHECK OPTION;

--2.Crea una vista que contenga la duración de cada album

CREATE OR REPLACE VIEW duracion_album(nombre_album, duracion) AS 
    SELECT nombre_album, SUM(duracion)"Duracion"
    FROM cancion
    GROUP BY nombre_album
WITH CHECK OPTION;

--3.Vista de las canciones del album El Alma al Aire de Alejandro Sanz

CREATE OR REPLACE VIEW el_alma_al_aire(titulo,artista,nombre_album,compositor,genero,duracion) AS 
   SELECT c.titulo,a.nombre_artistico,d.nombre_album,m.nombre_compositor,c.genero,c.duracion
   FROM cancion c, artista a, album d,compositor m
   WHERE c.artista=a.nombre_artistico AND c.compositor=m.nombre_compositor AND c.nombre_album=d.nombre_album
   AND d.nombre_album='El Alma al Aire'
;

--4.Vista con las canciones del estilo JAZZ y POP

CREATE OR REPLACE VIEW jazz_pop(titulo,artista,nombre_album,compositor,genero,duracion) AS
    SELECT c.titulo,c.artista,c.nombre_album,c.compositor,c.genero,c.duracion
    FROM cancion c, artista a, album d,compositor m
    WHERE c.artista=a.nombre_artistico AND c.compositor=m.nombre_compositor AND c.nombre_album=d.nombre_album
    AND (c.genero='POP' OR c.genero='JAZZ')
WITH CHECK OPTION;   

--Visualizaciones de las vistas:
SELECT * FROM compositor_cancion;
SELECT * FROM duracion_album;
SELECT * FROM el_alma_al_aire;
SELECT * FROM jazz_pop;


--INSERCCION DE DATOS

/*Ciudad*/
INSERT INTO ciudad VALUES('0001MADES','Madrid','España');
INSERT INTO ciudad VALUES('0001MALES','Malaga','España');
INSERT INTO ciudad VALUES('0001NEWUS','New York','USA');
INSERT INTO ciudad VALUES('0001TENUS','Tennessee','USA');
INSERT INTO ciudad VALUES('0001LONCA','London','Canada');
INSERT INTO ciudad VALUES('0001BOCUS','Boca Raton','USA');
INSERT INTO ciudad VALUES('0001LONRU','Londres','Reino Unido');
INSERT INTO ciudad VALUES('0001BRACA','Brampton','Canada');
INSERT INTO ciudad VALUES('0001LISPO','Lisboa','Portugal');
INSERT INTO ciudad VALUES('0001JERES','Jerez','España');
INSERT INTO ciudad VALUES('0001SEVES','Sevilla','España');
INSERT INTO ciudad VALUES('0001BARES','Barcelona','España');
INSERT INTO ciudad VALUES('0001HUELV','Huelva', 'España');



/*Artista*/
INSERT INTO artista VALUES('32582244A','Alejandro Sanz','Alejandro','Sanchez Pizarro','Madrid',625330185,'18-12-1968');
INSERT INTO artista VALUES('54321672B','Pablo Lopez','Pablo Jose','Lopez Jimenez','Malaga',675627387,'11-03-1984');
INSERT INTO artista VALUES('62561452C','Nicki Minaj','Onika','Tanya Maraj','New York',644332156,'08-12-1982');
INSERT INTO artista VALUES('83453432D','Miley Cyrus','Miley','Ray Cyrus','Tennessee',677465450,'23-11-1992');
INSERT INTO artista VALUES('95435254E','Justin Bieber','Justin','Drew Bieber','London',679456300,'01-03-1994');
INSERT INTO artista VALUES('84564356F','Ariana Grande','Ariana','Grande Butera','Boca Raton',625678987,'26-06-1993');
INSERT INTO artista VALUES('24163450G','Amy Winehouse','Amy','Jade Winehouse','Londres',655222222,'14-09-1983');
INSERT INTO artista VALUES('12342737H','Alessia Cara','Alessia','Caracciolo','Brampton',644332156,'11-07-1996');
INSERT INTO artista VALUES('66564801J','Enrique Iglesias','Enrique Miguel','Iglesias Preysler','Madrid',627233080,'08-05-1975');
INSERT INTO artista VALUES('33399911A','Manuel Carrasco','Manuel','Carrasco Galloso','Huelva', 629288001,'15-01-1981');

/*Contrato*/
INSERT INTO contrato VALUES('3570B','32582244A','Alejandro Sanz','13-07-1989','');
INSERT INTO contrato VALUES('2500A','54321672B','Pablo Lopez','05-03-2008','');
INSERT INTO contrato VALUES('3900A','62561452C','Nicki Minaj','06-04-2007','');
INSERT INTO contrato VALUES('4100B','83453432D','Miley Cyrus','08-07-2005','');
INSERT INTO contrato VALUES('4050','95435254E','Justin Bieber','14-05-2007','');
INSERT INTO contrato VALUES('4035B','84564356F','Ariana Grande','17-08-2008','');
INSERT INTO contrato VALUES('2600A','24163450G','Amy Winehouse','01-09-2003','');
INSERT INTO contrato VALUES('2250B','12342737H','Alessia Cara','06-04-2014','');
INSERT INTO contrato VALUES('4250B','66564801J','Enrique Iglesias','22-07-1990','');

/*Noticias*/
INSERT INTO noticias VALUES('http://www.europapress.es/chance/cineymusica','Su vida y su carrera en un documental','Alejandro Sanz','09-03-2018');
INSERT INTO noticias VALUES('http://www.universalmusic.es/','También arrasa en España','Justin Bieber','26-11-2015');
INSERT INTO noticias VALUES('http://www.itunes.com/','Se coloca 1 en iTunes el día de su salida','Justin Bieber','13-11-2015');

/*Tienda*/
INSERT INTO tienda VALUES('28','FNAC','Calle de Preciados','Madrid',952034523);
INSERT INTO tienda VALUES('42','FNAC','Calle de Goya','Madrid',952034524);
INSERT INTO tienda VALUES('27','All Ages Records','Camden Town','Londres',207267030);
INSERT INTO tienda VALUES('50', 'FNAC', 'Calle Gonzalo Jimenez','Sevilla', 923023300);

/*Escenario*/
INSERT INTO escenario VALUES('Bernabeu','Madrid',60000);
INSERT INTO escenario VALUES('Vista Park','Lisboa',200000);
INSERT INTO escenario VALUES('Circuito Angel Nieto','Jerez',150000);
INSERT INTO escenario VALUES('Corte Ingles','Sevilla',5000);
INSERT INTO escenario VALUES('Palau Sant Jordi','Barcelona',17000);

/*Evento*/
INSERT INTO evento VALUES('01A','Concierto','Music Reborn','Bernabeu',75,'18-08-2018');
INSERT INTO evento VALUES('01B','Festival','Rock in Rio','Vista Park',120,'05-05-2018');
INSERT INTO evento VALUES('02B','Festival','Primavera Fest','Circuito Angel Nieto',50,'25-05-2018');
INSERT INTO evento VALUES('01C','Firma de discos','Firma Pablo Lopez','Corte Ingles',0,'1-10-2018');
INSERT INTO evento VALUES('03B','Concierto','Gira Alejandro','Palau Sant Jordi',100,'5-12-2018');
INSERT INTO evento VALUES('04B','Concierto','Rok In Rio','Bernabeu',200,'5-12-2019');

/*Compositor*/
INSERT INTO compositor VALUES('32089546R','Sia',654654654,'18-12-1975');
INSERT INTO compositor VALUES('32738526V','Beyonce',633016589,'4-09-1981');
INSERT INTO compositor VALUES('32089533J','Adele',632423454,'05-05-1988');
INSERT INTO compositor VALUES('12456234K','Prince',652759476,'07-06-1958');
INSERT INTO compositor VALUES('32582244A','Alejandro Sanz',625330185,'18-12-1968');

/*Album*/
INSERT INTO album VALUES('El Alma al Aire','Alejandro Sanz',10,'26-09-2000');
INSERT INTO album VALUES('Camino, Fuego y Libertad','Pablo Lopez',11,'15-12-2017');
INSERT INTO album VALUES('The Pinkprint','Nicki Minaj',11,'15-12-2014');
INSERT INTO album VALUES('Younger Now','Miley Cyrus',12,'29-09-2017');
INSERT INTO album VALUES('Purpose','Justin Bieber',13,'13-11-2015');
INSERT INTO album VALUES('Sweetener','Ariana Grande',10,'16-04-2018');
INSERT INTO album VALUES('Back to Black','Amy Winehouse',11,'27-10-2006');
INSERT INTO album VALUES('Know-It-All','Alessia Cara',10,'13-11-2015');
INSERT INTO album VALUES('Sex and Love','Enrique Iglesias',8,'18-04-2014');
INSERT INTO album VALUES('El Disco','Alejandro Sanz',10,'04-04-2019');

/*Cancion*/
INSERT INTO cancion VALUES('Cuando Nadie Me Ve','Alejandro Sanz','Alejandro Sanz','El Alma al Aire','POP',5.07);
INSERT INTO cancion VALUES('Hay un universo','Alejandro Sanz','Alejandro Sanz','El Alma al Aire','POP',5.22);
INSERT INTO cancion VALUES('Quisiera Ser','Alejandro Sanz','Alejandro Sanz','El Alma al Aire','POP',5.30);
INSERT INTO cancion VALUES('Para Que Me Quieras','Alejandro Sanz','Alejandro Sanz','El Alma al Aire','POP',4.29);
INSERT INTO cancion VALUES('Llega, llego soledad','Alejandro Sanz','Alejandro Sanz','El Alma al Aire','POP',4.37);
INSERT INTO cancion VALUES('El alma al aire','Alejandro Sanz','Alejandro Sanz','El Alma al Aire','POP',6.03);
INSERT INTO cancion VALUES('Me ire','Alejandro Sanz','Alejandro Sanz','El Alma al Aire','POP',5.40);
INSERT INTO cancion VALUES('Hicimos un trato','Alejandro Sanz','Alejandro Sanz','El Alma al Aire','POP',4.37);
INSERT INTO cancion VALUES('Tiene Que Ser Pecado','Alejandro Sanz','Alejandro Sanz','El Alma al Aire','POP',5.05);
INSERT INTO cancion VALUES('Silencio','Alejandro Sanz','Alejandro Sanz','El Alma al Aire','POP',8.22);
INSERT INTO cancion VALUES('El Camino','Pablo Lopez','Alejandro Sanz','Camino, Fuego y Libertad','POP',3.48);
INSERT INTO cancion VALUES('El Patio','Pablo Lopez','Alejandro Sanz','Camino, Fuego y Libertad','POP',4.43);
INSERT INTO cancion VALUES('Feeling Myself','Nicki Minaj','Beyonce','The Pinkprint','TRAP',3.57);
INSERT INTO cancion VALUES('I Lied','Nicki Minaj','Beyonce','The Pinkprint','TRAP',5.04);
INSERT INTO cancion VALUES('Malibu','Miley Cyrus','Adele','Younger Now','POP',3.51);
INSERT INTO cancion VALUES('Younger Now','Miley Cyrus','Sia','Younger Now','POP',4.08);
INSERT INTO cancion VALUES('Bad Mood','Miley Cyrus','Adele','Younger Now','FOLK',2.59);
INSERT INTO cancion VALUES('What Do You Mean?','Justin Bieber','Sia','Purpose','POP',3.25);
INSERT INTO cancion VALUES('Sorry','Justin Bieber','Sia','Purpose','POP',3.20);
INSERT INTO cancion VALUES('No Pressure','Justin Bieber','Sia','Purpose','TRAP',4.46);
INSERT INTO cancion VALUES('No Tears Left to Cry','Ariana Grande','Sia','Sweetener','POP',3.25);
INSERT INTO cancion VALUES('Rehab','Amy Winehouse','Prince','Back to Black','JAZZ',3.25);
INSERT INTO cancion VALUES('Wake Up Alone','Amy Winehouse','Prince','Back to Black','JAZZ',3.42);
INSERT INTO cancion VALUES('Seventeen','Alessia Cara','Sia','Know-It-All','POP',3.32);
INSERT INTO cancion VALUES('Here','Alessia Cara','Beyonce','Know-It-All','POP',3.19);
INSERT INTO cancion VALUES('Scars to Your Beautiful','Alessia Cara','Beyonce','Know-It-All','POP',3.50);
INSERT INTO cancion VALUES('Bailando','Enrique Iglesias','Alejandro Sanz','Sex and Love','POP',4.03);
INSERT INTO cancion VALUES('You and I','Enrique Iglesias','Alejandro Sanz','Sex and Love','POP',3.05);
INSERT INTO cancion VALUES('Me Cuesta Tanto Olvidarte','Enrique Iglesias','Alejandro Sanz','Sex and Love','POP',3.34);
INSERT INTO cancion VALUES('Noche y De Día','Enrique Iglesias','Alejandro Sanz','Sex and Love','POP',3.42);
INSERT INTO cancion VALUES('Loco','Enrique Iglesias','Alejandro Sanz','Sex and Love','POP',3.13);
INSERT INTO cancion VALUES('El gato','Pablo Lopez','','Camino, Fuego y Libertad','ROCK',4.00);
INSERT INTO cancion VALUES('El niño','Pablo Lopez','','Camino, Fuego y Libertad','ROCK',4.00);
INSERT INTO cancion VALUES('Dejame Ser', 'Manuel Carrasco','','','POP',3.59);

/*Evento_artista*/
INSERT INTO evento_artista VALUES('01A','32582244A');
INSERT INTO evento_artista VALUES('01A','54321672B');
INSERT INTO evento_artista VALUES('01A','24163450G');
INSERT INTO evento_artista VALUES('01B','83453432D');
INSERT INTO evento_artista VALUES('01B','95435254E');
INSERT INTO evento_artista VALUES('01B','84564356F');
INSERT INTO evento_artista VALUES('01B','12342737H');
INSERT INTO evento_artista VALUES('02B','54321672B');
INSERT INTO evento_artista VALUES('02B','84564356F');
INSERT INTO evento_artista VALUES('01C','54321672B');
INSERT INTO evento_artista VALUES('03B','32582244A');
INSERT INTO evento_artista VALUES('03B','54321672B');
INSERT INTO evento_artista VALUES('03B','24163450G');
INSERT INTO evento_artista VALUES('03B','83453432D');

/*Album_tienda*/
INSERT INTO album_tienda VALUES('28','El Alma al Aire',20);
INSERT INTO album_tienda VALUES('42','El Alma al Aire',20);
INSERT INTO album_tienda VALUES('28','Camino, Fuego y Libertad',30);
INSERT INTO album_tienda VALUES('42','Camino, Fuego y Libertad',30);
INSERT INTO album_tienda VALUES('27','The Pinkprint',40);
INSERT INTO album_tienda VALUES('27','Younger Now',35);
INSERT INTO album_tienda VALUES('28','Younger Now',35);
INSERT INTO album_tienda VALUES('42','Younger Now',35);
INSERT INTO album_tienda VALUES('27','Purpose',35);
INSERT INTO album_tienda VALUES('28','Purpose',25);
INSERT INTO album_tienda VALUES('42','Purpose',25);
INSERT INTO album_tienda VALUES('27','Sweetener',25);
INSERT INTO album_tienda VALUES('28','Sweetener',25);
INSERT INTO album_tienda VALUES('42','Sweetener',25);
INSERT INTO album_tienda VALUES('27','Back to Black',25);
INSERT INTO album_tienda VALUES('28','Back to Black',25);
INSERT INTO album_tienda VALUES('42','Back to Black',15);
INSERT INTO album_tienda VALUES('27','Know-It-All',20);
INSERT INTO album_tienda VALUES('28','Know-It-All',20);
INSERT INTO album_tienda VALUES('42','Know-It-All',15);
INSERT INTO album_tienda VALUES('27','Sex and Love',15);
INSERT INTO album_tienda VALUES('28','Sex and Love',15);
INSERT INTO album_tienda VALUES('42','Sex and Love',15);

--UPDATES

--UPDATE 1. Aumentar el aforo en 1000 en los conciertos del Palau Sant Jordi

UPDATE escenario SET aforo=aforo+1000
WHERE nombre_escenario='Palau Sant Jordi';

--UPDATE 2. Actualiza con un único comando update e independientemente de los datos que se tengan almacenados el precio del evento con escenario Vista Park, 
--de tal manera que se establezca como precio la media de los precios del resto de eventos.

UPDATE evento  
SET precio=(SELECT AVG(precio) FROM evento WHERE escenario<> 'Vista Park') 
WHERE escenario='Vista Park';

--UPDATE 3. Actualiza con un único comando UPDATE e independientemente de los datos que se tengan almacenados la fecha fin de los contratos 
--que no tienen fecha final asignado, de tal manera que para cada contrato se establezcan como nueva fecha final, la fecha inicial de cada contrato mas 723 dias.

UPDATE contrato c
SET c.fecha_fin = c.fecha_inicio+723
WHERE c.fecha_fin IS NULL AND c.dni_artista IN (SELECT a.dni
                                                FROM artista a
                                                WHERE c.dni_artista=a.dni AND a.ciudad_natal='Malaga');
                                                
--UPDATE 4. Disminuye en un 10% el aforo del escenario Palau Sant Jordi y hayan cantado al menos 3 artistas.

UPDATE escenario e
SET e.aforo=e.aforo-e.aforo*0.10
WHERE e.nombre_escenario ='Palau Sant Jordi' AND (SELECT COUNT(ev.escenario) 
                                                  FROM evento ev, evento_artista ea, artista a
                                                  WHERE e.nombre_escenario=ev.escenario AND ev.cod_evento=ea.cod_evento AND ea.dni_artista=a.dni 
                                                  AND e.nombre_escenario ='Palau Sant Jordi'                  
                                                  )>3;

--INSERCCIONES

--INSERT 1.Inserta para la tienda FNAC de Sevilla el album Sex and Love de la tienda 'All Ages Records' de Londres con un incremento del 15%.

INSERT INTO album_tienda(cif,nombre_album,precio)
SELECT '50',nombre_album, precio*1.15
       FROM album_tienda
       WHERE nombre_album='Sex and Love' AND cif='27';
       
--INSERT 2.Inserta para el concierto Music Reborn el artista invitado Manuel Carrasco.
INSERT INTO evento_artista (cod_evento, dni_artista)
SELECT e.cod_evento, a.dni
FROM evento e, artista a
WHERE e.nombre_evento='Music Reborn' AND a.nombre_artistico='Manuel Carrasco';

--INSERT 3.Inserta para la noticia con fecha '09-03-2018' de Alejandro Sanz con el mismo titular para otra web.

INSERT INTO noticias (web,titular,artista,fecha)
SELECT 'https://www.lavozdigital.es/cadiz/lvdi-alejandro-sanz',titular,artista, fecha
FROM   noticias
WHERE  fecha='09-03-2018' AND artista='Alejandro Sanz';

--BORRADO

--BORRADO 1.Borra las canciones cuya duración es superior a la media de minutos de todas las canciones de Alejandro Sanz y es cantada por Alejandro Sanz.

DELETE FROM cancion c
WHERE c.artista='Alejandro Sanz' AND c.duracion>(SELECT AVG((c.duracion))
                                               FROM cancion c
                                               WHERE c.artista='Alejandro Sanz'
                                               GROUP BY c.artista);


--BORRADO 2.Borra los álbumes de la tiendas cuyo precio es superior a 30€ y su artista es Justin Bieber.

DELETE FROM album_tienda at
WHERE   precio > 30 AND at.nombre_album = (SELECT al.nombre_album
                                           FROM album al
                                           WHERE al.nombre_album=at.nombre_album AND al.nombre_artista='Justin Bieber');

--BORRADO 3.Borra las canciones que se llamen 'El gato' de los artistas cuya ciudad natal sea 'Malaga'

/*2 maneras de resolverlo:*/

/*Sincronizado*/
DELETE FROM cancion c
WHERE  c.titulo='El gato' AND c.artista IN (SELECT a.nombre_artistico
                                           FROM artista a
                                           WHERE c.artista=a.nombre_artistico AND a.ciudad_natal='Malaga');

/*No sincronizado*/
DELETE FROM cancion c
WHERE  c.titulo='El gato' AND c.artista IN (SELECT a.nombre_artistico
                                           FROM artista a
                                           WHERE a.ciudad_natal='Malaga');

--CONSULTAS:

--1.¿Cuál es el artista con el album con más duración?

SELECT a.nombre_artista, a.nombre_album, SUM (c.duracion)"Duracion"
FROM album a, cancion c
WHERE a.nombre_album = c.nombre_album
GROUP BY  a.nombre_artista, a.nombre_album
HAVING SUM(c.duracion) = ( SELECT MAX(SUM (c.duracion))
                           FROM album a, cancion c
                           WHERE a.nombre_album = c.nombre_album
                           GROUP BY a.nombre_artista, a.nombre_album);

--2.Cantante que lleva más tiempo en la Discografica Universal.
SELECT nombre_artistico,fecha_inicio
FROM artista ar, contrato co
WHERE ar.dni = co.dni_artista and co.fecha_inicio = (SELECT MIN(fecha_inicio) 
                                                     FROM  contrato);
     
   
--3.El tiempo que lleva Amy Winehouse en la discografica.
SELECT nombre_artistico,TO_DATE (SYSDATE, 'DD/MM/YYYY') - TO_DATE(co.fecha_inicio, 'DD/MM/YYYY')"Dias en Discografica"
FROM artista ar, contrato co
WHERE ar.dni = co.dni_artista and ar.nombre_artistico ='Amy Winehouse';


--4.Muestra todas las canciones (excepto las de género POP y ROCK), junto con el nombre artístico y la ciudad natal del artista
--   ordenadas por titulo ascendentemente.

SELECT c.titulo,a.nombre_artistico,c.genero, a.ciudad_natal
FROM artista a,cancion c
WHERE c.titulo IN (SELECT c.titulo
        FROM cancion c
        WHERE c.genero<>'POP' AND c.genero <>'ROCK')
ORDER BY 1;                                           

--5.Muestra todos los artistas que actúan en Music Reborn, ordenaos descendentemente.

SELECT a.nombre_artistico
FROM artista a, evento e, evento_artista c
WHERE e.nombre_evento='Music Reborn' AND c.cod_evento=e.cod_evento AND c.dni_artista=a.dni
ORDER BY 1 DESC;

--6.Qué parejas de artistas hacen canciones del mismo género.

SELECT a1.nombre_artistico, a2.nombre_artistico
FROM artista a1, artista a2
WHERE a1.nombre_artistico<a2.nombre_artistico AND   NOT EXISTS( 
                                                    (SELECT c.genero
                                                    FROM cancion c
                                                    WHERE a1.nombre_artistico=c.artista)
                                                    MINUS
                                                    (SELECT c.genero
                                                    FROM cancion c
                                                    WHERE a2.nombre_artistico=c.artista));  

--7.Lista de canciones POP y sus respectivos Artistas y Albums, ordenador por titulo y artista descendetemente.

SELECT c.titulo,c.artista,c.nombre_album,c.genero
FROM artista a,cancion c, album d
WHERE a.nombre_artistico=c.artista AND c.nombre_album=d.nombre_album
AND c.genero='POP'
ORDER BY 1 DESC,2 DESC;


--8.Disco más caro, tienda, artista y lugar donde se vende el mismo.

SELECT at.nombre_album,t.cif,a.nombre_artista,at.precio
FROM album_tienda at,tienda t, album a
WHERE at.cif=t.cif AND at.nombre_album=a.nombre_album AND
at.precio=(SELECT MAX(precio)
            FROM album_tienda);
            
--9.Artista que gana más haciendo eventos segun el precio de cada evento.

SELECT a.nombre_artistico, SUM (e.precio)"Suma entradas de los eventos"
FROM artista a, evento e, evento_artista ea
WHERE ea.dni_artista=a.dni AND e.cod_evento = ea.cod_evento
GROUP BY a.nombre_artistico
HAVING SUM (e.precio) = (SELECT MAX (SUM (e.precio))
                         FROM artista a, evento e, evento_artista ea
                         WHERE ea.dni_artista=a.dni AND e.cod_evento = ea.cod_evento
                         GROUP BY a.nombre_artistico);


--10.Consulta la canción con la duración más corta que no sea de Miley Cyrus.

SELECT c.titulo, c.artista, c.compositor, c.nombre_album, c.genero, c.duracion
FROM cancion c
WHERE c.artista <> 'Miley Cyrus' AND c.duracion = (SELECT MIN(duracion)
                                                   FROM cancion
                                                   WHERE artista <> 'Miley Cyrus');
                                                   
--11.Consultar los artistas que tienen más de un album.

SELECT a.nombre_artistico 
FROM artista a,album d
WHERE a.nombre_artistico=d.nombre_artista
GROUP BY a.nombre_artistico
HAVING COUNT(d.nombre_album) > 1;

--12.Informacion de los artistas de la compañia y la fecha cuando se iniciaron entre el 1 de Julio de 2005 hasta hoy.
--   El nombre y los apellidos del artista deben formar una cadena "Nombre y Apellidos" separados por un espacio.

SELECT a.dni,a.nombre_artistico,a.nombre || ' ' || a.apellidos"Nombre y Apellidos",a.ciudad_natal,a.telefono,a.f_nacimiento,c.fecha_inicio
FROM artista a, contrato c
WHERE a.dni= c.dni_artista AND c.fecha_inicio BETWEEN '01-07-2005' AND SYSDATE;


--13.Mostrar los artistas que realizan al menos un concierto y hayan nacido en Madrid.

SELECT a.nombre_artistico, COUNT(ea.dni_artista)"Conciertos que realizan"
FROM artista a, evento_artista ea 
WHERE a.ciudad_natal='Madrid' AND a.dni=ea.dni_artista
GROUP BY a.nombre_artistico
HAVING COUNT(ea.dni_artista) > 1;

--14.Mostrar aquellos artistas que posean canciones de todos los generos.

SELECT a.nombre_artistico
FROM artista a
WHERE NOT EXISTS ((SELECT genero 
                   FROM cancion)
                 MINUS
                (SELECT c.genero
                 FROM cancion c
                 WHERE a.nombre_artistico = c.artista));

--15.Consultar el album con mayor duracion de la vista duracion_album.

SELECT nombre_album, duracion
FROM duracion_album
WHERE duracion = (SELECT MAX(duracion)
                 FROM duracion_album);

--16.Obtener la tienda en la cual se obtiene el disco "Back to Black" más barato que en cualquier otra tienda.

SELECT t.cif,t.nombre_tienda,t.direccion,t.ciudad, t.telefono
FROM tienda t, album_tienda at
WHERE at.cif=t.cif AND at.nombre_album = 'Back to Black' AND 
at.precio = (SELECT MIN(at.precio)
        FROM tienda t, album_tienda at
        WHERE at.cif=t.cif AND at.nombre_album = 'Back to Black');

--17.Selecciona la tienda que mas albumes tiene.

SELECT at.cif,t.nombre_tienda, COUNT(at.nombre_album)"Numero de albumes"
FROM album_tienda at, tienda t
WHERE at.cif = t.cif 
GROUP BY at.cif, t.nombre_tienda
HAVING COUNT (at.nombre_album) =(SELECT MAX(COUNT(ate.nombre_album))
                                FROM album_tienda ate
                                GROUP BY ate.cif) ;



--18.Muestra los artistas que son cantante y compositor de sus canciones.

SELECT DISTINCT c.artista
FROM artista a, compositor co, cancion c
WHERE a.nombre_artistico=c.artista AND co.nombre_compositor=c.compositor AND a.nombre_artistico=co.nombre_compositor;

--19.Parejas de artistas que han tocado en los mismos eventos.

SELECT a1.nombre_artistico, a2.nombre_artistico
FROM artista a1, artista a2
WHERE a1.dni > a2.dni AND NOT EXISTS 
                                    ((SELECT e.nombre_evento
                                      FROM evento e, evento_artista ea
                                      WHERE e.cod_evento = ea.cod_evento AND a1.dni=ea.dni_artista)
                                    MINUS
                                    (SELECT e.nombre_evento
                                      FROM evento e, evento_artista ea
                                      WHERE e.cod_evento = ea.cod_evento AND a2.dni=ea.dni_artista));

--20.Muestra el álbum con la mayor cantidad de canciones.

SELECT a.nombre_album, COUNT(c.titulo)"Numero de canciones"
FROM album a, cancion c
WHERE a.nombre_album = c.nombre_album
GROUP BY a.nombre_album
HAVING COUNT (c.titulo) =(SELECT MAX(COUNT(c.titulo))
                        FROM album a, cancion c
                         WHERE a.nombre_album = c.nombre_album
                         GROUP BY a.nombre_album) ;

--21.Muestra todos los datos de los artistas españoles y que empiezen por la letra P.

SELECT a.dni,a.nombre_artistico,a.nombre || ' ' || a.apellidos"Nombre y Apellidos",a.ciudad_natal,a.telefono,a.f_nacimiento
FROM artista a, ciudad c
WHERE a.ciudad_natal = c.nombre_ciudad AND c.pais = 'España' AND UPPER(SUBSTR(a.nombre_artistico,1,1)) = 'P';


--22.Selecciona la cantidad de eventos que se ha realizado en los escenario que empiezan por la letra C.

SELECT es.nombre_escenario, COUNT (ev.nombre_evento)"Numero de Eventos"
FROM escenario es, evento ev
WHERE es.nombre_escenario = ev.escenario AND es.nombre_escenario LIKE 'C%'
GROUP BY es.nombre_escenario;

--23.Selecciona la duracion de cada album con sus artistas y ciudades natales ordenado por nombre artista y nombre album.

SELECT a.nombre_artista, a.nombre_album, ar.ciudad_natal, SUM (c.duracion)"Duracion Album"
FROM album a, cancion c, artista ar
WHERE a.nombre_album = c.nombre_album AND ar.nombre_artistico = a.nombre_artista
GROUP BY  a.nombre_artista, a.nombre_album, ar.ciudad_natal
ORDER BY 1,2;


--24.Muestra las cancion que sean inferior a la media de las canciones de la vista de EL_ALMA_AL_AIRE y empieza por la letra L.

SELECT titulo,duracion
FROM el_alma_al_aire
WHERE duracion<(SELECT AVG(duracion)
               FROM el_alma_al_aire) AND UPPER(SUBSTR(titulo,1,1)) = 'L'; 
               
--25.Muestra las canciones que superen la media de las canciones de la vista de EL_ALMA_AL_AIRE y contengan la cadena "Ser".               

SELECT titulo,duracion
FROM el_alma_al_aire
WHERE duracion>(SELECT AVG(duracion)
               FROM el_alma_al_aire) AND titulo LIKE '%Ser%';  

 
--26.Consultar la cancion con la duracion mas corta de la vista jazz_pop.

SELECT titulo,duracion,artista
FROM jazz_pop
WHERE duracion=(SELECT MIN(duracion)
               FROM jazz_pop);       
               

