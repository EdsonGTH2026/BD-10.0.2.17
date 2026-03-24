SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
                
create procedure [dbo].[pCsRptKPINacionaltbl2] @fecha smalldatetime
as   
set nocount on 

--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion
  
  
declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes

         
/*PARTE CREDITOS*/   
create table #ptmosCP (codprestamo varchar(25)  
      ,codoficina varchar(4)  
      ,nrodiasatraso int  
      ,secuenciacliente int  
      ,codproducto char(3)  
      ,codasesor varchar(15)  
      ,tiporeprog varchar(10))  
insert into #ptmosCP    
select c.codprestamo,c.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor,c.tiporeprog     
from tcscartera c with(nolock)    
inner join tcspadroncarteradet d with(nolock) on c.codprestamo=d.codprestamo    
where c.fecha=@fecha  
and cartera='ACTIVA'  and c.nrodiasatraso<=30    
insert into #ptmosCP    
select d.codprestamo,d.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor,c.tiporeprog      
from tcspadroncarteradet d with(nolock)    
left outer join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fechacorte    
where d.cancelacion>=@fecini and d.cancelacion<=@fecha    
       
       
       
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
where cu.codprestamo in(select codprestamo from #ptmosCP)    
and cu.numeroplan=0    
and cu.seccuota>0    
and cu.fechavencimiento>=@fecini and cu.fechavencimiento<=@fecha    
and cu.codconcepto = 'CAPI'    
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
  
------------VALORES DE COBRANZA CLASIFICADA POR ANTICIPADA Y ORGANICA        
--,sum(case when ca.tiporeprog='RENOV' then p.montodevengado else 0 end) progra_antCobrza              
--,sum(case when ca.tiporeprog='RENOV' then p.montopagado else 0 end) pag_antCobrza               
--,sum(case when ca.tiporeprog='SINRE' then p.montodevengado else 0 end) progra_OrgCobrza           
--,sum(case when ca.tiporeprog='SINRE' then p.montopagado else 0 end) pag_orgCobrza                   
into  #cobranzaP  
from #CUO p with(nolock)    
inner join #ptmosCP ca with(nolock) on ca.codprestamo=p.codprestamo    
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina    
inner join tclzona z with(nolock) on z.zona=o.zona    
inner join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor    
where o.zona not in('ZSC','ZCO')    
group by p.fechavencimiento,z.Nombre ,z.zona     
,o.codoficina    
,o.nomoficina ,ca.codasesor   
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
declare @cobranza table ( zona varchar(30)        
      ,progra_antCobrza money        
      ,pag_antCobrza money        
      ,progra_OrgCobrza money        
      ,pag_orgCobrza  money        
      ,Programado_S  money        
      ,Pagado_S money 
      --,Pagado_puntual money
      --,pagado_atrasado money               
      )        
insert into @cobranza       
select z.nombre        
 ------------VALORES DE COBRANZA CLASIFICADA POR ANTICIPADA Y ORGANICA        
,sum(case when tiporeprog='RENOV' then programado_s else 0 end) progra_antCobrza              
,sum(case when tiporeprog='RENOV' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_antCobrza               
,sum(case when tiporeprog='SINRE' then programado_s else 0 end) progra_OrgCobrza           
,sum(case when tiporeprog='SINRE' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_orgCobrza         
       
---VALORES DE COBRANZA TOTAL        
,sum(programado_s) Programado_S          
,sum(monto_anticipado+monto_puntual+momto_atrasado) Pagado_S              
--,sum(monto_anticipado) cobranza_puntual
--,sum(momto_atrasado) cobranza_atrasada
from #cobranzaP p with(nolock)  
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina 
inner join tclzona z with(nolock) on z.zona=p.zona
where atraso in ('0-7DM','8-30DM')--> 0 a 30 dm  
group by z.zona,z.nombre
order by z.nombre
 
 
--FILA DE TOTALES
declare @cobranzaTOT table ( zona varchar(30)        
      ,progra_antCobrza money        
      ,pag_antCobrza money        
      ,progra_OrgCobrza money        
      ,pag_orgCobrza  money        
      ,Programado_S  money        
      ,Pagado_S money 
      --,Pagado_puntual money
      --,pagado_atrasado money               
      ) 
insert into @cobranzaTOT   
select 'zTOTAL'       
 ------------VALORES DE COBRANZA CLASIFICADA POR ANTICIPADA Y ORGANICA        
,sum(case when tiporeprog='RENOV' then programado_s else 0 end) progra_antCobrza              
,sum(case when tiporeprog='RENOV' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_antCobrza               
,sum(case when tiporeprog='SINRE' then programado_s else 0 end) progra_OrgCobrza           
,sum(case when tiporeprog='SINRE' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) pag_orgCobrza         
       
---VALORES DE COBRANZA TOTAL        
,sum(programado_s) Programado_S          
,sum(monto_anticipado+monto_puntual+momto_atrasado) Pagado_S              
--,sum(monto_anticipado) cobranza_puntual
--,sum(momto_atrasado) cobranza_atrasada
from #cobranzaP p with(nolock)  
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina 
inner join tclzona z with(nolock) on z.zona=p.zona
where atraso in ('0-7DM','8-30DM')--> 0 a 30 dm  

select zona 
      ,round(pag_antCobrza*100/progra_antCobrza,2)  as '%Ranticipada'
      ,round(pag_orgCobrza*100/progra_OrgCobrza,2)  as '%organicas'
      --,Pagado_puntual as 'Cobranza Puntual'
      --,pagado_atrasado as 'Cobranza Atrasada'
      ,Pagado_S as 'Capital Cobrado'
      ,Programado_S as 'Capital Programado'
      ,round(Pagado_S*100/Programado_S,2) as 'Total'
from @cobranza
union
select 'zTOTAL'
      ,round(pag_antCobrza*100/progra_antCobrza,2)  as '%Ranticipada'
      ,round(pag_orgCobrza*100/progra_OrgCobrza,2)  as '%organicas'
      --,Pagado_puntual as 'Cobranza Puntual'
      --,pagado_atrasado as 'Cobranza Atrasada'
      ,Pagado_S as 'Capital Cobrado'
      ,Programado_S as 'Capital Programado'
      ,round(Pagado_S*100/Programado_S,2) as 'Total'
from @cobranzaTOT


drop table #ptmosCP    
drop table #CUO    
drop table  #cobranzaP  
GO