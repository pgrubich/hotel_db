alter procedure dodajKare
	@idKary int,
	@nrPokoju int,
	@oplata money,
	@opisZniszczen nvarchar(200),
	@data date
as
	if @idKary not in (select idKary from Kary)
	insert into Kary values
	(@idKary,@nrPokoju,@oplata,@opisZniszczen,@data)


-------------------------------------------------------------------------------------------------
alter procedure dodajUlge
	@idUlgi int,
	@idRezerwacji int,
	@nazwaUlgi nvarchar(50),
	@wysokoscUlgi decimal(2,2)
as
	if @idUlgi not in (select idUlgi from Ulgi)
	insert into Ulgi values
	(@idUlgi,@idRezerwacji,@nazwaUlgi,@wysokoscUlgi)

--------------------------------------------------------------------------------------------------
create procedure dodajGoscia
	@pesel char(11),
	@rezerwujacy char(11),
	@nazwisko nvarchar(20),
	@imie nvarchar(15)
as
	insert into Goscie values
	(@pesel,@rezerwujacy,@nazwisko,@imie)

---------------------------------------------------------------------------------------------------
create procedure dodaj_rezerwacje
	@idR int,
	@nrP int,
	@rez char(11),
	@dataP date,
	@dataK date

as
	if @idR not in (select idRezerwacji from Rezerwacje)
	declare @lDni int
	set @ldni = datediff(dd,@dataP,@dataK)
	insert into Rezerwacje values
	(@idR,@nrP,@rez,@dataP,@dataK,@lDni,default)

----------------------------------------------------------------------------------------------------

alter procedure usun_rezerwacje
	@idR int
as
	if @idR in (select idRezerwacji from Ulgi)
		delete from Ulgi
		where idRezerwacji = @idR
		delete from Rezerwacje
		where idRezerwacji = @idR

----------------------------------------------------------------------------------------------------

alter trigger t_anulowanieRezerwacji
on Rezerwacje
for delete
as
	if ( (select dateadd(dd,2,(select convert(date,getdate())))) > (select dataPoczatkowa from deleted) )
	begin
	print 'nie mozna anulowac rezerwacji mniej niz 2 dni przed planowanym poczatkiem'
	rollback
	end

go

---------------------------------------------------------------------------------------------------------
alter procedure dodaj_kwoteR
	@idR int
as
	 if @idR in (select idRezerwacji from Rezerwacje)
		 update Rezerwacje
		 set kwota = dbo.obliczKwote(@idR)
		 where idRezerwacji = @idR


-----------------------------------------------------------------------------------------------------

alter procedure zmien_date
	@idR int,
	@dataP date,
	@dataK date
as
	if @idR in (select idRezerwacji from Rezerwacje)
		update Rezerwacje
		set dataKoncowa = @dataK, dataPoczatkowa = @dataP, liczbaDni = datediff(dd,@dataP,@dataK)
		where idRezerwacji = @idR

-------------------------------------------------------------------------------------------------------

create function policz_oplateUslugi(@pesel varchar(11),@idRezerwacji int)
	returns money
as
begin

	return (select sum(kwoty)  from (select u.cena as 'kwoty' from SzczegolyUslug s join Uslugi u
		on s.idUslugi = u.idUslugi
		join Goscie g
		on s.pesel = g.pesel
		join Rezerwacje r
		on g.rezerwujacy = r.rezerwujacy
		where  g.pesel = @pesel and r.idRezerwacji = @idRezerwacji) tmp)

end

select  dbo.policz_oplateUslugi('72011498746','1')
--------------------------------------------------------------------------------------------------------

create function wolnePokoje (@data date)
	returns @pokoje table (nrPokoju int)
as
begin
	insert into @pokoje
		select p.nrPokoju from Pokoje p where p.nrPokoju not in
			(select p.nrPokoju from Pokoje p join Rezerwacje r on p.nrPokoju = r.nrPokoju
				 where @data between r.dataPoczatkowa and r.dataKoncowa)
return
end

------------------------------------------------------------------------------------------------

create function wyswietlRezerwacje(@data date)
	returns @rezerwacje table
	 (idRezerwacji int, nrPokoju int, nazwisko nvarchar(20), imie nvarchar(15), dataPoczatkowa date, dataKoncowa date)
as
begin
	insert into @rezerwacje
		select r.idRezerwacji, r.nrPokoju, g.nazwisko, g.imie, r.dataPoczatkowa, r.dataKoncowa
			from Rezerwacje r join Goscie g on r.rezerwujacy = g.pesel
				where @data between r.dataPoczatkowa and r.dataKoncowa
return
end

-----------------------------------------------------------------------------------------------------
create function obliczKwote(@idRezerwacji int)
	returns money
as
begin
	declare @suma money
	declare @uslugi money
	declare @kary money
	declare @nocleg money
	declare @ulga int
	declare @lDni int


	set @uslugi = (select sum(kwoty) from
					(select u.cena as 'kwoty'
					from SzczegolyUslug s join Uslugi u
					on s.idUslugi = u.idUslugi join Goscie g
					on s.pesel = g.pesel join Rezerwacje r
					on g.rezerwujacy = r.rezerwujacy
					where  r.idRezerwacji = @idRezerwacji and g.pesel in
						(select g.pesel
						from Goscie g join Rezerwacje r
						on g.rezerwujacy = r.rezerwujacy
						where r.idRezerwacji = @idRezerwacji)) tmp)

	set @uslugi = isnull(@uslugi,0)

	set @kary = (select k.oplata
				from Kary k join Pokoje p
				on k.nrPokoju = p.nrPokoju join Rezerwacje r
				on p.nrPokoju = r.nrPokoju
				where r.idRezerwacji = @idRezerwacji
				and k.data between r.dataPoczatkowa and r.dataKoncowa)

	set @kary = isnull(@kary,0)

	set @nocleg = (select p.cena
				from Pokoje p join Rezerwacje r
				on p.nrPokoju = r.nrPokoju
				where r.idRezerwacji = @idRezerwacji)

	set @lDni = (select r.liczbaDni
				from Rezerwacje r
				where r.idRezerwacji = @idRezerwacji)

	set @nocleg = @nocleg*@lDni

	set @ulga = (select sum(suma) from
					(select u.wysokoscUlgi as 'suma'
					from Ulgi u join Rezerwacje r
					on u.idRezerwacji = r.idRezerwacji
					where r.idRezerwacji = @idRezerwacji)tmp)

	set @ulga = isnull(@ulga,0)
	set @nocleg = @nocleg - (@nocleg*@ulga)

	set @suma = @uslugi + @kary + @nocleg

return @suma
end
-----------------------------------------------------------------------------------------------
alter view popularneUslugi(opisUslugi,suma)
as
select top(3) u.opisUslugi, count(*) as 'suma'
from SzczegolyUslug s join Uslugi u
on s.idUslugi = u.idUslugi
group by u.opisUslugi
order by suma desc

select * from popularneUslugi

------------------------------------------------------------------------------------------------
create view przychodyMiesiecznie(miesiac,przychod)
as
select month(dataKoncowa) as 'miesiac', sum(kwota) as 'kwota'
from Rezerwacje
group by month(dataKoncowa)

select * from przychodyMiesiecznie

--------------------------------------------------------------------------------------------------
alter view rezerwacjeMiesiecznie(miesiac,rezerwacje)
as
select top(5) month(dataKoncowa) as 'miesiac', count(*) as 'liczba rezerwacji'
from Rezerwacje
group by month(dataKoncowa)
order by [liczba rezerwacji] desc

select * from rezerwacjeMiesiecznie
-------------------------------------------------------------------------------------------------
alter function wolnePokoje(@data date)
	returns @pokoje table (nrPokoju int)
as
begin
	insert into @pokoje
		select p.nrPokoju from Pokoje p where p.nrPokoju not in
			(select p.nrPokoju from Pokoje p join Rezerwacje r on p.nrPokoju = r.nrPokoju
				 where @data between r.dataPoczatkowa and r.dataKoncowa and @data <> r.dataKoncowa)
return
end


select * from dbo.wolnePokoje('2016-07-29')
select * from Rezerwacje


---------------------------------------------------------------------------------------------------------
create trigger t_zmianaDaty
on Rezerwacje
for update
as
	declare @dataP date
	declare @dataK date
	declare @id int
	declare @nrPokoju int

	set @dataP = (select i.dataPoczatkowa
					from inserted i )

	set @dataK = (select i.dataKoncowa
					from inserted i )

	set @id = (select i.idRezerwacji
					from inserted i )

	set @nrPokoju = (select i.nrPokoju
						from inserted i )

	if (exists (select *
				from Rezerwacje r join Pokoje p
				on p.nrPokoju = r.nrPokoju
				where @dataP between r.dataPoczatkowa and r.dataKoncowa
				and r.idRezerwacji <> @id
				and r.nrPokoju = @nrPokoju )

	or exists (select *
				from deleted d join Pokoje p
				on p.nrPokoju = d.nrPokoju join Rezerwacje r
				on r.nrPokoju = p.nrPokoju
				where @dataK between r.dataPoczatkowa and r.dataKoncowa
				and r.idRezerwacji <> @id) )

	begin
	print 'pokoj zajety, nie mozna zmienic daty rezerwacji'
	rollback
	end
go

-----------------------------------------------------------------------------------------------------
create view statystkiPokoje(nrPokoju,liczbaDni)
as
(select p.nrPokoju, sum(r.liczbaDni)
from Pokoje p left join Rezerwacje r
on p.nrPokoju = r.nrPokoju
group by p.nrPokoju)


------------------------------------------------------------------------------------------------------
select *from Rezerwacje

--trigger anulowanie rezerwacji
exec dbo.usun_rezerwacje '1'

--obliczenie zaplaty
exec dbo.dodaj_kwoteR '17'

--widok uslugi
select * from popularneUslugi

--widok miesieczne przychody
select * from przychodyMiesiecznie

--widok miesiace z najwieksza liczba rezerwacji
select * from rezerwacjeMiesiecznie

--widok statystyki pokoje
select *from statystkiPokoje

--funkcja tablicowa
select * from wolnePokoje('2017-10-02')

--funkcja tablicowa
select * from wyswietlRezerwacje('2016-05-03')

--trigger zmiana daty
exec dbo.zmien_date '17','2016-11-31','2016-12-02'
