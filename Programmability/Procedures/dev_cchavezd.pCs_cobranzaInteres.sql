SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dev_cchavezd].[pCs_cobranzaInteres] @fecha smalldatetime      
as     
set nocount on 

--declare @fecha smalldatetime  ---LA FECHA DE CORTE
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion
 
declare @fecini smalldatetime
set @fecini = cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime) -- inicio de mes

--Cobranza programada vs real---
declare @fec_programado smalldatetime
set @fec_programado= @fecha

declare @fec_consulta smalldatetime
set @fec_consulta= @fecini  

/*PARTE 1 MUESTRA CREDITOS*/
create table #ptmos (codprestamo varchar(25),codasesor varchar(15),codoficina varchar(4),nrodiasatraso int,ciclo int,codproducto varchar(3),modalidadplazo char(1),cuotas int, tiporeprog varchar(10))
insert into #ptmos
          select distinct c.codprestamo,c.codasesor,c.codoficina,c.nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo
          ,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end,c.tiporeprog
          from tcscartera c with(nolock)
          inner join tcspadroncarteradet p with(nolock) on p.codprestamo=c.codprestamo
                      inner join tcscartera a with(nolock) on a.codprestamo=c.codprestamo and a.fecha=c.fechadesembolso
          where c.fecha=@fec_programado
          and c.cartera='ACTIVA' and c.codoficina not in('97','230','231')
          and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
  
create table #ptmos_Liq (codprestamo varchar(25),codasesor varchar(15),codoficina varchar(4),nrodiasatraso int,ciclo int,codproducto varchar(3),modalidadplazo char(1),cuotas int, tiporeprog varchar(10))
insert into #ptmos_Liq
select p.codprestamo,p.ultimoasesor,p.codoficina,0 nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo
,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end,p.tiporeprog
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo
inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso
where p.cancelacion>=@fec_consulta and cancelacion<=@fec_programado
union
select p.codprestamo,p.ultimoasesor,p.codoficina,0 nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo
,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end,p.tiporeprog
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo
inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso
where p.pasecastigado>=@fec_consulta and p.pasecastigado<=@fec_programado
delete from #ptmos
where codprestamo in(select codprestamo from #ptmos_liq with(nolock))
----------------------------------------------------------------------
/*PARTE 2.1 TABLA DE PAGOS*/
--Para creditos vigentes
select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montocuota) montocuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
into #PograInte1
from tcsplancuotas p with(nolock)
inner join #ptmos c on c.codprestamo=p.codprestamo and p.seccuota>c.cuotas
where p.fecha=@fec_programado and
p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos)
and p.codconcepto in('INTE')
and p.fechavencimiento>=@fec_consulta and p.fechavencimiento<=@fec_programado
group by c.codoficina,c.codasesor,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota

--Para creditos liquidados
select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montocuota) montocuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
into #PograInte2
from tcspadronplancuotas p with(nolock)
inner join #ptmos_Liq c on c.codprestamo=p.codprestamo and p.seccuota>c.cuotas
where p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos_Liq)
and p.fechavencimiento>=@fec_consulta and p.fechavencimiento<=@fec_programado
and p.codconcepto in('INTE')
group by c.codoficina,c.codasesor,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota

/*PARTE 3 consulta INTERES*/
select @fec_programado fecha
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'
           when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'
           when ca.nrodiasatraso>=31 then '31+DM' else '' end Atraso
,sum(p.montodevengado) ProgramadoInte_S
,sum(p.montopagado) PagadoInte_S
,round(case when sum(p.montopagado)=0 then 0 else (sum(p.montopagado)/sum(p.montodevengado))*100 end,2) PorPagadoInte_S
from (
          select * from #PograInte1 with(nolock)
          union
          select * from #PograInte2 with(nolock)
) p
inner join (
          select * from #ptmos with(nolock)
          union
          select * from #ptmos_Liq with(nolock)
) ca on ca.codprestamo=p.codprestamo --> este siempre estuvo de mas
inner join tcspadronclientes pro with(nolock) on p.codasesor=pro.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
where o.zona not in('ZSC','ZCO')and ca.tiporeprog <>'REEST'
group by 
case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'
           when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'
           when ca.nrodiasatraso>=31 then '31+DM' else '' end

drop table #PograInte1
drop table #PograInte2
drop table #ptmos
drop table #ptmos_Liq
 
 

GO