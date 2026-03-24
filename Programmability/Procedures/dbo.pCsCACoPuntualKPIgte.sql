SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCACoPuntualKPIgte] @fecha smalldatetime, @fecini smalldatetime  
as  
--Cobranza Puntual al Día--   
set nocount on  
--declare @fecha smalldatetime  
--set @fecha='20230625'  
  
--declare @fecini smalldatetime  
--set @fecini='20230601'  
   
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


create table #CUO(  
          codoficina varchar(4),  
          codprestamo varchar(25),  
          seccuota int,  
          montodevengado money,  
          montopagado money,  
          montocondonado money,  
          fechavencimiento smalldatetime,  
          fechapago smalldatetime,  
          estadocuota varchar(20)  
)  
insert into #CUO  
select p.codoficina,cu.codprestamo,cu.seccuota  
,sum(cu.montodevengado) montodevengado  
,sum(cu.montopagado) montopagado  
,sum(cu.montocondonado) montocondonado  
,cu.fechavencimiento  
,max(cu.fechapagoconcepto) fechapago  
,cu.estadocuota  
from tcspadronplancuotas cu with(nolock)  
inner join #ptmos p with(nolock) on p.codprestamo=cu.codprestamo  
where cu.codprestamo in(select codprestamo from #ptmos)  
and cu.numeroplan=0  
and cu.seccuota>0 
and cu.codconcepto = 'CAPI'  
and cu.fechavencimiento>=@fecini 
and cu.fechavencimiento<=@fecha  
group by cu.codprestamo,cu.seccuota  
,cu.fechavencimiento  
,cu.estadocuota  
,p.codoficina  
   
---------------CONSULTA GENERAL---------------

   
select @fecha fecha
--,p.fechavencimiento, z.Nombre region  
--,o.nomoficina sucursal  
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'  
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'  
            when ca.nrodiasatraso>=31 then '31+DM' else '' end atraso  
  
--,case when ca.secuenciacliente>=10 then 'c.10+'  
--         when ca.secuenciacliente>=6 then 'c.6-9'  
--         when ca.secuenciacliente>=4 then 'c.4-5'  
--         when ca.secuenciacliente=3 then 'c.3'  
--         when ca.secuenciacliente=2 then 'c.2'  
--         else 'c.1' end rangoCiclo  
  
--,sum(p.montodevengado) - sum(p.montopagado) - sum(p.montocondonado) saldo  
--,sum(p.montocondonado) condonado  
   
--,count(p.codprestamo) programado_n  
,sum(p.montodevengado) programado_s  
  
--,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end) anticipado  
--, count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end) puntual  
--, count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) atrasado  
  
,sum(case when p.estadocuota='CANCELADO'and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) monto_anticipado  
, sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) monto_puntual  
, sum(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.montopagado else 0 end) momto_atrasado  
  
--,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end)  
--+ count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end)  
--+ count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) creditosPagados  
,sum(p.montopagado) capitalPagado  
--,0 pagado_por  
   
----,count(p.codprestamo) - count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) sinpago_n  
--,sum(p.montodevengado) - sum(case when p.estadocuota='CANCELADO' then p.montopagado else 0 end)-sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.montopagado else 0 end) sinpago_s  
--,0 sinpago_por  
   
--,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.codprestamo else null end) pagoparcial_n  
,sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.montopagado else 0 end) pagoparcial_s  
--,0 parcial_por  
   
--,0 total_n  
--,0 total_s  
--,0 total_por  
  
--,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then 1  
--            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then 2  
--            when ca.nrodiasatraso>=31 then 3 else 4 end orden  
--,pro.nombrecompleto promotor  
from #CUO p with(nolock)  
inner join #ptmos ca with(nolock) on ca.codprestamo=p.codprestamo  
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina  
--inner join tclzona z with(nolock) on z.zona=o.zona  
inner join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor  
--left outer join #CA c with(nolock) on c.codprestamo=p.codprestamo  
where o.zona not in('ZSC','ZCO')  
group by p.fechavencimiento--,z.Nombre  
--,p.codoficina  
,o.nomoficina  
--,cl.nombrecompleto  
--,p.codprestamo  
--,case when ca.secuenciacliente>=10 then 'c.10+'  
--         when ca.secuenciacliente>=6 then 'c.6-9'  
--         when ca.secuenciacliente>=4 then 'c.4-5'  
--         when ca.secuenciacliente=3 then 'c.3'  
--         when ca.secuenciacliente=2 then 'c.2'  
--         else 'c.1' end   
          
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'  
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'  
            when ca.nrodiasatraso>=31 then '31+DM' else '' end  
            --,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then 1  
            --when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then 2  
            --when ca.nrodiasatraso>=31 then 3 else 4 end  
--,pro.nombrecompleto  
--order by z.Nombre  
--,p.codoficina  
--,o.nomoficina  
--,p.codprestamo  
--,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then 1  
--            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then 2  
--            when ca.nrodiasatraso>=31 then 3 else 4 end  
  
  
drop table #ptmos  
drop table #CUO  
--drop table #CA  
GO