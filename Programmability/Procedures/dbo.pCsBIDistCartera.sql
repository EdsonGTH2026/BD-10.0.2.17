SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBIDistCartera] 
as

--sp_helptext 
--exec [pCsBIDistCartera]



declare @fmesfin smalldatetime
select @fmesfin= fechaconsolidacion from vcsfechaconsolidacion 

declare @fecini smalldatetime
select @fecini=dateadd(day,(-1)*day(@fmesfin),@fmesfin)

declare @fmesini smalldatetime

select @fmesini= dateadd(day,(-1)*day(@fmesfin)+1,@fmesfin)


declare @fcorte smalldatetime
select @fcorte= fechaconsolidacion from vcsfechaconsolidacion

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
--@fmesini fecini,@fmesfin fecfin,
j.nomoficina Sucursal
, z.nombre Region--, pd.codprestamo--,pd.PrimerAsesor
--,co.NombreCompleto,em.ingreso
,case when datediff(month,em.ingreso,@fmesfin)>=12 then 'e.12+'
 when datediff(month,em.ingreso,@fmesfin)>=9 then 'd.9a12'
 when datediff(month,em.ingreso,@fmesfin)>=6 then 'c.6a9'
 when datediff(month,em.ingreso,@fmesfin)>=3 then 'b.3a6'
 else 'a.0a3' end Antiguedad
                --,c.estado estadoactual
                ,case when c.estado='CANCELADO' and pd.cancelacion <= @fcorte then 0 else d.saldocapital end Saldo
                ,case when c.nrodiasatraso is null then 'LIQUIDADO'              
                when c.estado ='CASTIGADO' then 'CASTIGADO'     
                               when c.nrodiasatraso >=90 then 'VENCIDO'
                               when c.nrodiasatraso >=30 then 'ATRASADO' 
                else 'VIGENTE' end Estado
                ,case
                      when pd.monto>=30000 then 'c.30mil+'
                    
                      when pd.monto>=15000 then 'b.15mil+'
                      when pd.monto<15000 then 'a.15mil-'
                else '?' end Monto
                ,case when pd.secuenciacliente >= 10 then 'e.c10+' 
                      when pd.secuenciacliente >= 7 then 'd.c7-9'
                      when pd.secuenciacliente >= 4 then 'c.c4-6'
                      when pd.secuenciacliente >= 2 then 'b.c2-3'
                      when pd.secuenciacliente = 1 then 'a.c1'
                else '?' end Ciclo
              
                ,case when pd.codproducto='170' then 'Productivo'
     when pd.codproducto='370' then 'Consumo'
     else 'Null' end Producto
     ,1 Cuenta
     ,case when c.nrodiasatraso >= 90 then d.saldocapital else 0 end 'VENCIDO'
     ,case when c.nrodiasatraso >= 30 and c.nrodiasatraso< 90 then d.saldocapital else 0 end 'ATRASADO'
     ,case when c.nrodiasatraso < 30 then d.saldocapital else 0 end 'VIGENTE'
from tcspadroncarteradet pd with(nolock)
left outer join tcscarteradet d with(nolock) on d.fecha=@fcorte
and pd.codprestamo=d.codprestamo
left outer join tcscartera c with(nolock) on d.codprestamo=c.codprestamo and d.fecha=c.fecha
inner join #cai i with(nolock) on i.codprestamo=pd.codprestamo
inner join tcloficinas j with(nolock) on j.codoficina=pd.codoficina
inner join tclzona z with(nolock) on z.zona=j.zona
left outer join tcspadronclientes co with(nolock) on co.codusuario=pd.ultimoasesor
left outer join tcsempleados em with(nolock) on em.codusuario=pd.ultimoasesor
left outer join tcscartera ca with(nolock) on pd.codprestamo=ca.codprestamo and pd.fechacorte=ca.fecha
where pd.codoficina not in('230','231','97') and isnull(c.nrodiasatraso,1000000) <> 1000000 
--and j.nomoficina='Atlixtac'


drop table #cai
GO