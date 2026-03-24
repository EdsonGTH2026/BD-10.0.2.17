SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBIMatrizDeter] 
as

--sp_helptext [pCsBIMatrizDeter]
--exec [pCsBIMatrizDeter]

declare @fecha smalldatetime  
select @fecha=fechaconsolidacion from vcsfechaconsolidacion  

 CREATE TABLE #Colocacion
 (periodo varchar(20)
 ,secuenciacliente integer
 ,colocacion money)
 
 Insert into #Colocacion
 
 select  dbo.fdufechaaperiodo(desembolso) periodo, secuenciacliente,sum(monto) colocacion from tcspadroncarteradet with(NoLock)
where desembolso >= '20180101' and desembolso <= @fecha and codoficina not in ('97','230','231','98')
group by dbo.fdufechaaperiodo(desembolso),secuenciacliente

 
 select dbo.fdufechaaperiodo(fechadesembolso) desembolso
,c.fecha
,datediff(month,c.fechadesembolso,c.fecha) nro
,sum(case when nrodiasatraso>=31 then saldocapital else 0 end) vencida
,d.secuenciacliente, cl.colocacion
from tcscartera c with(nolock)
inner join tcspadroncarteradet d with (nolock) on d.codprestamo=c.codprestamo 
inner join #Colocacion cl with(nolock) on dbo.fdufechaaperiodo(fechadesembolso)=cl.periodo and d.secuenciacliente=cl.secuenciacliente
where c.fecha in(select ultimodia from tclperiodo with(nolock) where ultimodia>='20180101' union select @fecha)
and c.codoficina not in(97,230,231)
and c.codprestamo not in(select codprestamo from tcscarteraalta with(nolock))
and c.fechadesembolso>='20180101' and c.fechadesembolso<=@fecha
group by c.fecha,dbo.fdufechaaperiodo(fechadesembolso), d.secuenciacliente
,datediff(month,c.fechadesembolso,c.fecha), cl.colocacion
 
 drop table #Colocacion

GO