SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCARptCartaCERSucursalPtmos
create procedure [dbo].[pCsCARptCartaCERSucursalPtmos] @fecha smalldatetime,@codoficina varchar(4)
as
--declare @fecha smalldatetime
--set @fecha='20160430'

create table #PtmoCER(
	item int,
	Descripcion varchar(15),
	Prestamos2014 varchar(1000) default(''),
	Prestamos2015 varchar(1000) default(''),
	Prestamos2016 varchar(1000) default('')
)

insert into #PtmoCER (item,descripcion) values(1,'CER@4')
insert into #PtmoCER (item,descripcion) values(2,'CER@4 y CER@60')

declare @valores varchar(1000)
set @valores=''
SELECT @valores= c.codprestamo+ ', '+@valores 
FROM tCsCartera c with(nolock)
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso>=4 and c.nrodiasatraso<=59 
and c.codoficina=@codoficina
and c.codoficina<100
and c.fechadesembolso>='20140101' and c.fechadesembolso<='20141231'
--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2014=substring(@valores,1,len(@valores)-1)
	where item=1
end

set @valores=''
SELECT @valores= c.codprestamo+ ', '+@valores 
FROM tCsCartera c with(nolock)
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso>=4 and c.nrodiasatraso<=59 
and c.codoficina=@codoficina
and c.codoficina<100
and c.fechadesembolso>='20150101' and c.fechadesembolso<='20151231'
--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2015=substring(@valores,1,len(@valores)-1)
	where item=1
end

set @valores=''
SELECT @valores= c.codprestamo+ ', '+@valores 
FROM tCsCartera c with(nolock)
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso>=4 and c.nrodiasatraso<=59 
and c.codoficina=@codoficina
and c.codoficina<100
and c.fechadesembolso>='20160101' and c.fechadesembolso<='20161231'
--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2016=substring(@valores,1,len(@valores)-1)
	where item=1
end

/*CER60*/
set @valores=''
SELECT @valores= c.codprestamo+ ', '+@valores 
FROM tCsCartera c with(nolock)
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso>=60
and c.codoficina=@codoficina
and c.codoficina<100
and c.fechadesembolso>='20140101' and c.fechadesembolso<='20141231'
--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2014=substring(@valores,1,len(@valores)-1)
	where item=2
end

set @valores=''
SELECT @valores= c.codprestamo+ ', '+@valores 
FROM tCsCartera c with(nolock)
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso>=60
and c.codoficina=@codoficina
and c.codoficina<100
and c.fechadesembolso>='20150101' and c.fechadesembolso<='20151231'
--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2015=substring(@valores,1,len(@valores)-1)
	where item=2
end

set @valores=''
SELECT @valores= c.codprestamo+ ', '+@valores 
FROM tCsCartera c with(nolock)
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso>=60
and c.codoficina=@codoficina
and c.codoficina<100
and c.fechadesembolso>='20160101' and c.fechadesembolso<='20161231'
--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2016=substring(@valores,1,len(@valores)-1)
	where item=2
end

select * from #PtmoCER

drop table #PtmoCER


GO