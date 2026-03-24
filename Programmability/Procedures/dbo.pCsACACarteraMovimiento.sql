SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsACACarteraMovimiento]
as
set nocount on

declare @fcorte smalldatetime
--set @fcorte='20190731'
select @fcorte=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini=cast((dbo.fdufechaatexto(@fcorte,'AAAAMM')+'01') as smalldatetime) -1 --'20190731'

declare @fmesini smalldatetime
declare @fmesfin smalldatetime
set @fmesini= cast((dbo.fdufechaatexto(@fcorte,'AAAAMM')+'01') as smalldatetime)  --@fecini+1
set @fmesfin= @fcorte --@fecini+21

select codprestamo,nrodiasatraso, saldocapital, estado,codsolicitud,codoficina
into #cai
from tcscartera with(nolock)
where fecha=@fecini 
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and codoficina not in('230','231','97')
and cartera='ACTIVA' 

insert into #cai
select p.codprestamo,-1 nrodiasatraso,p.monto saldocapital, p.estadocalculado,c.codsolicitud,c.codoficina
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on p.fechacorte=c.fecha and p.codprestamo=c.codprestamo
where p.desembolso>=@fmesini and p.desembolso<=@fmesfin

select s.codsolicitud,s.codoficina,s.calificacion, s.calificapromotor, s.calificacioncapacidadpago
into #sol
from [10.0.2.14].finmas.dbo.tCaSolicitudproce s
inner join #cai ca on ca.codsolicitud=s.codsolicitud and ca.codoficina=s.codoficina

truncate table tCsACarteraMovimiento
insert into tCsACarteraMovimiento
select 
@fmesini fecini,@fmesfin fecfin,j.nomoficina sucursal, z.nombre region, pd.codprestamo,i.estado estadoinicial
       ,c.estado estadofechacorte
       ,pd.estadocalculado estadoactual,pd.cancelacion,pd.monto
       ,pd.desembolso, dbo.fdufechaaperiodo(pd.desembolso) cosecha
       ,i.nrodiasatraso nrodiasatraso_ini,c.nrodiasatraso nrodiasatraso_fin
       ,i.saldocapital capitalInicial
       ,case when pd.estadocalculado='CANCELADO' and pd.cancelacion <= @fcorte then 0 else d.saldocapital end saldocapitalFin
       , d.interesvigente intVigenteFin, d.interesvencido intVencFin, ca.CodFondo
       ,pd.SecuenciaCliente
       , case when i.nrodiasatraso = -1 then 'Nuevo' 
               when i.nrodiasatraso = 0 then '0dm'
               when i.nrodiasatraso <=7 then '1-7dm'
               when i.nrodiasatraso <=15 then '8-15dm'
               when i.nrodiasatraso <=30 then '16-30dm'
               when i.nrodiasatraso <=60 then '31-60dm'
               when i.nrodiasatraso <=89 then '61-89dm'
               when i.nrodiasatraso <=120 then '90-120dm'
               when i.nrodiasatraso <=150 then '121-150dm'
               when i.nrodiasatraso <=180 then '151-180dm'
               when i.nrodiasatraso <=210 then '181-210dm'
               when i.nrodiasatraso <=240 then '211-240dm'
               when i.nrodiasatraso >=241 then '241+dm'
       else '?' end cubetaInicial
       ,case 
             when c.nrodiasatraso is null then 'LIQUIDADO'     
             when c.nrodiasatraso = -1 then 'NUEVO' 
               when c.nrodiasatraso = 0 then '0dm'
               when c.nrodiasatraso <=7 then '1-7dm'
               when c.nrodiasatraso <=15 then '8-15dm'
               when c.nrodiasatraso <=30 then '16-30dm'
               when c.nrodiasatraso <=60 then '31-60dm'
               when c.nrodiasatraso <=89 then '61-89dm'
               when c.nrodiasatraso <=120 then '90-120dm'
               when c.nrodiasatraso <=150 then '121-150dm'
               when c.nrodiasatraso <=180 then '151-180dm'
               when c.nrodiasatraso <=210 then '181-210dm'
               when c.nrodiasatraso <=240 then '211-240dm'
               when c.nrodiasatraso >=241 then '241+dm'
       else '?' end cubetaFinal
       ,case when i.nrodiasatraso = -1 then 'NUEVO' 
             when i.nrodiasatraso<=30 then 'VIGENTE' 
       else 'VENCIDO' end estadoInicialOperativo
       
       ,case when c.nrodiasatraso is null then 'LIQUIDADO'  
             when c.nrodiasatraso <=30 then 'VIGENTE' 
       else 'VENCIDO' end estadoFinalOperativo
       ,case when pd.monto>=50000 then '50mil+'
             when pd.monto>=40000 then '40mil+'
             when pd.monto>=30000 then '30mil+'
             when pd.monto>=20000 then '20mil+'
             when pd.monto>=15000 then '15mil+'
             when pd.monto>=10000 then '10mil+'
             when pd.monto>=5000 then '5mil+'
             when pd.monto<50000 then '5mil-'
       else '?' end rangoMonto
       ,case when pd.secuenciacliente >= 10 then 'c10+' 
             when pd.secuenciacliente >= 7 then 'c7-9'
             when pd.secuenciacliente >= 4 then 'c4-6'
             when pd.secuenciacliente >= 2 then 'c2-3'
             when pd.secuenciacliente = 1 then 'c1'
       else '?' end rangoCiclo
       ,pr.calificacion, pr.calificapromotor, pr.calificacioncapacidadpago
--into tCsACarteraMovimiento
from tcspadroncarteradet pd
left outer join tcscarteradet d with(nolock) on d.fecha=@fcorte
and pd.codprestamo=d.codprestamo
left outer join tcscartera c with(nolock) on d.codprestamo=c.codprestamo and d.fecha=c.fecha
inner join #cai i with(nolock) on i.codprestamo=pd.codprestamo
inner join tcloficinas j with(nolock) on j.codoficina=pd.codoficina
inner join tclzona z on z.zona=j.zona
--LEFT OUTER JOIN [10.0.2.14].finmas.dbo.tCaSolicitudproce pr on pr.CodOficina=c.CodOficina and pr.CodSolicitud=c.CodSolicitud
LEFT OUTER JOIN #sol pr on pr.CodOficina=c.CodOficina and pr.CodSolicitud=c.CodSolicitud
left outer join tcscartera ca with(nolock) on pd.codprestamo=ca.codprestamo and pd.fechacorte=ca.fecha
--where pd.codprestamo='322-170-06-00-04409'

drop table #cai
drop table #sol
GO