SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
                            
CREATE procedure [dbo].[pCsRptKPIregionaltbl3] @fecha smalldatetime, @zona varchar(5)    
as       
set nocount on     
    
--declare @fecha smalldatetime      
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion    
  
--declare @zona varchar(5)    
--set @zona = 'z14'  
    
      
declare @fecini smalldatetime    
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes    
    
    
declare @oficinas table(zona varchar(5),codoficina varchar(5))  
insert into @oficinas  
select zona,codoficina  
from tcloficinas with(nolock)  
where  zona=@zona  
and tipo<>'cerrada'  
    
             
/*PARTE CREDITOS*/       
create table #ptmos (codprestamo varchar(25)      
      ,codoficina varchar(4)      
      ,nrodiasatraso int      
      --,secuenciacliente int      
      ,codproducto char(3)      
      ,codasesor varchar(15)      
      ,tiporeprog varchar(10))      
insert into #ptmos      
select c.codprestamo,c.codoficina,c.nrodiasatraso--,d.secuenciacliente
,c.codproducto
,c.codasesor--,d.ultimoasesor
,c.tiporeprog         
from tcscartera c with(nolock)        
--inner join tcspadroncarteradet d with(nolock) on c.codprestamo=d.codprestamo        
where c.fecha=@fecha
and c.codoficina in(select codoficina from @oficinas )   
and cartera='ACTIVA'  
and c.nrodiasatraso<=30  


create table #ptmosCP (codprestamo varchar(25)      
      ,codoficina varchar(4)      
      ,nrodiasatraso int      
      ,secuenciacliente int      
      ,codproducto char(3)      
      ,codasesor varchar(15)      
      ,tiporeprog varchar(10))      
insert into #ptmosCP        
select c.codprestamo,c.codoficina,c.nrodiasatraso,d.secuenciacliente
,c.codproducto
,c.codasesor
,c.tiporeprog         
from #ptmos c with(nolock)        
inner join tcspadroncarteradet d with(nolock) on c.codprestamo=d.codprestamo        
 
insert into #ptmosCP        
select d.codprestamo,d.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor,c.tiporeprog          
from tcspadroncarteradet d with(nolock)        
left outer join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fechacorte        
where d.cancelacion>=@fecini 
and d.cancelacion<=@fecha        
and d.codoficina in(select codoficina from @oficinas )   
           
           
           
/*PARTE 2 TABLA DE PAGOS*/                
create table #CUO(        
          codoficina varchar(4),        
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
where 
cu.fechavencimiento>=@fecini 
and cu.fechavencimiento<=@fecha        
and cu.codoficina in(select codoficina from @oficinas )     
and cu.codprestamo in(select codprestamo from #ptmosCP)        
and cu.numeroplan=0        
and cu.seccuota>0 
and cu.codconcepto = 'CAPI'          
group by cu.codprestamo,cu.seccuota        
,cu.fechavencimiento        
,cu.estadocuota        
,p.codoficina             
           
      
select @fecha fecha, z.Nombre region,z.zona        
,o.nomoficina nomoficina,o.codoficina codoficina , ca.codasesor       
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'        
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'        
            when ca.nrodiasatraso>=31 then '31+DM' else '' end atraso         
,case when ca.secuenciacliente>=5 then 5       
         when ca.secuenciacliente>=3 then 3        
         when ca.secuenciacliente=2 then 2        
         else 1 end     rangoCiclo       
,ca.tiporeprog        
,sum(p.montodevengado) programado_s         
,sum(case when p.estadocuota='CANCELADO'and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) monto_anticipado        
,sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) monto_puntual       
,sum(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.montopagado else 0 end) momto_atrasado        
,count(p.codprestamo) - count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) sinpago_n        
into  #cobranzaP      
from #CUO p with(nolock)        
inner join #ptmosCP ca with(nolock) on ca.codprestamo=p.codprestamo        
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina        
inner join tclzona z with(nolock) on z.zona=o.zona        
--inner join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor        
where o.zona not in('ZSC','ZCO')        
group by p.fechavencimiento,z.Nombre ,z.zona         
,o.codoficina        
,o.nomoficina ,ca.codasesor       
,case when ca.secuenciacliente>=5 then 5       
         when ca.secuenciacliente>=3 then 3        
         when ca.secuenciacliente=2 then 2        
         else 1 end                
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'        
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'        
            when ca.nrodiasatraso>=31 then '31+DM' else '' end        
,ca.tiporeprog        
order by z.Nombre       
            
         
            
/*PARTE 3 --CONSULTA FINAL */            
declare @cobranza table ( zona varchar (5),codoficina varchar(5),nomoficina varchar(30) ,rangoCiclo VARCHAR(20)           
      ,progra_antCobrza money            
      ,pag_antCobrza money            
      ,progra_OrgCobrza money            
      ,pag_orgCobrza  money            
      ,Programado_S  money            
      ,Pagado_S money ,cobranza_puntual money ,porpagado money,porpuntual money,sinpago_n int)      
insert into @cobranza           
select zona,codoficina,nomoficina   
,case when rangoCiclo>=5 then 'c.5+'        
         when rangoCiclo>=3 then 'c.3-4'        
         when rangoCiclo=2 then 'c.2'        
         else 'c.1' end   rangoCiclo                
 ------------VALORES DE COBRANZA CLASIFICADA POR ANTICIPADA Y ORGANICA            
,sum(case when tiporeprog='RENOV' then programado_s else 0 end) progra_antCobrza                  
,sum(case when tiporeprog='RENOV' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_antCobrza                   
,sum(case when tiporeprog='SINRE' then programado_s else 0 end) progra_OrgCobrza               
,sum(case when tiporeprog='SINRE' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_orgCobrza                     
---VALORES DE COBRANZA TOTAL            
,sum(programado_s) Programado_S              
,sum(monto_anticipado+monto_puntual+momto_atrasado) Pagado_S                  
,sum(monto_anticipado+monto_puntual) cobranza_puntual   
,(sum(monto_anticipado+monto_puntual+momto_atrasado)/sum(programado_s))*100 Porpagado                  
,(sum(monto_anticipado+monto_puntual)/sum(programado_s))*100 porpuntual   
,sum(sinpago_n)sinpago_n  
from #cobranzaP p with(nolock)      
where atraso in ('0-7DM','8-30DM')--> 0 a 30 dm      
group by ZONA, codoficina,nomoficina   
,case when rangoCiclo>=5 then 'c.5+'        
         when rangoCiclo>=3 then 'c.3-4'        
         when rangoCiclo=2 then 'c.2'        
         else 'c.1' end   
     
 --por sucursal  
select zona,codoficina,nomoficina  
,sum(progra_antCobrza)progra_antCobrza,sum(pag_antCobrza)pag_antCobrza --- cobranza por tipo de crédito                  
,sum(progra_OrgCobrza)progra_OrgCobrza ,sum(pag_orgCobrza)pag_orgCobrza             
,sum(Programado_S)Programado_S         
,sum(case when rangoCiclo='c.5+'  then Programado_S else 0 end) 'programadoC5+'        
,sum(case when  rangoCiclo='c.3-4' then Programado_S else 0 end) 'programadoC3-4'        
,sum(case when  rangoCiclo='c.2'  then Programado_S else 0 end) 'programadoC2'        
,sum(case when  rangoCiclo='c.1' then Programado_S else 0  end) 'programadoC1'  
,sum(Pagado_S)Pagado_S  
,sum(case when rangoCiclo='c.5+'  then Pagado_S else 0 end )'cobradoC5+'        
,sum(case when  rangoCiclo='c.3-4' then Pagado_S else 0 end) 'cobradoC3-4'        
,sum(case when  rangoCiclo='c.2'  then Pagado_S else 0 end) 'cobradoC2'        
,sum(case when  rangoCiclo='c.1' then Pagado_S else 0  end) 'cobradoC1'  
--,Porpagado  
--,sum(case when rangoCiclo='c.5+'  then Porpagado else 0 end) 'PorpagadoC5+'        
--,sum(case when  rangoCiclo='c.3-4' then Porpagado else 0 end) 'PorpagadoC3-4'        
--,sum(case when  rangoCiclo='c.2'  then Porpagado else 0 end )'PorpagadoC2'        
--,sum(case when  rangoCiclo='c.1' then Porpagado else 0  end) 'PorpagadoC1'  
,sum(cobranza_puntual)cobranza_puntual  
--,sum(case when rangoCiclo='c.5+'  then porpuntual else 0 end) 'porpuntualC5+'        
--,sum(case when  rangoCiclo='c.3-4' then porpuntual else 0 end) 'porpuntualC3-4'        
--,sum(case when  rangoCiclo='c.2'  then porpuntual else 0 end) 'porpuntualC2'        
--,sum(case when  rangoCiclo='c.1' then porpuntual else 0  end) 'porpuntualC1'  
  
,sum(case when rangoCiclo='c.5+'  then sinpago_n else 0 end) 'sinpago_nC5+'        
,sum(case when  rangoCiclo='c.3-4' then sinpago_n else 0 end) 'sinpago_nC3-4'        
,sum(case when  rangoCiclo='c.2'  then sinpago_n else 0 end )'sinpago_nC2'        
,sum(case when  rangoCiclo='c.1' then sinpago_n else 0  end) 'sinpago_nC1'  
,sum(sinpago_n)sinpago_n  
,(case when sum(Programado_S)=0  then 0 else (sum(Pagado_S)/sum(Programado_S))*100 end) 'porRecuperacion'        
,(case when sum(Programado_S)=0  then 0 else (sum(cobranza_puntual)/sum(Programado_S))*100 end) 'porRecuperaPuntual'        
from @cobranza  
group by zona,codoficina,nomoficina  
union  
select c.zona,c.zona,z.nombre  
,sum(progra_antCobrza)progra_antCobrza,sum(pag_antCobrza)pag_antCobrza --- cobranza por tipo de crédito                  
,sum(progra_OrgCobrza)progra_OrgCobrza ,sum(pag_orgCobrza)pag_orgCobrza             
,sum(Programado_S)Programado_S         
,sum(case when rangoCiclo='c.5+'  then Programado_S else 0 end) 'programadoC5+'        
,sum(case when  rangoCiclo='c.3-4' then Programado_S else 0 end) 'programadoC3-4'        
,sum(case when  rangoCiclo='c.2'  then Programado_S else 0 end) 'programadoC2'        
,sum(case when  rangoCiclo='c.1' then Programado_S else 0  end) 'programadoC1'  
,sum(Pagado_S)Pagado_S  
,sum(case when rangoCiclo='c.5+'  then Pagado_S else 0 end )'cobradoC5+'        
,sum(case when  rangoCiclo='c.3-4' then Pagado_S else 0 end) 'cobradoC3-4'        
,sum(case when  rangoCiclo='c.2'  then Pagado_S else 0 end) 'cobradoC2'        
,sum(case when  rangoCiclo='c.1' then Pagado_S else 0  end) 'cobradoC1'  
--,Por recuperado con atraso  
--,0 'PorpagadoC5+'        
--,0 'PorpagadoC3-4'        
--,0'PorpagadoC2'        
--,0 'PorpagadoC1'  
,sum(cobranza_puntual)cobranza_puntual  
  
,sum(case when rangoCiclo='c.5+'  then sinpago_n else 0 end) 'sinpago_nC5+'        
,sum(case when  rangoCiclo='c.3-4' then sinpago_n else 0 end) 'sinpago_nC3-4'        
,sum(case when  rangoCiclo='c.2'  then sinpago_n else 0 end )'sinpago_nC2'        
,sum(case when  rangoCiclo='c.1' then sinpago_n else 0  end) 'sinpago_nC1'  
,sum(sinpago_n)sinpago_n  
,(case when sum(Programado_S)=0  then 0 else (sum(Pagado_S)/sum(Programado_S))*100 end) 'porRecuperacion'        
,(case when sum(Programado_S)=0  then 0 else (sum(cobranza_puntual)/sum(Programado_S))*100 end) 'porRecuperaPuntual'        
from @cobranza c  
INNER JOIN tclzona z on z.zona=c.zona  
group by c.zona,z.nombre  
   

drop table #ptmos     
drop table #ptmosCP        
drop table #CUO        
drop table  #cobranzaP 

/*
------------------------------
                      
--CREATE procedure dbo.pCsRptKPIregionaltbl3 @fecha smalldatetime, @zona varchar(5)    
--as       
--set nocount on     
    
----declare @fecha smalldatetime      
----select @fecha=fechaconsolidacion from vcsfechaconsolidacion    
  
----declare @zona varchar(5)    
----set @zona = 'z14'  
    
      
--declare @fecini smalldatetime    
--set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes    
    
    
--declare @oficinas table(zona varchar(5),codoficina varchar(5))  
--insert into @oficinas  
--select zona,codoficina  
--from tcloficinas with(nolock)  
--where  zona=@zona  
--and tipo<>'cerrada'  
    
             
--/*PARTE CREDITOS*/       
--create table #ptmosCP (codprestamo varchar(25)      
--      ,codoficina varchar(4)      
--      ,nrodiasatraso int      
--      ,secuenciacliente int      
--      ,codproducto char(3)      
--      ,codasesor varchar(15)      
--      ,tiporeprog varchar(10))      
--insert into #ptmosCP        
--select c.codprestamo,c.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor,c.tiporeprog         
--from tcscartera c with(nolock)        
--inner join tcspadroncarteradet d with(nolock) on c.codprestamo=d.codprestamo        
--where c.fecha=@fecha      
--and cartera='ACTIVA'  and c.nrodiasatraso<=30    
--and c.codoficina in(select codoficina from @oficinas )   
--insert into #ptmosCP        
--select d.codprestamo,d.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor,c.tiporeprog          
--from tcspadroncarteradet d with(nolock)        
--left outer join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fechacorte        
--where d.cancelacion>=@fecini and d.cancelacion<=@fecha        
--and d.codoficina in(select codoficina from @oficinas )   
           
           
           
--/*PARTE 2 TABLA DE PAGOS*/                
--create table #CUO(        
--          codoficina varchar(4),        
--          codprestamo varchar(25),        
--          seccuota int,        
--          montodevengado money,        
--          montopagado money,        
--          fechavencimiento smalldatetime,        
--          fechapago smalldatetime,        
--          estadocuota varchar(20))        
--insert into #CUO        
--select p.codoficina,cu.codprestamo,cu.seccuota        
--,sum(cu.montodevengado) montodevengado        
--,sum(cu.montopagado) montopagado        
--,cu.fechavencimiento        
--,max(cu.fechapagoconcepto) fechapago        
--,cu.estadocuota       
--from tcspadronplancuotas cu with(nolock)        
--inner join #ptmosCP p with(nolock) on p.codprestamo=cu.codprestamo        
--where cu.codprestamo in(select codprestamo from #ptmosCP)        
--and cu.numeroplan=0        
--and cu.seccuota>0        
--and cu.fechavencimiento>=@fecini and cu.fechavencimiento<=@fecha        
--and cu.codconcepto = 'CAPI'    
--and p.codoficina in(select codoficina from @oficinas )     
--group by cu.codprestamo,cu.seccuota        
--,cu.fechavencimiento        
--,cu.estadocuota        
--,p.codoficina             
           
      
--select @fecha fecha, z.Nombre region,z.zona        
--,o.nomoficina nomoficina,o.codoficina codoficina , ca.codasesor       
--,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'        
--            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'        
--            when ca.nrodiasatraso>=31 then '31+DM' else '' end atraso         
--,case when ca.secuenciacliente>=5 then 5       
--         when ca.secuenciacliente>=3 then 3        
--         when ca.secuenciacliente=2 then 2        
--         else 1 end     rangoCiclo       
--,ca.tiporeprog        
--,sum(p.montodevengado) programado_s         
--,sum(case when p.estadocuota='CANCELADO'and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) monto_anticipado        
--, sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) monto_puntual       
--, sum(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.montopagado else 0 end) momto_atrasado        
--,count(p.codprestamo) - count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) sinpago_n        
--into  #cobranzaP      
--from #CUO p with(nolock)        
--inner join #ptmosCP ca with(nolock) on ca.codprestamo=p.codprestamo        
--inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina        
--inner join tclzona z with(nolock) on z.zona=o.zona        
--inner join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor        
--where o.zona not in('ZSC','ZCO')        
--group by p.fechavencimiento,z.Nombre ,z.zona         
--,o.codoficina        
--,o.nomoficina ,ca.codasesor       
--,case when ca.secuenciacliente>=5 then 5       
--         when ca.secuenciacliente>=3 then 3        
--         when ca.secuenciacliente=2 then 2        
--         else 1 end                
--,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'        
--            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'        
--            when ca.nrodiasatraso>=31 then '31+DM' else '' end        
--,ca.tiporeprog        
--order by z.Nombre       
            
         
            
--/*PARTE 3 --CONSULTA FINAL */            
--declare @cobranza table ( zona varchar (5),codoficina varchar(5),nomoficina varchar(30) ,rangoCiclo VARCHAR(20)           
--      ,progra_antCobrza money            
--      ,pag_antCobrza money            
--      ,progra_OrgCobrza money            
--      ,pag_orgCobrza  money            
--      ,Programado_S  money            
--      ,Pagado_S money ,cobranza_puntual money ,porpagado money,porpuntual money,sinpago_n int)      
--insert into @cobranza           
--select zona,codoficina,nomoficina   
--,case when rangoCiclo>=5 then 'c.5+'        
--         when rangoCiclo>=3 then 'c.3-4'        
--         when rangoCiclo=2 then 'c.2'        
--         else 'c.1' end   rangoCiclo         
-- ------------VALORES DE COBRANZA CLASIFICADA POR ANTICIPADA Y ORGANICA            
--,sum(case when tiporeprog='RENOV' then programado_s else 0 end) progra_antCobrza                  
--,sum(case when tiporeprog='RENOV' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_antCobrza                   
--,sum(case when tiporeprog='SINRE' then programado_s else 0 end) progra_OrgCobrza               
--,sum(case when tiporeprog='SINRE' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_orgCobrza             
           
-----VALORES DE COBRANZA TOTAL            
--,sum(programado_s) Programado_S              
--,sum(monto_anticipado+monto_puntual+momto_atrasado) Pagado_S                  
--,sum(monto_anticipado+monto_puntual) cobranza_puntual   
  
--,(sum(monto_anticipado+monto_puntual+momto_atrasado)/sum(programado_s))*100 Porpagado                  
--,(sum(monto_anticipado+monto_puntual)/sum(programado_s))*100 porpuntual   
--,sum(sinpago_n)sinpago_n  
--from #cobranzaP p with(nolock)      
--where atraso in ('0-7DM','8-30DM')--> 0 a 30 dm      
--group by ZONA, codoficina,nomoficina   
--,case when rangoCiclo>=5 then 'c.5+'        
--         when rangoCiclo>=3 then 'c.3-4'        
--         when rangoCiclo=2 then 'c.2'        
--         else 'c.1' end   
     
-- --por sucursal  
--select zona,codoficina,nomoficina  
--,sum(progra_antCobrza)progra_antCobrza,sum(pag_antCobrza)pag_antCobrza --- cobranza por tipo de crédito                  
--,sum(progra_OrgCobrza)progra_OrgCobrza ,sum(pag_orgCobrza)pag_orgCobrza             
--,sum(Programado_S)Programado_S         
--,sum(case when rangoCiclo='c.5+'  then Programado_S else 0 end) 'programadoC5+'        
--,sum(case when  rangoCiclo='c.3-4' then Programado_S else 0 end) 'programadoC3-4'        
--,sum(case when  rangoCiclo='c.2'  then Programado_S else 0 end) 'programadoC2'        
--,sum(case when  rangoCiclo='c.1' then Programado_S else 0  end) 'programadoC1'  
--,sum(Pagado_S)Pagado_S  
--,sum(case when rangoCiclo='c.5+'  then Pagado_S else 0 end )'cobradoC5+'        
--,sum(case when  rangoCiclo='c.3-4' then Pagado_S else 0 end) 'cobradoC3-4'        
--,sum(case when  rangoCiclo='c.2'  then Pagado_S else 0 end) 'cobradoC2'        
--,sum(case when  rangoCiclo='c.1' then Pagado_S else 0  end) 'cobradoC1'  
----,Porpagado  
----,sum(case when rangoCiclo='c.5+'  then Porpagado else 0 end) 'PorpagadoC5+'        
----,sum(case when  rangoCiclo='c.3-4' then Porpagado else 0 end) 'PorpagadoC3-4'        
----,sum(case when  rangoCiclo='c.2'  then Porpagado else 0 end )'PorpagadoC2'        
----,sum(case when  rangoCiclo='c.1' then Porpagado else 0  end) 'PorpagadoC1'  
--,sum(cobranza_puntual)cobranza_puntual  
----,sum(case when rangoCiclo='c.5+'  then porpuntual else 0 end) 'porpuntualC5+'        
----,sum(case when  rangoCiclo='c.3-4' then porpuntual else 0 end) 'porpuntualC3-4'        
----,sum(case when  rangoCiclo='c.2'  then porpuntual else 0 end) 'porpuntualC2'        
----,sum(case when  rangoCiclo='c.1' then porpuntual else 0  end) 'porpuntualC1'  
  
--,sum(case when rangoCiclo='c.5+'  then sinpago_n else 0 end) 'sinpago_nC5+'        
--,sum(case when  rangoCiclo='c.3-4' then sinpago_n else 0 end) 'sinpago_nC3-4'        
--,sum(case when  rangoCiclo='c.2'  then sinpago_n else 0 end )'sinpago_nC2'        
--,sum(case when  rangoCiclo='c.1' then sinpago_n else 0  end) 'sinpago_nC1'  
--,sum(sinpago_n)sinpago_n  
--,(case when sum(Programado_S)=0  then 0 else (sum(Pagado_S)/sum(Programado_S))*100 end) 'porRecuperacion'        
--,(case when sum(Programado_S)=0  then 0 else (sum(cobranza_puntual)/sum(Programado_S))*100 end) 'porRecuperaPuntual'        
--from @cobranza  
--group by zona,codoficina,nomoficina  
--union  
--select c.zona,c.zona,z.nombre  
--,sum(progra_antCobrza)progra_antCobrza,sum(pag_antCobrza)pag_antCobrza --- cobranza por tipo de crédito                  
--,sum(progra_OrgCobrza)progra_OrgCobrza ,sum(pag_orgCobrza)pag_orgCobrza             
--,sum(Programado_S)Programado_S         
--,sum(case when rangoCiclo='c.5+'  then Programado_S else 0 end) 'programadoC5+'        
--,sum(case when  rangoCiclo='c.3-4' then Programado_S else 0 end) 'programadoC3-4'        
--,sum(case when  rangoCiclo='c.2'  then Programado_S else 0 end) 'programadoC2'        
--,sum(case when  rangoCiclo='c.1' then Programado_S else 0  end) 'programadoC1'  
--,sum(Pagado_S)Pagado_S  
--,sum(case when rangoCiclo='c.5+'  then Pagado_S else 0 end )'cobradoC5+'        
--,sum(case when  rangoCiclo='c.3-4' then Pagado_S else 0 end) 'cobradoC3-4'        
--,sum(case when  rangoCiclo='c.2'  then Pagado_S else 0 end) 'cobradoC2'        
--,sum(case when  rangoCiclo='c.1' then Pagado_S else 0  end) 'cobradoC1'  
----,Por recuperado con atraso  
----,0 'PorpagadoC5+'        
----,0 'PorpagadoC3-4'        
----,0'PorpagadoC2'        
----,0 'PorpagadoC1'  
--,sum(cobranza_puntual)cobranza_puntual  
  
--,sum(case when rangoCiclo='c.5+'  then sinpago_n else 0 end) 'sinpago_nC5+'        
--,sum(case when  rangoCiclo='c.3-4' then sinpago_n else 0 end) 'sinpago_nC3-4'        
--,sum(case when  rangoCiclo='c.2'  then sinpago_n else 0 end )'sinpago_nC2'        
--,sum(case when  rangoCiclo='c.1' then sinpago_n else 0  end) 'sinpago_nC1'  
--,sum(sinpago_n)sinpago_n  
--,(case when sum(Programado_S)=0  then 0 else (sum(Pagado_S)/sum(Programado_S))*100 end) 'porRecuperacion'        
--,(case when sum(Programado_S)=0  then 0 else (sum(cobranza_puntual)/sum(Programado_S))*100 end) 'porRecuperaPuntual'        
--from @cobranza c  
--INNER JOIN tclzona z on z.zona=c.zona  
--group by c.zona,z.nombre  

--drop table #ptmosCP        
--drop table #CUO        
--drop table  #cobranzaP 
*/
GO