SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptCubetasSucursal2] @codoficina varchar(2000)
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
	Vigentenroptmo int,
	Vigentesaldo money,
	VigentePor money,
	Atrasadonroptmo int,
	Atrasadosaldo money,
	Atrasadopor money,
	Vencidonroptmo int,
	Vencidosaldo money,
	Vencidopor money
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
	,count(distinct D8nroptmo) D8nroptmo,sum(D8saldo) D8saldo, (sum(D8saldo)/sum(saldocapital))*100 D8por	
	,count(distinct D31nroptmo) D31nroptmo,sum(D31saldo) D31saldo, (sum(D31saldo)/sum(saldocapital))*100 D31por
	from (
	  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal
	  ,cd.saldocapital
	  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end D0nroptmo
	  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end D0saldo

	  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.codprestamo else null end D8nroptmo
	  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end D8saldo

	  ,case when c.NroDiasAtraso>=31 then cd.codprestamo else null end D31nroptmo
	  ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end D31saldo
  
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

--insert into #cuadro (etiqueta,nroptmo,saldocapitalVigentenroptmo,Vigentesaldo,VigentePor
--					,Atrasadonroptmo,Atrasadosaldo,Atrasadopor,Vencidonroptmo,Vencidosaldo,Vencidopor)
--select 'Mov. Mensual' as etiqueta
--,h.nroptmo-i.nroptmo nroptmo,h.saldocapital-i.saldocapital saldocapital,h.D0nroptmo-i.D0nroptmo D0nroptmo,h.D0saldo-i.D0saldo D0saldo
--,h.D1a7nroptmo-i.D1a7nroptmo D1a7nroptmo,h.D1a7saldo-i.D1a7saldo D1a7saldo,h.D8a15nroptmo-i.D8a15nroptmo D8a15nroptmo,h.D8a15saldo-i.D8a15saldo D8a15saldo
--,h.D16a30nroptmo-i.D16a30nroptmo D16a30nroptmo,h.D16a30saldo-i.D16a30saldo D16a30saldo,h.D31a60nroptmo-i.D31a60nroptmo D31a60nroptmo,h.D31a60saldo-i.D31a60saldo D31a60saldo
--,h.D61a89nroptmo-i.D61a89nroptmo D61a89nroptmo,h.D61a89saldo-i.D61a89saldo D61a89saldo,h.D90a120nroptmo-i.D90a120nroptmo D90a120nroptmo,h.D90a120saldo-i.D90a120saldo D90a120saldo
--,h.D121a239nroptmo-i.D121a239nroptmo D121a239nroptmo,h.D121a239saldo-i.D121a239saldo D121a239saldo,h.D240nroptmo-i.D240nroptmo D240nroptmo,h.D240saldo-i.D240saldo D240saldo
--from #cuadro h cross join #cuadro i
--where h.etiqueta='Hoy' and i.etiqueta='Inicio Mes'

--insert into #cuadro (etiqueta,nroptmo,saldocapital,D0nroptmo,D0saldo,D1a7nroptmo,D1a7saldo,D8a15nroptmo,D8a15saldo,D16a30nroptmo
--					,D16a30saldo,D31a60nroptmo,D31a60saldo,D61a89nroptmo,D61a89saldo,D90a120nroptmo,D90a120saldo,D121a239nroptmo,D121a239saldo,D240nroptmo,D240saldo)
--select 'Mov. Diario' as etiqueta
--,h.nroptmo-i.nroptmo nroptmo,h.saldocapital-i.saldocapital saldocapital,h.D0nroptmo-i.D0nroptmo D0nroptmo,h.D0saldo-i.D0saldo D0saldo
--,h.D1a7nroptmo-i.D1a7nroptmo D1a7nroptmo,h.D1a7saldo-i.D1a7saldo D1a7saldo,h.D8a15nroptmo-i.D8a15nroptmo D8a15nroptmo,h.D8a15saldo-i.D8a15saldo D8a15saldo
--,h.D16a30nroptmo-i.D16a30nroptmo D16a30nroptmo,h.D16a30saldo-i.D16a30saldo D16a30saldo,h.D31a60nroptmo-i.D31a60nroptmo D31a60nroptmo,h.D31a60saldo-i.D31a60saldo D31a60saldo
--,h.D61a89nroptmo-i.D61a89nroptmo D61a89nroptmo,h.D61a89saldo-i.D61a89saldo D61a89saldo,h.D90a120nroptmo-i.D90a120nroptmo D90a120nroptmo,h.D90a120saldo-i.D90a120saldo D90a120saldo
--,h.D121a239nroptmo-i.D121a239nroptmo D121a239nroptmo,h.D121a239saldo-i.D121a239saldo D121a239saldo,h.D240nroptmo-i.D240nroptmo D240nroptmo,h.D240saldo-i.D240saldo D240saldo
--from #cuadro h cross join #cuadro i
--where h.etiqueta='Hoy' and i.etiqueta='Ayer'

select @fecha fechareporte,* from #cuadro

drop table #ptmos
drop table #cuadro
GO