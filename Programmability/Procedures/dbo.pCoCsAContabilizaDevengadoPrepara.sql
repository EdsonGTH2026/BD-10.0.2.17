SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCoCsAContabilizaDevengadoPrepara]	@fecha smalldatetime
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20151001'

--create table #tca(
--	codprestamo varchar(25),
--	prestamoid varchar(25),
--	codserviciop varchar(25)
--)
--insert into #tca (codprestamo,prestamoid,codserviciop)
--select codprestamo,codanterior,codserviciop from [10.0.2.14].finmas.dbo.tcaprestamos where codoficina>100

create table #CarDev(
	codoficina varchar(4),
	codprestamo varchar(25),
	nrodiasatraso int,
	estado varchar(15),
	interesdevengado decimal(16,2),
	moratoriodevengado decimal(16,2)
)

insert into #CarDev
SELECT c.codoficina,c.codprestamo,c.nrodiasatraso,c.estado
--,sum(d.interesdevengado) interesdevengado
,sum(case when c.codfondo=20 then (d.interesdevengado)*0.3 
		  when c.codfondo=21 then (d.interesdevengado)*0.25
		  else d.interesdevengado end) interesdevengado
,sum(case when c.codfondo=20 then (d.moratoriodevengado)*0.3 
		  when c.codfondo=21 then (d.moratoriodevengado)*0.25
		  else d.moratoriodevengado end) moratoriodevengado
FROM tCsCartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
--where c.fecha=@fecha and c.estado<>'CASTIGADO' and c.codoficina<>'97'
--and c.codprestamo not in (select codprestamo from #tca where codserviciop not in ('ALTA1','ALTA2','ALTA4'))
where c.fecha=@fecha and c.cartera='ACTIVA' and c.codoficina not in('97','230','231','999')
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
group by c.codoficina,c.codprestamo,c.nrodiasatraso,c.estado

drop table tCoDevengamientoDiario
create table tCoDevengamientoDiario(
	item int identity(1,1),
	fecha smalldatetime,
	codoficina varchar(4),
	codprestamo varchar(25),
	codcta varchar(15),
	debe money,
	haber money,
	glosagral varchar(200)
)

insert into tCoDevengamientoDiario (fecha,codoficina,codprestamo,codcta,debe,haber,glosagral)
/*Devengamiento interes corriente*/
select @fecha fecha,codoficina,codprestamo,'139110101' codcta,interesdevengado debe,0 haber,'Devengamiento diario int. ordinario Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estado='VIGENTE' and interesdevengado<>0
union
select @fecha fecha,codoficina,codprestamo,'610110101' codcta,0 debe,interesdevengado haber,'Devengamiento diario int. ordinario Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estado='VIGENTE' and interesdevengado<>0
union
/*Devengamiento interes moratorio*/
select @fecha fecha,codoficina,codprestamo,'139110102' codcta,moratoriodevengado debe,0 haber,'Devengamiento diario int. moratorio Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estado='VIGENTE' and moratoriodevengado<>0
union
select @fecha fecha,codoficina,codprestamo,'610410101' codcta,0 debe,moratoriodevengado haber,'Devengamiento diario int. moratorio Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estado='VIGENTE' and moratoriodevengado<>0
union
/*Devengamiento interes corriente*/
select @fecha fecha,codoficina,codprestamo,'740110101' codcta,interesdevengado debe,0 haber,'Devengamiento diario int. ordinario Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estado='VENCIDO' and interesdevengado<>0
union
select @fecha fecha,codoficina,codprestamo,'840110101' codcta,0 debe,interesdevengado haber,'Devengamiento diario int. ordinario Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estado='VENCIDO' and interesdevengado<>0
union
/*Devengamiento interes moratorio*/
select @fecha fecha,codoficina,codprestamo,'740210101' codcta,moratoriodevengado debe,0 haber,'Devengamiento diario int. moratorio Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estado='VENCIDO' and moratoriodevengado<>0
union
select @fecha fecha,codoficina,codprestamo,'840210101' codcta,0 debe,moratoriodevengado haber,'Devengamiento diario int. moratorio Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estado='VENCIDO' and moratoriodevengado<>0

--drop table #tca
drop table #CarDev

--select * from tCoDevengamientoDiario

--14,776 el script
--14,777 unisap menos 1 anulado
GO