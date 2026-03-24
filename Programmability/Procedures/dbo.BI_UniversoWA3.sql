SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext 'BI_UniversoWA3'

--sp_helptext BI_UniversoWA    
    
CREATE procedure [dbo].[BI_UniversoWA3] as        
        
declare @fecha smalldatetime        
select @fecha = fechaconsolidacion from vcsfechaconsolidacion        
        
--select codprestamo, (MontoCuota-MontoPagado) MontoCuota, FechaVencimiento        
--into #Cuotas        
--from tcspadronplancuotas p with (nolock)        
--WHERE CodConcepto in ('CAPI') AND FechaVencimiento=@fecha+1        
        
--select         
--z.Nombre region        
--,o.NomOficina sucursal        
--,t.codprestamo codprestamo        
--,c.CodSolicitud        
--,c.CodAsesor        
--,c.CodOficina        
--,d.SecuenciaCliente        
--,p.saldocapital + p.interesvigente + p.interesvencido + p.interesctaorden + p.moratoriovigente + p.moratoriovencido + p.moratorioctaorden + p.cargomora + p.otroscargos + p.impuestos Saldo_Pendiente        
--,c.nrodiasatraso        
--,p.MontoDesembolsoTotal credito_actual        
--,cl.nombres nombre        
--,'521' + p.telefonomovil phone        
--,p.Direccion + ' ' + p.NUMERO + ', Col.' + p.COLONIA + ', Mun.' + p.Municipio + ', ' + p.ESTADO Direccion        
--,p.nombre_coordinador Promotor        
--,p.TasaIntCorriente Tasa        
--,p.nrocuotas Plazo        
----,ROUND((case when c.NrodiasMax <= 3 then d.Monto*1.2        
----    else d.Monto*1.1 end) /100,0)*100 oferta_credito        
----,(ROUND((case when c.NrodiasMax <= 3 then d.Monto*1.2        
----    else d.Monto*1.1 end) /100,0)*100) - (p.saldocapital + p.interesvigente + p.interesvencido + p.interesctaorden + p.moratoriovigente + p.moratoriovencido + p.moratorioctaorden + p.cargomora + p.otroscargos + p.impuestos) monto_renovado        
----,ROUND((d.Monto*.95)/100,0)*100 oferta_5        
----,ROUND((d.Monto*.90)/100,0)*100 oferta_10        
----,Round((ROUND((case when c.NrodiasMax <= 3 then d.Monto*1.2        
----    else d.Monto*1.1 end) /100,0)*100*(case when (r.MontoGarLiq/p.MontoDesembolsoTotal) >= .1 then (r.MontoGarLiq/p.MontoDesembolsoTotal) else .1 end)) - r.MontoGarLiq,0) Garantia        
--,r.MontoGarLiq        
--,c.NroDiasMax        
--,(p.saldocapital + p.interesvigente + p.interesvencido + p.interesctaorden + p.moratoriovigente + p.moratoriovencido + p.moratorioctaorden + p.cargomora + p.otroscargos + p.impuestos) deuda2        
--,p.NombreCliente      
--,e.score_valor Score    
--from tcscarteradet t with(nolock)         
--inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo and c.fecha= @fecha        
--inner join tCsADatosCliCarteraActiva p with(nolock) on p.codusuario=c.CodUsuario        
--inner join  tcspadronclientes cl with(nolock) on c.CodUsuario = cl.CodUsuario        
--inner join tcloficinas o with(nolock) on o.codoficina = c.codoficina        
--inner join tclzona z on z.zona =o .zona        
--inner join tcspadroncarteradet d with(nolock) on d.CodPrestamo = c.CodPrestamo         
--inner join tcscarterareserva r with(nolock) on r.codprestamo = c.CodPrestamo and r.fecha = @fecha        
----inner join tcsaRenovaAnticipaPreCal ra with(nolock) on t.codprestamo = ra.codprestamo         
--inner join #Cuotas cu with(nolock) on cu.CodPrestamo=t.CodPrestamo        
--left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e WITH(NOLOCK) ON t.codprestamo=e.codprestamo    
--where        
--t.codoficina not in('97','231','230','999','98','469','474','489','468','474','480','485','484','481','330')     
--and t.fecha = @fecha        
--and c.cartera='ACTIVA'        
--and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))        
--and c.NroDiasAtraso = 0        
--and (t.saldoCapital-cu.MontoCuota)/c.MontoDesembolso <= .35        
--and t.SaldoCapital/c.MontoDesembolso > .35        
--and d.Monto <= 130000        
--and c.NrodiasMax <= 16        
--and d.SecuenciaCliente >= 3        
----and c.CodPrestamo = '301-170-06-06-08602'        
        
--UNION ALL        
        
select         
z.Nombre region        
,o.NomOficina sucursal        
,t.codprestamo codprestamo        
,c.CodSolicitud        
,c.CodAsesor        ,c.CodOficina        
,d.SecuenciaCliente        
,ra.deuda2 Saldo_Pendiente        
,c.nrodiasatraso        
,p.MontoDesembolsoTotal credito_actual        
,cl.nombres nombre       
,'521' + p.telefonomovil phone        
,p.Direccion + ' ' + p.NUMERO + ', Col.' + p.COLONIA + ', Mun.' + p.Municipio + ', ' + p.ESTADO Direccion        
,p.nombre_coordinador Promotor        
,p.TasaIntCorriente Tasa        
,p.nrocuotas Plazo        
--,ROUND((case when c.NrodiasMax <= 3 then d.Monto*1.2        
--    else d.Monto*1.1 end) /100,0)*100 oferta_credito        
--,(ROUND((case when c.NrodiasMax <= 3 then d.Monto*1.2        
--    else d.Monto*1.1 end) /100,0)*100) - ra.deuda2 monto_renovado        
--,ROUND((d.Monto*.95)/100,0)*100 oferta_5        
--,ROUND((d.Monto*.90)/100,0)*100 oferta_10        
--,Round((ROUND((case when c.NrodiasMax <= 3 then d.Monto*1.2        
--    else d.Monto*1.1 end) /100,0)*100*(case when (r.MontoGarLiq/p.MontoDesembolsoTotal) >= .1 then (r.MontoGarLiq/p.MontoDesembolsoTotal) else .1 end)) - r.MontoGarLiq,0) Garantia        
,r.MontoGarLiq        
,c.NroDiasMax        
,ra.deuda2        
,p.NombreCliente      
,isnull(e.score_valor,0) Score    
from tcscarteradet t with(nolock)         
inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo and c.fecha= @fecha        
inner join tCsADatosCliCarteraActiva p with(nolock) on p.codusuario=c.CodUsuario        
inner join  tcspadronclientes cl with(nolock) on c.CodUsuario = cl.CodUsuario        
inner join tcloficinas o with(nolock) on o.codoficina = c.codoficina        
inner join tclzona z on z.zona =o .zona        
inner join tcspadroncarteradet d with(nolock) on d.CodPrestamo = c.CodPrestamo         
inner join tcscarterareserva r with(nolock) on r.codprestamo = c.CodPrestamo and r.fecha = @fecha        
inner join tcsaRenovaAnticipaPreCal ra with(nolock) on t.codprestamo = ra.codprestamo     
left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e WITH(NOLOCK) ON t.codprestamo=e.codprestamo    
where         
t.codoficina not in('97','231','230','999','98','469','474','489','468','474','480','485','484','481','330')         
and t.fecha = @fecha        
and c.cartera='ACTIVA'        
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))        
and c.NroDiasAtraso = 0        
and t.saldoCapital/c.MontoDesembolso <= .35        
and d.Monto <= 130000        
and c.NrodiasMax <= 16        
and d.SecuenciaCliente >= 3        
and c.CodPrestamo = '1'    
        
--DROP TABLE #Cuotas        
GO