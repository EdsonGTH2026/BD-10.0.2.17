SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---- Cambio en el calculo de créditos liquidados y renovados 20221118  
---- Generar un sp para el calculo del KPI -- 20221123  
---- Optimizacion del sp 2023.10.17 ZCCU
  
CREATE procedure [dbo].[pCsCaGeneraReporteKPI]    
as  
set nocount on   
  
--Begin tran  
  
declare @fecha smalldatetime    
select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
  
declare @fecante smalldatetime  
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1  --fecha de termino del mes anterior  
  
declare @fecini smalldatetime  
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes  
  
declare @fecfin smalldatetime  
select @fecfin = ultimodia from tclperiodo where dbo.fdufechaaperiodo(ultimodia)=dbo.fdufechaaperiodo(@fecha)  
  
declare @feciniCosecha smalldatetime  
set @feciniCosecha=dbo.fdufechaaperiodo(dateadd(month,-3,@fecha))+'01'  
    
declare @fecfinCosecha smalldatetime  
set @fecfinCosecha=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes  
  
--select @fecha 'fecha'  
--select @fecini 'fecini'  
--select @fecante 'fecante'  
--select @fecfinCosecha  'fecfinCosecha'  
--select @feciniCosecha 'feciniCosecha'  
  
----------VARIABLES DE TIEMPO----------        
--DECLARE @T1 DATETIME        
--DECLARE @T2 DATETIME        
--SET @T1=GETDATE()        
        
/*------------STATUS DE CARTERA DEL MES ANTERIOR*/  
  
create table #saldoIni (codoficina varchar(4)   --cartera del mes anterior  
						 --,nomoficina varchar(30)  
						 --,region varchar(50)    
						 ,saldocapital money  
						 ,vigente0a30 money  
						 ,atraso31a89 money  
						 ,vencido90 money  
						 ,saldoCastigado money  
						 ,cartVencidaIni money  
						 ,PtmosVigIni int)     
insert into #saldoIni    
exec  pCsSalCarteraKPI @fecante   --- fecha de cierre de mes anterior / Optimizado el sp 2023.10.17 ZCCU 

---- 28 seg
--SET @T2=GETDATE()        
--PRINT '1.Cartera Inicial --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()      
  
--select * from #saldoIni with(nolock)  
--drop table #saldoIni  
  
/*---------- STATUS DE CARTERA A FECHA DE CONSULTA*/  

create table #saldoFin (codoficina varchar(4) --cartera actual  
						 --,nomoficina varchar(30)  
						 --,region varchar(50)    
						 ,saldocapfinal money  
						 ,vigente0a30fin money  
						 ,atraso31a89fin money  
						 ,ven90fin money  
						 ,saldoCastigado money  
						 ,cartVencidaFin money  
						 ,PtmosVigFin int )     
insert into #saldoFin 
exec  pCsSalCarteraKPI @fecha    --- fecha de consulta / Optimizado del sp 2023.10.17 ZCCU   

----5 seg
--SET @T2=GETDATE()        
--PRINT '2.Cartera Final --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()  
  
 --drop table #saldoFin 
 --drop table #saldoIni
  
/*--------------------VARIACION MENSUAL*/  
declare @varMes table (codoficina varchar(4) --Variacion de cartera  
						 --,nomoficina varchar(30)  
						 --,region varchar(50)    
						 ,var0a30 money  
						 ,var31a89 money  
						 ,var90 money  
						 ,varCapital money  
						 ,varCapVencido money  
						 ,varClientes int )     
insert into @varMes   
select a.codoficina--,s.nomoficina,s.region  
,isnull(sum(a.vigente0a30fin),0)-isnull(sum(s.vigente0a30),0) var0a30  
,isnull(sum(a.atraso31a89fin),0)-isnull(sum(s.atraso31a89) ,0)var31a89  
,isnull(sum(a.ven90fin),0)-isnull(sum(s.vencido90),0) var90  
,isnull(sum(a.saldocapfinal),0)-isnull(sum(s.saldocapital),0) varCapital  
,isnull(sum(a.cartVencidaFin),0)-isnull(sum(s.cartVencidaIni),0) varCapVencido  
,isnull(sum(a.PtmosVigFin),0)-isnull(sum(s.PtmosVigIni),0) varClientes  
from  #saldoFin a  with(nolock)  
left outer join #saldoIni s with(nolock) on  a.codoficina=s.codoficina  
group by a.codoficina --,s.nomoficina,s.region  
 
-- -- seg
--SET @T2=GETDATE()        
--PRINT '3.Variacion de Cartera --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 

--drop table #saldoFin 
--drop table #saldoIni

 
/*---------- @IMOR */  
declare @imorBase table (codoficina varchar(4)  
						  ,Imor1 money  
						  ,Imor8 money  
						  ,Imor16 money  
						  ,Imor30 money  
						  ,Imor31 money  
						  ,Imor90 money)  
insert into @imorBase        
select c.codoficina--,z.zona  
,(sum(case when c.nrodiasatraso>=1 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor1    
,(sum(case when c.nrodiasatraso>=8 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor8    
,(sum(case when c.nrodiasatraso>=16 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor16   
,(sum(case when c.nrodiasatraso>=30 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor30  
,(sum(case when c.nrodiasatraso>=31 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor31   
,(sum(case when c.nrodiasatraso>=90 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor90  
from tcscartera c with(nolock)  
inner join tcscarteradet i with(nolock) on c.fecha=i.fecha and c.codprestamo=i.codprestamo    
--inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
--inner join tclzona z with(nolock) on z.zona=o.zona  
where c.fecha=@fecha
and c.codprestamo not in(select codprestamo from tCsCarteraAlta with(nolock))
and c.codoficina not in('97','231','230','999')     
and  cartera='ACTIVA'   
group by c.codoficina  
 
 
-- -- 2 seg
--SET @T2=GETDATE()        
--PRINT '4.IMOR Cartera --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 

--drop table #saldoFin 
--drop table #saldoIni
 
 
declare @imorRegion table (zona varchar(4)  
						  ,Imor1 money  
						  ,Imor8 money  
						  ,Imor16 money  
						  ,Imor30 money  
						  ,Imor31 money  
						  ,Imor90 money)  
insert into @imorRegion  
select z.zona  
,(sum(case when c.nrodiasatraso>=1 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor1    
,(sum(case when c.nrodiasatraso>=8 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor8    
,(sum(case when c.nrodiasatraso>=16 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor16   
,(sum(case when c.nrodiasatraso>=30 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor30  
,(sum(case when c.nrodiasatraso>=31 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor31   
,(sum(case when c.nrodiasatraso>=90 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor90  
from tcscartera c with(nolock)  
inner join tcscarteradet i with(nolock) on c.fecha=i.fecha and c.codprestamo=i.codprestamo   
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina and o.tipo not in ('Cerrada') 
inner join tclzona z with(nolock) on z.zona=o.zona   
where c.fecha=@fecha 
and c.codprestamo not in(select codprestamo from tCsCarteraAlta with(nolock)) 
and  cartera='ACTIVA'  
--and o.tipo<>'Cerrada'  
group by z.zona  
  
-- -- 3 seg
--SET @T2=GETDATE()        
--PRINT '5.IMOR Region --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE() 

--drop table #saldoFin 
--drop table #saldoIni
 -------------------/*-------------- COBRANZA*/  
/*PARTE CREDITOS*/     ---ajuste zccu 2023.10.17
create table #ptmosCP (codprestamo varchar(25)    
					   ,codoficina varchar(4)    
					   ,nrodiasatraso int    
					   ,secuenciacliente int    
					   ,codproducto char(3)    
					   ,codasesor varchar(15)    
					   ,tiporeprog varchar(10))    
insert into #ptmosCP      
select c.codprestamo,c.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,c.codasesor,c.tiporeprog           
from tcscartera c with(nolock)      
inner join tcspadroncarteradet d with(nolock) on c.codprestamo=d.codprestamo      
where c.fecha=@fecha and cartera='ACTIVA'  and c.nrodiasatraso<=30      
  
insert into #ptmosCP      
select d.codprestamo,d.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor,c.tiporeprog        
from tcspadroncarteradet d with(nolock)      
left outer join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fechacorte      
where d.cancelacion>=@fecini and d.cancelacion<=@fecha      
                         
/*PARTE 2 TABLA DE PAGOS*/              
create table #CUO(codoficina varchar(4),      
				  codprestamo varchar(25),      
				  seccuota int,      
				  montodevengado money,      
				  montopagado money,      
				  fechavencimiento smalldatetime,      
				  fechapago smalldatetime,      
				  estadocuota varchar(20))      
insert into #CUO      
select p.codoficina,cu.codprestamo,cu.seccuota      
,sum(cu.montodevengado) montodevengado      
,sum(cu.montopagado) montopagado      
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
         
    
select @fecha fecha, z.Nombre region,z.zona      
,o.nomoficina sucursal,o.codoficina codoficina , ca.codasesor     
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'      
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'      
            when ca.nrodiasatraso>=31 then '31+DM' else '' end atraso       
,case when ca.secuenciacliente>=5 then 'c.5+'      
         when ca.secuenciacliente>=3 then 'c.3-4'      
         when ca.secuenciacliente=2 then 'c.2'      
         else 'c.1' end rangoCiclo     
,ca.tiporeprog      
,sum(p.montodevengado) programado_s       
,sum(case when p.estadocuota='CANCELADO'and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) monto_anticipado      
, sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) monto_puntual     
, sum(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.montopagado else 0 end) momto_atrasado      
,count(p.codprestamo) - count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) sinpago_n      
into  #cobranzaP    
from #CUO p with(nolock)      
inner join #ptmosCP ca with(nolock) on ca.codprestamo=p.codprestamo      
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina      
inner join tclzona z with(nolock) on z.zona=o.zona      
inner join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor      
where o.zona not in('ZSC','ZCO')      
group by p.fechavencimiento,z.Nombre ,z.zona,o.codoficina,o.nomoficina ,ca.codasesor     
,case when ca.secuenciacliente>=5 then 'c.5+'      
         when ca.secuenciacliente>=3 then 'c.3-4'      
         when ca.secuenciacliente=2 then 'c.2'      
         else 'c.1' end              
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'      
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'      
            when ca.nrodiasatraso>=31 then '31+DM' else '' end      
,ca.tiporeprog      
order by z.Nombre     
          
       
          
/*PARTE 3 --CONSULTA FINAL */          
create table #Basecobrza(codoficina varchar(4)  
						  ,progra_antCobrza money  
						  ,pag_antCobrza money  
						  ,progra_OrgCobrza money  
						  ,pag_orgCobrza  money  
						  ,Programado_S  money  
						  ,Pagado_S money  
						  ,progra_Cobrza5 money  
						  ,pag_Cobrza5 money  
						  ,progra_Cobrza3a4  money  
						  ,pag_Cobrza3a4  money  
						  ,progra_Cobrza2  money  
						  ,pag_Cobrza2  money  
						  ,progra_Cobrza1  money  
						  ,pag_Cobrza1  money  
						  ,pagP_1  int  
						  ,pagP_2  int  
						  ,pagP_3a4 int )  
insert into #Basecobrza            
select codoficina codoficina          
 ------------VALORES DE COBRANZA CLASIFICADA POR ANTICIPADA Y ORGANICA          
,sum(case when tiporeprog='RENOV' then programado_s else 0 end) progra_antCobrza                
,sum(case when tiporeprog='RENOV' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_antCobrza                 
,sum(case when tiporeprog='SINRE' then programado_s else 0 end) progra_OrgCobrza             
,sum(case when tiporeprog='SINRE' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_orgCobrza                 
---VALORES DE COBRANZA TOTAL          
,sum(programado_s) Programado_S            
,sum(monto_anticipado+monto_puntual+momto_atrasado) Pagado_S                         
--COBRANZA  ANTI. Y ORGANICA x CICLOS          
,sum(case when rangoCiclo in ('c.5+') then (programado_s) else 0 end)  progra_Cobrza5    
,sum(case when rangoCiclo in ('c.5+') then (monto_anticipado+monto_puntual+momto_atrasado) else 0 end) pag_Cobrza5               
,sum(case when rangoCiclo in ('c.3-4') then (programado_s) else 0 end) progra_Cobrza3a4  --CICLO 3 a 4         
,sum(case when rangoCiclo in ('c.3-4') then (monto_anticipado+monto_puntual+momto_atrasado) else 0 end)  pag_Cobrza3a4        
,sum(case when rangoCiclo='c.2' then (programado_s)  else 0 end) progra_Cobrza2    --CICLO 2        
,sum(case when rangoCiclo='c.2' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_Cobrza2                
,sum(case when rangoCiclo='c.1' then (programado_s) else 0 end) progra_Cobrza1   --CICLO 1          
,sum(case when rangoCiclo='c.1' then (monto_anticipado+monto_puntual+momto_atrasado) else 0 end) pag_Cobrza1                
--- contar sin pago -- pago pendiente       
,sum(case when rangoCiclo='c.1' then sinpago_n else 0 end) pagP_1    
,sum(case when rangoCiclo='c.2' then sinpago_n else 0 end) pagP_2    
,sum(case when rangoCiclo in ('c.3-4')  then sinpago_n else 0 end ) pagP_3a4    
    
from #cobranzaP with(nolock)    
where atraso in ('0-7DM','8-30DM')--> 0 a 30 dm    
group by codoficina    
    
    
drop table #ptmosCP      
drop table #CUO      
drop table  #cobranzaP    

--create table #Basecobrza(codoficina varchar(4)  ---------------comentar la parte del sp x que se duplica el tiempo-- 2023.10.17 ZCCU 
--						  ,progra_antCobrza money  
--						  ,pag_antCobrza money  
--						  ,progra_OrgCobrza money  
--						  ,pag_orgCobrza  money  
--						  ,Programado_S  money  
--						  ,Pagado_S money  
--						  ,progra_Cobrza5 money  
--						  ,pag_Cobrza5 money  
--						  ,progra_Cobrza3a4  money  
--						  ,pag_Cobrza3a4  money  
--						  ,progra_Cobrza2  money  
--						  ,pag_Cobrza2  money  
--						  ,progra_Cobrza1  money  
--						  ,pag_Cobrza1  money  
--						  ,pagP_1  int  
--						  ,pagP_2  int  
--						  ,pagP_3a4 int )  
--insert into #Basecobrza  
--exec pCsCobranza_kpi  @fecha --'20231016'---- / Optimizado el sp 2023.10.17 ZCCU  
 
 
 
--  -- 35 seg
--SET @T2=GETDATE()        
--PRINT '6.Cobranza --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()

--drop table #saldoFin 
--drop table #saldoIni
--drop table #Basecobrza

 
/*--------------------------------------- Capital Cobrado total y por ciclos*/  
declare  @capCobrado table (  codoficina varchar(25)  
							  --,nomoficina varchar(30)  
							  ,cap_cobrza money  
							  ,Cap_cobrza5 money  
							  ,Cap_cobrza3a4 money  
							  ,Cap_cobrza2 money  
							  ,Cap_cobrza1 money)  
insert into @capCobrado  
select p.codoficina--,o.nomoficina  
,sum(t.montocapitaltran) capital  
,sum(case when p.secuenciacliente>=5 then t.montocapitaltran else 0 end)Cap_cobrza5  
,sum(case when p.secuenciacliente>=3 and p.secuenciacliente<=4then t.montocapitaltran else 0 end)Cap_cobrza3a4  
,sum(case when p.secuenciacliente=2 then t.montocapitaltran else 0 end)Cap_cobrza2  
,sum(case when p.secuenciacliente=1 then t.montocapitaltran else 0 end)Cap_cobrza1  
from tcstransacciondiaria t with(nolock)  
inner join  tcspadroncarteradet p with(nolock) on p.codprestamo=t.codigocuenta   
--inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo and c.codusuario=p.codusuario  
--inner join tcloficinas o on o.codoficina=p.codoficina  
where t.fecha>=@fecini and t.fecha<=@fecha--'20211215'--  
and t.codsistema='CA'  
and t.codoficina not in('97','231','230','999')  
and t.tipotransacnivel3 in(104,105) and t.extornado=0 
group by p.codoficina--,o.nomoficina  
  
--  -- 3 seg
--SET @T2=GETDATE()        
--PRINT '7.Capital Cobrado --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()

--drop table #saldoFin 
--drop table #saldoIni
--drop table #Basecobrza
  
  
  
--select * from @capCobrado  
  
/*------------ANTICIPADAS */  
  
--select *  
--into tcsaRenovaAnticipaPreCal_03022022   
--from tcsaRenovaAnticipaPreCal  
  
  
declare @Anticipadas table(codoficina varchar(3)  
                           ,nroAnticipadas int  
                           ,montoAnticipadas money )  
insert into @Anticipadas  
select codoficina,count(codprestamo)nroAnticipada ,sum(montodisponibleRenovacion)anticipaMonto  
from tcsaRenovaAnticipaPreCal  with(nolock)   -----OJO cambiar en produccion  
group by codoficina  
   
   
--SET @T2=GETDATE()        
--PRINT '8.Anticipadas --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()


/* COLOCACIÓN OK ---*/  
  
declare @liqreno table(codprestamo varchar(30)  
      ,desembolso smalldatetime  
      ,codusuario varchar(15)  
      ,cancelacion smalldatetime)  
insert into @liqreno  
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion  
--select top 10*  
from tcspadroncarteradet p with(nolock)  
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso  
where p.desembolso>=@fecini --------fecha de inicio de mes  
and p.desembolso<=@fecha -----------fecha de consulta  
and p.codoficina not in('97','231','230','999')    
group by p.codprestamo,p.desembolso,p.codusuario  
having max(a.cancelacion) is not null  
  
--SET @T2=GETDATE()        
--PRINT '8.Liqui y Renovaciones --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()


  
declare @colocacionMontos table(codoficina varchar(30)  
								  ,RenovAntDisper money  
								  ,ReactivacionDisper money  
								  ,RenovDisper money  
								  ,nuevoDisper money  
								  ,montoDispersion money  
								  ,RenovAntEnt money  
								  ,ReactEnt money  
								  ,RenovEnt money  
								  ,nuevoEnt money  
								  ,montoEntrega money  
								  ,#RenovPtmos int  
								  ,#RAnticipaPtmos int  
								  ,#ReactivaPtmos  int  
								  ,#nuevosPtmos  int  
								  ,#totaPtmos int  
								  )  
insert into @colocacionMontos  
select p.codoficina  
------------------------ colocacion Dispersion -- monto  
,sum(case when p.TipoReprog='RENOV' then (case when s.montodesembolsoreal is NULL   
   then p.monto else s.montodesembolsoreal end) else 0 end )RenovAntDisper  
,sum(case when p.TipoReprog='RENOV' then 0 ELSE  
                case when l.cancelacion is NULL then 0 ELSE  
                case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)  
                               then 0 else (case when s.montodesembolsoreal is NULL then p.monto   
                               else s.montodesembolsoreal end) end END end) ReactivacionDisper  
 ,sum(case when p.TipoReprog='RENOV' then 0 ELSE  
                case when l.cancelacion is NULL then 0 ELSE  
                case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)  
                               then (case when s.montodesembolsoreal is NULL then p.monto else s.montodesembolsoreal end)   
        else 0 end END end) RenovDisper                                
,sum(case when l.cancelacion is NULL  then (case when s.montodesembolsoreal is NULL then p.monto   
        else s.montodesembolsoreal end) else 0 end) nuevoDisper  
,sum(case when s.montodesembolsoreal is NULL then p.monto else s.montodesembolsoreal end) montoDispersion  
------------------------ colocacion Entrega --monto  
,sum(case when p.TipoReprog='RENOV' then p.monto else 0 end )RenovAntEnt  
,sum(case when p.TipoReprog='RENOV' then 0 ELSE  
                case when l.cancelacion is NULL then 0 ELSE  
                case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)  
                               then 0 else p.monto end END end) ReacEntrega  
,sum(case when p.TipoReprog='RENOV' then 0 ELSE  
                case when l.cancelacion is NULL then 0 ELSE  
                case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)  
                               then p.monto  else 0 end END end) RenovEnt     
,sum(case when l.cancelacion is NULL  then p.monto else 0 end) nuevoEntrega  
,sum(p.monto)montoEntrega  
---------------------------#Créditos   
,sum(case when p.TipoReprog='RENOV' then 0 ELSE  
                case when l.cancelacion is NULL then 0 ELSE  
                case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)  
                               then 1  else 0 end END end) #RenovPtmos  
,sum(case when p.TipoReprog='RENOV' then 1 else 0 end )#RAnticipaPtmos  
,sum(case when p.TipoReprog='RENOV' then 0 ELSE  
                case when l.cancelacion is NULL then 0 ELSE  
                case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)  
                               then 0 else 1 end END end) #ReactivaPtmos  
,sum(case when l.cancelacion is NULL  then 1 else 0 end) #nuevosPtmos  
,count(p.codprestamo)#totaPtmos  
from tcspadroncarteradet p with(nolock)  
left outer join @liqreno l on l.codprestamo=p.codprestamo  
inner join tcscartera c with(nolock) on c.CodPrestamo=p.CodPrestamo and c.fecha=p.Desembolso  
left outer join [10.0.2.14].finmas.dbo.tcasolicitudrenovacionanticipadaproce s ON s.CodSolicitud=c.CodSolicitud and s.CodOficina=c.CodOficina  
where p.desembolso>=@fecini and p.desembolso<=@fecha  
and p.codoficina NOT IN ('97','231','230','999')  
group by p.codoficina  
  
--SET @T2=GETDATE()        
--PRINT '9.Colocacion Montos --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()
---------------------------------- LIQQRR   
  
--select *  
--into tCsACaLIQUI_RR_03022022   
--from tCsACaLIQUI_RR  
  
declare @Liqr table(codoficina varchar(3)  
     ,NewMontoRenovacion money  
     ,nroRenovacion int  
     ,montoTotal money  
     ,nroTotal int  
     ,PendienteRenov$$ money  
     ,nroPendienteRenov int  
     ,poralcanceRenov money  
     ,porClientesRenov money  
     )  
insert into @Liqr      
select   
t.codoficina--,t.sucursal  
--,sum(case when p.TipoReprog='RENOV' or p.TipoReprog='SINRE' and month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso) then t.nuevomonto else 0 end) NewMontoRenovacion   
--,sum(case when p.TipoReprog='RENOV' or p.TipoReprog='SINRE' and month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso) then 1 else 0 end)nroRenovacion    
,sum(case when t.secuenciaCliente<=3 and atrasomaximo<=8 and (p.TipoReprog='RENOV' or p.TipoReprog='SINRE' and month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)) then  t.nuevomonto    
   when t.secuenciaCliente>3 and atrasomaximo<=15 and (p.TipoReprog='RENOV' or p.TipoReprog='SINRE' and month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso))then  t.nuevomonto  
   else 0 end)NewMontoRenovacion  
,sum(case when t.secuenciaCliente<=3 and atrasomaximo<=8 and (p.TipoReprog='RENOV' or p.TipoReprog='SINRE' and month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)) then 1    
   when t.secuenciaCliente>3 and atrasomaximo<=15 and (p.TipoReprog='RENOV' or p.TipoReprog='SINRE' and month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso))then 1  
   else 0 end)nroRenovacion  
  
,sum(t.monto) montoTotal  
,count(t.codprestamo) nroTotal  
,sum(case when t.estado='Sin Renovar' then t.monto else 0 end)+ sum(case when t.estado in('En proceso' ,'En App') then t.monto else 0 end)PendienteRenov$$  
,sum(case when t.estado in('En proceso' ,'En App','Sin Renovar')then 1 else 0 end) nroPendienteRenov  
,round((case when sum(t.monto)=0 then 0 else sum((case when p.TipoReprog='RENOV' or p.TipoReprog='SINRE' and month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)  
        then t.nuevomonto else 0 end))/sum(t.monto)end)*100,2) poralcanceRenov                                 
,round(case when isnull(count(t.codprestamo),0)=0 then 0 else isnull(sum(case when p.TipoReprog='RENOV' or p.TipoReprog='SINRE' and month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)  
       then 1 else 0 end),0)/cast(isnull(count(t.codprestamo),0) as decimal(8,4))end*100,2) porClientesRenov   
from tCsACaLIQUI_RR  t with(nolock)                      ------- OJO QUITAR EN PRODUCCION  
left outer join tcspadroncarteradet p with(nolock) on p.codprestamo = t.codprestamonuevo  
left outer join @liqreno l  on l.codprestamo=p.codprestamo  
where t.cancelacion>=@fecini and t.cancelacion<=@fecha--'20211201'  
--and t.atrasomaximo>=0 and t.atrasomaximo<=15  
and ((t.secuenciaCliente<=3 and atrasomaximo<=8)or (t.secuenciaCliente>3 and atrasomaximo<=15))  
group by t.codoficina  
  
--  SET @T2=GETDATE()        
--PRINT '10.Liqr  --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()
  
  
------------------------------------------------ REACTIVACIONES   
/*Modificacion del parametro solicitado por Miriam*/  
declare @Reactivacion table  (codoficina varchar(40)  
       ,sucursal varchar(40)  
       ,nuevomonto money  
       ,nuevodesembolso int  
       ,codprestamonuevo varchar (30))   
insert into @Reactivacion  
select   
codoficina,sucursal,(nuevomonto)nuevomonto  
,dbo.fdufechaaperiodo(nuevodesembolso) nuevodesembolso  
,(codprestamonuevo)codprestamonuevo  
from tCsACaLIQUI_RR t with(nolock)   
where cancelacion>=@feciniCosecha and cancelacion<@fecfinCosecha ---inicio de mes --'20220101'  
and estado='Reactivado'  
and  t.atrasomaximo<=30  
  
  
--  SET @T2=GETDATE()        
--PRINT '11.Reactivacion   --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()


/*Modificacion del parametro solicitado por Miriam*/  
declare @pCosecha table  (codoficina varchar(40)  
       ,sucursal varchar(40)  
       ,monto money  
       ,codprestamo varchar (30))   
insert into @pCosecha         
select codoficina,sucursal,monto monto,codprestamo codprestamo  
from tCsACaLIQUI_RR t with(nolock)                    ---OJO CAMBIAR EN PRODUCCION  
where cancelacion>=@feciniCosecha--cancelacion periodox3 meses anteriores  
 and cancelacion<@fecfinCosecha  -- inicio de mes  
and estado<>'Reactivado' and estado<>'Renovado'  
and  t.atrasomaximo<=30 ---modificado   
 
--  SET @T2=GETDATE()        
--PRINT '12.Reactivaciones y Renovados  --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()
 
 
  
declare @BaseReactivacion  table (codoficina varchar(40)  
								   ,sucursal varchar(40)  
								   ,nroNewPtmos int  
								   ,nroPtmos int  
								   ,porAlcance decimal(8,4)  
								   ,montoPendte money  
								   ,nroPendiente int)  
insert into @BaseReactivacion         
select a.codoficina,a.sucursal  
--,sum(nuevomonto) nuevomonto,sum(monto)monto,  
,sum(codprestamonuevo)nroNewPtmos  
,sum(codprestamo)nroPtmos  
,case when sum(codprestamo)=0 then 0 else sum(codprestamonuevo)/cast(isnull(sum(codprestamo),0) as decimal(8,4)) end *100 porAlcance  
,isnull(sum(monto),0)-isnull(sum(nuevomonto),0)montoPendte  
,isnull(sum(codprestamo),0)- isnull(sum(codprestamonuevo),0) nroPendiente  
from (  
 select 1x,  
  codoficina,sucursal,sum(nuevomonto)nuevomonto,count(codprestamonuevo)codprestamonuevo  
  ,0 monto,0 codprestamo  
     from @Reactivacion  
     where nuevodesembolso>=dbo.fdufechaaperiodo(@fecha)  --Periodo mes actual--'202201'  
   group by codoficina,sucursal  
 union  
 select 2x,  
 codoficina,sucursal,0 nuevomonto,0 condprestamonuevo  
 ,sum(monto)monto,count(codprestamo)codprestamo  
 from @pCosecha   
 group by codoficina, sucursal  
)a   
group by codoficina,sucursal  

--  SET @T2=GETDATE()        
--PRINT '13.BaseReactivacion    --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()
  
------------------ANTIGUEDAD DE PROMOTORES ACTIVOS  
  
--Cambio solicitado x miriam  
  
declare @ingresos table(fecha smalldatetime,codoficina varchar(4),mes0a3 int)  
insert into @ingresos  
select @fecha,codoficina  
,count((datediff(month,e.Ingreso,@fecha))) mes0a3  
from tCsempleados e with (nolock)  
where E.Ingreso>= @fecini and e.Ingreso <= @fecha   
and e.CodPuesto ='66'  
and e.salida is null  
--and  e.codmbaja is null   
group by  codoficina--,e.Ingreso ,e.Salida   
  
--Ingresos de meses anteriores  
declare @Plantilla table(fecha smalldatetime,codoficina varchar(4),mes0a3 int,mes3a6 int,mes6a9 int,mes9a12 int,mes12 int,totSucursal int)  
insert into @Plantilla  
select b1.fecha, b1.Codoficina  
--,(datediff(day,e.Ingreso,b1.fecha)/30) mesesantiguedad  
,sum(case when (datediff(day,e.Ingreso,b1.fecha)/30)>=0 and (datediff(day,e.Ingreso,b1.fecha)/30)<3 then 1 else 0 end) mes0a3  
,sum(case when (datediff(day,e.Ingreso,b1.fecha)/30)>=3 and (datediff(day,e.Ingreso,b1.fecha)/30)<6 then 1 else 0 end) mes3a6  
,sum(case when (datediff(day,e.Ingreso,b1.fecha)/30)>=6 and (datediff(day,e.Ingreso,b1.fecha)/30)<9 then 1 else 0 end) mes6a9  
,sum(case when (datediff(day,e.Ingreso,b1.fecha)/30)>=9 and (datediff(day,e.Ingreso,b1.fecha)/30)<12 then 1 else 0 end) mes9a12  
,sum(case when (datediff(day,e.Ingreso,b1.fecha)/30)>=12 then 1 else 0 end) mes12  
,count(b1.codusuario)totSucursal  
from tCsempleadosfecha as b1 with(nolock)  
inner join tCsempleados as e with(nolock) on b1.codusuario=e.codusuario  
where b1.CodPuesto=66 and b1.Fecha=@fecha and e.Ingreso <@fecini --inicio de mes  
group by b1.fecha, b1.codoficina--,e.Ingreso  
  
  
--  SET @T2=GETDATE()        
--PRINT '14.Plantilla    --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()


declare @Antiguedad table (codoficina varchar(4),nomoficina varchar(30),mes0a3 int,mes3a6 int,mes6a9 int,mes9a12 int,mes12 int,totSucursal int)  
insert into @Antiguedad  
select a.codoficina,nomoficina,sum(mes0a3)mes0a3,sum(mes3a6)mes3a6,sum(mes6a9)mes6a9,sum(mes9a12)mes9a12,sum(mes12)mes12  
,sum(mes0a3+mes3a6+mes6a9+mes9a12+mes12)totSucursal  
from (select 1 x,  
      codoficina,mes0a3,mes3a6,mes6a9,mes9a12,mes12,totSucursal  
      from @Plantilla   
      union  
      select 2 x,  
      codoficina,mes0a3,0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
      from @ingresos   
)a  
inner join tcloficinas o with(nolock) on o.codoficina=a.codoficina  
Group by a.codoficina,nomoficina  

  
--  SET @T2=GETDATE()        
--PRINT '15.Antiguedad    --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()
--select * from @Antiguedad  
  
/*------------METAS por sucursal*/  
declare @MeCrecimiento table(codoficina varchar(3), saldo money)  
insert into @MeCrecimiento  
select codigo,monto   
from tcscametas with(nolock)  
where fecha=@fecfin --'20220131' --  
and tipocodigo=1 and meta=1 --crecimiento  
  
declare @MeColocacion table(codoficina varchar(3), montocolocacion money)  
insert into @MeColocacion  
select codigo, monto  
from tcscametas with(nolock)  
where fecha=@fecfin --'20220131'   
and tipocodigo=1 and meta=2 --colocacion  
  
  
declare @MeVacantes table(fecha smalldatetime ,codoficina varchar(3), plantilla money)  
insert into @MeVacantes  
select max(fecha)fecha,codigo,monto  
from tcscametas with(nolock)  
where tipocodigo=1 and meta=3 --nro en la plantilla  
group by codigo, monto  
having max(fecha) is not null  
  
/*-------------- Metas x Region*/  
declare @MeRegCrecimiento table(zona varchar(3), saldoR money)  
insert into @MeRegCrecimiento  
select codigo,monto   
from tcscametas with(nolock)  
where fecha=@fecfin   
and tipocodigo=3 and meta=1 --crecimiento  

--SET @T2=GETDATE()        
--PRINT '16.1.Metas    --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()

declare @MeRegColocacion table(zona varchar(3), montocolocacionR money)  
insert into @MeRegColocacion  
select codigo, monto  
from tcscametas with(nolock)  
where fecha=@fecfin   
and tipocodigo=3 and meta=2 --colocacion    

--SET @T2=GETDATE()        
--PRINT '16.2.Metas    --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()
    
 declare @Metas table(codoficina varchar(3)  
    ,saldo money  
    ,montocolocacion money  
    ,vacante int  
       ,mecliente int)   
insert into @Metas    
select m.codoficina,saldo,montocolocacion--,plantilla,totSucursal  
,(plantilla-isnull(totSucursal,0)) vacante  
,case when isnull(PtmosVigIni,0)>=0 and isnull(PtmosVigIni,0)<300 then 20  
 when isnull(PtmosVigIni,0)>=300 and isnull(PtmosVigIni,0)<500 then 15  
 when isnull(PtmosVigIni,0)>=500 and isnull(PtmosVigIni,0)<700 then 10  
 when isnull(PtmosVigIni,0)>=700 and isnull(PtmosVigIni,0)<1000 then 5  
 when isnull(PtmosVigIni,0)>=1000 then 0 end mecliente  
from @MeCrecimiento m  
left outer join @MeColocacion c on c.codoficina=m.codoficina  
left outer join @MeVacantes v on v.codoficina=m.codoficina  
left outer join #saldoIni s with(nolock) on s.codoficina=m.codoficina  
inner join tcloficinas o with(nolock)on o.codoficina=m.codoficina  
left outer join (select nomoficina,sum(totSucursal)totSucursal   
                         from @Antiguedad group by nomoficina) a on a.nomoficina=o.nomoficina  
  
--  SET @T2=GETDATE()        
--PRINT '16.Metas    --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()


/*-------CONSULTA*/  
           
select o.zona,a.codoficina  
,sum(a.vigente0a30)saldo0a30Ini,sum(a.atraso31a89)saldo31a89Ini,sum(vencido90)saldo90Ini,sum(a.saldocapital) saldocapIni  
,sum(vigente0a30fin)saldo0a30Fin,sum(atraso31a89fin)saldo31a89Fin,sum(ven90fin)saldo90Fin,sum(saldoCastigado)saldoCastigado,sum(saldocapfinal) saldocapFinal  
,sum(var0a30)var0a30,sum(var31a89)var31a89,sum(var90)var90,sum(varCapital)carteraTotal  
,sum(Imor1)Imor1 ,sum(Imor8)Imor8,sum(Imor16) Imor16,sum(Imor30) Imor30,sum(Imor31) Imor31,sum(Imor90) Imor90  
,sum(saldo)montoSaldo,sum(montocolocacion)montoColocacion,sum(vacante)vacante,sum(mecliente)mecliente  
--COBRANZA  
,round(case when sum(progra_antCobrza)=0  then 0 else sum(pag_antCobrza)/sum(progra_antCobrza) end*100,2) porAnticipado_Cobrza -- proporcion pagoanticipado/programdoAnticipado es: %Recuperacion   
,round(case when sum(progra_OrgCobrza)=0  then 0 else sum(pag_orgCobrza)/sum(progra_OrgCobrza) end*100,2) porOrganico_Cobrza   
,round(case when sum(Programado_S)=0 then 0 else sum(Pagado_S)/sum(Programado_S)end*100,2)  portotalCobrza  
,sum(cap_cobrza)CapitalCobrado,sum(Programado_S)CapitalProgramado,sum(pagP_1) pagP_1 ,sum(pagP_2) pagP_2 ,sum(pagP_3a4) pagP_3a4        
,round(case when sum(progra_Cobrza1)=0  then 0 else sum(pag_Cobrza1)/sum(progra_Cobrza1) end*100,2) totalCiclo1   
,sum(Cap_cobrza1)capCiclo1,sum(Cap_cobrza2)capCiclo2,sum(Cap_cobrza3a4)capCiclo3a4,sum(Cap_cobrza5)capCiclo5   
,round(case when sum(progra_Cobrza2)=0  then 0 else sum(pag_Cobrza2)/sum(progra_Cobrza2) end*100,2)   totalCiclo2  
,round(case when sum(progra_Cobrza3a4)=0  then 0 else sum(pag_Cobrza3a4)/sum(progra_Cobrza3a4) end*100,2) totalCiclo3a4  
,round(case when sum(progra_Cobrza5)=0  then 0 else sum(pag_Cobrza5)/sum(progra_Cobrza5) end*100,2)  totalCiclo5  
--cap programado  
,sum(progra_Cobrza1)capProgra1,sum(progra_Cobrza2)capProgra2,sum(progra_Cobrza3a4)capProgra3a4,sum(progra_Cobrza5)capProgra5  
--cap Pagado  
,sum(Pagado_S)CapitalPagado,sum(pag_Cobrza1)capPagado1,sum(pag_Cobrza2)capPagado2,sum(pag_Cobrza3a4)capPagado3a4,sum(pag_Cobrza5)capPagado5  
--COLOCACION  
,sum(RenovAntDisper)RenovAntDisper ,sum(ReactivacionDisper)ReactivacionDisper,sum(RenovDisper)RenovDisper   
,sum(nuevoDisper)nuevoDisper,sum(montoDispersion)montoDispersion,sum(RenovAntEnt)RenovAntEnt ,sum(ReactEnt)ReactEnt   
,(case when isnull(sum(cap_cobrza),0)=0 then 0 else isnull(sum(montoDispersion),0)/isnull(sum(cap_cobrza),0) end*100)porDispersion  
,(case when isnull(sum(cap_cobrza),0)=0 then 0 else isnull(sum(montoEntrega),0)/isnull(sum(cap_cobrza),0) end*100)porEntrega  
,sum(RenovEnt)RenovEnt,sum(nuevoEnt)nuevoEnt ,sum(montoEntrega)montoEntrega , sum(#nuevosPtmos)#nuevosPtmos  
,sum(#RenovPtmos)#RenovPtmos,sum(#RAnticipaPtmos)#RAnticipaPtmos,sum(#ReactivaPtmos)#ReactivaPtmos ,sum(#totaPtmos)#totaPtmos  
,(case when isnull(sum(#RenovPtmos),0)=0 then 0 else isnull(sum(RenovEnt),0)/isnull(sum(#RenovPtmos),0) end)promRenovColoca  
,(case when isnull(sum(#RAnticipaPtmos),0)=0 then 0 else isnull(sum(RenovAntEnt),0)/isnull(sum(#RAnticipaPtmos),0) end)promRAnticipaColoca  
,(case when isnull(sum(#ReactivaPtmos),0)=0 then 0 else isnull(sum(ReactEnt),0)/isnull(sum(#ReactivaPtmos),0) end)promReactivaColoca  
,(case when isnull(sum(#nuevosPtmos),0)=0 then 0 else isnull(sum(nuevoEnt),0)/isnull(sum(#nuevosPtmos),0) end)promNuevoColoca  
,(case when isnull(sum(#totaPtmos),0)=0 then 0 else isnull(sum(montoEntrega),0)/isnull(sum(#totaPtmos),0) end)promTotalColoca  
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(RenovEnt),0)/isnull(sum(montoEntrega),0)*100 end)por$$Renov  
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(RenovAntEnt),0)/isnull(sum(montoEntrega),0)*100 end)por$$RAnticipa  
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(ReactEnt),0)/isnull(sum(montoEntrega),0)*100 end)por$$Reactiva  
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(nuevoEnt),0)/isnull(sum(montoEntrega),0)*100 end)por$$Nuevo  
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(montoEntrega),0)/isnull(sum(montoEntrega),0)*100 end)por$$Total  
--Crean  
,sum(nroAnticipadas)nroAnticipadas,sum(montoAnticipadas)montoAnticipadas   
--LQQRR  
,sum(nroPendienteRenov) nroPendienteRenov  
,sum(PendienteRenov$$)PendienteRenov$$,sum(poralcanceRenov)  poralcanceRenov,sum(porClientesRenov) porClientesRenov           
,sum(mes0a3) mes0a3,sum(mes3a6) mes3a6,sum(mes6a9) mes6a9,sum(mes9a12) mes9a12, sum(mes12)mes12,sum(totSucursal)totSucursal  
,sum(NewMontoRenovacion)newMontoRenov,sum(nroRenovacion)ptmosRenov,sum(montoTotal)montoLiqui,sum(nroTotal)ptmsLiqui   
--cartera vencida  
,sum(cartVencidaIni)cartVencidaIni,sum(cartVencidaFin)cartVencidaFin,sum(varCapVencido)varCapVencido  
--clientes en cartera vigente  
,sum(PtmosVigIni)PtmosVigIni,sum(PtmosVigFin)PtmosVigFin,sum(varClientes)varClientes  
,sum(porAlcance)porAlcance,sum(montoPendte) montoPendte,sum(nroPendiente)nroPendiente  
into #base  
from (  
 select 1 x,  
 codoficina,vigente0a30,atraso31a89,vencido90,saldocapital,cartVencidaIni,PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes   
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega, 0 #nuevosPtmos,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos,0 #totaPtmos   
    ,0 mes0a3,0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,0 saldo,0 montocolocacion, 0 vacante,0 mecliente       
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal   
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from #saldoIni  with(nolock)
 union  
 select 2 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,vigente0a30fin,atraso31a89fin,ven90fin,saldoCastigado,saldocapfinal,cartVencidaFin,PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes  
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega,0 #nuevosPtmos,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos,0 #totaPtmos    
    ,0 mes0a3,0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,0 saldo,0 montocolocacion, 0 vacante,0 mecliente   
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal    
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from #saldoFin  with(nolock)
 union  
 select 3 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,var0a30,var31a89,var90,varCapital, varCapVencido, varClientes  
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega ,0 #nuevosPtmos,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos,0 #totaPtmos    
    ,0 mes0a3,0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,0 saldo,0 montocolocacion, 0 vacante,0 mecliente  
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal    
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from @varMes  
  union  
 select 4 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes  
    ,cap_cobrza,Cap_cobrza1,Cap_cobrza2,Cap_cobrza3a4,Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega ,0 #nuevosPtmos ,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos,0 #totaPtmos   
    ,0 mes0a3,0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,0 saldo,0 montocolocacion, 0 vacante,0 mecliente         
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal    
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from @capCobrado    
 union  
 select 5 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes  
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
 ,RenovAntDisper ,ReactivacionDisper ,RenovDisper ,nuevoDisper ,montoDispersion   
 ,RenovAntEnt ,ReactEnt ,RenovEnt,nuevoEnt ,montoEntrega,#nuevosPtmos,#RenovPtmos ,#RAnticipaPtmos,#ReactivaPtmos, #totaPtmos     
    ,0 mes0a3,0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,0 saldo,0 montocolocacion, 0 vacante,0 mecliente   
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal    
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from @colocacionMontos  
 union  
 select 8 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes  
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega ,0 #nuevosPtmos,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos,0 #totaPtmos    
    ,mes0a3,mes3a6,mes6a9,mes9a12,mes12,totSucursal    
    ,0 saldo,0 montocolocacion, 0 vacante,0 mecliente         
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal    
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from  @Antiguedad  
 union  
 select 9 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes  
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega ,0 #nuevosPtmos,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos,0 #totaPtmos    
    ,0 mes0a3, 0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,saldo, montocolocacion,vacante,mecliente  
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal    
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from @Metas  
 union  
 select 10 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes  
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega ,0 #nuevosPtmos ,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos,0 #totaPtmos   
    ,0 mes0a3, 0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,0 saldo,0 montocolocacion, 0 vacante,0 mecliente  
    ,progra_antCobrza,pag_antCobrza,progra_OrgCobrza ,pag_orgCobrza,Programado_S  
    ,Pagado_S,progra_Cobrza5,pag_Cobrza5,progra_Cobrza3a4,pag_Cobrza3a4,progra_Cobrza2   
    ,pag_Cobrza2,progra_Cobrza1,pag_Cobrza1,pagP_1,pagP_2,pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal    
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from #Basecobrza with(nolock) 
 union  
 select 11 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes  
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega ,0 #nuevosPtmos,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos ,0 #totaPtmos   
    ,0 mes0a3, 0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,0 saldo,0 montocolocacion,0 vacante,0 mecliente  
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas , nroPendienteRenov  
    ,PendienteRenov$$,poralcanceRenov, porClientesRenov,NewMontoRenovacion,nroRenovacion,montoTotal,nroTotal   
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from @Liqr  
 union  
 select 12 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes  
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega ,0 #nuevosPtmos,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos ,0 #totaPtmos   
    ,0 mes0a3, 0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,0 saldo,0 montocolocacion,0 vacante,0 mecliente  
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal   
    ,Imor1,Imor8,Imor16,Imor30,Imor31,Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from @imorBase  
 union  
 select 13 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes  
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega ,0 #nuevosPtmos,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos ,0 #totaPtmos   
    ,0 mes0a3, 0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,0 saldo,0 montocolocacion,0 vacante,0 mecliente  
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,0 nroAnticipadas,0 montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal   
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,porAlcance,montoPendte,nroPendiente  
 from @BaseReactivacion   
 union  
    select 14 x,  
 codoficina  
    ,0 vigente0a30,0 atraso31a89,0 vencido90,0 saldocapital,0 cartVencidaIni,0 PtmosVigIni  
 ,0 vigente0a30fin,0 atraso31a89fin,0 ven90fin,0 saldoCastigado,0 saldocapfinal,0 cartVencidaFin,0 PtmosVigFin  
 ,0 var0a30,0 var31a89,0 var90,0 varCapital,0 varCapVencido,0 varClientes  
    ,0 cap_cobrza,0 Cap_cobrza1,0 Cap_cobrza2,0 Cap_cobrza3a4,0 Cap_cobrza5   
    ,0 RenovAntDisper,0 ReactivacionDisper,0 RenovDisper,0 nuevoDisper,0 montoDispersion   
 ,0 RenovAntEnt,0 ReactEnt,0 RenovEnt,0 nuevoEnt,0 montoEntrega ,0 #nuevosPtmos,0 #RenovPtmos,0 #RAnticipaPtmos,0 #ReactivaPtmos,0 #totaPtmos    
    ,0 mes0a3, 0 mes3a6,0 mes6a9,0 mes9a12,0 mes12,0 totSucursal  
    ,0 saldo,0 montocolocacion,0 vacante,0 mecliente  
    ,0 progra_antCobrza,0 pag_antCobrza,0 progra_OrgCobrza,0 pag_orgCobrza,0 Programado_S  
    ,0 Pagado_S,0 progra_Cobrza5,0 pag_Cobrza5,0 progra_Cobrza3a4,0 pag_Cobrza3a4,0 progra_Cobrza2   
    ,0 pag_Cobrza2,0 progra_Cobrza1,0 pag_Cobrza1,0 pagP_1,0 pagP_2,0 pagP_3a4   
    ,nroAnticipadas,montoAnticipadas ,0 nroPendienteRenov  
    ,0 PendienteRenov$$,0 poralcanceRenov,0 porClientesRenov,0 NewMontoRenovacion,0 nroRenovacion,0 montoTotal,0 nroTotal   
    ,0 Imor1,0 Imor8,0 Imor16,0 Imor30,0 Imor31,0 Imor90  
    ,0 porAlcance,0 montoPendte,0 nroPendiente  
 from @Anticipadas   
)a  
left outer join tcloficinas o with(nolock)on o.codoficina=a.codoficina   
where  o.tipo<>'Cerrada'  
group by o.zona,a.codoficina  

--  SET @T2=GETDATE()        
--PRINT '17.base    --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()

/*------ baseRegion*/  
  
select z.nombre region,'zz' as nomoficina,'TOTAL'tipoSucursal  
,sum(saldo0a30Ini)saldo0a30Ini,sum(saldo31a89Ini)saldo31a89Ini,sum(saldo90Ini)saldo90Ini,sum(saldocapIni)saldocapIni  
,sum(saldo0a30Fin)saldo0a30Fin,sum(saldo31a89Fin)saldo31a89Fin,sum(saldo90Fin)saldo90Fin,sum(saldoCastigado)saldoCastigado,sum(saldocapFinal) saldocapFinal  
,sum(var0a30)var0a30,sum(var31a89)var31a89,sum(var90)var90,sum(carteraTotal)carteraTotal  
--cartera vencida  
,sum(cartVencidaIni)cartVencidaIni,sum(cartVencidaFin)cartVencidaFin,sum(varCapVencido)varCapVencido  
--clientes en cartera   
,sum(PtmosVigIni)PtmosVigIni,sum(PtmosVigFin)PtmosVigFin,sum(varClientes)varClientes,sum(mecliente)metacliente  
,case when sum(mecliente)=0 then 0 else sum(varClientes)/cast(isnull(sum(mecliente),0) as decimal(8,4))*100 end porCliente  
,((r.Imor1))Imor1,(r.Imor8) Imor8,(r.Imor16) Imor16,(r.Imor30) Imor30,(r.Imor31) Imor31 ,(r.Imor90) Imor90  
,(saldoR)metaCrecimiento  
,case when (saldoR)=0 then 0 else sum(var0a30)/(saldoR)*100 end porCrecimiento  
,(montocolocacionR)montoColocacion  
,case when (montocolocacionR)=0 then 0 else sum(montoEntrega)/(montocolocacionR)*100 end porColocacion  
,round(case when sum(progra_antCobrza)=0  then 0 else sum(pag_antCobrza)/sum(progra_antCobrza) end*100,2) porAnticipado_Cobrza -- proporcion pagoanticipado/programdoAnticipado es: %Recuperacion   
,round(case when sum(progra_OrgCobrza)=0  then 0 else sum(pag_orgCobrza)/sum(progra_OrgCobrza) end*100,2) porOrganico_Cobrza   
,round(case when sum(Programado_S)=0 then 0 else sum(Pagado_S)/sum(Programado_S)end*100,2)  portotalCobrza  
,sum(CapitalProgramado)CapitalProgramado,sum(CapitalCobrado)CapitalCobrado,sum(c.pagP_1) pagP_1   
,round(case when sum(c.progra_Cobrza1)=0  then 0 else sum(c.pag_Cobrza1)/sum(c.progra_Cobrza1) end*100,2) totalCiclo1   
,sum(capCiclo1)capCiclo1,sum(c.pagP_2) pagP_2  
,round(case when sum(c.progra_Cobrza2)=0  then 0 else sum(c.pag_Cobrza2)/sum(c.progra_Cobrza2) end*100,2)   totalCiclo2  
,sum(capCiclo2)capCiclo2 ,sum(c.pagP_3a4) pagP_3a4  
,round(case when sum(c.progra_Cobrza3a4)=0  then 0 else sum(c.pag_Cobrza3a4)/sum(c.progra_Cobrza3a4) end*100,2) totalCiclo3a4  
,sum(capCiclo3a4)capCiclo3a4  
,round(case when sum(c.progra_Cobrza5)=0  then 0 else sum(c.pag_Cobrza5)/sum(c.progra_Cobrza5) end*100,2)  totalCiclo5  
,sum(capCiclo5)capCiclo5   
,sum(RenovAntDisper)RenovAntDisper ,sum(ReactivacionDisper)ReactivacionDisper,sum(RenovDisper)RenovDisper   
,sum(nuevoDisper)nuevoDisper,sum(montoDispersion)montoDispersion,sum(RenovAntEnt)RenovAntEnt ,sum(ReactEnt)ReactEnt   
,sum(RenovEnt)RenovEnt,sum(nuevoEnt)nuevoEnt ,sum(montoEntrega)montoEntrega , sum(#nuevosPtmos)#nuevosPtmos  
,(case when isnull(sum(cap_cobrza),0)=0 then 0 else isnull(sum(montoDispersion),0)/isnull(sum(cap_cobrza),0) end*100)porDispersion  
,(case when isnull(sum(cap_cobrza),0)=0 then 0 else isnull(sum(montoEntrega),0)/isnull(sum(cap_cobrza),0) end*100)porEntrega  
,sum(nroAnticipadas)nroAnticipadas,sum(montoAnticipadas)montoAnticipadas    
,sum(b.nroPendienteRenov) nroPendienteRenov,sum(b.PendienteRenov$$)PendienteRenov$$  
,round((case when sum(montoTotal)=0 then 0 else sum(NewMontoRenovacion)/sum(montoTotal)end)*100,2) poralcanceRenov                                 
,round(case when isnull(sum(nroTotal),0)=0 then 0 else isnull(sum(nroRenovacion),0)/cast(isnull(sum(nroTotal),0) as decimal(8,4))end*100,2) porClientesRenov   
,case when sum(nroPtmos)=0 then 0 else sum(nroNewPtmos)/cast(isnull(sum(nroPtmos),0) as decimal(8,4)) end *100 porAlcance  
,sum(b.montoPendte) montPendReactivacion,sum(b.nroPendiente) nroPendReactivacion--reactivaciones  
,sum(mes0a3) mes0a3,sum(mes3a6) mes3a6,sum(mes6a9) mes6a9,sum(mes9a12) mes9a12, sum(mes12)mes12,sum(totSucursal)totSucursal,sum(vacante)vacante  
,sum(capProgra1)capProgra1,sum(capProgra2)capProgra2,sum(capProgra3a4)capProgra3a4,sum(capProgra5)capProgra5  
,sum(CapitalPagado)CapitalPagado,sum(capPagado1)capPagado1,sum(capPagado2)capPagado2,sum(capPagado3a4)capPagado3a4,sum(capPagado5)capPagado5  
,sum(#RenovPtmos)#RenovPtmos,sum(#RAnticipaPtmos)#RAnticipaPtmos,sum(#ReactivaPtmos)#ReactivaPtmos ,sum(#totaPtmos ) #totaPtmos  
,(case when isnull(sum(#RenovPtmos),0)=0 then 0 else isnull(sum(RenovEnt),0)/isnull(sum(#RenovPtmos),0) end)promRenovColoca  
,(case when isnull(sum(#RAnticipaPtmos),0)=0 then 0 else isnull(sum(RenovAntEnt),0)/isnull(sum(#RAnticipaPtmos),0) end)promRAnticipaColoca  
,(case when isnull(sum(#ReactivaPtmos),0)=0 then 0 else isnull(sum(ReactEnt),0)/isnull(sum(#ReactivaPtmos),0) end)promReactivaColoca  
,(case when isnull(sum(#nuevosPtmos),0)=0 then 0 else isnull(sum(nuevoEnt),0)/isnull(sum(#nuevosPtmos),0) end)promNuevoColoca  
,(case when isnull(sum(#totaPtmos),0)=0 then 0 else isnull(sum(montoEntrega),0)/isnull(sum(#totaPtmos),0) end)promTotalColoca  
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(RenovEnt),0)/isnull(sum(montoEntrega),0)*100 end)por$$Renov  
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(RenovAntEnt),0)/isnull(sum(montoEntrega),0)*100 end)por$$RAnticipa  
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(ReactEnt),0)/isnull(sum(montoEntrega),0)*100 end)por$$Reactiva  
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(nuevoEnt),0)/isnull(sum(montoEntrega),0)*100 end)por$$Nuevo  
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(montoEntrega),0)/isnull(sum(montoEntrega),0)*100 end)por$$Total  
,sum(newMontoRenov)MontoRenov,sum(ptmosRenov)ptmosRenov,sum(montoLiqui)montoLiqui,sum(ptmsLiqui)ptmsLiqui   
into #baseRegion   
from #base b with(nolock)  
left outer join @BaseReactivacion  f on f.codoficina=b.codoficina  
left outer join tcloficinas o with(nolock) on o.codoficina=b.codoficina  
left outer join tclzona z with(nolock) on z.zona=o.zona  
left outer join #Basecobrza c with(nolock) on b.codoficina=c.codoficina  
left outer join @Liqr l on l.codoficina=b.codoficina  
left outer join @imorRegion r on r.zona=b.zona   
left outer join @capCobrado cc on cc.codoficina=b.codoficina  
left outer join @MeRegCrecimiento m on z.zona=m.zona  
left outer join @MeRegColocacion co on co.zona=z.zona  
where z.zona  not in( 'ZSC','ZCO') and o.tipo<>'Cerrada'  
group by z.zona,z.nombre,r.Imor1,r.Imor8,r.Imor16,r.Imor30,r.Imor31,r.Imor90,montocolocacionR,saldoR  
order by z.nombre,o.nomoficina  
  
--  SET @T2=GETDATE()        
--PRINT '18.base Region   --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()


/*--------------------------------- CONSULTA FINAL----------*/  
delete from FNMGConsolidado.dbo.tCaReporteKPI where fecha=@fecha   
insert into FNMGConsolidado.dbo.tCaReporteKPI  
  
select @fecha fecha, z.nombre region,o.nomoficina--,b.codoficina  
,case when o.EsVirtual=1 then 'VIRTUAL' else 'FISICA' end tipoSucursal  
,sum(saldo0a30Ini)saldo0a30Ini,sum(saldo31a89Ini)saldo31a89Ini,sum(saldo90Ini)saldo90Ini,sum(saldocapIni)saldocapIni  
,sum(saldo0a30Fin)saldo0a30Fin,sum(saldo31a89Fin)saldo31a89Fin,sum(saldo90Fin)saldo90Fin,sum(saldoCastigado)saldoCastigado,sum(saldocapFinal) saldocapFinal  
,sum(var0a30)var0a30,sum(var31a89)var31a89,sum(var90)var90,sum(carteraTotal)carteraTotal  
--cartera vencida  
,sum(cartVencidaIni)cartVencidaIni,sum(cartVencidaFin)cartVencidaFin,sum(varCapVencido)varCapVencido  
--clientes en cartera   
,sum(PtmosVigIni)PtmosVigIni,sum(PtmosVigFin)PtmosVigFin,sum(varClientes)varClientes,sum(mecliente)metacliente  
,case when sum(mecliente)=0 then 0 else sum(varClientes)/cast(isnull(sum(mecliente),0) as decimal(8,4))*100 end porCliente  
,sum((Imor1))Imor1,sum(Imor8) Imor8,sum(Imor16) Imor16,sum(Imor30) Imor30,sum(Imor31) Imor31 ,sum(Imor90) Imor90  
,sum(montoSaldo)metaCrecimiento  
,case when sum(montoSaldo)=0 then 0 else sum(var0a30)/sum(montoSaldo)*100 end porCrecimiento  
,sum(montocolocacion)montoColocacion  
,case when sum(montocolocacion)=0 then 0 else sum(montoEntrega)/sum(montocolocacion)*100 end porColocacion  
,sum(porAnticipado_Cobrza) porAnticipado_Cobrza ,sum(porOrganico_Cobrza) porOrganico_Cobrza   
,sum(portotalCobrza) portotalCobrza,sum(CapitalProgramado)CapitalProgramado,sum(CapitalCobrado)CapitalCobrado  
,sum(pagP_1) pagP_1 ,sum(totalCiclo1) totalCiclo1   
,sum(capCiclo1)capCiclo1,sum(pagP_2) pagP_2,sum(totalCiclo2) totalCiclo2,sum(capCiclo2)capCiclo2 ,sum(pagP_3a4) pagP_3a4  
,sum(totalCiclo3a4) totalCiclo3a4,sum(capCiclo3a4)capCiclo3a4,sum(totalCiclo5)  totalCiclo5,sum(capCiclo5)capCiclo5   
,sum(RenovAntDisper)RenovAntDisper ,sum(ReactivacionDisper)ReactivacionDisper,sum(RenovDisper)RenovDisper   
,sum(nuevoDisper)nuevoDisper,sum(montoDispersion)montoDispersion,sum(RenovAntEnt)RenovAntEnt ,sum(ReactEnt)ReactEnt   
,sum(RenovEnt)RenovEnt,sum(nuevoEnt)nuevoEnt ,sum(montoEntrega)montoEntrega , sum(#nuevosPtmos)#nuevosPtmos  
,sum(porDispersion)porDispersion,sum(porEntrega)porEntrega  
,sum(nroAnticipadas)nroAnticipadas,sum(montoAnticipadas)montoAnticipadas  
,sum(nroPendienteRenov) nroPendienteRenov,sum(PendienteRenov$$)PendienteRenov$$         
,sum(poralcanceRenov) poralcanceRenov ,sum(porClientesRenov) porClientesRenov            
,sum(porAlcance) porAlcaReactivacion,sum(montoPendte) montPendReactivacion,sum(nroPendiente) nroPendReactivacion  
,sum(mes0a3) mes0a3,sum(mes3a6) mes3a6,sum(mes6a9) mes6a9,sum(mes9a12) mes9a12, sum(mes12)mes12,sum(totSucursal)totSucursal,sum(vacante)vacante  
/*Campos agregados para la carta gte*/  
,sum(capProgra1)capProgra1,sum(capProgra2)capProgra2,sum(capProgra3a4)capProgra3a4,sum(capProgra5)capProgra5  
,sum(CapitalPagado)CapitalPagado,sum(capPagado1)capPagado1,sum(capPagado2)capPagado2,sum(capPagado3a4)capPagado3a4,sum(capPagado5)capPagado5  
,sum(#RenovPtmos)#RenovPtmos,sum(#RAnticipaPtmos)#RAnticipaPtmos,sum(#ReactivaPtmos)#ReactivaPtmos,sum(#totaPtmos ) #totaPtmos   
,sum(promRenovColoca)promRenovColoca,sum(promRAnticipaColoca)promRAnticipaColoca,sum(promReactivaColoca)promReactivaColoca  
,sum(promNuevoColoca)promNuevoColoca,sum(promTotalColoca)promTotalColoca  
,sum(por$$Renov)por$$Renov,sum(por$$RAnticipa)por$$RAnticipa,sum(por$$Reactiva)por$$Reactiva,sum(por$$Nuevo)por$$Nuevo,sum(por$$Total)por$$Total  
,sum(newMontoRenov)MontoRenov,sum(ptmosRenov)ptmosRenov,sum(montoLiqui)montoLiqui,sum(ptmsLiqui)ptmsLiqui   
from #base b with(nolock)  
left outer join tcloficinas o with(nolock) on o.codoficina=b.codoficina  
left outer join tclzona z with(nolock) on z.zona=o.zona  
where z.zona  not in( 'ZSC','ZCO')and o.tipo<>'Cerrada'  
group by z.zona,z.nombre,o.nomoficina,o.EsVirtual  
union  
select @fecha fecha,  
region region,'zz' as nomoficina,'TOTAL'tipoSucursal  
,saldo0a30Ini,saldo31a89Ini,saldo90Ini,saldocapIni  
,saldo0a30Fin,saldo31a89Fin,saldo90Fin,saldoCastigado,saldocapFinal  
,var0a30,var31a89,var90,carteraTotal  
--cartera vencida  
,cartVencidaIni,cartVencidaFin,varCapVencido  
--clientes en cartera   
,PtmosVigIni,PtmosVigFin,varClientes,metacliente,porCliente  
,Imor1, Imor8, Imor16, Imor30, Imor31 , Imor90  
,metaCrecimiento,porCrecimiento,montoColocacion,porColocacion,porAnticipado_Cobrza,porOrganico_Cobrza ,portotalCobrza  
,CapitalProgramado,CapitalCobrado, pagP_1 ,totalCiclo1,capCiclo1,pagP_2,totalCiclo2,capCiclo2,pagP_3a4,totalCiclo3a4  
,capCiclo3a4,totalCiclo5,capCiclo5 ,RenovAntDisper ,ReactivacionDisper,RenovDisper   
,nuevoDisper,montoDispersion,RenovAntEnt,ReactEnt,RenovEnt,nuevoEnt,montoEntrega,#nuevosPtmos  
,porDispersion,porEntrega,nroAnticipadas,montoAnticipadas,nroPendienteRenov  
,PendienteRenov$$,poralcanceRenov,porClientesRenov,porAlcance,montPendReactivacion, nroPendReactivacion  
,mes0a3, mes3a6, mes6a9, mes9a12, mes12,totSucursal,vacante  
/*Campos agregados para la carta gte*/  
,capProgra1,capProgra2,capProgra3a4,capProgra5  
,CapitalPagado,capPagado1,capPagado2,capPagado3a4,capPagado5,#RenovPtmos,#RAnticipaPtmos,#ReactivaPtmos ,#totaPtmos  
,promRenovColoca,promRAnticipaColoca,promReactivaColoca,promNuevoColoca,promTotalColoca,por$$Renov  
,por$$RAnticipa,por$$Reactiva,por$$Nuevo,por$$Total,MontoRenov,ptmosRenov,montoLiqui,ptmsLiqui   
from #baseRegion with(nolock)  
  

--  SET @T2=GETDATE()        
--PRINT '19.Consulta Final  --> ' + CAST(DATEDIFF(SECOND,@T1,@T2) AS VARCHAR(20))        
--SET @T1=GETDATE()

-----------------------------------------  
drop table #saldoIni  
drop table #saldoFin  
drop table #Basecobrza  
drop table #base  
drop table #baseRegion  
  
--ROLLBACK TRAN
GO