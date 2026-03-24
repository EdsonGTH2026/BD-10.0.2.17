SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBIRenovacionesCosechas] 
as

--sp_helptext 
--exec [pCsBIRenovacionesCosechas]

declare @fecha smalldatetime
select @fecha= fechaconsolidacion from vcsfechaconsolidacion 

Select l.codprestamo, l.region, l.sucursal
,case when  l.secuenciacliente>= 10 then '10+'
when l.secuenciacliente >= 6 then '6-9' 
when l.secuenciacliente >= 4 then '4-6'
when l.secuenciacliente = 3 then '3'
when l.secuenciacliente = 2 then '2'
else '1' end Ciclo
, l.monto 
,(select primerdia from tclperiodo with(nolock) where primerdia<=l.cancelacion and ultimodia>=l.cancelacion) cosecha
,l.estado ,isnull(l.nuevomonto,0) MontoRenovado, l.nuevodesembolso
,case when l.estado <>'Renovado' and l.estado <> 'Reactivado' then 'Sin Renovar'  
when datediff(month,l.cancelacion,l.nuevodesembolso)>= 12 then 'R4'
when datediff(month,l.cancelacion,l.nuevodesembolso)>=6 then 'R3'
when datediff(month,l.cancelacion,l.nuevodesembolso)>=3 then 'R2'
when datediff(month,l.cancelacion,l.nuevodesembolso)>=1 then 'R1'
else 'R0' end Clasificacion
,'1' Cuenta
,case when (l.estado = 'Renovado' or l.estado ='Reactivado') then nuevomonto else 0 end MontoRenovado
,case when (l.estado = 'Renovado' or l.estado ='Reactivado') and datediff(month,l.cancelacion,l.nuevodesembolso)>= 12 then nuevomonto else 0 end R4
,case when (l.estado = 'Renovado' or l.estado ='Reactivado') and datediff(month,l.cancelacion,l.nuevodesembolso)>= 6 and datediff(month,l.cancelacion,nuevodesembolso)<12 then nuevomonto else 0 end R3
,case when (l.estado = 'Renovado' or l.estado ='Reactivado') and datediff(month,l.cancelacion,l.nuevodesembolso)>= 3 and datediff(month,l.cancelacion,nuevodesembolso)<6 then nuevomonto else 0 end R2
,case when (l.estado = 'Renovado' or l.estado ='Reactivado') and datediff(month,l.cancelacion,l.nuevodesembolso)>= 1 and datediff(month,l.cancelacion,nuevodesembolso)<3 then nuevomonto else 0 end R1
,case when l.estado = 'Renovado' and datediff(month,l.cancelacion,l.nuevodesembolso)= 0 then nuevomonto else 0 end R0
,case when l.estado <>'Renovado' and l.estado <> 'Reactivado' then l.monto else 0 end MontoSinRenovar
,case when (l.estado = 'Renovado' or l.estado ='Reactivado') then 1 else 0 end #Renovaciones
,case when (l.estado = 'Renovado' or l.estado ='Reactivado') and datediff(month,l.cancelacion,l.nuevodesembolso)>= 12 then 1 else 0 end #R4
,case when (l.estado = 'Renovado' or l.estado ='Reactivado') and datediff(month,l.cancelacion,l.nuevodesembolso)>= 6 and datediff(month,l.cancelacion,nuevodesembolso)<12 then 1 else 0 end #R3
,case when (l.estado = 'Renovado' or l.estado ='Reactivado') and datediff(month,l.cancelacion,l.nuevodesembolso)>= 3 and datediff(month,l.cancelacion,nuevodesembolso)<6 then 1 else 0 end #R2
,case when (l.estado = 'Renovado' or l.estado ='Reactivado') and datediff(month,l.cancelacion,l.nuevodesembolso)>= 1 and datediff(month,l.cancelacion,nuevodesembolso)<3 then 1 else 0 end #R1
,case when l.estado = 'Renovado' and datediff(month,l.cancelacion,l.nuevodesembolso)= 0 then 1 else 0 end #R0
,case when l.estado <> 'Renovado' and l.estado <> 'Reactivado' then 1 else 0 end #SinRenovar

,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else 'ACTIVO' end promotor
  
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO'
      when (pd.ultimoasesor<>pd.primerasesor) then 'TRANSICION'
 else  'ACTIVO' end tipoCartera 


From tCsACaLIQUI_RR l with(nolock) 
left outer join tcspadroncarteradet pd with(NoLock) on l.codprestamo=pd.codprestamo and l.codusuario=pd.codusuario
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=l.codpromotor and e.fecha=@fecha


where sucursal <>'Villa Hidalgo' and atrasomaximo<30 and region <> 'Zona Cerradas' and l.cancelacion <= @fecha

GO