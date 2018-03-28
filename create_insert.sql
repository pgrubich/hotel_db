if OBJECT_ID('Kary','U') is not null
drop table Kary

if OBJECT_ID('Ulgi','U') is not null
drop table Ulgi

if OBJECT_ID('SzczegolyUslug','U') is not null
drop table SzczegolyUslug

if OBJECT_ID('Uslugi','U') is not null
drop table Uslugi

if OBJECT_ID('Rezerwacje','U') is not null
drop table Rezerwacje

if OBJECT_ID('Goscie','U') is not null
drop table Goscie

if OBJECT_ID('Pokoje','U') is not null
drop table Pokoje

create table Pokoje
( nrPokoju int primary key,
  standard varchar(15) check (standard in ('apartament','zwykly')),
  liczbaOsob int check (liczbaOsob between 1 and 4),
  cena money );

create table Kary
( idKary int primary key,
  nrPokoju int references Pokoje(nrPokoju),
  oplata money,
  opisZniszczen nvarchar(200),
  data date );

create table Goscie
( pesel char(11) primary key,
  rezerwujacy char(11) references Goscie(pesel),
  nazwisko nvarchar(20) not null,
  imie nvarchar(15) not null );

create table Rezerwacje
( idRezerwacji int primary key,
  nrPokoju int references Pokoje(nrPokoju),
  rezerwujacy char(11) references Goscie(pesel),
  dataPoczatkowa date,
  dataKoncowa date,
  liczbaDni int,
  kwota money default 0,
  constraint ck_rez_data check (dataKoncowa > dataPoczatkowa) );

create table Ulgi
( idUlgi int primary key,
  idRezerwacji int references Rezerwacje(idRezerwacji),
  nazwaUlgi nvarchar(50),
  wysokoscUlgi decimal(2,2) check (wysokoscUlgi between 0.05 and 1 ));

create table Uslugi
( idUslugi int primary key,
  cena money,
  opisUslugi nvarchar(100) );

create table SzczegolyUslug
( pesel char(11) references Goscie(pesel),
  idUslugi int references Uslugi(idUslugi),
  status varchar(20) check (status in ('oplacona', 'nieoplacona')),
  data date );


insert into Pokoje values
 ('1','zwykly',1,150),
 ('2','zwykly',2,240),
 ('3','apartament',1,250),
 ('4','apartament',2,440),
 ('5','zwykly',1,150),
 ('6','zwykly',1,150),
 ('7','zwykly',1,150),
 ('8','zwykly',1,150),
 ('9','zwykly',2,240),
 ('10','zwykly',2,250),
 ('11','zwykly',2,220),
 ('12','zwykly',2,240),
 ('13','zwykly',2,240),
 ('14','zwykly',3,360),
 ('15','zwykly',3,380),
 ('16','zwykly',3,360),
 ('17','zwykly',3,390),
 ('18','zwykly',3,400),
 ('19','zwykly',4,480),
 ('20','zwykly',4,500),
 ('21','apartament',1,250),
 ('22','apartament',2,500),
 ('23','apartament',2,500),
 ('24','apartament',3,750),
 ('25','apartament',4,850)


insert into Goscie values
 ('77120907939','77120907939','Kowalski','Jan'),
 ('56021009670','56021009670','Nowak','Adam'),
 ('48042916921','48042916921','Brzęczyszczykiewicz','Marek'),
 ('48091806897','48042916921','Pieczyński','Aleksander'),
 ('78031518830','78031518830','Drzazga','Anna'),
 ('80011005076','78031518830','Zientek','Maria'),
 ('84072719136','84072719136','Radecki','Grzegorz'),
 ('66101301192','84072719136','Janiczek','Jerzy'),
 ('58072511838','58072511838','Galiński','Tadeusz'),
 ('80060111351','58072511838','Marszałkowski','Adamr'),
 ('08230203354','58072511838','Mińkowski','Łukasz'),
 ('71090719659','71090719659','Paszkowski','Dariusz'),
 ('91021310843','71090719659','Gacek','Robert'),
 ('49081504838','49081504838','Gaca','Mateusz'),
 ('72122018469','72122018469','Gniazdowski','Rafał'),
 ('85072507769','72122018469','Sibiński','Władysław'),
 ('98110917585','72122018469','Szumski','Roman'),
 ('75031601355','72122018469','Wolszczak','Przemysław'),
 ('09212211402','09212211402','Kobylecki','Edward'),
 ('00321803979','09212211402','Paś','Sebastian'),
 ('81092909251','81092909251','Sobieraj','Czesław'),
 ('87100305833','81092909251','Joński','Leszek'),
 ('71100403349','71100403349','Dziwisz','Daniel'),
 ('82112617291','82112617291','Troszczyński','Waldemar'),
 ('60021205394','82112617291','Cyganek','Henryk'),
 ('87032906476','82112617291','Klimkiewicz','Mariusz'),
 ('70100514138','70100514138','Nosal','Kazimierz'),
 ('51112217213','70100514138','Próchniak','Wojciech'),
 ('01230205807','01230205807','Kwidziński','Robert'),
 ('64113019425','01230205807','Dudek','Marta'),
 ('68100500763','01230205807','Knop','Dorota'),
 ('97102502572','97102502572','Ignatowski','Aleksander'),
 ('98100118541','98100118541','Palka','Halina'),
 ('90110527594','98100118541','Pszczółkowski','Jan')


insert into Rezerwacje values
 ('1','1','77120907939','07-26-2017','07-29-2017',3,0),
 ('2','3','56021009670','10-01-2017','10-10-2017',9,0),
 ('3','2','48042916921','10-01-2017','10-07-2017',6,0),
 ('4','4','78031518830','02-01-2016','04-01-2016',60,0),
 ('5','9','84072719136','02-17-2016','02-19-2016',2,0),
 ('6','14','58072511838','02-01-2016','02-10-2016',9,0),
 ('7','22','71090719659','03-03-2016','03-08-2016',5,0),
 ('8','21','49081504838','03-27-2016','03-30-2016',3,0),
 ('9','25','72122018469','04-16-2016','04-17-2016',1,0),
 ('10','10','09212211402','05-21-2016','05-30-2016',9,0),
 ('11','11','81092909251','05-01-2016','05-06-2016',5,0),
 ('12','7','71100403349','06-07-2016','06-10-2016',3,0),
 ('13','15','82112617291','07-10-2016','07-16-2016',6,0),
 ('14','12','70100514138','08-04-2016','08-09-2016',5,0),
 ('15','16','01230205807','09-01-2016','09-04-2016',3,0),
 ('16','1','97102502572','10-01-2016','10-10-2016',9,0),
 ('17','4','98100118541','12-01-2016','12-03-2016',2,0)

insert into Ulgi values
 ('1','1','ulga okresowa',0.05),
 ('2','3','znizka rodzinna',0.1),
 ('3','5','znizka rodzinna',0.1),
 ('4','7','wczesna rezerwacja',0.05),
 ('5','9','last minute',0.15),
 ('6','11','ulga okresowa',0.05)

insert into Uslugi values
 ('1',100,'masaż'),
 ('2',20,'śniadanie'),
 ('3',15,'dodatkowe sprzątanie'),
 ('4',10,'pranie'),
 ('5',25,'wynajem roweru'),
 ('6',100,'opiekunka dla dziecka'),
 ('7',5,'sauna'),
 ('8',60,'fryzjer')


insert into SzczegolyUslug values
 ('77120907939','1','nieoplacona','07-26-2017'),
 ('56021009670','1','nieoplacona','07-26-2017'),
 ('48042916921','1','nieoplacona','10-01-2017'),
 ('80011005076','1','oplacona','02-02-2016'),
 ('84072719136','1','oplacona','02-17-2016'),
 ('66101301192','2','oplacona','02-17-2016'),
 ('58072511838','2','oplacona','02-09-2016'),
 ('80060111351','2','oplacona','02-09-2016'),
 ('08230203354','2','oplacona','02-09-2016'),
 ('71090719659','2','oplacona','03-05-2016'),
 ('49081504838','2','oplacona','03-30-2016'),
 ('85072507769','3','oplacona','04-16-2016'),
 ('98110917585','4','oplacona','04-16-2016'),
 ('75031601355','4','oplacona','04-16-2016'),
 ('09212211402','5','oplacona','05-21-2016'),
 ('09212211402','6','oplacona','05-22-2016'),
 ('81092909251','7','oplacona','05-01-2016'),
 ('81092909251','7','oplacona','05-01-2016'),
 ('81092909251','7','oplacona','05-01-2016'),
 ('71100403349','7','oplacona','06-07-2016'),
 ('60021205394','7','oplacona','07-10-2016'),
 ('60021205394','8','oplacona','07-10-2016'),
 ('70100514138','8','oplacona','08-04-2016'),
 ('97102502572','3','oplacona','10-01-2016'),
 ('98100118541','1','oplacona','12-03-2016')


 insert into Kary values
 ('1','1',100,'zbite lustro','07-26-2017'),
 ('2','2',100,'wyrwana klamka','10-01-2017'),
 ('3','3',200,'dziura w dywanie','10-10-2017'),
 ('4','9',500,'uszkodzony zlew','02-19-2016')

 create table Pokoje
( nrPokoju int primary key,
  standard varchar(15) check (standard in ('apartament','zwykly')),
  liczbaOsob int check (liczbaOsob between 1 and 4),
  cena money );

create table Kary
( idKary int primary key,
  nrPokoju int references Pokoje(nrPokoju),
  oplata money,
  opisZniszczen nvarchar(200),
  data date );

create table Goscie
( pesel char(11) primary key,
  rezerwujacy char(11) references Goscie(pesel),
  nazwisko nvarchar(20) not null,
  imie nvarchar(15) not null );

create table Rezerwacje
( idRezerwacji int primary key,
  nrPokoju int references Pokoje(nrPokoju),
  rezerwujacy char(11) references Goscie(pesel),
  dataPoczatkowa date,
  dataKoncowa date,
  liczbaDni int,
  kwota money default 0,
  constraint ck_rez_data check (dataKoncowa > dataPoczatkowa) );

create table Ulgi
( idUlgi int primary key,
  idRezerwacji int references Rezerwacje(idRezerwacji),
  nazwaUlgi nvarchar(50),
  wysokoscUlgi decimal(2,2) check (wysokoscUlgi between 0.05 and 1 ));

create table Uslugi
( idUslugi int primary key,
  cena money,
  opisUslugi nvarchar(100) );

create table SzczegolyUslug
( pesel char(11) references Goscie(pesel),
  idUslugi int references Uslugi(idUslugi),
  status varchar(20) check (status in ('oplacona', 'nieoplacona')),
  data date );
