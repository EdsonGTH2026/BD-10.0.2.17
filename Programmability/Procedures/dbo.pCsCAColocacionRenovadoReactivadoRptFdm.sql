SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---exec pCsCAColocacionRenovadoReactivadoRptFdm '20180927'
CREATE procedure [dbo].[pCsCAColocacionRenovadoReactivadoRptFdm] @fecfin smalldatetime
as
declare @fecini smalldatetime
--declare @fecfin smalldatetime

--set @fecfin='20180923'
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'--'20180901'

declare @fecini_t smalldatetime
declare @fecfin_t smalldatetime
set @fecini_t=@fecini
set @fecfin_t=@fecfin

create table #co(
	periodo varchar(50),
	montototal money,
	nrototal	money,
	renovadomonto money,
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
	exec pCsCAColocacionRenovadoReactivado @fecini_t,@fecfin_t

	set @fecini_t=dateadd(month,-@n,@fecini)
	--set @fecfin_t=dateadd(month,-@n,@fecfin)
	select @fecfin_t=ultimodia from tclperiodo where primerdia<=dateadd(month,-@n,@fecfin) and ultimodia>=dateadd(month,-@n,@fecfin)
	
	set @n=@n+1
end

select periodo,montototal,nrototal,renovadomonto,renovadonro,reactivadomonto,reactivadonro,montototal-renovadomonto-reactivadomonto nuevo
,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado
into #cx
from #co

insert into #cx(periodo,montototal,renovadomonto,reactivadomonto,nuevo,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado)
select 'Promedio' Titulo,avg(montototal) montototal,avg(renovadomonto) renovadomonto,avg(reactivadomonto) reactivadomonto,avg(nuevo) nuevo
,avg(renovadoActivo) renovadoActivo,avg(renovadohuerfano) renovadohuerfano,avg(renovadoReasignado) renovadoReasignado
,avg(reactivadoActivo) reactivadoActivo,avg(reactivadohuerfano) reactivadohuerfano,avg(reactivadoReasignado) reactivadoReasignado
from #cx
where periodo<>dbo.fdufechaaperiodo(@fecfin)

insert into #cx(periodo,montototal,renovadomonto,reactivadomonto,nuevo,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado)
select 'diferencia' periodo
,a.montototal-b.montototal montototal
,a.renovadomonto-b.renovadomonto renovadomonto
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

select * from #cx

drop table #co
drop table #cx
GO