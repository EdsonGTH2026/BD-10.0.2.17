SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create PROCEDURE  [dbo].[pCsActualizaPagosProm_Reproceso]  @fechaini smalldatetime,@fechaAct smalldatetime                       
AS                          
SET NOCOUNT ON   


----------------------------------------------
declare @fechainicial smalldatetime
--select @fechaactual=fechaconsolidacion from vcsfechaconsolidacion
set @fechainicial = @fechaini---'20241117' -------------------- fecha de incio de semana: domingo

declare @fechaactual smalldatetime
--select @fechaactual=fechaconsolidacion from vcsfechaconsolidacion
set @fechaactual = @fechaAct  --- '20241122' ---------------------- fecha a actualizzar


declare @fechafin smalldatetime
set @fechafin = dateadd(day,7,@fechainicial)

select CodPrestamo CodPrestamoseg
,DIA_DE_PAGO DIA_DE_PAGOSeg 
,PagoRequerido_Ini PagoRequeridoSeg 
,PagoAdelantado_ini PagoAdelantadoSeg 
,Pago_ini PagoSeg 
,MontoCuota_ini MontoCuotaSeg 
,DeudaCuotaLejana_ini DeudaCuotaLejanaSeg 
,DeudaSemanaActual_ini DeudaSemanaActualSeg 
,DevengadoSemana_ini DevengadoSemanaSeg 
,PagoRequeridoDinamico_Segui PagoRequeridoDinamicoAnterior
into #SEGUIPtmos 
from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA  ------29
where EstatusActual_Segui not in ('Pagado')


select cs.codprestamo, cs.NroDiasAtraso, CodOficina, Fecha
into #Ptmos
from tcscartera cs with(nolock)
where cs.fecha = @fechainicial
and CodOficina not in ('97','231','230','98','999')
and cartera='ACTIVA'
and codprestamo in (select codprestamoseg from #SEGUIPtmos with(nolock))
and NroDiasAtraso <= 30

select *
into #CuotasPtmos
--from tcsPadronPlanCuotas  with(nolock)   --- siempre es a fecha de corte
from tcsPlanCuotas  with(nolock)   --- siempre es a fecha de corte
where codprestamo in (select codprestamo from #Ptmos)
and fecha=@fechaactual
-----------------------

--
--select segui.CodPrestamoSeg, MAX(p.FechaPagoConcepto)FechaPagoConcepto,SecCuotaSeg--,p.secCuota
--into #cuotasFechaPago
--from #seguimientoLunes segui 
--inner join #CuotasPtmos p on p.codprestamo=segui.CodPrestamoSeg and p.seccuota=segui.SecCuotaSeg
----where segui.CodPrestamoSeg='003-170-06-00-09336' --and p.FechaPagoConcepto=MAX(p.FechaPagoConcepto)
--group by segui.CodPrestamoSeg,SecCuotaSeg,p.secCuota

------------------------
select codprestamo, sum(MontoCuota) MontoCuota
into #Cuotas
from #CuotasPtmos p with (nolock)
where codprestamo in (select codprestamo from #Ptmos)
and SecCuota = 1 and CodConcepto in ('CAPI','INTE','IVAIT','SDV')
group by CodPrestamo

select CodigoCuenta, sum(MontoTotalTran) MontoPagado
into #PagosSemana
from tcstransacciondiaria t with(nolock)
where CodigoCuenta in (select Codprestamo from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA)
and codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0
and Fecha > @fechainicial and Fecha <=@fechaactual---@fechafin
group by CodigoCuenta

select codprestamo, sum(MontoPagado) PagoAdelantado 
into #PagosAdelantados
from #CuotasPtmos p with (nolock)
where codprestamo in (select codprestamo from #Ptmos)
and FechaVencimiento > @fechainicial and FechaVencimiento <= @fechafin
and MontoPagado > 0
group by codprestamo

select p.CodPrestamo, MIN(p.secCuota) CuotaLejana
into #CuotaLejana
from #CuotasPtmos p with (nolock)
where p.CodPrestamo in (select codprestamo from #Ptmos)
and p.FechaVencimiento <= @fechainicial 
and p.MontoPagado < p.MontoDevengado
and p.EstadoCuota = 'VENCIDO'
group by p.CodPrestamo

select c.CodPrestamo, p.MontoDevengado - p.MontoPagado MontoDeuda
into #Deuda
from #CuotaLejana c
left outer join (select codprestamo, SecCuota, sum(montoDevengado) - sum(MontoCondonado) MontoDevengado, sum(MontoPagado) MontoPagado
				from #CuotasPtmos p with (nolock)
				where codprestamo in (select codprestamo from #Ptmos)
				and FechaVencimiento <= @fechainicial 
				and MontoPagado < MontoDevengado
				and EstadoCuota = 'VENCIDO'
group by codprestamo, SecCuota) p on c.CodPrestamo = p.CodPrestamo and c.CuotaLejana = p.SecCuota
order by c.CodPrestamo

select codprestamo, sum(MontoDevengado - MontoPagado) DeudaSemana, sum(MontoDevengado) - sum(montoCondonado) DevengadoSemana
into #DeudaSemana
from #CuotasPtmos p with (nolock)
where FechaVencimiento > @fechainicial and FechaVencimiento <= @fechafin
--and EstadoCuota <> 'CANCELADO' 
and codprestamo in (select codprestamo from #Ptmos)
group by codprestamo

---------------numero de dias de atraso

select cs.codprestamo, isnull(cs.NroDiasAtraso,0)NroDiasAtraso
into #diasAtraso
from tcscartera cs with(nolock)
where cs.fecha = @fechaactual
--and CodOficina not in ('97','231','230','98','999')
--and cartera='ACTIVA'
and codprestamo in (select CodPrestamoseg from #SEGUIPtmos with(nolock))
--and NroDiasAtraso <= 30




select p.CodPrestamo CodPrestamo, p.CodOficina CodOficina, dias.NroDiasAtraso NroDiasAtraso
, @fechaactual fechaActual
,case when ds.codprestamo is null and d.MontoDeuda is null then 0 
      when ds.CodPrestamo is null and d.MontoDeuda > c.MontoCuota then d.MontoDeuda
	  when ds.CodPrestamo is null and c.MontoCuota >= d.MontoDeuda then c.MontoCuota
      when ds.DeudaSemana = 0 then pa.PagoAdelantado
	  when d.MontoDeuda is not null and d.MontoDeuda >= c.MontoCuota then d.MontoDeuda
	  when d.MontoDeuda is not null then c.MontoCuota
	  when pa.PagoAdelantado > 0 then ds.DevengadoSemana
	  else ds.DeudaSemana end PagoRequerido
,isnull(pa.PagoAdelantado,0) PagoAdelantado
,isnull(ps.MontoPagado,0) Pago
,c.MontoCuota
,isnull(d.MontoDeuda,0) DeudaCuotaLejana
,isnull(ds.DeudaSemana,0) DeudaSemanaActual
,isnull(ds.DevengadoSemana,0) DevengadoSemana
into #actualizaPagos
from #Ptmos p
left outer join #Cuotas c on p.CodPrestamo=c.CodPrestamo
left outer join #PagosAdelantados pa on p.CodPrestamo = pa.CodPrestamo
left outer join #Deuda d on p.CodPrestamo = d.CodPrestamo
left outer join #PagosSemana ps on p.CodPrestamo = ps.CodigoCuenta
left outer join #DeudaSemana ds on p.codprestamo = ds.codprestamo
left outer join #diasAtraso dias on dias.codprestamo=p.codprestamo

--select top 10* 
--from 

select sl.*,ap.*
,CASE 
	WHEN (sl.PagoAdelantadoSeg + ap.pago + 5) >= sl.PagoRequeridoDinamicoAnterior  THEN 'Pagado'
	WHEN sl.PagoAdelantadoSeg + ap.pago > 0 THEN 'Pago Parcial'	
	ELSE 'Pendiente' 
	--WHEN sl.PagoAdelantado IS NULL OR sl.PagoAdelantado=0 THEN 'Pendiente' 

END EstatusActual 
into #pre
from #SEGUIPtmos sl
inner join #actualizaPagos ap on ap.codprestamo=sl.codprestamoSeg


select PRE.*
,PAGO + PagoAdelantadoSeg PagoActual
,CASE WHEN (CASE WHEN EstatusActual = 'Pagado' THEN PagoRequeridoDinamicoAnterior  ELSE PagoRequerido END)=0 
	 THEN (PAGO + PagoAdelantadoSeg) 
	 ELSE (CASE WHEN EstatusActual = 'Pagado' THEN PagoRequeridoDinamicoAnterior  ELSE PagoRequerido END) 
	 END 'PagoRequeridoDinamico2'
into #BaseFinal
from #pre pre
--where codprestamo='004-170-06-03-06925'
--------------------------------------------comienzan los updates
--- Actualiza fechaActual
update FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA
set FechaActualiza = @fechaactual--'20240916'--
from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA   

---------------------------------------------------------actualiza pagos
update FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA
set PagoActual_Segui	 = isnull(ps.MontoPagado,0)+PagoAdelantado_Ini
--select COUNT(*)--a.codprestamoSEG,a.pago, isnull(ps.MontoPagado,0) Pago
from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA   a
inner join #PagosSemana ps on ps.CodigoCuenta= a.codprestamo



--Actualiza los casos que no han sido pagados
update FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA
set NroDiasAtraso_segui = base.NroDiasAtraso	
,FechaActualiza = base.fechaActual
,PagoRequerido_segui = base.PagoRequerido 
--,PagoAdelantado_segui = base.PagoAdelantado
--,Pago_segui 	      = base.Pago
,MontoCuota_segui 	  = base.MontoCuota
,DeudaCuotaLejana_segui = base.DeudaCuotaLejana 
,DeudaSemanaActual_segui = base.DeudaSemanaActual
,DevengadoSemana_segui 	 = base.DevengadoSemana
,EstatusActual_segui 	 = base.EstatusActual
,PagoRequeridoDinamico_segui = base.PagoRequeridoDinamico2
,PagoActual_segui    = base.PagoActual
--Select count(*)
from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA  a --where CodPrestamo='003-170-06-00-09472'
inner join #BaseFinal base on base.codprestamo= a.codprestamo


---------------------------actualiza estatus
update FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA
set EstatusActual_segui 	 = 'Pagado'
from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA   
where EstatusActual_segui not in ('Pagado')
and PagoActual_segui >= PagoRequeridoDinamico_segui


drop table #SEGUIPtmos
Drop Table #Ptmos
Drop table #Cuotas
Drop Table #PagosSemana
drop table #PagosAdelantados
drop table #CuotaLejana
drop table #Deuda
drop table #DeudaSemana
drop table #CuotasPtmos 
drop table #pre
--drop table #seguimientoLunes
drop table #actualizaPagos
drop table #diasAtraso
drop table #BaseFinal

GO