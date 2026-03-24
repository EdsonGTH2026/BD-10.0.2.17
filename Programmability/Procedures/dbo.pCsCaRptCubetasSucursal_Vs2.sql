SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsCaRptCubetasSucursal_Vs2 '3'
CREATE procedure [dbo].[pCsCaRptCubetasSucursal_Vs2] @codoficina varchar(2000)
as
set nocount on
--declare @codoficina varchar(500)
--set @codoficina='4'

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fechas table(sec int,etiqueta varchar(20),fecha smalldatetime)
insert into @fechas values(1,'Inicio Mes',cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1)
insert into @fechas values(2,'Ayer',@fecha-1)
insert into @fechas values(3,'Hoy',@fecha)

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

create table #ptmos (codprestamo varchar(25))
create table #cuadro (
	etiqueta varchar(20),
	fecha smalldatetime,
	nroptmo int,
	saldocapital money,
	D0nroptmo int,
	D0saldo money,
	D0Por money,
	D1a7nroptmo int,
	D1a7saldo money,
	D1a7por money,
	D8a15nroptmo int,
	D8a15saldo money,
	D8a15por money,

	D16a20nroptmo int,
	D16a20saldo money,
	D16a20por money,

	D21a30nroptmo int,
	D21a30saldo money,
	D21a30por money,

	D31a60nroptmo int,
	D31a60saldo money,
	D31a60por money,
	D61a89nroptmo int,
	D61a89saldo money,
	D61a89por money,
	D90a120nroptmo int,
	D90a120saldo money,
	D90a120por money,
	D121a239nroptmo int,
	D121a239saldo money,
	D121a239por money,
	D240nroptmo int,
	D240saldo money,
	D240por money,

	imor21 money,
	imor31 money
)
declare @n int
declare @x int
select @n=count(*) from @fechas
set @x=1

Declare @f smalldatetime
Declare @e varchar(20)

while(@x<@n+1)
begin
	select @f=fecha,@e=etiqueta from @fechas where sec=@x

	truncate table #ptmos
	insert into #ptmos
	select distinct codprestamo 
	from tcscartera with(nolock)
	where fecha=@f
	and cartera='ACTIVA' and codoficina not in('97','230','231')
	and codprestamo not in (select codprestamo from tCsCarteraAlta)
	and codoficina in(select codigo from @sucursales)

	insert into #cuadro
	select @e etiqueta,@f fecha--,sucursal
	,count(distinct codprestamo) nroptmo
	,sum(saldocapital) saldocapital
	,count(distinct D0nroptmo) D0nroptmo,sum(D0saldo) D0saldo, (sum(D0saldo)/sum(saldocapital))*100 D0Por
	,count(distinct D1a7nroptmo) D1a7nroptmo,sum(D1a7saldo) D1a7saldo, (sum(D1a7saldo)/sum(saldocapital))*100 D1a7por
	,count(distinct D8a15nroptmo) D8a15nroptmo,sum(D8a15saldo) D8a15saldo, (sum(D8a15saldo)/sum(saldocapital))*100 D8a15por
	,count(distinct D16a20nroptmo) D16a20nroptmo,sum(D16a20saldo) D16a20saldo, (sum(D16a20saldo)/sum(saldocapital))*100 D16a20por
	,count(distinct D21a30nroptmo) D21a30nroptmo,sum(D21a30saldo) D21a30saldo, (sum(D21a30saldo)/sum(saldocapital))*100 D21a30por
	,count(distinct D31a60nroptmo) D31a60nroptmo,sum(D31a60saldo) D31a60saldo, (sum(D31a60saldo)/sum(saldocapital))*100 D31a60por
	,count(distinct D61a89nroptmo) D61a89nroptmo,sum(D61a89saldo) D61a89saldo, (sum(D61a89saldo)/sum(saldocapital))*100 D61a89por
	,count(distinct D90a120nroptmo) D90a120nroptmo,sum(D90a120saldo) D90a120saldo, (sum(D90a120saldo)/sum(saldocapital))*100 D90a120por
	,count(distinct D121a239nroptmo) D121a239nroptmo,sum(D121a239saldo) D121a239saldo, (sum(D121a239saldo)/sum(saldocapital))*100 D121a239por
	,count(distinct D240nroptmo) D240nroptmo,sum(D240saldo) D240saldo, (sum(D240saldo)/sum(saldocapital))*100 D240por
	
	, (sum(DM21saldo)/sum(saldocapital))*100 DM21_imor
	, (sum(DM31saldo)/sum(saldocapital))*100 DM31_imor
	from (
	  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal
	  ,cd.saldocapital
	  ,case when c.NroDiasAtraso=0 then cd.codprestamo else null end D0nroptmo
	  ,case when c.NroDiasAtraso=0 then cd.saldocapital else 0 end D0saldo

	  ,case when c.NroDiasAtraso>=1 and c.NroDiasAtraso<=7 then cd.codprestamo else null end D1a7nroptmo
	  ,case when c.NroDiasAtraso>=1 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end D1a7saldo

	  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end D8a15nroptmo
	  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.saldocapital else 0 end D8a15saldo

	  ,case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=20 then cd.codprestamo else null end D16a20nroptmo
	  ,case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=20 then cd.saldocapital else 0 end D16a20saldo

	  ,case when c.NroDiasAtraso>=21 and c.NroDiasAtraso<=30 then cd.codprestamo else null end D21a30nroptmo
	  ,case when c.NroDiasAtraso>=21 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end D21a30saldo

	  ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end D31a60nroptmo
	  ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.saldocapital else 0 end D31a60saldo

	  ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end D61a89nroptmo
	  ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.saldocapital else 0 end D61a89saldo

	  ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.codprestamo else null end D90a120nroptmo
	  ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.saldocapital else 0 end D90a120saldo

	  ,case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=239 then cd.codprestamo else null end D121a239nroptmo
	  ,case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=239 then cd.saldocapital else 0 end D121a239saldo

	  ,case when c.NroDiasAtraso>=240 then cd.codprestamo else null end D240nroptmo
	  ,case when c.NroDiasAtraso>=240 then cd.saldocapital else 0 end D240saldo
  
	  ,case when c.NroDiasAtraso>=21 then cd.saldocapital else 0 end DM21saldo
	  ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end DM31saldo
	  FROM tCsCartera c with(nolock)
	  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
	  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
	  where c.fecha=@f--echa 
	  and c.cartera='ACTIVA'
	  --and c.codoficina not in('97','231','231')
	  and c.codprestamo in(select codprestamo from #ptmos)
	) a
	--group by sucursal

	set @x=@x+1
end

insert into #cuadro (etiqueta,nroptmo,saldocapital,D0nroptmo,D0saldo,D1a7nroptmo,D1a7saldo,D8a15nroptmo,D8a15saldo
					,D16a20nroptmo,D16a20saldo,D21a30nroptmo,D21a30saldo
					,D31a60nroptmo,D31a60saldo,D61a89nroptmo,D61a89saldo,D90a120nroptmo,D90a120saldo,D121a239nroptmo,D121a239saldo,D240nroptmo,D240saldo)
select 'Mov. Mensual' as etiqueta
,h.nroptmo-i.nroptmo nroptmo,h.saldocapital-i.saldocapital saldocapital,h.D0nroptmo-i.D0nroptmo D0nroptmo,h.D0saldo-i.D0saldo D0saldo
,h.D1a7nroptmo-i.D1a7nroptmo D1a7nroptmo,h.D1a7saldo-i.D1a7saldo D1a7saldo,h.D8a15nroptmo-i.D8a15nroptmo D8a15nroptmo,h.D8a15saldo-i.D8a15saldo D8a15saldo
,h.D16a20nroptmo-i.D16a20nroptmo D16a20nroptmo,h.D16a20saldo-i.D16a20saldo D16a20saldo
,h.D21a30nroptmo-i.D21a30nroptmo D21a30nroptmo,h.D21a30saldo-i.D21a30saldo D21a30saldo
,h.D31a60nroptmo-i.D31a60nroptmo D31a60nroptmo,h.D31a60saldo-i.D31a60saldo D31a60saldo
,h.D61a89nroptmo-i.D61a89nroptmo D61a89nroptmo,h.D61a89saldo-i.D61a89saldo D61a89saldo,h.D90a120nroptmo-i.D90a120nroptmo D90a120nroptmo,h.D90a120saldo-i.D90a120saldo D90a120saldo
,h.D121a239nroptmo-i.D121a239nroptmo D121a239nroptmo,h.D121a239saldo-i.D121a239saldo D121a239saldo,h.D240nroptmo-i.D240nroptmo D240nroptmo,h.D240saldo-i.D240saldo D240saldo
from #cuadro h cross join #cuadro i
where h.etiqueta='Hoy' and i.etiqueta='Inicio Mes'

insert into #cuadro (etiqueta,nroptmo,saldocapital,D0nroptmo,D0saldo,D1a7nroptmo,D1a7saldo,D8a15nroptmo,D8a15saldo
					,D16a20nroptmo,D16a20saldo,D21a30nroptmo,D21a30saldo
					,D31a60nroptmo,D31a60saldo,D61a89nroptmo,D61a89saldo,D90a120nroptmo,D90a120saldo,D121a239nroptmo,D121a239saldo,D240nroptmo,D240saldo)
select 'Mov. Diario' as etiqueta
,h.nroptmo-i.nroptmo nroptmo,h.saldocapital-i.saldocapital saldocapital,h.D0nroptmo-i.D0nroptmo D0nroptmo,h.D0saldo-i.D0saldo D0saldo
,h.D1a7nroptmo-i.D1a7nroptmo D1a7nroptmo,h.D1a7saldo-i.D1a7saldo D1a7saldo,h.D8a15nroptmo-i.D8a15nroptmo D8a15nroptmo,h.D8a15saldo-i.D8a15saldo D8a15saldo
,h.D16a20nroptmo-i.D16a20nroptmo D16a20nroptmo,h.D16a20saldo-i.D16a20saldo D16a20saldo
,h.D21a30nroptmo-i.D21a30nroptmo D21a30nroptmo,h.D21a30saldo-i.D21a30saldo D21a30saldo
,h.D31a60nroptmo-i.D31a60nroptmo D31a60nroptmo,h.D31a60saldo-i.D31a60saldo D31a60saldo
,h.D61a89nroptmo-i.D61a89nroptmo D61a89nroptmo,h.D61a89saldo-i.D61a89saldo D61a89saldo,h.D90a120nroptmo-i.D90a120nroptmo D90a120nroptmo,h.D90a120saldo-i.D90a120saldo D90a120saldo
,h.D121a239nroptmo-i.D121a239nroptmo D121a239nroptmo,h.D121a239saldo-i.D121a239saldo D121a239saldo,h.D240nroptmo-i.D240nroptmo D240nroptmo,h.D240saldo-i.D240saldo D240saldo
from #cuadro h cross join #cuadro i
where h.etiqueta='Hoy' and i.etiqueta='Ayer'

select @fecha+1 fechareporte,* from #cuadro

drop table #ptmos
drop table #cuadro

GO