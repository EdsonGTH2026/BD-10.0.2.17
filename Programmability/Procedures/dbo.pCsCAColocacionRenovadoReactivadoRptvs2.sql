SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCAColocacionRenovadoReactivadoRptvs2] @fecfin smalldatetime
as

--declare @fecfin smalldatetime
--set @fecfin='20210819'
set nocount on
declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'--'20180901'

--Calculo fechas dia max record
declare @dia int
set @dia=day(@fecfin)

declare @fecini12 smalldatetime
set @fecini12=dbo.fdufechaaperiodo(dateadd(month,-12,@fecfin))+'01'

select primerdia,case when day(ultimodia)>=@dia then dbo.fdufechaaperiodo(primerdia) + replicate('0',2-len(cast(@dia as varchar(2)))) + cast(@dia as varchar(2)) else ultimodia end ultimodia
into #dias
from tclperiodo
where primerdia>=@fecini12

declare @monto money
select @monto=max(monto) --monto
from (
	select dbo.fdufechaaperiodo(desembolso) periodo,sum(monto) monto
	from tcspadroncarteradet p with(nolock)
	inner join #dias d with(nolock) on p.desembolso>=d.primerdia and desembolso<=d.ultimodia	
	group by dbo.fdufechaaperiodo(desembolso)
) a

declare @feciniMax smalldatetime
declare @fecfinMax smalldatetime

select @feciniMax=primerdia,@fecfinMax=ultimodia
from (
	select dbo.fdufechaaperiodo(desembolso) periodo,d.primerdia,d.ultimodia,sum(monto) monto
	from tcspadroncarteradet p with(nolock)
	inner join #dias d with(nolock) on p.desembolso>=d.primerdia and desembolso<=d.ultimodia
	group by dbo.fdufechaaperiodo(desembolso),d.primerdia,d.ultimodia
) a
where monto=@monto

--select @feciniMax
--select @fecfinMax
--Calculo fechas dia max record

declare @fecini_t smalldatetime
declare @fecfin_t smalldatetime
set @fecini_t=@fecini
set @fecfin_t=@fecfin

create table #co(
	periodo varchar(50),
	montototal money,
	nrototal	money,
	renovadomonto money,
	renovadomontoAnticipa money,
	renovadonro	money,
	reactivadomonto money,
	reactivadonro	money,
	renovadoActivo	money,
	renovadohuerfano	money,
	renovadoReasignado	money,
	reactivadoActivo	money,
	reactivadohuerfano	money,
	reactivadoReasignado	money
)

declare @nro int
declare @n int
set @nro=3--4
set @n=1

while(@nro+1<>@n)
begin
	--select @fecini_t,@fecfin_t
	insert into #co
	exec pCsCAColocacionRenovadoReactivadovs2 @fecini_t,@fecfin_t

	set @fecini_t=dateadd(month,-@n,@fecini)
	set @fecfin_t=dateadd(month,-@n,@fecfin)
	
	set @n=@n+1
end

set @n=0
while(@nro<>@n)
begin
	set @fecini_t=dateadd(year,-1,dateadd(month,-@n,@fecini))
	set @fecfin_t=dateadd(year,-1,dateadd(month,-@n,@fecfin))

	--select @fecini_t,@fecfin_t
	--select @n '@n'
	insert into #co
	--exec pCsCAColocacionRenovadoReactivado @fecini_t,@fecfin_t
	exec pCsCAColocacionRenovadoReactivadovs2 @fecini_t,@fecfin_t
		
	set @n=@n+1
end

select periodo,montototal,nrototal,renovadomonto,renovadomontoAnticipa,renovadonro,reactivadomonto,reactivadonro,montototal-renovadomonto-renovadomontoAnticipa-reactivadomonto nuevo
,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado
into #cx
from #co

insert into #cx(periodo,montototal,renovadomonto,renovadomontoAnticipa,reactivadomonto,nuevo,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado)
select 'Promedio' Titulo,avg(montototal) montototal,avg(renovadomonto) renovadomonto,avg(renovadomontoAnticipa) renovadomontoAnticipa,avg(reactivadomonto) reactivadomonto,avg(nuevo) nuevo
,avg(renovadoActivo) renovadoActivo,avg(renovadohuerfano) renovadohuerfano,avg(renovadoReasignado) renovadoReasignado
,avg(reactivadoActivo) reactivadoActivo,avg(reactivadohuerfano) reactivadohuerfano,avg(reactivadoReasignado) reactivadoReasignado
from #cx
where periodo<>dbo.fdufechaaperiodo(@fecfin)
and substring(periodo,1,4)=substring(dbo.fdufechaaperiodo(@fecfin),1,4)

insert into #cx(periodo,montototal,renovadomonto,renovadomontoAnticipa,reactivadomonto,nuevo,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado)
select 'diferencia' periodo
,a.montototal-b.montototal montototal
,a.renovadomonto-b.renovadomonto renovadomonto
,a.renovadomontoAnticipa-b.renovadomontoAnticipa renovadomontoAnticipa
,a.reactivadomonto-b.reactivadomonto reactivadomonto
,a.nuevo-b.nuevo nuevo
,a.renovadoActivo-b.renovadoActivo renovadoActivo
,a.renovadohuerfano-b.renovadohuerfano renovadohuerfano
,a.renovadoReasignado-b.renovadoReasignado renovadoReasignado
,a.reactivadoActivo-b.reactivadoActivo reactivadoActivo
,a.reactivadohuerfano-b.reactivadohuerfano reactivadohuerfano
,a.reactivadoReasignado-b.reactivadoReasignado reactivadoReasignado
from #cx a
cross join #cx b 
where a.periodo=dbo.fdufechaaperiodo(@fecfin)
and b.periodo='promedio'

--select @feciniMax '@feciniMax'
--select @fecfinMax '@fecfinMax'

truncate table #co
insert into #co
exec pCsCAColocacionRenovadoReactivadovs2 @feciniMax,@fecfinMax

insert into #cx
select 'x'+periodo,montototal,nrototal,renovadomonto,renovadomontoAnticipa,renovadonro,reactivadomonto,reactivadonro,montototal-renovadomonto-renovadomontoAnticipa-reactivadomonto nuevo
,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado
from #co

select * from #cx

drop table #co
drop table #cx
drop table #dias
GO