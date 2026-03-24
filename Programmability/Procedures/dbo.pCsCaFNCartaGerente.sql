SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
 /*Reporte de carta gerente-Sucursal*/  
    
CREATE procedure [dbo].[pCsCaFNCartaGerente]      
as    
set nocount on      
    
declare @fecha smalldatetime  ---LA FECHA DE CORTE    
select @fecha=fechaconsolidacion from vcsfechaconsolidacion    
     
declare @fecante smalldatetime    
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1  -- '20211130'--fecha de termino del mes anterior    
    
declare @fecini smalldatetime    
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes    
    
declare @fecosecha smalldatetime --A PARTIR DE QUE FECHA QUIERES EVALUAR COSECHAS    
set @fecosecha=dbo.fdufechaaperiodo(dateadd(month,-11,@fecha))+'01'    
    
declare @diacorte int  -- dia de corte  que le corresponde en este periodo //    
select @diacorte=day(@fecha)    
    
        
-------------------------VARIABLES DE TIEMPO----------        
--DECLARE @T1 DATETIME        
--DECLARE @T2 DATETIME        
--SET @T1=GETDATE()        
            
    
    
/*--1ra seccion CARTERA KPI*/    
declare @baseKpi table(fecha smalldatetime,Region varchar(30),nomoficina varchar(30),tiposucursal varchar(10),saldo0a30Ini money    
,saldo31a89Ini money,saldo90Ini money,saldocapIni money,saldo0a30Fin money,saldo31a89Fin money,saldo90Fin money ,saldocapFinal money    
,Imor16 money,Imor30 money,Imor90 money,metaCrecimiento money,CapitalProgramado money,totalCiclo1 money,totalCiclo2 money,totalCiclo3a4 money    
,totalCiclo5 money,capProgra1 money,capProgra2 money,capProgra3a4 money,capProgra5 money,CapitalPagado money,capPagado1 money,capPagado2 money    
,capPagado3a4 money,capPagado5 money,nroAnticipadas int,montoAnticipadas money,montPendReactivacion money,nroPendReactivacion money,RenovAntEnt money    
,ReactEnt money,RenovEnt money,nuevoEnt money,montoEntrega money,nuevosPtmos int,RenovPtmos int,ReAnticipaPtmos int,ReactivaPtmos int,totaPtmos int    
,promRenovColoca money,promRAnticipaColoca money,promReactivaColoca money,promNuevoColoca money,promTotalColoca money,porRenov money,porRAnticipa money    
,porReactiva money,porNuevo money,porTotal money,MontoRenov money,ptmosRenov int,montoLiqui money,ptmsLiqui int    
,portotalCobrza money,mes0a3 int,mes3a6 int,mes6a9 int,mes9a12 int,mes12 int,totSucursal int,vacante int    
/*se agregan mas columnas--solicitado por Miriam */    
,ptmosVigIni int,PtmosVigFin int,varClientes int ,montoColocacion money,porColocacion money)    
insert into @baseKpi    
select fecha, Region,nomoficina,tiposucursal,saldo0a30Ini,saldo31a89Ini,saldo90Ini,saldocapIni,saldo0a30Fin,saldo31a89Fin,saldo90Fin     
,saldocapFinal,Imor16,Imor30,Imor90,metaCrecimiento,CapitalProgramado,totalCiclo1,totalCiclo2,totalCiclo3a4,totalCiclo5,capProgra1    
,capProgra2,capProgra3a4,capProgra5,CapitalPagado,capPagado1,capPagado2,capPagado3a4,capPagado5,nroAnticipadas,montoAnticipadas     
,montPendReactivacion,nroPendReactivacion,RenovAntEnt,ReactEnt,RenovEnt,nuevoEnt,montoEntrega    
,nuevosPtmos,RenovPtmos,RAnticipaPtmos,ReactivaPtmos,totaPtmos --->nombre de columnas actualizadas    
,promRenovColoca,promRAnticipaColoca,promReactivaColoca,promNuevoColoca,promTotalColoca    
,porRenov,porRAnticipa,porReactiva,porNuevo,porTotal --->nombre de columnas actualizadas    
,MontoRenov,ptmosRenov,montoLiqui,ptmsLiqui    
,portotalCobrza,mes0a3,mes3a6,mes6a9,mes9a12,mes12,totSucursal,vacante    
,ptmosVigIni,PtmosVigFin,varClientes,montoColocacion,porColocacion    
from FNMGConsolidado.dbo.tCaReporteKPI with(nolock)  --consulta a la tabla kpi    
where fecha=@fecha and  nomoficina <>'zz'    
    
--SET @T2=GETDATE()        
--PRINT '1 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()        

    
/*------CRECIMIENTO MENSUAL*/    
declare @crecimientoMes table (nomoficina varchar(30) --Variacion de cartera    
     ,crecimiento0a30 money    
     ,crecimiento31a89 money    
     ,crecimiento90 money    
     ,crecimientoTotal money)       
insert into @crecimientoMes    
select s.nomoficina    
,sum(saldo0a30Fin)-sum(saldo0a30Ini) crecimiento0a30    
,sum(saldo31a89Fin)-sum(saldo31a89Ini) crecimiento31a89    
,sum(saldo90Fin)-sum(saldo90Ini) crecimiento90    
,sum(saldocapFinal)-sum(saldocapIni) crecimientoCap    
from @baseKpi s     
group by s.nomoficina    
    
/*---parametros del alcance de crecimiento*/    

--SET @T2=GETDATE()        
--PRINT '2--> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 

 
declare @indiceAlcance decimal(5,2)     
if(day(@fecha)<=30)    
begin    
  set @indiceAlcance = round(3.333333*@diacorte,0)     
end    
else     
begin    
  set @indiceAlcance=100     
end    
      
    
declare @estadoAlcance table (codoficina varchar(3),metacrecimiento money,porAlcance money,estadoAlcance varchar(8))    
insert into @estadoAlcance    
select o.codoficina,metacrecimiento     
,case when metacrecimiento=0 then 0 else crecimiento0a30/metacrecimiento*100 end porAlcance    
,case when (case when metacrecimiento=0 then 0 else crecimiento0a30/metacrecimiento*100 end)>=@indiceAlcance then 'OK'     
          when (case when metacrecimiento=0 then 0 else crecimiento0a30/metacrecimiento*100 end)>=@indiceAlcance*0.8 and (case when metacrecimiento=0 then 0 else crecimiento0a30/metacrecimiento*100 end)<@indiceAlcance then 'REGULAR'    
    else 'MAL' end estadoAlcance     
from @baseKpi m    
inner join tcloficinas o on o.nomoficina=m.nomoficina    
left outer join @crecimientoMes v  on v.nomoficina=m.nomoficina    
where   o.tipo<>'cerrada' and(o.codoficina<100 or o.codoficina>199)     
  
  
--SET @T2=GETDATE()        
--PRINT '3 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 


/*--- IMOR INICIAL*/    
    
declare @imorIni table (codoficina varchar(35)     
      ,Imor16ini money    
      ,Imor30ini money    
      ,Imor90ini money)    
insert into @imorIni          
select codoficina--,i.nomoficina    
,Imor16,Imor30,Imor90    
from FNMGConsolidado.dbo.tCaReporteKPI i with(nolock)  --consulta a la tabla kpi    
inner join tcloficinas o on o.nomoficina=i.nomoficina    
where fecha=@fecante and  i.nomoficina <>'zz' --fecha de fin mes anterior--'20220331'--    
and  o.tipo<>'cerrada' and(o.codoficina<100 or o.codoficina>199)and o.zona  not in( 'ZSC','ZCO')    
    
    
-- SET @T2=GETDATE()        
--PRINT '4 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 


/*-----IMOR FINAL */    
declare @imor table(codoficina varchar(3)    
     ,nomoficina varchar(30)    
     ,Imor16Ini money    
     ,Imor30Ini money    
     ,Imor90Ini money    
     ,descripImor16 varchar(8)    
     ,descripImor30 varchar(8)    
     ,descripImor90 varchar(8)    
     )    
insert into @imor         
select i.codoficina,b.nomoficina,Imor16Ini,Imor30Ini,Imor90Ini    
,case when Imor16>Imor16Ini then 'SUBE'    
      when Imor16=Imor16Ini then 'IGUAL'    
      when Imor16<Imor16Ini then 'BAJA' else'' end descripImor16    
,case when Imor30>Imor30Ini then 'SUBE'    
      when Imor30=Imor30Ini then 'IGUAL'    
      when Imor30<Imor30Ini then 'BAJA' else'' end descripImor30     
,case when Imor90>Imor90Ini then 'SUBE'    
      when Imor90=Imor90Ini then 'IGUAL'    
      when Imor90<Imor90Ini then 'BAJA' else'' end descripImor90      
from @imorIni i    
inner join tcloficinas o on o.codoficina=i.codoficina    
left outer join @baseKpi b on o.nomoficina=b.nomoficina    
    
    
--SET @T2=GETDATE()        
--PRINT '5 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()     
    
    
    
/*COBRANZA PUNTUAL*/     
--Se agregan campos, solicitados x Miriam    
    
create table #ptmos (codprestamo varchar(25),codoficina varchar(4),nrodiasatraso int,secuenciacliente int,codproducto char(3),codasesor varchar(15))--      
insert into #ptmos      
select c.codprestamo,c.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor      
from tcscartera c with(nolock)      
inner join tcspadroncarteradet d with(nolock) on c.codprestamo=d.codprestamo      
where c.fecha=@fecha    
and cartera='ACTIVA'      
insert into #ptmos      
select d.codprestamo,d.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor      
from tcspadroncarteradet d with(nolock)      
left outer join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fechacorte      
where d.cancelacion>=@fecini and d.cancelacion<=@fecha      
    
    
--SET @T2=GETDATE()        
--PRINT '6 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 


create table #CUO(      
          codoficina varchar(4),      
          codprestamo varchar(25),      
          seccuota int,      
          montodevengado money,      
          montopagado money,      
          fechavencimiento smalldatetime,      
          fechapago smalldatetime,      
          estadocuota varchar(20)      
)      
insert into #CUO      
select p.codoficina,cu.codprestamo,cu.seccuota      
,sum(cu.montodevengado) montodevengado      
,sum(cu.montopagado) montopagado      
,cu.fechavencimiento      
,max(cu.fechapagoconcepto) fechapago      
,cu.estadocuota  
---Fecha, CodOficina, CodPrestamo, CodUsuario, NumeroPlan, SecCuota, CodConcepto    
from tcspadronplancuotas cu with(nolock)      
inner join #ptmos p with(nolock) on p.codprestamo=cu.codprestamo      
where cu.codprestamo in(select codprestamo from #ptmos)      
and cu.numeroplan=0      
and cu.seccuota>0 
and cu.codconcepto = 'CAPI'          
and cu.fechavencimiento>=@fecini and cu.fechavencimiento<=@fecha      
group by cu.codprestamo,cu.seccuota      
,cu.fechavencimiento      
,cu.estadocuota      
,p.codoficina      
       
       
--SET @T2=GETDATE()        
--PRINT '7 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 
         
select @fecha fecha, z.Nombre region      
,o.nomoficina sucursal,o.codoficina codoficina     
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'      
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'      
            when ca.nrodiasatraso>=31 then '31+DM' else '' end atraso       
,case when ca.secuenciacliente>=5 then 'c.5+'      
         when ca.secuenciacliente>=3 then 'c.3-4'      
         when ca.secuenciacliente=2 then 'c.2'      
         else 'c.1' end rangoCiclo       
,sum(p.montodevengado) programado_s        
,sum(case when p.estadocuota='CANCELADO'and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) monto_anticipado      
, sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) monto_puntual     
into  #cobranzaP    
from #CUO p with(nolock)      
inner join #ptmos ca with(nolock) on ca.codprestamo=p.codprestamo      
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina      
inner join tclzona z with(nolock) on z.zona=o.zona      
inner join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor      
where o.zona not in('ZSC','ZCO')      
group by p.fechavencimiento,z.Nombre      
,o.codoficina      
,o.nomoficina      
,case when ca.secuenciacliente>=5 then 'c.5+'      
         when ca.secuenciacliente>=3 then 'c.3-4'      
         when ca.secuenciacliente=2 then 'c.2'      
         else 'c.1' end              
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'      
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'      
            when ca.nrodiasatraso>=31 then '31+DM' else '' end      
order by z.Nombre      
    
    
    
--SET @T2=GETDATE()        
--PRINT '8 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 


declare @pDiariaxSucursal table(region varchar(30),sucursal varchar(30),puntualc1 money,puntualC2 money,puntualC3_4 money    
      ,puntualC5m money,PuntualTotal money,programadoTotal money,programadoC1 money    
      ,programadoC2 money,programadoC3_4 money,programadoC5m money)    
insert into @pDiariaxSucursal    
select region,sucursal    
,sum(case when rangoCiclo='c.1' then (monto_puntual+monto_anticipado) else 0 end) puntualC1    
,sum(case when rangoCiclo='c.2' then (monto_puntual+monto_anticipado) else 0 end) puntualC2    
,sum(case when rangoCiclo in ('c.3-4') then (monto_puntual+monto_anticipado) else 0 end) puntualC3_4    
,sum(case when rangoCiclo in ('c.5+') then (monto_puntual+monto_anticipado) else 0 end) puntualC5m    
,sum(monto_puntual+monto_anticipado) puntualTotal    
,sum(programado_s) programadoTotal    
,sum(case when rangoCiclo='c.1' then (programado_s) else 0 end) programadoC1    
,sum(case when rangoCiclo='c.2' then (programado_s)  else 0 end) programadoC2    
,sum(case when rangoCiclo in ('c.3-4') then (programado_s) else 0 end)  programadoC3_4    
,sum(case when rangoCiclo in ('c.5+') then (programado_s) else 0 end)  programadoC5m    
from #cobranzaP with(nolock)    
where atraso in ('0-7DM','8-30DM')--> 0 a 30 dm    
group by region,sucursal    
    
--SET @T2=GETDATE()        
--PRINT '9 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 

declare @CobranzaPuntual table(fecha smalldatetime ,region varchar(30),sucursal varchar(30)    
        ,CobranzaPuntalC1 money    
        ,CobranzaPuntualC2 money    
        ,CobranzaPuntualC3_4 money    
        ,CobranzaPuntualC5m money    
        ,CobranzaPuntalTotal money)             
insert into @CobranzaPuntual    
select @fecha,region,sucursal    
,sum(case when programadoC1=0 then 0 else (puntualC1)/(programadoC1) end)*100 recPuntualC1    
,sum(case when programadoC2=0 then 0 else (puntualC2)/(programadoC2) end)*100 recPuntualC2    
,sum(case when programadoC3_4=0 then 0 else (puntualC3_4)/(programadoC3_4) end)*100 recPuntualC3_4    
,sum(case when programadoC5m=0 then 0 else (puntualC5m)/(programadoC5m) end)*100 recPuntualC5m    
,sum(case when programadoTotal=0 then 0 else (puntualTotal)/(programadoTotal) end)*100 recPuntualTotal    
from  @pDiariaxSucursal    
group by region,sucursal    
    
       
drop table #ptmos      
drop table #CUO      
drop table  #cobranzaP    
    
--SET @T2=GETDATE()        
--PRINT '10 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 
    
    
/*--------4ta seccion ---------- RENOVACION LQQRR  KPI*/    
    
declare @previo table(fecha smalldatetime,region varchar(30),nomoficina varchar(30),codoficina varchar(3)    
,tiposucursal varchar(10),saldo0a30Ini money,saldo31a89Ini money,saldo90Ini money,saldocapIni money    
,saldo0a30Fin money,saldo31a89Fin money,saldo90Fin money,saldocapFinal money,crecimiento0a30 money,crecimiento31a89 money    
,crecimiento90 money,crecimientoTotal money,metacrecimiento money, porAlcance money,estadoAlcance varchar(10)    
,Imor16Ini money ,Imor30Ini money,Imor90Ini money,Imor16 money,Imor30 money,Imor90 money,descripImor16 varchar(8),descripImor30 varchar(8)    
,descripImor90 varchar(8),capProgra1 money,capProgra2 money,capProgra3a4 money,capProgra5 money,CapitalProgramado money    
,capPagado1 money,capPagado2 money,capPagado3a4 money,capPagado5 money,CapitalPagado money,totalCiclo1 money,totalCiclo2 money    
,totalCiclo3a4 money,totalCiclo5 money,portotalCobrza money,RenovAntEnt money,ReactEnt money,RenovEnt money,nuevoEnt money,montoEntrega money    
,RenovPtmos int,ReAnticipaPtmos int,ReactivaPtmos int,nuevosPtmos int,totaPtmos int,promRenovColoca money,promRAnticipaColoca money    
,promReactivaColoca money,promNuevoColoca money,promTotalColoca money,porRenov money,porRAnticipa money,porReactiva money,porNuevo money    
,porTotal money,nroAnticipadas int,montoAnticipadas money,montPendReactivacion money,nroPendReactivacion int,MontoRenov money    
,ptmosRenov int,montoLiqui money,ptmsLiqui int,mes0a3 int,mes3a6 int,mes6a9 int,mes9a12 int,mes12 int,totSucursal int,vacante int    
,ptmosVigIni int,PtmosVigFin int,varClientes int ,montoColocacion money,porColocacion money    
,CobranzaPuntalC1 money,CobranzaPuntualC2 money,CobranzaPuntualC3_4 money,CobranzaPuntualC5m money,CobranzaPuntalTotal money)    
insert into @previo    
select     
b.fecha,b.region,b.nomoficina,a.codoficina,tiposucursal,saldo0a30Ini,saldo31a89Ini,saldo90Ini,saldocapIni    
,saldo0a30Fin,saldo31a89Fin,saldo90Fin,saldocapFinal,crecimiento0a30,crecimiento31a89,crecimiento90,crecimientoTotal    
,b.metacrecimiento , porAlcance,estadoAlcance    
,Imor16Ini,Imor30Ini,Imor90Ini,Imor16,Imor30,Imor90,descripImor16,descripImor30,descripImor90    
--cobranza    
,capProgra1,capProgra2,capProgra3a4,capProgra5,CapitalProgramado    
,capPagado1,capPagado2,capPagado3a4,capPagado5,CapitalPagado    
,totalCiclo1,totalCiclo2,totalCiclo3a4,totalCiclo5,portotalCobrza    
--colocacion    
,RenovAntEnt,ReactEnt,RenovEnt,nuevoEnt,montoEntrega --montos     
,RenovPtmos,ReAnticipaPtmos,ReactivaPtmos,nuevosPtmos,totaPtmos --#ptmos    
,promRenovColoca,promRAnticipaColoca,promReactivaColoca,promNuevoColoca,promTotalColoca --promedios    
,porRenov,porRAnticipa ,porReactiva,porNuevo,porTotal--porcentaje de recup    
--universo    
,nroAnticipadas,montoAnticipadas     
,montPendReactivacion,nroPendReactivacion    
--renovaciones    
,MontoRenov,ptmosRenov,montoLiqui,ptmsLiqui    
--Antiguedad    
,mes0a3,mes3a6,mes6a9,mes9a12,mes12,totSucursal,vacante    
--clientes           ----- nuevos campos solicitados     
,ptmosVigIni,PtmosVigFin,varClientes    
--referente de colocacion     
,montoColocacion,porColocacion    
--Cobranza Puntual  -->nuevos campos    
,CobranzaPuntalC1,CobranzaPuntualC2,CobranzaPuntualC3_4,CobranzaPuntualC5m ,CobranzaPuntalTotal     
from @baseKpi b    
left outer join @imor i on i.nomoficina=b.nomoficina    
left outer join @estadoAlcance a on i.codoficina=a.codoficina    
left outer join @crecimientoMes m on b.nomoficina=m.nomoficina    
left outer join @CobranzaPuntual p on p.sucursal=b.nomoficina    
    
delete from @previo where codoficina is null    
 
 
--SET @T2=GETDATE()        
--PRINT '11 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()    
/*----Saldo capital por cubetas*/    
    
declare  @CubetaIni table(codoficina varchar(4)    
     ,nomoficina varchar(30)    
     ,sal1a7ini money    
     ,sal8a15ini money    
     ,sal16a30ini money    
     ,sal31ini money    
     ,salTotalini money    
     ,ptmos1a7ini money    
     ,ptmos8a15ini money    
     ,ptmos16a30ini money    
     ,ptmos31ini money    
     ,ptmosTotalini money)       
insert into @CubetaIni     
select c.codoficina codoficina    
,o.nomoficina nomoficina    
--saldo     
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then c.saldocapital else 0 end)cubeta1a7    
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then c.saldocapital else 0 end)cubeta8a15    
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then c.saldocapital else 0 end)cubeta16a30    
,sum(case when c.nrodiasatraso>=31 then c.saldocapital else 0 end)cubeta31    
,sum(case when c.nrodiasatraso>=1 then c.saldocapital else 0 end)cubetaTotal    
--ptmos    
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then 1 else 0 end)ptmos1a7    
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then 1 else 0 end)ptmos8a15    
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then 1 else 0 end)ptmos16a30    
,sum(case when c.nrodiasatraso>=31 then 1 else 0 end)ptms31    
,sum(case when c.nrodiasatraso>=1 then 1 else 0 end)ptmosTotal    
from tcscartera c with(nolock)      
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina    
where c.fecha=@fecante --fecha fin de mes anterior    
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
and c.codoficina not in('97','231','230')    
and cartera='ACTIVA'     
group by c.codoficina,o.nomoficina    

--SET @T2=GETDATE()        
--PRINT '12 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()  
    
declare  @CubetaFin table(codoficina varchar(4)    
     ,nomoficina varchar(30)    
     ,sal1a7fin money    
     ,sal8a15fin money    
     ,sal16a30fin money    
     ,sal31fin money    
     ,salTotalfin money    
     ,ptmos1a7fin money    
     ,ptmos8a15fin money    
     ,ptmos16a30fin money    
     ,ptmos31fin money    
     ,ptmosTotalfin money    
    )       
insert into @CubetaFin     
select c.codoficina codoficina    
,o.nomoficina nomoficina    
--saldo     
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then c.saldocapital else 0 end)cubeta1a7    
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then c.saldocapital else 0 end)cubeta8a15    
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then c.saldocapital else 0 end)cubeta16a30    
,sum(case when c.nrodiasatraso>=31 then c.saldocapital else 0 end)cubeta31    
,sum(case when c.nrodiasatraso>=1 then c.saldocapital else 0 end)cubetaTotal    
--ptmos    
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then 1 else 0 end)ptmos1a7    
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then 1 else 0 end)ptmos8a15    
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then 1 else 0 end)ptmos16a30    
,sum(case when c.nrodiasatraso>=31 then 1 else 0 end)ptms31    
,sum(case when c.nrodiasatraso>=1 then 1 else 0 end)ptmosTotal  
from tcscartera c with(nolock)      
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina    
where c.fecha=@fecha --fecha corte     
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))   
and c.codoficina not in('97','231','230')      
and cartera='ACTIVA'    
group by c.codoficina,o.nomoficina    

--SET @T2=GETDATE()        
--PRINT '13 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 
 
declare @Cubetas table (codoficina varchar(3),nomoficina varchar(30),sal1a7ini money,sal8a15ini money,sal16a30ini money,sal31ini money    
,salTotalini money,ptmos1a7ini int,ptmos8a15ini int,ptmos16a30ini int,ptmos31ini int,ptmosTotalini int,sal1a7fin money,sal8a15fin money    
,sal16a30fin money,sal31fin money,salTotalfin money,ptmos1a7fin int,ptmos8a15fin int,ptmos16a30fin int,ptmos31fin int,ptmosTotalfin int    
,varSaldo1a7 money,varSaldo8a15 money,varSaldo16a30 money,varSaldo31 money,varSaldoTotal money,varPtmos1a7 money,varPtmos8a15 money    
,varPtmos16a30 money,varPtmos131 money,varPtmosTotal money,montoSinRenovacion money,nroSinRenovar int,promLiquida money,promRenovacion money    
,porRenovmonto money,porRenovptmos money,totalPromotor int,cartePromPromotor money)    
insert into @Cubetas    
select i.codoficina,i.nomoficina    
  -- cubetas de saldo    
,sal1a7ini,sal8a15ini,sal16a30ini,sal31ini ,salTotalini,ptmos1a7ini,ptmos8a15ini,ptmos16a30ini,ptmos31ini,ptmosTotalini    
,sal1a7fin,sal8a15fin ,sal16a30fin,sal31fin,salTotalfin,ptmos1a7fin,ptmos8a15fin,ptmos16a30fin,ptmos31fin,ptmosTotalfin    
,sal1a7fin- sal1a7ini varSaldo1a7    
,sal8a15fin -sal8a15ini  varSaldo8a15    
,sal16a30fin -sal16a30ini  varSaldo16a30    
,sal31fin -sal31ini   varSaldo31    
,salTotalfin -salTotalini varSaldoTotal    
,ptmos1a7fin -ptmos1a7ini varPtmos1a7    
,ptmos8a15fin -ptmos8a15ini varPtmos8a15    
,ptmos16a30fin -ptmos16a30ini varPtmos16a30    
,ptmos31fin -ptmos31ini varPtmos131    
,ptmosTotalfin -ptmosTotalini varPtmosTotal    
-- parte de Renovacion    
,montoLiqui-MontoRenov montoSinRenovacion    
,ptmsLiqui-ptmosRenov nroSinRenovar    
,case when ptmsLiqui=0 then 0 else montoLiqui/ptmsLiqui end promLiquida    
,case when ptmosRenov=0 then 0 else MontoRenov/ptmosRenov end promRenovacion    
,case when montoLiqui=0 then 0 else MontoRenov/montoLiqui *100 end porRenovmonto    
,case when ptmsLiqui=0 then 0 else round(ptmosRenov/cast(ptmsLiqui as decimal)*100,2) end porRenovptmos    
,totSucursal totalPromotor    
,case when totSucursal=0 then 0 else round(saldo0a30Fin/cast(totSucursal as decimal),2) end cartePromPromotor    
from @CubetaIni i    
left outer join @CubetaFin f on i.codoficina=f.codoficina    
left outer join @previo p on i.codoficina=p.codoficina    
    
delete from @cubetas where codoficina is null    

--SET @T2=GETDATE()        
--PRINT '14 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()    
------------------- DETERIORO    
 declare @ptmos table(codprestamo varchar(20))    
 insert into @ptmos    
 select distinct codprestamo    
 from tcspadroncarteradet pd with(nolock)    
 where codprestamo not in (select codprestamo from tCsCarteraAlta) 
 and pd.desembolso>=@fecosecha -- A PARTIR DE QUE FECHA COSECHAS SE EVALUA    
 and pd.desembolso<=@fecha       -- fecha corte   
 and pd.codoficina not in('97','230','231','98')     
     
declare @cos table (ID int IDENTITY(1,1),cosecha varchar(6))    
insert into @cos(cosecha)     
select DISTINCT dbo.fdufechaaperiodo(pd.desembolso)cosecha    
FROM tcspadroncarteradet pd with(nolock)    
where pd.codprestamo in(select codprestamo from @ptmos)    
order by dbo.fdufechaaperiodo(pd.desembolso)    
    
-- SET @T2=GETDATE()        
--PRINT '15 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 
/*--- Mostrar un periodo de  12 cosechas */    
    
declare @deterioro table (codoficina varchar(3)    
      ,montodesembolso money    
      ,recuperado money    
      ,cosecha varchar(6)    
      ,D0saldo money    
      ,D0a15saldo money    
      ,D16saldo money    
      ,Castigadosaldo money)    
insert into @deterioro         
select a.codoficina    
 ,sum(montodesembolso) montodesembolso    
 ,sum(montodesembolso)-sum(D0saldo)-sum(Castigadosaldo) recuperado    
 ,cosecha cosecha    
 ,sum(D0saldo)D0saldo    
 ,sum(D0a15saldo)D0a15saldo    
 ,sum(D16saldo)D16saldo    
 ,sum(Castigadosaldo)Castigadosaldo    
 from (    
   SELECT     
  o.codoficina ,    
  isnull(cd.saldocapital,0) saldocapital    
   ,pd.monto montodesembolso    
   ,dbo.fdufechaaperiodo(pd.Desembolso) cosecha      
 ,case when c.cartera= 'CASTIGADA' then   cd.saldocapital   else 0 end Castigadosaldo    
 ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=16 then  cd.saldocapital  else 0 end else 0 end D16saldo    
    ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=15  then  cd.saldocapital  else 0 end else 0 end D0a15saldo    
  ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=0 then cd.saldocapital  else 0 end else 0 end D0saldo    
   FROM tcspadroncarteradet pd with(nolock)    
   left outer join tcscarteradet cd with(nolock) on cd.fecha=@fecha and cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario    
   left outer join tCsCartera c with(nolock) on cd.fecha=c.fecha and cd.codprestamo=c.codprestamo   
   inner join tcloficinas o with(nolock) on o.codoficina=pd.codoficina    
   where pd.codprestamo in(select codprestamo from @ptmos)     
 ) a     
   group by a.codoficina,cosecha    
   order by codoficina,cosecha    

--SET @T2=GETDATE()        
--PRINT '16 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 
   
declare @idCosecha1 varchar(6)    
select @idCosecha1 =  cosecha from @cos  where id=1    
declare @idCosecha2 varchar(6)    
select @idCosecha2 =  cosecha from @cos  where id=2    
declare @idCosecha3 varchar(6)    
select @idCosecha3 =  cosecha from @cos  where id=3    
declare @idCosecha4 varchar(6)    
select @idCosecha4 =  cosecha from @cos  where id=4    
declare @idCosecha5 varchar(6)    
select @idCosecha5 =  cosecha from @cos  where id=5    
declare @idCosecha6 varchar(6)    
select @idCosecha6 =  cosecha from @cos  where id=6    
declare @idCosecha7 varchar(6)    
select @idCosecha7 =  cosecha from @cos  where id=7    
declare @idCosecha8 varchar(6)    
select @idCosecha8 =  cosecha from @cos  where id=8    
declare @idCosecha9 varchar(6)    
select @idCosecha9 =  cosecha from @cos  where id=9    
declare @idCosecha10 varchar(6)    
select @idCosecha10 =  cosecha from @cos  where id=10    
declare @idCosecha11 varchar(6)    
select @idCosecha11 =  cosecha from @cos  where id=11    
declare @idCosecha12 varchar(6)    
select @idCosecha12 =  cosecha from @cos  where id=12    
    
declare @det table (codoficina varchar(3)    
,colocacionC1 money,porRecuperaC1 money,Deterioro0a15C1 money,Deterioro16C1 money    
,colocacionC2 money,porRecuperaC2 money,Deterioro0a15C2 money,Deterioro16C2 money    
,colocacionC3 money,porRecuperaC3 money,Deterioro0a15C3 money,Deterioro16C3 money    
,colocacionC4 money,porRecuperaC4 money,Deterioro0a15C4 money,Deterioro16C4 money    
,colocacionC5 money,porRecuperaC5 money,Deterioro0a15C5 money,Deterioro16C5 money    
,colocacionC6 money,porRecuperaC6 money,Deterioro0a15C6 money,Deterioro16C6 money    
,colocacionC7 money,porRecuperaC7 money,Deterioro0a15C7 money,Deterioro16C7 money    
,colocacionC8 money,porRecuperaC8 money,Deterioro0a15C8 money,Deterioro16C8 money    
,colocacionC9 money,porRecuperaC9 money,Deterioro0a15C9 money,Deterioro16C9 money    
,colocacionC10 money,porRecuperaC10 money,Deterioro0a15C10 money,Deterioro16C10 money    
,colocacionC11 money,porRecuperaC11 money,Deterioro0a15C11 money,Deterioro16C11 money    
,colocacionC12 money,porRecuperaC12 money,Deterioro0a15C12 money,Deterioro16C12  money    
)     
insert into @det    
select     
      d.codoficina     
      --,@idCosecha1 cosecha1    
   ,sum(case when c.id=1 then montodesembolso else 0 end )colocacionC1     
   ,case when sum(case when c.id=1 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=1 then recuperado else 0 end )    
   /sum(case when c.id=1 then montodesembolso else 0 end )*100 end porRecuperaC1    
      ,case when sum(case when c.id=1 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=1 then(D0a15saldo) else 0 end)/sum(case when c.id=1 then montodesembolso else 0 end)*100 end Deterioro0a15C1    
      ,case when sum(case when c.id=1 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=1 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=1 then montodesembolso else 0 end)*100 end Deterioro16C1    
   --,@idCosecha2 cosecha2    
   ,sum(case when c.id=2 then montodesembolso else 0 end )colocacionC2    
    ,case when sum(case when c.id=2 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=2 then recuperado else 0 end )    
   /sum(case when c.id=2 then montodesembolso else 0 end )*100 end porRecuperaC2    
      ,case when sum(case when c.id=2 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=2 then(D0a15saldo) else 0 end)/sum(case when c.id=2 then montodesembolso else 0 end)*100 end Deterioro0a15C2    
      ,case when sum(case when c.id=2 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=2 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=2 then montodesembolso else 0 end)*100 end Deterioro16C2    
   --,@idCosecha3 cosecha3    
   ,sum(case when c.id=3 then montodesembolso else 0 end )colocacionC3     
   ,case when sum(case when c.id=3 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=3 then recuperado else 0 end )    
   /sum(case when c.id=3 then montodesembolso else 0 end )*100 end porRecuperaC3    
      ,case when sum(case when c.id=3 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=3 then(D0a15saldo) else 0 end)/sum(case when c.id=3 then montodesembolso else 0 end)*100 end Deterioro0a15C3    
      ,case when sum(case when c.id=3 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=3 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=3 then montodesembolso else 0 end)*100 end Deterioro16C3    
   --,@idCosecha4 cosecha4    
   ,sum(case when c.id=4 then montodesembolso else 0 end )colocacionC4     
   ,case when sum(case when c.id=4 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=4 then recuperado else 0 end )    
   /sum(case when c.id=4 then montodesembolso else 0 end )*100 end porRecuperaC4    
      ,case when sum(case when c.id=4 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=4 then(D0a15saldo) else 0 end)/sum(case when c.id=4 then montodesembolso else 0 end)*100 end Deterioro0a15C4    
      ,case when sum(case when c.id=4 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=4 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=4 then montodesembolso else 0 end)*100 end Deterioro16C4    
   --,@idCosecha5 cosecha5    
   ,sum(case when c.id=5 then montodesembolso else 0 end )colocacionC5     
   ,case when sum(case when c.id=5 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=5 then recuperado else 0 end )    
   /sum(case when c.id=5 then montodesembolso else 0 end )*100 end porRecuperaC5    
      ,case when sum(case when c.id=5 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=5 then(D0a15saldo) else 0 end)/sum(case when c.id=5 then montodesembolso else 0 end)*100 end Deterioro0a15C5    
      ,case when sum(case when c.id=5 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=5 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=5 then montodesembolso else 0 end)*100 end Deterioro16C5    
   --,@idCosecha6 cosecha6    
   ,sum(case when c.id=6 then montodesembolso else 0 end )colocacionC6     
   ,case when sum(case when c.id=6 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=6 then recuperado else 0 end )    
   /sum(case when c.id=6 then montodesembolso else 0 end )*100 end porRecuperaC6    
      ,case when sum(case when c.id=6 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=6 then(D0a15saldo) else 0 end)/sum(case when c.id=6 then montodesembolso else 0 end)*100 end Deterioro0a15C6    
      ,case when sum(case when c.id=6 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=6 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=6 then montodesembolso else 0 end)*100 end Deterioro16C6    
   --,@idCosecha7 cosecha7    
   ,sum(case when c.id=7 then montodesembolso else 0 end )colocacionC7     
   ,case when sum(case when c.id=7 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=7 then recuperado else 0 end )    
   /sum(case when c.id=7 then montodesembolso else 0 end )*100 end porRecuperaC7    
      ,case when sum(case when c.id=7 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=7 then(D0a15saldo) else 0 end)/sum(case when c.id=7 then montodesembolso else 0 end)*100 end Deterioro0a15C7    
      ,case when sum(case when c.id=7 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=7 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=7 then montodesembolso else 0 end)*100 end Deterioro16C7    
   --,@idCosecha8 cosecha8    
   ,sum(case when c.id=8 then montodesembolso else 0 end )colocacionC8     
   ,case when sum(case when c.id=8 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=8 then recuperado else 0 end )    
   /sum(case when c.id=8 then montodesembolso else 0 end )*100 end porRecuperaC8    
      ,case when sum(case when c.id=8 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=8 then(D0a15saldo) else 0 end)/sum(case when c.id=8 then montodesembolso else 0 end)*100 end Deterioro0a15C8    
      ,case when sum(case when c.id=8 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=8 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=8 then montodesembolso else 0 end)*100 end Deterioro16C8    
   --,@idCosecha9 cosecha9    
   ,sum(case when c.id=9 then montodesembolso else 0 end )colocacionC9     
   ,case when sum(case when c.id=9 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=9 then recuperado else 0 end )    
   /sum(case when c.id=9 then montodesembolso else 0 end )*100 end porRecuperaC9    
      ,case when sum(case when c.id=9 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=9 then(D0a15saldo) else 0 end)/sum(case when c.id=9 then montodesembolso else 0 end)*100 end Deterioro0a15C9    
      ,case when sum(case when c.id=9 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=9 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=9 then montodesembolso else 0 end)*100 end Deterioro16C9    
   --,@idCosecha10 cosecha10    
   ,sum(case when c.id=10 then montodesembolso else 0 end )colocacionC10    
   ,case when sum(case when c.id=10 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=10 then recuperado else 0 end )    
   /sum(case when c.id=10 then montodesembolso else 0 end )*100 end porRecuperaC10    
      ,case when sum(case when c.id=10 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=10 then(D0a15saldo)else 0 end)/sum(case when c.id=10 then montodesembolso else 0 end)*100 end Deterioro0a15C10    
      ,case when sum(case when c.id=10 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=10 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=10 then montodesembolso else 0 end)*100 end Deterioro16C10    
   --,@idCosecha11 cosecha11    
   ,sum(case when c.id=11 then montodesembolso else 0 end )colocacionC11    
   ,case when sum(case when c.id=11 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=11 then recuperado else 0 end )    
   /sum(case when c.id=11 then montodesembolso else 0 end )*100 end porRecuperaC11    
      ,case when sum(case when c.id=11 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=11 then(D0a15saldo) else 0 end)/sum(case when c.id=11 then montodesembolso else 0 end)*100 end Deterioro0a15C11    
      ,case when sum(case when c.id=11 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=11 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=11 then montodesembolso else 0 end)*100 end Deterioro16C11    
   --,@idCosecha12 cosecha12    
   ,sum(case when c.id=12 then montodesembolso else 0 end )colocacionC12     
   ,case when sum(case when c.id=12 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=12 then recuperado else 0 end )    
   /sum(case when c.id=12 then montodesembolso else 0 end )*100 end porRecuperaC12    
      ,case when sum(case when c.id=12 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=12 then(D0a15saldo)else 0 end)/sum(case when c.id=12 then montodesembolso else 0 end)*100 end Deterioro0a15C12    
      ,case when sum(case when c.id=12 then montodesembolso else 0 end )=0 then 0 else     
      sum(case when c.id=12 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=12 then montodesembolso else 0 end)*100 end Deterioro16C12    
    FROM @cos c     
    left outer join @deterioro d on d.cosecha=c.cosecha    
      group by d.codoficina    
    
delete from @det where codoficina is null    

--SET @T2=GETDATE()        
--PRINT '17 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()   
----------------------------CONSULTA FINAL    
delete FNMGConsolidado.dbo.tcacartagerente where fecha=@fecha    
insert into FNMGConsolidado.dbo.tcacartagerente    
    
select     
@fecha fecha,@diacorte DiaCorte,p.region,c.nomoficina,c.codoficina,tiposucursal,saldo0a30Ini,saldo31a89Ini,saldo90Ini,saldocapIni    
,saldo0a30Fin,saldo31a89Fin,saldo90Fin,saldocapFinal,crecimiento0a30,crecimiento31a89,crecimiento90,crecimientoTotal    
,metacrecimiento, porAlcance,estadoAlcance    
,Imor16Ini,Imor30Ini,Imor90Ini,Imor16,Imor30,Imor90,descripImor16,descripImor30,descripImor90    
--cobranza    
,capProgra1,capProgra2,capProgra3a4,capProgra5,CapitalProgramado CapProgramadoTotal    
,capPagado1,capPagado2,capPagado3a4,capPagado5,CapitalPagado CapPagadoTotal    
,totalCiclo1 porCobranzaC1,totalCiclo2 porCobranzaC2,totalCiclo3a4 porCobranzaC3a4,totalCiclo5 porCobranzaC5,portotalCobrza porCobranzaTotal    
--colocacion    
,RenovAntEnt moRenovAnt,ReactEnt moReact,RenovEnt moRenov,nuevoEnt moNuevo,montoEntrega moTotal --montos     
,RenovPtmos,ReAnticipaPtmos,ReactivaPtmos,nuevosPtmos,totaPtmos --#ptmos    
,promRenovColoca,promRAnticipaColoca,promReactivaColoca,promNuevoColoca,promTotalColoca --promedios    
,porRenov,porRAnticipa,porReactiva,porNuevo,porTotal--porcentaje de recup    
--universo disponible    
,nroAnticipadas ptmosAnticipadasU    
,montoAnticipadas  montoAnticipadasU    
,montPendReactivacion  montPendReactivacionU    
,nroPendReactivacion   nroPendReactivacionU    
,montoSinRenovacion montoRenovaU     
,nroSinRenovar    ptmosRenovaPendU    
,montoAnticipadas+montoSinRenovacion+montPendReactivacion montoTotalU    
,nroAnticipadas+nroPendReactivacion+nroSinRenovar ptmosTotalU    
 -- cubetas de saldo    
,sal1a7ini,sal8a15ini,sal16a30ini,sal31ini ,salTotalini,ptmos1a7ini,ptmos8a15ini,ptmos16a30ini,ptmos31ini,ptmosTotalini    
,sal1a7fin,sal8a15fin ,sal16a30fin,sal31fin,salTotalfin,ptmos1a7fin,ptmos8a15fin,ptmos16a30fin,ptmos31fin,ptmosTotalfin    
,varSaldo1a7,varSaldo8a15,varSaldo16a30,varSaldo31,varSaldoTotal,varPtmos1a7,varPtmos8a15,varPtmos16a30,varPtmos131,varPtmosTotal    
-- parte de Renovacion    
,MontoRenov,ptmosRenov,montoLiqui,ptmsLiqui,montoSinRenovacion    
,nroSinRenovar,promLiquida,promRenovacion,porRenovmonto,porRenovptmos    
--Deterioro    
,@idCosecha1 cosecha1 ,colocacionC1,porRecuperaC1,Deterioro0a15C1,Deterioro16C1    
,@idCosecha2 cosecha2,colocacionC2,porRecuperaC2,Deterioro0a15C2,Deterioro16C2    
,@idCosecha3 cosecha3,colocacionC3,porRecuperaC3,Deterioro0a15C3,Deterioro16C3    
,@idCosecha4 cosecha4,colocacionC4,porRecuperaC4,Deterioro0a15C4,Deterioro16C4    
,@idCosecha5 cosecha5,colocacionC5,porRecuperaC5,Deterioro0a15C5,Deterioro16C5    
,@idCosecha6 cosecha6,colocacionC6,porRecuperaC6,Deterioro0a15C6,Deterioro16C6    
,@idCosecha7 cosecha7,colocacionC7,porRecuperaC7,Deterioro0a15C7,Deterioro16C7    
,@idCosecha8 cosecha8,colocacionC8,porRecuperaC8,Deterioro0a15C8,Deterioro16C8    
,@idCosecha9 cosecha9,colocacionC9,porRecuperaC9,Deterioro0a15C9,Deterioro16C9    
,@idCosecha10 cosecha10,colocacionC10,porRecuperaC10,Deterioro0a15C10,Deterioro16C10    
,@idCosecha11 cosecha11,colocacionC11,porRecuperaC11,Deterioro0a15C11,Deterioro16C11    
,@idCosecha12 cosecha12,colocacionC12,porRecuperaC12,Deterioro0a15C12,Deterioro16C12     
,cartePromPromotor    
,case when totalPromotor =0 then '' when cartePromPromotor>=1200000 then '*Se necesitan más promotores'    
      when cartePromPromotor<800000 then '*Debe crecer la cartera por promotor' else '' end nota      
 --Antiguedad    
,mes0a3,mes3a6,mes6a9,mes9a12,mes12,totSucursal promotoresTotal,vacante     
--clientes      
,ptmosVigIni,PtmosVigFin,varClientes    --campos nuevos    
--referente de colocacion       
,montoColocacion,porColocacion         --campos nuevos    
--Cobranza Puntual    
,CobranzaPuntalC1,CobranzaPuntualC2,CobranzaPuntualC3_4,CobranzaPuntualC5m,CobranzaPuntalTotal,z.zona zona     
from @previo p     
inner join @det d on d.codoficina=p.codoficina    
inner  join @Cubetas c on p.codoficina=c.codoficina    
inner join tcloficinas o on p.codoficina=o.codoficina  
inner join tclzona z on z.zona=o.zona  
    
-- SET @T2=GETDATE()        
--PRINT '18 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 
GO