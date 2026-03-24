SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBICosechas] 
as

--sp_helptext 
--exec [pCsBICosechas]


declare @fecini smalldatetime
set @fecini='20171231'

declare @fmesini smalldatetime
declare @fmesfin smalldatetime
set @fmesini= '20180101'  
select @fmesfin= fechaconsolidacion from vcsfechaconsolidacion 

select codprestamo,nrodiasatraso, saldocapital, estado
into #cai
from tcscartera with(nolock)
where fecha=@fecini 
and codoficina not in('230','231','97')
and cartera='ACTIVA' and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))

insert into #cai
select codprestamo,-1 nrodiasatraso,monto saldocapital, estadocalculado
from tcspadroncarteradet with(nolock)
where desembolso>=@fmesini and desembolso<=@fmesfin


select 
@fmesini fecini,@fmesfin fecfin,j.nomoficina sucursal
, z.nombre region

,(select primerdia from tclperiodo with(nolock) where primerdia <=pd.desembolso and ultimodia>=pd.desembolso) desembolso  


, i.estado estadoinicial
              
                ,pd.monto
            
                ,case when pd.estadocalculado='CANCELADO' and pd.cancelacion <= @fmesfin then 0 else d.saldocapital end saldocapitalFin

                ,case when i.nrodiasatraso = -1 then 'NUEVO' 
                               when i.nrodiasatraso<=14 then 'Vigente' 
                               when i.nrodiasatraso <= 29 then 'EnRiesgo'
                else 'VENCIDO' end estadoInicialOperativo
                
                ,case when c.nrodiasatraso is null then 'LIQUIDADO'              
                when c.estado ='CASTIGADO'then 'CASTIGADO'     
                               when c.nrodiasatraso <=14 then 'VIGENTE'
                               when c.nrodiasatraso <= 29 then 'ENRIESGO' 
                else 'VENCIDO' end estadoFinalOperativo
                ,case when c.nrodiasatraso <= 14 then c.saldocapital else 0 end Vigente
                ,case when c.nrodiasatraso >14 and c.nrodiasatraso <= 29 then c.saldocapital else 0 end EnRiesgo
                ,case when c.nrodiasatraso >= 30 and c.nrodiasatraso <=89 then c.saldocapital else 0 end Atrasado
                ,case when c.estado = 'CASTIGADO' then 0 when c.nrodiasatraso >89 then c.saldocapital else 0 end Vencido 
                ,case when c.estado = 'CASTIGADO' then c.saldocapital else 0 end Castigado 

                
from tcspadroncarteradet pd
left outer join tcscarteradet d with(nolock) on d.fecha=@fmesfin
and pd.codprestamo=d.codprestamo
left outer join tcscartera c with(nolock) on d.codprestamo=c.codprestamo and d.fecha=c.fecha
inner join #cai i with(nolock) on i.codprestamo=pd.codprestamo
inner join tcloficinas j with(nolock) on j.codoficina=pd.codoficina
inner join tclzona z on z.zona=j.zona
left outer join tcspadronclientes co on co.codusuario=pd.primerasesor
left outer join tcsempleados em on em.codusuario=pd.primerasesor
left outer join tcscartera ca with(nolock) on pd.codprestamo=ca.codprestamo and pd.fechacorte=ca.fecha
where pd.codoficina not in('230','231','97') 


drop table #cai



               
GO