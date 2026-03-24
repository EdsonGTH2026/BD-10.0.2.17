SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*---calculo para el reporte diario---*/                  
  --- Se optimiza sp 2023.10.19 ZCCU  
                   
CREATE procedure [dbo].[pcsFNMGReporteDiario]                          
as                          
                  
/*TABLA DE RESULTADOS OPERATIVOS */                  
set nocount on                    
declare @fecha smalldatetime  ---LA FECHA DE CORTE                  
select @fecha=fechaconsolidacion from vcsfechaconsolidacion    --'20230630'--              
                  
declare @fecini smalldatetime                  
set @fecini=cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)                   
                  
declare @fecante smalldatetime                  
set @fecante=cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1                   
                  
                  
--delete  FNMGConsolidado.dbo.tCaReporteDiario where fecha=@fecha  --comentar para ejecutar ----Se comenta para modificar la tabla                  
  
---------------------------VARIABLES DE TIEMPO----------            
--DECLARE @T1 DATETIME            
--DECLARE @T2 DATETIME            
--SET @T1=GETDATE()                
                  
/*CALCULO DE EPRC */                  
                  
---SALDO EPRC --- ptmos LIQUIDADOS                  
--declare @eprLiqui table(fecha smalldatetime,EPRliquidado money)      
CREATE TABLE #eprLiqui (fecha smalldatetime,EPRliquidado money)                 
insert into #eprLiqui                  
select @fecha fecha,isnull(sum(r.eprc_total),0) EPRliquidado                  
from tcspadroncarteradet c with(nolock)                  
inner join tCsCarteraReserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.Cancelacion-1                  
where (Cancelacion>= @fecini --> ptmos liquidados                   
and Cancelacion <= @fecha)                  
and c.codoficina not in('999','97','230','231')                  
                  
--SET @T2=GETDATE()            
--PRINT '1 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()             
                  
---SALDO EPRC ---- ptmos CASTIGADOS                  
--declare @eprCastigado table (fecha smalldatetime,EPRcastigo money)    
CREATE TABLE #eprCastigado (fecha smalldatetime,EPRcastigo money)               
insert into #eprCastigado                  
select @fecha id,isnull(sum(r.eprc_total),0) EPRcastigo                  
from tcspadroncarteradet c with(nolock)                  
inner join tCsCarteraReserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.PaseCastigado-1                  
where (PaseCastigado>=@fecini -->ptmos castigados en el periodo evaluado                  
and PaseCastigado<=@fecha )                  
and c.codoficina not in('999','97','230','231')                  
                  
                  
                  
--SET @T2=GETDATE()            
--PRINT '2 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
                 
---EPRC al dia de consulta y al inicio del mes---                  
--declare @eprc table (fecha smalldatetime,fech smalldatetime,eprc money)    
CREATE TABLE #eprc  (fecha smalldatetime,fech smalldatetime,eprc money)                 
insert into #eprc                  
select @fecha fecha,r.fecha fech,sum(r.eprc_total) eprc                  
from tCsCarteraReserva r with (nolock)                  
inner join tcscartera c with(nolock) on c.codprestamo=r.codprestamo and r.fecha=c.fecha                  
--where (r.fecha = @fecha --- FECHA DE CONSULTA                  
--or r.fecha=@fecante )-- fecha fin de mes anterior         
where r.fecha in (@fecha,@fecante)      
and c.codoficina not in('999','97','230','231')                  
group by r.fecha                  
  
--SET @T2=GETDATE()            
--PRINT '3 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()                   
                  
--declare @pcsEpr table  (fechacorte smalldatetime--,saldoEPRCFin money,saldoEPRCini money ,EPRCliqui money, EPRCcastigado money                  
--       ,GastoEPRC money)                     
--insert into @pcsEpr                      
CREATE TABLE #pcsEpr (fechacorte smalldatetime--,saldoEPRCFin money,saldoEPRCini money ,EPRCliqui money, EPRCcastigado money                  
                      ,GastoEPRC money)      
                     
insert into #pcsEpr                      
select @fecha fecha                  
--,sum(case when p.fech=@fecha then eprc else 0 end) saldoEPRCFin                  
--,sum(case when p.fech=@fecante then eprc else 0 end) saldoEPRCIni                  
--,(EPRliquidado)EPRCliquidado                  
--,(EPRcastigo)EPRCcastigo                   
,sum(case when p.fech=@fecha then eprc else 0 end)-sum(case when p.fech=@fecante then eprc else 0 end)                  
+EPRcastigo+EPRliquidado GastoEPRC                  
from #eprLiqui l   WITH(NOLOCK)               
left outer join #eprCastigado c WITH(NOLOCK)on l.fecha=c.fecha                  
left outer join #eprc p WITH(NOLOCK)on p.fecha=l.fecha                  
group by EPRcastigo,EPRliquidado                  
               
               
   
DROP TABLE #eprLiqui  
DROP TABLE #eprCastigado  
DROP TABLE #eprc              
--DROP TABLE #pcsEpr  
               
               
/*CALCULO DE INTERES*/                  
 --Gastos x intereses//comisiones y tarifas cobradas// ingresos por intereses                  
  
--SET @T2=GETDATE()            
--PRINT '4 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
                   
---Interes devengado Ahorro                    
 --declare @devAh table  (fecha smalldatetime,devengado money )      
CREATE TABLE #devAh(fecha smalldatetime,devengado money )               
insert into #devAh                  
select @fecha fecha ,sum(case when InteresCalculado<0 then 0                  
                             else case when fechavencimiento is null then InteresCalculado                  
                             else case when fecha<fechavencimiento then InteresCalculado else 0 end end end) devengado                  
from tcsahorros a with(nolock)                  
where a.fecha>=@fecini --> fecha de inicio mes                  
and a.fecha<=@fecha --> fecha de consulta                  
and a.codoficina not in('999','97','230','231')                   
  
--SET @T2=GETDATE()            
--PRINT '5 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()                  
                          
-----------Comisiones Cobradas y pagadas                    
CREATE TABLE #Cob  (fecha smalldatetime                  
       ,codprestamo varchar(25)                  
       ,interes money                  
       ,cargos money                  
       ,seguros money                  
       ,cargoReest money)                  
insert into #Cob                  
select fecha,codigocuenta                  
,montointerestran interes                  
,montocargos cargos                  
,MontoOtrosTran seguros                  
,montoinvetran                  
from tcstransacciondiaria with(nolock)                  
where fecha>=@fecini                  
and fecha<= @fecha                  
and codsistema='CA'   
and codoficina not in('97','231','230','999')    
and tipotransacnivel3 in(104,105)   
and extornado=0        
  
  
--SET @T2=GETDATE()            
--PRINT '6 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
    
---HLL se creo este indice para darle velocidad en la consulta mas adelante      
CREATE  INDEX ix_tempCob ON #Cob ([codprestamo]) WITH  FILLFACTOR = 80,  PAD_INDEX  ON [PRIMARY]               
                             
--declare @Ca table(codprestamo varchar(25),tiporeprog varchar(10),codfondo int)   
 CREATE TABLE  #Ca (codprestamo varchar(25),tiporeprog varchar(10),codfondo int)          
insert into #Ca                   
select p.codprestamo,c.tiporeprog,c.codfondo                  
from tcspadroncarteradet p with(nolock)                  
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo and c.codusuario=p.codusuario                  
where p.codprestamo in(select distinct codprestamo from #Cob with(nolock))               
and c.codoficina not in('97','231','230','999')                  
                  
CREATE TABLE #Co   ( fecha smalldatetime,                  
      cargos money,                  
      seguros money,                  
      cargoReest money)                  
insert into #Co                  
 select @fecha                  
,sum(cargos) cargos                  
,sum(seguros) seguros                                                 
,sum(case when c.codfondo=20 then t.cargoReest*.30                  
       when c.codfondo=21 then t.cargoReest*.25                  
    else t.cargoReest end) cargoReestPropio                  
from #Cob t with(nolock)              
inner join #Ca  c with(nolock) on t.codprestamo=c.codprestamo                  
                   
  
--SET @T2=GETDATE()            
--PRINT '7 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()                
 -------------------- Interes devengado Crédito          
                    
--declare @dev table(fecha smalldatetime,tiporeprog varchar(6),intDevTotal money)     
CREATE TABLE #dev (fecha smalldatetime,tiporeprog varchar(6),intDevTotal money)                    
insert into #dev                  
select @fecha fecha,c.TipoReprog                  
,sum(t.interesdevengado) intDevTotal                  
from tcscarteradet t with(nolock)                  
inner join tcscartera c with(nolock) on c.fecha=t.fecha and c.codprestamo=t.codprestamo                  
where c.fecha>=@fecini                   
and c.fecha<=@fecha      
and c.codoficina not in('97','231','999','230')   
and c.estado='VIGENTE' and c.NroDiasAtraso<=89                  
group by  c.TipoReprog        
                   
  
--SET @T2=GETDATE()            
--PRINT '7 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()                  
                   
--declare @pFin table (fecha smalldatetime,cargos money,seguros money,cargoReest money ,devengadoAh money,inteDevengado money)                  
--insert into @pFin                  
--exec pCs_cteraInteres @fecha   
  
CREATE TABLE #pFin (fecha smalldatetime,cargos money,seguros money,cargoReest money ,devengadoAh money,inteDevengado money)                  
insert into #pFin                  
select t.fecha,cargos,seguros,cargoReest,devengado,sum(intDevTotal)                  
from #Co t  WITH(NOLOCK)                
left outer join #devAh d WITH(NOLOCK) on d.fecha=t.fecha                  
left outer join #dev c WITH(NOLOCK)on c.fecha=t.fecha                  
group by t.fecha,cargos,seguros,cargoReest,devengado    
  
DROP TABLE #Co  
DROP TABLE #devAh   
--DROP TABLE #dev               
  
--SET @T2=GETDATE()            
--PRINT '8 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
              
/*------------------------------*/                  
--declare #base table    
CREATE TABLE #base(   fecha smalldatetime,periodo varchar(6),gastoEPRC money                  
      ,inteDevengado money,gastoxInteres money,comisionCobrada money    
      ,marAjustado money,cargos money,seguros money,cargoReest money    
      ,devengadoAh money)                  
insert into #base                      
select @fecha,dbo.fdufechaaperiodo(fechacorte) periodo                  
,gastoEPRC gastoEPRC                  
,inteDevengado inteDevengado                  
,devengadoAh gastoxInteres                  
,cargos+seguros+cargoReest comisionCobrada                  
,inteDevengado-devengadoAh-(gastoEPRC) marAjustado                  
,cargos,seguros,cargoReest,devengadoAh                  
from #pcsEpr e   with(nolock)                    
left outer join #pFin p with(nolock)  on p.fecha=e.fechacorte          
          
DROP TABLE   #pFin     
DROP TABLE   #pcsEpr       
          
          
--SET @T2=GETDATE()            
--PRINT '9 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()         
            
/*tabla 1 estado de operaciones*/                  
--declare #baseOperativa table     
CREATE TABLE  #baseOperativa(fecha smalldatetime,periodo varchar(8),InteDevengado money,GastoxInteres money,EPRC money,                  
       MargenAjustado money, Co_CobradaPagada money,seguros money, pagoTardio money,OtrosIngresos money,                  
       co_ctasDigital money, co_bancarias money,GastoEstimado money, NominaCentral money, NominaRed money,                  
       Gastos money, Otros money,ResultadoOp money,GastoTotal money)                  
insert into #baseOperativa                           
select @fecha fecha, isnull(b.periodo,0) periodo,isnull(b.inteDevengado ,0)InteDevengado ,isnull(b.gastoxInteres,0) GastoxInteres         
,isnull(b.gastoEPRC,0) EPRC,isnull(b.marAjustado,0) MargenAjustado ,isnull(b.comisionCobrada,0) Co_CobradaPagada         
,isnull(b.seguros,0) seguros ,isnull(b.cargos,0) pagoTardio ,isnull(b.cargoReest,0) OtrosIngresos ,                  
0 co_ctasDigital ,0 co_bancarias ,isnull(GastoEstimado ,0)GastoEstimado ,isnull(NominaCentral,0) NominaCentral         
,isnull(NominaRed,0) NominaRed , isnull(Gastos,0) Gastos ,isnull(Otros ,0)Otros         
,isnull(b.marAjustado,0)+isnull(b.comisionCobrada,0)-isnull(GastoEstimado,0) ResultadoOp                   
,isnull(b.inteDevengado,0)+isnull(b.comisionCobrada,0)-isnull(b.gastoxInteres,0)-isnull(b.gastoEPRC,0) GastoTotal                  
from #base b with(nolock)               
left outer join FNMGCONSOLIDADO.DBO.TCAPROYECCIONXPERIODO m with(nolock) on m.periodo=b.periodo                  
  
--SET @T2=GETDATE()            
--PRINT '10 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()  
              
/*SE AGREGA INTERES DEVENGADO VS INTERES COBRADO --CRÉDITO */                  
                  
--declare @intCo table (tiporeprog varchar(6),interes money)     
CREATE TABLE #intCo  (tiporeprog varchar(6),interes money)              
insert into #intCo                  
select tiporeprog,sum(interes)interes                  
from #Cob t with(nolock)                  
inner join #Ca c with(nolock)  on t.codprestamo=c.codprestamo                  
group by tiporeprog                  
                  
DROP TABLE #base              
DROP TABLE #Ca   
                  
--SET @T2=GETDATE()            
--PRINT '11 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()                  
                  
/*--------Tabla de int devengado vs int cobrado*/                  
--declare #interesDevengado table    
CREATE TABLE #interesDevengado (fecha smalldatetime,DevengadoRenov  money,DevengadoSinre money                  
                                ,intCobradoRenov money,intCobradoSinre money,interesCobrado money)                  
insert into #interesDevengado                  
select @fecha fecha                  
,sum(case when i.tiporeprog='RENOV' then isnull(intDevTotal,0) else 0 end) DevengadoRenov                   
,sum(case when i.tiporeprog='SINRE' then isnull(intDevTotal,0) else 0 end) DevengadoSinre                  
,sum(case when i.tiporeprog='RENOV' then isnull(interes,0) else 0 end) intCobradoRenov                   
,sum(case when i.tiporeprog='SINRE' then isnull(interes,0) else 0 end) intCobradoSinre                  
,sum(isnull(interes,0)) interesCobrado                  
from #intCo i WITH(NOLOCK)                                                     
left outer join #dev d WITH(NOLOCK) on i.tiporeprog=d.tiporeprog                  
         
DROP TABLE #dev   
DROP TABLE #intCo              
-----------------------------------------------------------------------------------------------        
--DROP TABLE #interesDevengado  
--drop table #Cob    
--DROP TABLE #baseOperativa    
-----------------------------------------------------------------------------------------------           
--SET @T2=GETDATE()            
--PRINT '12 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
                  
/*CAPTACION --DEVENGADO DE AHORRO*/          
create table #devahorro (fecha smalldatetime,Tipo varchar(15),saldoCapital money,devengado money)                  
insert into #devahorro                     
select a.fecha ,case when substring(a.codcuenta,5,1)='2' then 'DPF'                  
      else case when a.codproducto='111' then 'GARANTIA' else 'A LA VISTA' end                  
      end Tipo                  
,sum(SaldoCuenta) saldoCapital                  
,sum(case when InteresCalculado<0 then 0                  
     else case when fechavencimiento is null then InteresCalculado                  
     else case when fecha<fechavencimiento then InteresCalculado else 0 end end end) devengado                  
from tcsahorros a with(nolock)                  
where a.fecha>=@fecante                   
and a.fecha<=@fecha                   
and a.codoficina not in('97','231','999','230')                  
group by a.Fecha                   
,case when substring(a.codcuenta,5,1)='2' then 'DPF'                  
          else case when a.codproducto='111' then 'GARANTIA' else 'A LA VISTA' end                  
          end    
                          
--SET @T2=GETDATE()            
--PRINT '13 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
                                      
---HLL se creo este indice para darle velocidad en la consulta mas adelante      
CREATE  INDEX ix_tempdevahorro ON #devahorro ([fecha]) WITH  FILLFACTOR = 80,  PAD_INDEX  ON [PRIMARY]      
      
declare @tasa table  (fecha smalldatetime,tasaDiaria money,tasaDiaria2 money)                  
insert into @tasa                       
select fecha ,round(case when sum(case when Tipo='DPF' then saldocapital else 0 end)=0 then 0                   
                    else sum(case when Tipo in('DPF','A LA VISTA') then devengado else 0 end)/cast(sum(case when Tipo='DPF' then saldocapital else 0 end) as decimal)end*100,4) tasaDiaria                    
,round(sum(devengado)/cast(sum(saldocapital)as decimal)*100,4) tasaDiaria2                  
from #devahorro with(nolock)               
where fecha>=@fecini --> fecha inicio mes                  
and fecha<=@fecha --> fecha                  
group by fecha                  
                  
--SET @T2=GETDATE()            
--PRINT '14 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()                  
                  
--declare @ahorro table     
CREATE TABLE #ahorro (fecha smalldatetime, saldoDPF_Fin money,saldoGarantia_Fin money                  
       ,saldoVista_Fin money,saldoDPF_Ini money,saldoGarantia_Ini money  
       ,saldoVista_Ini money,Captacion_Fin money,Captacion_Ini money                  
       ,PlazoFijo_tasaAnual money,Cartera_tasaAnual money)                  
insert into #ahorro                  
select @fecha fecha                  
,sum(case when a.Fecha=@fecha and tipo='DPF' then saldocapital else 0 end)DPF_sFin                  
,sum(case when a.Fecha=@fecha and tipo='GARANTIA' then saldocapital else 0 end)Garantia_sFin                  
,sum(case when a.Fecha=@fecha and tipo='A LA VISTA' then saldocapital else 0 end)Vista_sFin                  
,sum(case when a.Fecha=@fecante and tipo='DPF' then saldocapital else 0 end)DPF_sIni                  
,sum(case when a.Fecha=@fecante and tipo='GARANTIA' then saldocapital else 0 end)Garantia_sIni                  
,sum(case when a.Fecha=@fecante and tipo='A LA VISTA' then saldocapital else 0 end)Vista_sIni                  
,sum(case when a.Fecha=@fecha  then saldocapital else 0 end)Captacion_sFin                  
,sum(case when a.Fecha=@fecante  then saldocapital else 0 end)Captacion_sIni                  
,0 tasaMensual1,0 tasaMensual2                  
from #devahorro a   with(nolock)   
               
--SET @T2=GETDATE()            
--PRINT '15 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
                  
update #ahorro                  
set PlazoFijo_tasaAnual=(select avg(tasaDiaria)*360 from @tasa)                  
,Cartera_tasaAnual=(select avg(tasaDiaria2)*360 from @tasa)                  
                  
---------                  
/*COBRANZA PROGRAMADA VS RECIBIDA*/                  
                  
/*COBRANZA PUNTUAL*/         
  
create table #ptmosCP (codprestamo varchar(25),codoficina varchar(4),nrodiasatraso int,secuenciacliente int,codproducto char(3),codasesor varchar(15))--          
insert into #ptmosCP          
select c.codprestamo,c.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,c.codasesor--d.ultimoasesor          
from tcscartera c with(nolock)          
inner join tcspadroncarteradet d with(nolock) on c.codprestamo=d.codprestamo          
where c.fecha=@fecha---1 --and c.codprestamo in (select codprestamo from #ptmosCP with(nolock))          
and c.codoficina not in('97','231','999','230')                    
and cartera='ACTIVA'       
         
insert into #ptmosCP          
select d.codprestamo,d.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,c.codasesor--,d.ultimoasesor          
from tcspadroncarteradet d with(nolock)          
left outer join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fechacorte          
where d.cancelacion>=@fecini and d.cancelacion<=@fecha          
and d.codoficina not in('97','231','999','230')                    
         
---optimizar campos necesarios zccu 2023.10.14      
create table #CUOCP(          
          codoficina varchar(4),          
          codprestamo varchar(25),          
          seccuota int,          
          montodevengado money,          
          montopagado money,          
          montocondonado money,          
          fechavencimiento smalldatetime,          
          fechapago smalldatetime,          
          estadocuota varchar(20))          
insert into #CUOCP          
select p.codoficina,cu.codprestamo,cu.seccuota          
,sum(cu.montodevengado) montodevengado          
,sum(cu.montopagado) montopagado          
,sum(cu.montocondonado) montocondonado          
,cu.fechavencimiento          
,max(cu.fechapagoconcepto) fechapago          
,cu.estadocuota          
from tcspadronplancuotas cu with(nolock)          
inner join #ptmosCP p with(nolock) on p.codprestamo=cu.codprestamo          
where cu.codprestamo in(select codprestamo from #ptmosCP)          
and cu.numeroplan=0          
and cu.seccuota>0         
and cu.codconcepto = 'CAPI'          
and cu.fechavencimiento>=@fecini and cu.fechavencimiento<=@fecha          
group by cu.codprestamo,cu.seccuota          
,cu.fechavencimiento          
,cu.estadocuota          
,p.codoficina          
       
       
       
create table #cobranzaPuntual (   fecha smalldatetime,    
          fechavencimiento smalldatetime,    
          region varchar(50)    
          ,atraso varchar (10),    
          programado_s money ,    
          monto_anticipado money    
          ,monto_puntual money,    
          momto_atrasado money,    
          capitalPagado money,  
          pagoparcial_s money)      
insert into  #cobranzaPuntual                      
select @fecha fecha,p.fechavencimiento, z.Nombre region          
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'          
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'          
            when ca.nrodiasatraso>=31 then '31+DM' else '' end atraso                
,sum(p.montodevengado) programado_s               
,sum(case when p.estadocuota='CANCELADO'and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) monto_anticipado          
, sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) monto_puntual          
, sum(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.montopagado else 0 end) momto_atrasado                
,sum(p.montopagado) capitalPagado          
,sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.montopagado else 0 end) pagoparcial_s          
from #CUOCP p with(nolock)          
inner join #ptmosCP ca with(nolock) on ca.codprestamo=p.codprestamo          
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina          
inner join tclzona z with(nolock) on z.zona=o.zona          
where o.zona not in('ZSC','ZCO')          
group by p.fechavencimiento,z.Nombre          
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'          
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'          
            when ca.nrodiasatraso>=31 then '31+DM' else '' end          
            ,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then 1          
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then 2          
            when ca.nrodiasatraso>=31 then 3 else 4 end          
order by z.Nombre          
          
drop table #ptmosCP          
drop table #CUOCP     
  
  
  
---------------------------------------------------------------------           
-----ZCCU Comentar campos no necesarios     
--create table #cobranzaPuntual (   fecha smalldatetime,    
--          fechavencimiento smalldatetime,    
--          region varchar(15)    
--          ,atraso varchar (10),    
--          programado_s money ,    
--          monto_anticipado money    
--          ,monto_puntual money,    
--          momto_atrasado money,    
--          capitalPagado money,pagoparcial_s money)      
--  ---,anticipado int---,puntual int ,---atrasado int,    
--  --rangoCiclo varchar(10)--,saldo money--,condonado money,--programado_n int,--,sucursal varchar(30)--creditosPagados int,    
--  --pagado_por money,sinpago_n int,sinpago_s money,--sinpago_por money,pagoparcial_n int    
--  --parcial_por money,total_n int,total_s money,--total_por money,orden int,promotor varchar(200)                
--insert into  #cobranzaPuntual                  
--exec [pCsCACobPuntualReOpera] @fecha,@fecini --- se ajusta para correr a fechas pasadas. ZCCU  // NO USAR EL SP, SE TRIPLICA EL TIEMPO DE EJCUCION              
                
                
--SET @T2=GETDATE()            
--PRINT '16 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
                
--declare @CobranzaPuntual2 table     
CREATE  TABLE #CobranzaPuntual2 (fecha smalldatetime                  
         ,Programado0a7_s money                  
         ,Programado8a30_s money                  
         ,Programado31m_s money                  
         ,CapPagado0a7_s money                  
         ,CapPagado8a30_s money                  
         ,CapPagado31m_s money                         
         ,puntual money                  
         ,Anticipado money                  
         ,Atrasado money                  
         ,pagoParcial money)                  
insert into #CobranzaPuntual2                  
select fecha fecha                  
,sum(case when atraso='0-7DM' then isnull(programado_s,0) else 0 end)Programado0a7_s                  
,sum(case when atraso='8-30DM' then isnull(programado_s,0) else 0 end)Programado8a30_s                  
,sum(case when atraso='31+DM' then isnull(programado_s,0) else 0 end)Programado31m_s                  
                  
,sum(case when atraso='0-7DM' then isnull(capitalPagado,0) else 0 end)CapPagado0a7_s                  
,sum(case when atraso='8-30DM' then isnull(capitalPagado,0) else 0 end)CapPagado8a30_s                  
,sum(case when atraso='31+DM' then isnull(capitalPagado,0) else 0 end)CapPagado31m_s                  
                  
,sum(isnull(monto_puntual,0))Puntual                  
,sum(isnull(monto_anticipado,0))Anticipado                  
,sum(isnull(momto_atrasado,0))Atrasado                  
,sum(isnull(pagoParcial_s,0))pagoParcial                  
from  #cobranzaPuntual with(nolock)                  
group by fecha                  
                  
-- SET @T2=GETDATE()            
--PRINT '17 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()                  
/*--INTERES TOTAL*/                  
                  
declare @fec_programado smalldatetime                  
set @fec_programado= @fecha                  
                  
declare @fec_consulta smalldatetime                  
set @fec_consulta= @fecini                    
                  
                  
/*PARTE 1 MUESTRA CREDITOS*/           
create table #ptmos (codprestamo varchar(25),codoficina varchar(4),nrodiasatraso int,tiporeprog varchar(10))                  
insert into #ptmos                  
          select distinct c.codprestamo,c.codoficina,c.nrodiasatraso,c.tiporeprog                  
          from tcscartera c with(nolock)                  
          inner join tcscartera a with(nolock) on a.codprestamo=c.codprestamo and a.fecha=c.fechadesembolso                  
          where c.fecha=@fec_programado       
          and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))        
          and c.codoficina not in('97','230','231','999')      
          and c.cartera='ACTIVA'                   
                          
                    
create table #ptmos_Liq (codprestamo varchar(25),codoficina varchar(4),nrodiasatraso int, tiporeprog varchar(10))                  
insert into #ptmos_Liq               
select p.codprestamo,p.codoficina,0 nrodiasatraso,p.tiporeprog                  
from tcspadroncarteradet p with(nolock)                  
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo                  
inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso                  
where p.cancelacion>=@fec_consulta and cancelacion<=@fec_programado and p.codoficina not in('97','230','231','999')                  
union                  
select p.codprestamo,p.codoficina,0 nrodiasatraso,p.tiporeprog                  
from tcspadroncarteradet p with(nolock)                  
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo                  
inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso                  
where p.pasecastigado>=@fec_consulta and p.pasecastigado<=@fec_programado and p.codoficina not in('97','230','231','999')                  
delete from #ptmos                  
where codprestamo in(select codprestamo from #ptmos_liq with(nolock))                  
----------------------------------------------------------------------      
  
--SET @T2=GETDATE()            
--PRINT '18 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
              
/*PARTE 2.1 TABLA DE PAGOS*/                  
--Para creditos vigentes   
CREATE TABLE #PograInte1(CODOFICINA VARCHAR(5),CODPRESTAMO VARCHAR(30),MONTODEVENGADO MONEY,MONTOPAGADO MONEY)  
INSERT into #PograInte1                  
select c.codoficina,p.codprestamo,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado                  
--into #PograInte1                  
from tcsplancuotas p with(nolock)                  
inner join #ptmos c with(nolock) on c.codprestamo=p.codprestamo                  
where p.fecha=@fec_programado       
and p.codoficina not in('97','230','231','999')       
and p.codprestamo in(select codprestamo from #ptmos)       
and p.seccuota>0      
and p.numeroplan=0                   
and p.codconcepto in('INTE')                  
and p.fechavencimiento>=@fec_consulta and p.fechavencimiento<=@fec_programado                             
group by c.codoficina,p.codprestamo   
                 
--SET @T2=GETDATE()            
--PRINT '19 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
                  
--Para creditos liquidados  
CREATE TABLE #PograInte2(CODOFICINA VARCHAR(5),CODPRESTAMO VARCHAR(30),MONTODEVENGADO MONEY,MONTOPAGADO MONEY)  
INSERT into #PograInte2                   
select c.codoficina,p.codprestamo,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado                  
--into #PograInte2                  
from tcspadronplancuotas p with(nolock)                  
inner join #ptmos_Liq c with(nolock) on c.codprestamo=p.codprestamo                  
where p.codoficina not in('97','230','231','999') and      
p.codprestamo in(select codprestamo from #ptmos_Liq) and      
p.numeroplan=0 and p.seccuota>0         
and p.codconcepto in('INTE')                 
and p.fechavencimiento>=@fec_consulta and p.fechavencimiento<=@fec_programado                  
group by c.codoficina,p.codprestamo                  
                  
-- SET @T2=GETDATE()            
--PRINT '20 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()    
                
/*PARTE 3 consulta INTERES*/                  
--declare @interes table    
CREATE TABLE #interes(fecha smalldatetime,inteProgramado_0a7 money,inteProgramado_8a30 money  
                      ,inteProgramado_31m money                  
                      ,intePagado_0a7 money,intePagado_8a30 money, intePagado_31m money )                  
insert into #interes                  
select @fec_programado fecha                  
,sum(case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then isnull(p.montodevengado,0)  else 0 end)inteProgramado_0a7                  
,sum(case when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then isnull(p.montodevengado,0) else 0 end)inteProgramado_8a30                  
,sum(case when ca.nrodiasatraso>=31 then isnull( p.montodevengado,0) else 0 end)inteProgramado_31m                  
,sum(case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then  isnull(p.montopagado ,0) else 0 end)intePagado_0a7                  
,sum(case when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then isnull(p.montopagado,0)  else 0 end)intePagado_8a30                  
,sum(case when ca.nrodiasatraso>=31 then isnull(p.montopagado,0)  else 0 end)intePagado_31m                  
from (                  
          select * from #PograInte1 with(nolock)                  
          union                  
          select * from #PograInte2 with(nolock)                  
) p       
inner join (                  
          select * from #ptmos with(nolock)                  
          union                  
          select * from #ptmos_Liq with(nolock)                  
) ca on ca.codprestamo=p.codprestamo                   
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina                  
inner join tclzona z with(nolock) on z.zona=o.zona                  
where o.zona not in('ZSC','ZCO')and ca.tiporeprog <>'REEST' and o.codoficina not in('97','230','231','999')                  
                  
drop table #Cob      
drop table #devahorro      
drop table #PograInte1              
drop table #PograInte2                  
drop table #ptmos                  
drop table #ptmos_Liq                  
drop table #cobranzaPuntual     
         
--SET @T2=GETDATE()            
--PRINT '21 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()                  
/*-------------CONSULTA FINAL---*/ 

delete  FNMGConsolidado.dbo.tCaReporteDiario where fecha=@fecha  --comentar para ejecutar ----Se comenta para modificar la tabla                         
insert into FNMGConsolidado.dbo.tCaReporteDiario   --comentar para ejecutar ----Se comenta para no insertar valores a la tabla                  
                  
select b.fecha,periodo                  
,InteDevengado ,GastoxInteres,EPRC,MargenAjustado ,Co_CobradaPagada,seguros,pagoTardio,OtrosIngresos,co_ctasDigital,co_bancarias                   
,GastoEstimado,NominaCentral,NominaRed,Gastos,Otros,ResultadoOp ,GastoTotal                                 
/*Interes devengado vs Cobrado*/                  
,isnull(DevengadoRenov,0) ,isnull(DevengadoSinre,0)        
,isnull(intCobradoRenov,0) ,isnull(intCobradoSinre,0),isnull(interesCobrado,0)        
/*Cobranza programada vs cobrada --interes*/                  
,isnull(Programado0a7_s,0) ,isnull(Programado8a30_s,0) ,isnull(Programado31m_s,0)                   
,isnull(CapPagado0a7_s,0) ,isnull(CapPagado8a30_s,0) ,isnull(CapPagado31m_s,0)                          
,isnull(puntual,0) monto_puntual ,isnull(Anticipado,0) monto_Anticipado,isnull(Atrasado,0)  monto_Atrasado        
,isnull(pagoParcial,0)  monto_pagoParcial                  
,isnull(inteProgramado_0a7,0) intProgramado0a7_s,isnull(inteProgramado_8a30,0) intProgramado8a30_s,isnull(inteProgramado_31m,0) intProgramado31m_s                  
,isnull(intePagado_0a7,0) intPagado0a7_s,isnull(intePagado_8a30,0)intPagado8a30_s,isnull(intePagado_31m,0)  intPagado31m_s                  
                  
/*Captacion */                  
,saldoDPF_Fin ,saldoDPF_Ini                   
,saldoVista_Fin,saldoVista_Ini                  
,saldoGarantia_Fin,saldoGarantia_Ini                  
,Captacion_Fin,Captacion_Ini                  
,PlazoFijo_tasaAnual ,Cartera_tasaAnual                   
                  
from #baseOperativa b with(nolock)              
left outer join #interesDevengado i with(nolock) on i.fecha=b.fecha                  
left outer join #ahorro a with(nolock)on a.fecha=b.fecha                  
left outer join #interes n with(nolock) on n.fecha=b.fecha                  
left outer join #CobranzaPuntual2 p with(nolock)on p.fecha=b.fecha                  
   
   
-- SET @T2=GETDATE()            
--PRINT '22 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
                
--drop table #Cob      
--drop table #devahorro      
--drop table #PograInte1              
--drop table #PograInte2                  
--drop table #ptmos                  
--drop table #ptmos_Liq                  
--drop table #cobranzaPuntual     
      
drop table #baseOperativa    
drop table #interesDevengado    
drop table #ahorro    
DROP TABLE #CobranzaPuntual2    
DROP TABLE #interes    
      
      
GO