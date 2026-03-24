SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCAColoCoorHuer] @fecfin smalldatetime
as
set nocount on
declare @fecini smalldatetime
--declare @fecfin smalldatetime
--set @fecfin='20180913'
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'
--select @fecini
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion--,a.codprestamo,a.desembolso,a.cancelacion
into #liqreno
from tcspadroncarteradet p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
and substring(p.codprestamo,5,3) = (case when substring(a.codprestamo,5,3) ='370' then '370' else '170' end)
where p.desembolso>=@fecini
and p.desembolso<=@fecfin
and p.codoficina<>'97'
group by p.codprestamo,p.desembolso,p.codusuario
having max(a.cancelacion) is not null
 
select l.codprestamo,p.codprestamo codprestamo_ante,p.monto monto_ante,p.primerasesor codasesor_ante, p.secuenciacliente
into #CredAnte
from #liqreno l
inner join tcspadroncarteradet p with(nolock)
on l.codusuario=p.codusuario and l.cancelacion=p.cancelacion
and substring(l.codprestamo,5,3) = (case when substring(p.codprestamo,5,3) ='370' then '370' else '170' end)
 
select @fecfin fecha,p.codprestamo,p.codusuario,p.desembolso,p.monto,l.cancelacion
,co.nombrecompleto coordinador,o.nomoficina sucursal
,case when e.codusuario is null then 'HUERFANO' ELSE
            case when e.estado=1 and e.codpuesto=66 then 'ACTIVO' else 'HUERFANO' end
     END tipo
,an.codprestamo_ante
,an.monto_ante
,case when ex.codusuario is null then 'HUERFANO' ELSE
            case when ex.estado=1 and ex.codpuesto=66 then 'ACTIVO' else 'HUERFANO' end
     END tipo_ante
,cox.nombrecompleto coordinador_ante
,e.ingreso
,an.secuenciacliente
--into tCsACAColoCoorHuer
from tcspadroncarteradet p
left outer join #liqreno l on l.codprestamo=p.codprestamo
left outer join #CredAnte an on an.codprestamo=l.codprestamo
left outer join tcspadronclientes co on co.codusuario=p.primerasesor
inner join tcloficinas o on o.codoficina=p.codoficina
left outer join tcsempleados e on e.codusuario=p.primerasesor
left outer join tcsempleados ex on ex.codusuario=an.codasesor_ante
left outer join tcspadronclientes cox on cox.codusuario=an.codasesor_ante
where p.desembolso>=@fecini and p.desembolso<=@fecfin
and p.codoficina<>'97'
 
drop table #liqreno
drop table #CredAnte
GO