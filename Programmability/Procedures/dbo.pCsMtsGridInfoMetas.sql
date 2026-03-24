SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsMtsGridInfoMetas] @fecha smalldatetime, @codoficina varchar(4)
as
--declare @fecha smalldatetime
--declare @codoficina varchar(4)
--set @fecha='20150524'
--set @codoficina='4'

declare @fechaMeta smalldatetime
--set @fechaMeta='20150630'
set @fechaMeta=dateadd(day,-1,(cast(dbo.fdufechaaperiodo(dateadd(month,2,@fecha))+'01' as smalldatetime)))
--select @fechaMeta '@fechaMeta'
select a.codasesor,pro.nombrecompleto promotor,Np,saldocartera
,isnull(MCN.valorprog,0) MCN
,isnull(MCR.valorprog,0) MCR
,isnull(MCD.valorprog,0) MCD
,isnull(MCN.valorprog,0) + isnull(MCR.valorprog,0) + Np NFinMes
,isnull(MCD.valorprog,0) + saldocartera SaldoFinMes

,isnull(MCN_r.valorprog,0) MCN_r
,isnull(MCR_r.valorprog,0) MCR_r
,isnull(MCD_r.valorprog,0) MCD_r

from (
SELECT c.codasesor
,count(distinct c.codprestamo) Np
,sum(d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido) saldocartera
FROM tCsCartera c with(nolock)
inner join tCsCarteraDet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.fecha=@fecha and c.codoficina=@codoficina and c.cartera='ACTIVA'
group by c.codasesor
) a
left outer join tCsBsMetaxUEN MCN on MCN.ncamvalor=a.codasesor and MCN.fecha=@fechaMeta and MCN.iCodTipoBS=5 and MCN.iCodIndicador=11--> metas de nuevos clientes
left outer join tCsBsMetaxUEN MCR on MCR.ncamvalor=a.codasesor and MCR.fecha=@fechaMeta and MCR.iCodTipoBS=5 and MCR.iCodIndicador=8--> metas de nuevos renovados
left outer join tCsBsMetaxUEN MCD on MCD.ncamvalor=a.codasesor and MCD.fecha=@fechaMeta and MCD.iCodTipoBS=5 and MCD.iCodIndicador=1--> metas de desembolsos
inner join tcspadronclientes pro with(nolock) on pro.codusuario=a.codasesor

left outer join (
	select fecha,icodtipobs,icodindicador,ncamvalor,sum(valorprog) valorprog
	from tCsBsMetaxUENdet group by fecha,icodtipobs,icodindicador,ncamvalor
) MCN_r on MCN_r.ncamvalor=a.codasesor and MCN_r.fecha=@fechaMeta and MCN_r.iCodTipoBS=5 and MCN_r.iCodIndicador=11
left outer join (
	select fecha,icodtipobs,icodindicador,ncamvalor,sum(valorprog) valorprog
	from tCsBsMetaxUENdet group by fecha,icodtipobs,icodindicador,ncamvalor
) MCR_r on MCR_r.ncamvalor=a.codasesor and MCR_r.fecha=@fechaMeta and MCR_r.iCodTipoBS=5 and MCR_r.iCodIndicador=8
left outer join (
	select fecha,icodtipobs,icodindicador,ncamvalor,sum(valorprog) valorprog
	from tCsBsMetaxUENdet group by fecha,icodtipobs,icodindicador,ncamvalor
) MCD_r on MCD_r.ncamvalor=a.codasesor and MCD_r.fecha=@fechaMeta and MCD_r.iCodTipoBS=5 and MCD_r.iCodIndicador=1

order by codasesor
GO