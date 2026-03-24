SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsACaIntDevengadoDiaMes '20181101','20181130'
CREATE procedure [dbo].[pCsACaIntDevengadoDiaMes] @fecini smalldatetime,@fecfin smalldatetime
as
--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--set @fecini='20181101'
--set @fecfin='20181130'

declare @feci smalldatetime
declare @fecf smalldatetime
set @feci=@fecini
set @fecf=@fecfin

create table #tca(
	codprestamo varchar(25),
	prestamoid varchar(25),
	codserviciop varchar(25)
)
insert into #tca (codprestamo,prestamoid,codserviciop)
select codprestamo,codanterior,codserviciop
from [10.0.2.14].finmas.dbo.tcaprestamos --where codoficina>100
where cast(codoficina as int)>100 and cast(codoficina as int)<300
and codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9')

select --dbo.fdufechaaperiodo(d.fecha) periodo,
sum(d.interesdevengado) interes
,sum(case when day(d.fecha)>=1 and day(d.fecha)<=5 then d.interesdevengado else 0 end) int_1a5
--,(sum(case when day(fecha)>=1 and day(fecha)<=5 then interesdevengado else 0 end)/sum(montocapitaltran))*100 por_1a5
,sum(case when day(d.fecha)>=6 and day(d.fecha)<=10 then d.interesdevengado else 0 end) int_6a10
--,(sum(case when day(fecha)>=6 and day(fecha)<=10 then interesdevengado else 0 end)/sum(montocapitaltran))*100 por_6a10
,sum(case when day(d.fecha)>=11 and day(d.fecha)<=15 then d.interesdevengado else 0 end) int_11a15
--,(sum(case when day(fecha)>=11 and day(fecha)<=15 then interesdevengado else 0 end)/sum(montocapitaltran))*100 por_11a15
,sum(case when day(d.fecha)>=16 and day(d.fecha)<=20 then d.interesdevengado else 0 end) int_16a20
--,(sum(case when day(fecha)>=16 and day(fecha)<=20 then interesdevengado else 0 end)/sum(montocapitaltran))*100 por_16a20
,sum(case when day(d.fecha)>=21 and day(d.fecha)<=25 then d.interesdevengado else 0 end) int_21a25
--,(sum(case when day(fecha)>=21 and day(fecha)<=25 then interesdevengado else 0 end)/sum(montocapitaltran))*100 por_21a25
,sum(case when day(d.fecha)>=26 and day(d.fecha)<=31 then d.interesdevengado else 0 end) int_26a31
--,(sum(case when day(fecha)>=26 and day(fecha)<=31 then interesdevengado else 0 end)/sum(montocapitaltran))*100 por_26a31
from tcscarteradet d with(nolock)
inner join tcscartera c with(nolock) on c.fecha=d.fecha and d.codprestamo=c.codprestamo
where d.codprestamo not in(select codprestamo from #tca)
and c.codoficina not in('97','230','231')
and d.fecha>=@feci and d.fecha<=@fecf
and c.estado='VIGENTE'
--group by dbo.fdufechaaperiodo(d.fecha)

drop table #tca

GO

GRANT EXECUTE ON [dbo].[pCsACaIntDevengadoDiaMes] TO [marista]
GO