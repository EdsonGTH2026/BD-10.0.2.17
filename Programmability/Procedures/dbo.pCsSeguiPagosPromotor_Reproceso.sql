SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsSeguiPagosPromotor_Reproceso]    @fechaini smalldatetime                         
AS                            
SET NOCOUNT ON                 
--   declare @fechaini smalldatetime              
--set @fechaini = '20241006'              
               
/*      
 -En NroDiasAtraso_Segui poner los días de atraso en la fecha actualiza,      
-Partir la cubeta d.16+ en d.16-21 y e.22+      
-Agregar el saldo capital inicial      
*/      
declare @fechainicial smalldatetime              
set @fechainicial = @fechaini              
              
--declare @fechaactual smalldatetime              
--select @fechaactual=fechaconsolidacion from vcsfechaconsolidacion              
--set @fechaactual = '20240524'              
              
              
declare @fechafin smalldatetime              
set @fechafin = dateadd(day,7,@fechainicial)-----------siguiente domingo              
              
select cs.codprestamo, cs.NroDiasAtraso, CodOficina, Fecha, CodAsesor,FechaVencimiento,proximoVencimiento      
,saldoCapital SaldoCapital_Ini              
into #Ptmos --select top 10*             
from tcscartera cs with(nolock)              
where cs.fecha = @fechainicial              
and CodOficina not in ('97','231','230','98','999')              
and cartera='ACTIVA'              
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))              
and NroDiasAtraso <= 30              
              
----DIA DE PAGO              
create table #cuofecs(codprestamo varchar(19),seccuota int,estadocuota varchar(20),fechavencimiento smalldatetime)                
insert into #cuofecs                
select codprestamo,seccuota,estadocuota,fechavencimiento                
from tCsPlanCuotas with(nolock)                
where seccuota>0 and numeroplan=0                
and codprestamo in (select codprestamo from #ptmos)              
and fecha=@fechainicial          -----------lunes                
group by codprestamo,seccuota,estadocuota,fechavencimiento                
              
              
                
create table #fpv(codprestamo varchar(19),fecha smalldatetime, dia varchar(10))                
insert into #fpv                
select codprestamo, fecha                
,case datepart(weekday,fecha)                 
 when 1 then 'Domingo'                
 when 2 then 'Lunes'                
 when 3 then 'Martes'                
 when 4 then 'Miercoles'                
 when 5 then 'Jueves'                
 when 6 then 'Viernes'                
 when 7 then 'Lunes'--'Sabado'                
 else 'ND' end dia--'DIA_DE_PAGO'                
from (                
 select codprestamo,min(fechavencimiento) fecha                
 from #cuofecs with(nolock)                
 where estadocuota<>'CANCELADO'  ---AND codprestamo='308-170-06-08-09837'              
 group by codprestamo                
) a                
                
---------------------------              
              
select *              
into #CuotasPtmos              
from tCsPlanCuotas p with (nolock)              
where codprestamo in (select codprestamo from #Ptmos)              
and fecha=@fechainicial ---'20240811'------------lunes              
--AND codprestamo='308-170-06-08-09837'              
              
select codprestamo, sum(MontoCuota) MontoCuota              
into #Cuotas              
from #CuotasPtmos p with (nolock)              
where codprestamo in (select codprestamo from #Ptmos)              
and fecha=@fechainicial -----------lunes              
and SecCuota = 1 and CodConcepto in ('CAPI','INTE','IVAIT','SDV')              
group by CodPrestamo              
              
select CodigoCuenta, sum(MontoTotalTran) MontoPagado --------pagado en la semana              
into #PagosSemana              
from tcstransacciondiaria t with(nolock)              
where CodigoCuenta in (select Codprestamo from #Ptmos)              
and codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0              
and Fecha > @fechainicial and Fecha <= @fechainicial---@fechafin              
group by CodigoCuenta              
              
select codprestamo, sum(MontoPagado) PagoAdelantado               
into #PagosAdelantados              
--from tcspadronplancuotas p with (nolock)              
from #CuotasPtmos p with (nolock)              
where codprestamo in (select codprestamo from #Ptmos)              
and fecha=@fechainicial -----------lunes              
and FechaVencimiento > @fechainicial and FechaVencimiento <= @fechafin              
and MontoPagado > 0              
group by codprestamo              
              
select p.CodPrestamo, MIN(p.secCuota) CuotaLejana              
into #CuotaLejana              
--from tcspadronplancuotas p with (nolock)              
from #CuotasPtmos p with (nolock)              
where codprestamo in (select codprestamo from #Ptmos)              
and fecha=@fechainicial -----------lunes              
and p.FechaVencimiento <= @fechainicial               
and p.MontoPagado < p.MontoDevengado              
and p.EstadoCuota = 'VENCIDO'              
group by p.CodPrestamo              
              
select c.CodPrestamo, p.MontoDevengado - p.MontoPagado MontoDeuda, p.SecCuota              
into #Deuda              
from #CuotaLejana c              
left outer join (select codprestamo, SecCuota, sum(montoDevengado) - sum(MontoCondonado) MontoDevengado, sum(MontoPagado) MontoPagado              
     from #CuotasPtmos p with (nolock)              
     where codprestamo in (select codprestamo from #Ptmos)              
     and fecha=@fechainicial -----------lunes              
     and FechaVencimiento <= @fechainicial               
     and MontoPagado < MontoDevengado              
     and EstadoCuota = 'VENCIDO'              
group by codprestamo, SecCuota) p on c.CodPrestamo = p.CodPrestamo and c.CuotaLejana = p.SecCuota              
order by c.CodPrestamo              
              
select codprestamo, sum(MontoDevengado - MontoPagado) DeudaSemana, sum(MontoDevengado) - sum(montoCondonado) DevengadoSemana, SecCuota              
into #DeudaSemana              
--from tcspadronplancuotas p with (nolock)              
--select *              
from #CuotasPtmos p with (nolock)              
where codprestamo in (select codprestamo from #Ptmos)              
and fecha=@fechainicial -----------lunes              
and FechaVencimiento > @fechainicial               
and FechaVencimiento <= @fechafin              
----and EstadoCuota <> 'CANCELADO'               
--AND codprestamo='308-170-06-08-09837'              
group by codprestamo, SecCuota              
              
select p.CodPrestamo, p.CodOficina,              
z.nombre Region, --add              
o.NomOficina Sucursal, --add              
--case when o.NomOficina = 'Tecamac' then 'PIRAMIDES' else o.NomOficina end Sucursal,              
case when z.nombre in ('Costa Chica','Costa Grande','Centro','Estado') then 'Centro'              
      when z.nombre in ('Sur tizimin','Sur progreso') then 'Sur'              
   when z.nombre in ('Tabasco - Chiapas','Veracruz Norte','Veracruz Sur') then 'Veracruz'              
   else z.nombre end Division,              
p.NroDiasAtraso, @fechainicial FechaConsulta,              
p.FechaVencimiento FechaVencimiento2, -------se agrega              
fpv.dia 'DIA_DE_PAGO'  ,-------se agrega              
cli.NombreCompleto,              
cdet.SecuenciaCliente Ciclo2,-------se agrega              
--cla.telefonomovil Telefono             
cli.telefonomovil Telefono2              
              
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
-----agregado              
--,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cla.nombre_coordinador end Promotor  --SE VERIFICAN LOS HUERFANOS              
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cli2.NombreCompleto end Promotor2  --SE VERIFICAN LOS HUERFANOS --------------como estaban el lunes              
,isnull(d.SecCuota,ds.SecCuota) SecCuota             
,ISNULL(P.SaldoCapital_Ini,0)SaldoCapital_Ini       
into #DatosFinales               
from #Ptmos p              
left outer join #Cuotas c on p.CodPrestamo=c.CodPrestamo              
left outer join #PagosAdelantados pa on p.CodPrestamo = pa.CodPrestamo              
left outer join #Deuda d on p.CodPrestamo = d.CodPrestamo              
left outer join #PagosSemana ps on p.CodPrestamo = ps.CodigoCuenta              
left outer join #DeudaSemana ds on p.codprestamo = ds.codprestamo              
--AGREGADO PARA QUERY PAGOS SEMANALES LUNES              
--left outer join tCsADatosCliCarteraActiva cla with(nolock) on cla.codprestamo=p.CodPrestamo              
left outer join tcloficinas o with(nolock) on o.codoficina=p.codoficina              
inner join tclzona z on z.zona=o.Zona               
left outer join tcsempleadosfecha e on e.codusuario=p.CodAsesor and e.fecha=@fechainicial --'20240820'--echaactual              
inner join tcspadroncarteradet cdet on cdet.codprestamo=p.CodPrestamo               
left outer join tcsPadronClientes cli on cli.codusuario=cdet.codusuario              
left outer join tcsPadronClientes cli2 on cli2.codusuario=p.codAsesor              
inner join #fpv fpv on fpv.codprestamo=p.CodPrestamo              
order by p.FechaVencimiento, z.Nombre, o.NomOficina, case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cli2.NombreCompleto end --, cl.Cliente, cl.secuenciacliente              
              
              
              
SELECT *               
----SE ASIGNA ESTATUS AL PAGO              
,CASE               
 WHEN PagoAdelantado >= PagoRequerido  THEN 'Pagado'              
 WHEN PagoAdelantado > 0 AND PagoAdelantado < PagoRequerido THEN 'Pago Parcial'               
 WHEN PagoAdelantado IS NULL OR PagoAdelantado=0 THEN 'Pendiente'               
END Estatus              
,CASE               
 WHEN NroDiasAtraso=0 THEN 'a.0'              
 WHEN NroDiasAtraso>1 AND NroDiasAtraso<8 THEN 'b.1-7'              
 WHEN NroDiasAtraso>=8 AND NroDiasAtraso<=15 THEN 'c.8-15'        
 WHEN NroDiasAtraso>=16 AND NroDiasAtraso<=21 THEN 'd.16-21'              
 ELSE 'e.22+'  END CubetaMoraInicial              
INTO #DatosFinales2              
FROM #DatosFinales WHERE PagoRequerido>0              
              
--select count (*) from  #DatosFinales2              
              
SELECT CodPrestamo, CodOficina, Region,              
--case when promotor2 in ('CRUZ GARCIA JUAN MANUEL','CRUZ GARCIA V JUAN MANUEL','MOLINA JIMENEZ MAYRA JAZMIN','MOLINA JIMENEZ V MAYRA JAZMIN','VILLANUEVA RAMIREZ PEDRO','VILLANUEVA RAMIREZ V PEDRO','HERNANDEZ DUCOING V ABRAHAM BENJAMIN'    
--, 'HERNANDEZ DUCOING ABRAHAM BENJAMIN') then 'VICTORIA'               
-- when promotor2 in ('CERON VIDAL ROBERTO EMMANUEL','MOJICA RUIZ JOSE ALBERTO', 'TADEO RICO EDGAR GUSTAVO') then 'CARLOS A. CARRILLO'              
-- else Sucursal end Sucursal      
Sucursal  Sucursal,      
Division, NroDiasAtraso, FechaConsulta,               
FechaVencimiento2, -------se agrega              
DIA_DE_PAGO  ,-------se agrega              
Ciclo2,-------se agrega              
NombreCompleto,              
Telefono2,             
PagoRequerido,               
PagoAdelantado, Pago, MontoCuota, DeudaCuotaLejana, DeudaSemanaActual,               
DevengadoSemana              
,REPLACE(Promotor2,' V ', ' ') Promotor,              
Estatus, CubetaMoraInicial, SecCuota,         
SaldoCapital_Ini       
FROM #DatosFinales2 WHERE PagoRequerido>0               
              
              
Drop Table #Ptmos              
Drop table #Cuotas              
Drop Table #PagosSemana              
drop table #PagosAdelantados              
drop table #CuotaLejana              
drop table #Deuda            
drop table #DeudaSemana              
drop table #DatosFinales              
drop table #DatosFinales2               
drop table #CuotasPtmos              
drop table #cuofecs              
drop table #fpv 
GO