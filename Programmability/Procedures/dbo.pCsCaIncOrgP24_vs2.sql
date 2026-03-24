SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCaIncOrgP24_vs2] @fecha smalldatetime ,@fecini  smalldatetime  
as  
--declare @fecha smalldatetime  
--set @fecha='20211208'  

--declare @fecinixp smalldatetime
--set @fecinixp = @fecini-- '20211201'       --fecha de inicio de corte

--declare @feciniM smalldatetime  
--set @feciniM=cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1  ------------fecha inicio mes
 
select codasesor,coordinador,codoficina,sum(saldo30ini) saldo30ini,sum(saldo30fin) saldo30fin, sum(saldo30fin)-sum(saldo30ini) crecimiento  
,sum(nroptmos30ini) nroptmos30ini,sum(nroptmos30fin) nroptmos30fin  
from (  
 select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor  
 ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador  
 ,c.codoficina  
 ,sum(case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then d.saldocapital else 0 end) saldo30ini --+d.interesvigente+d.interesvencido  
 ,0 saldo30fin  
 ,count(c.codprestamo) nroptmos30ini  
 ,0 nroptmos30fin  
 from tcscartera c with(nolock)  
 inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo  
 left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=c.fecha  
 inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor  
 where c.fecha=@fecini--'20200930'  --------fecha al inicio de corte
 and c.cartera='ACTIVA' and c.codoficina not in('97','230','231')  
 and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
 and c.tiporeprog<>'REEST'  
 and case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end<>'HUERFANO'  
 group by c.codoficina,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end  
 ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end  
 union  
 select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor  
 ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador  
 ,c.codoficina  
 ,0 saldo30ini  
 ,sum(case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then d.saldocapital else 0 end) saldo30fin--+d.interesvigente+d.interesvencido  
 ,0 nroptmos30ini  
 ,count(c.codprestamo) nroptmos30fin  
 from tcscartera c with(nolock)  
 inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo  
 left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=c.fecha  
 inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor  
 where c.fecha=@fecha--'20201007'  --------fecha corte
 and c.cartera='ACTIVA' and c.codoficina not in('97','230','231')  
 and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
 and c.tiporeprog<>'REEST'  
 and case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end<>'HUERFANO'  
 group by c.codoficina,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end  
 ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end  
) a  
group by codasesor,coordinador,codoficina  
GO