SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsRptCaPreventivaPorOficina] (@codoficina varchar(15))
as

declare @fecha smalldatetime
--declare @codoficina varchar(4)
--set @fecha='20160430'
select @fecha = fechaconsolidacion from vcsfechaconsolidacion
--set @codoficina=126

create table #PtmoCER(
	item int,
	Descripcion varchar(20),
	Prestamos2014 varchar(1000) default(''),
	Prestamos2015 varchar(1000) default(''),
	Prestamos2016 varchar(1000) default('')
)

insert into #PtmoCER (item,descripcion) values(1,'1 día')
insert into #PtmoCER (item,descripcion) values(2,'2 días')
insert into #PtmoCER (item,descripcion) values(3,'3 días')

declare @valores varchar(1000)
set @valores=''
/*
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),c.codprestamo)+ ', '+@valores 
FROM tCsCartera c with(nolock)
left outer join tCsCaCosechasBase b with(nolock) on b.codprestamo=c.codprestamo
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso=1 --and c.nrodiasatraso<=3
and c.codoficina=@codoficina
--and c.codoficina<100
and c.fechadesembolso>='20140101' and c.fechadesembolso<='20141231'
*/

-- se quito la tabla tCsCartera
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),b.codprestamo)+ ', '+@valores 
FROM tCsCaCosechasBase b with(nolock) 
where --b.fecha=@fecha and 
b.Desembolso>='20140101' and b.codproducto not in(167,168)
and b.nrodiasatraso=1 --and c.nrodiasatraso<=3
and b.codoficina=@codoficina
and b.Desembolso>='20140101' and b.Desembolso<='20141231'

--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2014=substring(@valores,1,len(@valores)-1)
	where item=1
end

set @valores=''
/*
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),c.codprestamo)+ ', '+@valores 
FROM tCsCartera c with(nolock)
left outer join tCsCaCosechasBase b with(nolock) on b.codprestamo=c.codprestamo
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso=1 --and c.nrodiasatraso<=3
and c.codoficina=@codoficina
--and c.codoficina<100
and c.fechadesembolso>='20150101' and c.fechadesembolso<='20151231'
*/

-- se quito la tabla tCsCartera
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),b.codprestamo)+ ', '+@valores 
FROM  tCsCaCosechasBase b with(nolock) 
where --c.fecha=@fecha and 
b.Desembolso>='20140101' and b.codproducto not in(167,168)
and b.nrodiasatraso=1 --and c.nrodiasatraso<=3
and b.codoficina=@codoficina
and b.Desembolso>='20150101' and b.Desembolso<='20151231'

--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2015=substring(@valores,1,len(@valores)-1)
	where item=1
end

set @valores=''
/*
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),c.codprestamo)+ ', '+@valores 
FROM tCsCartera c with(nolock)
left outer join tCsCaCosechasBase b with(nolock) on b.codprestamo=c.codprestamo
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso=1 --and c.nrodiasatraso<=3
and c.codoficina=@codoficina
--and c.codoficina<100
and c.fechadesembolso>='20160101' and c.fechadesembolso<='20161231'
*/

-- se quito la tabla tCsCartera
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),b.codprestamo)+ ', '+@valores 
FROM tCsCaCosechasBase b with(nolock) 
where --c.fecha=@fecha and 
b.Desembolso>='20140101' and b.codproducto not in(167,168)
and b.nrodiasatraso=1 --and c.nrodiasatraso<=3
and b.codoficina=@codoficina
and b.Desembolso>='20160101' and b.Desembolso<='20161231'

--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2016=substring(@valores,1,len(@valores)-1)
	where item=1
end

/**2222222222222222222222222222222222*/
set @valores=''
/*
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),c.codprestamo)+ ', '+@valores 
FROM tCsCartera c with(nolock)
left outer join tCsCaCosechasBase b with(nolock) on b.codprestamo=c.codprestamo
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso=2 --and c.nrodiasatraso<=3
and c.codoficina=@codoficina
--and c.codoficina<100
and c.fechadesembolso>='20140101' and c.fechadesembolso<='20141231'
*/

-- se quito la tabla tCsCartera
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),b.codprestamo)+ ', '+@valores 
FROM tCsCaCosechasBase b with(nolock) 
where --c.fecha=@fecha and 
b.Desembolso>='20140101' and b.codproducto not in(167,168)
and b.nrodiasatraso=2 --and c.nrodiasatraso<=3
and b.codoficina=@codoficina
and b.Desembolso>='20140101' and b.Desembolso<='20141231'

--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2014=substring(@valores,1,len(@valores)-1)
	where item=2
end

set @valores=''
/*
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),c.codprestamo)+ ', '+@valores 
FROM tCsCartera c with(nolock)
left outer join tCsCaCosechasBase b with(nolock) on b.codprestamo=c.codprestamo
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso=2 --and c.nrodiasatraso<=3
and c.codoficina=@codoficina
--and c.codoficina<100
and c.fechadesembolso>='20150101' and c.fechadesembolso<='20151231'
*/

-- se quito la tabla tCsCartera
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),b.codprestamo)+ ', '+@valores 
FROM tCsCaCosechasBase b with(nolock) 
where --c.fecha=@fecha and 
b.Desembolso>='20140101' and b.codproducto not in(167,168)
and b.nrodiasatraso=2 --and c.nrodiasatraso<=3
and b.codoficina=@codoficina
and b.Desembolso>='20150101' and b.Desembolso<='20151231'

--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2015=substring(@valores,1,len(@valores)-1)
	where item=2
end

set @valores=''
/*
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),c.codprestamo)+ ', '+@valores 
FROM tCsCartera c with(nolock)
left outer join tCsCaCosechasBase b with(nolock) on b.codprestamo=c.codprestamo
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso=2 --and c.nrodiasatraso<=3
and c.codoficina=@codoficina
--and c.codoficina<100
and c.fechadesembolso>='20160101' and c.fechadesembolso<='20161231'
*/

-- se quito la tabla tCsCartera
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),b.codprestamo)+ ', '+@valores 
FROM tCsCaCosechasBase b with(nolock)
where --c.fecha=@fecha and 
b.Desembolso>='20140101' and b.codproducto not in(167,168)
and b.nrodiasatraso=2 --and c.nrodiasatraso<=3
and b.codoficina=@codoficina
and b.Desembolso>='20160101' and b.Desembolso<='20161231'

--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2016=substring(@valores,1,len(@valores)-1)
	where item=2
end

/**3333333333333333333333333*/
set @valores=''
/*
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),c.codprestamo)+ ', '+@valores 
FROM tCsCartera c with(nolock)
left outer join tCsCaCosechasBase b with(nolock) on b.codprestamo=c.codprestamo
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso=3 --and c.nrodiasatraso<=3
and c.codoficina=@codoficina
--and c.codoficina<100
and c.fechadesembolso>='20140101' and c.fechadesembolso<='20141231'
*/

-- se quito la tabla tCsCartera
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),b.codprestamo)+ ', '+@valores 
FROM tCsCaCosechasBase b with(nolock)
where --c.fecha=@fecha and 
b.Desembolso>='20140101' and b.codproducto not in(167,168)
and b.nrodiasatraso=3 --and c.nrodiasatraso<=3
and b.codoficina=@codoficina
and b.Desembolso>='20140101' and b.Desembolso<='20141231'

--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2014=substring(@valores,1,len(@valores)-1)
	where item=3
end

set @valores=''
/*
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),c.codprestamo)+ ', '+@valores 
FROM tCsCartera c with(nolock)
left outer join tCsCaCosechasBase b with(nolock) on b.codprestamo=c.codprestamo
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso=3 --and c.nrodiasatraso<=3
and c.codoficina=@codoficina
--and c.codoficina<100
and c.fechadesembolso>='20150101' and c.fechadesembolso<='20151231'
*/

-- se quito la tabla tCsCartera
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),b.codprestamo)+ ', '+@valores 
FROM tCsCaCosechasBase b with(nolock)
where --c.fecha=@fecha and 
b.Desembolso>='20140101' and b.codproducto not in(167,168)
and b.nrodiasatraso=3 --and c.nrodiasatraso<=3
and b.codoficina=@codoficina
and b.Desembolso>='20150101' and b.Desembolso<='20151231'

--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2015=substring(@valores,1,len(@valores)-1)
	where item=3
end

set @valores=''
/*
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),c.codprestamo)+ ', '+@valores 
FROM tCsCartera c with(nolock)
left outer join tCsCaCosechasBase b with(nolock) on b.codprestamo=c.codprestamo
where c.fecha=@fecha and c.fechadesembolso>='20140101' and c.codproducto not in(167,168)
and c.nrodiasatraso=3 --and c.nrodiasatraso<=3
and c.codoficina=@codoficina
--and c.codoficina<100
and c.fechadesembolso>='20160101' and c.fechadesembolso<='20161231'
*/

-- se quito la tabla tCsCartera
SELECT @valores= isnull(cast(b.prestamoid as varchar(20)),b.codprestamo)+ ', '+@valores 
FROM tCsCaCosechasBase b with(nolock)
where --c.fecha=@fecha and 
b.Desembolso>='20140101' and b.codproducto not in(167,168)
and b.nrodiasatraso=3 --and c.nrodiasatraso<=3
and b.codoficina=@codoficina
and b.Desembolso>='20160101' and b.Desembolso<='20161231'

--select @valores

if len(@valores)>0
begin
	update #PtmoCER
	set Prestamos2016=substring(@valores,1,len(@valores)-1)
	where item=3
end

select * from #PtmoCER

drop table #PtmoCER



GO