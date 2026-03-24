SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
      
--CALCULO DE -- Cobranza Puntual a cualquier fecha anterior --     
 --- se optimiza sp 2023.10.17 zccu     
CREATE procedure [dbo].[pCsCACobranzaPuntualcartas] @fecha smalldatetime, @fecini smalldatetime          
as          
--set nocount on          
--declare @fecha smalldatetime          
--set @fecha='20231016'          
          
--declare @fecini smalldatetime          
--set @fecini='20231001'          
           
create table #ptmosCPP (codprestamo varchar(25),codoficina varchar(4),nrodiasatraso int,secuenciacliente int,codproducto char(3),codasesor varchar(15))--          
insert into #ptmosCPP          
select c.codprestamo,c.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,codasesor----,d.ultimoasesor ---->Se cambia por codasesor(cartera)           
from tcscartera c with(nolock)          
inner join tcspadroncarteradet d with(nolock) on c.codprestamo=d.codprestamo          
where c.fecha=@fecha---1   
and c.codoficina not in ('97','230','231','999')         
and cartera='ACTIVA'          
        
insert into #ptmosCPP          
select d.codprestamo,d.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor          
from tcspadroncarteradet d with(nolock)          
left outer join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fechacorte          
where d.cancelacion>=@fecini and d.cancelacion<=@fecha          
and c.codoficina not in ('97','230','231','999')    
        
        
        
create table #CUOCPP(          
          codoficina varchar(4),          
          codprestamo varchar(25),          
          seccuota int,          
          montodevengado money,          
          montopagado money,          
          montocondonado money,          
          fechavencimiento smalldatetime,          
          fechapago smalldatetime,          
          estadocuota varchar(20))          
insert into #CUOCPP          
select p.codoficina,cu.codprestamo,cu.seccuota          
,sum(cu.montodevengado) montodevengado          
,sum(cu.montopagado) montopagado          
,sum(cu.montocondonado) montocondonado          
,cu.fechavencimiento          
,max(cu.fechapagoconcepto) fechapago          
,cu.estadocuota          
from tcspadronplancuotas cu with(nolock)          
inner join #ptmosCPP p with(nolock) on p.codprestamo=cu.codprestamo          
where cu.codprestamo in(select codprestamo from #ptmosCPP)          
and cu.numeroplan=0          
and cu.seccuota>0 
and cu.codconcepto = 'CAPI'                  
and cu.fechavencimiento>=@fecini and cu.fechavencimiento<=@fecha          
group by cu.codprestamo,cu.seccuota,cu.fechavencimiento          
,cu.estadocuota,p.codoficina          
    
           
select @fecha fecha, z.Nombre region          
,o.nomoficina sucursal        
,p.codoficina codoficina        
,pro.nombrecompleto promotor             
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'          
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'          
            when ca.nrodiasatraso>=31 then '31+DM' else '' end atraso               
,sum(p.montodevengado) programado_s          
,sum(case when p.estadocuota='CANCELADO'and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) monto_anticipado          
,sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) monto_puntual          
,sum(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento and p.fechapago<=@fecha then p.montopagado else 0 end) momto_atrasado            
from #CUOCPP p with(nolock)          
inner join #ptmosCPP ca with(nolock) on ca.codprestamo=p.codprestamo          
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina          
inner join tclzona z with(nolock) on z.zona=o.zona          
inner join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor          
where o.zona not in('ZSC','ZCO')          
group by p.fechavencimiento,z.Nombre          
,o.nomoficina         
,p.codoficina         
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'          
when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'          
            when ca.nrodiasatraso>=31 then '31+DM' else '' end          
            ,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then 1          
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then 2          
            when ca.nrodiasatraso>=31 then 3 else 4 end          
,pro.nombrecompleto          
order by z.Nombre          
        
          
          
drop table #ptmosCPP          
drop table #CUOCPP          
GO

GRANT EXECUTE ON [dbo].[pCsCACobranzaPuntualcartas] TO [mledesmav]
GO