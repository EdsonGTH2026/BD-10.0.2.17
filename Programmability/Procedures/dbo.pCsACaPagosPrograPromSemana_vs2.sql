SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsACaPagosPrograPromSemana_vs2]
as
set nocount on
set ansi_Warnings off

declare @fec_programado smalldatetime
--set @fec_programado='20200701'
select @fec_programado=fechaconsolidacion from vcsfechaconsolidacion

declare @diasemana int
set @diasemana = case when DATEPART(weekday, @fec_programado)=1 then 6 when DATEPART(weekday, @fec_programado)=2 then 0 else DATEPART(weekday, @fec_programado)-2 end

declare @fec_consulta smalldatetime
set @fec_consulta=dateadd(day,(-1)*@diasemana,@fec_programado)--@fec_programado+1--+7
--'20200428'
 
/*PARTE 1 MUESTRA CREDITOS*/
create table #ptmos (codprestamo varchar(25),codasesor varchar(15),codoficina varchar(4),nrodiasatraso int,ciclo int,codproducto varchar(3),modalidadplazo char(1),cuotas int)
insert into #ptmos
--select codprestamo,codasesor,codoficina,max(nrodiasatraso) nrodiasatraso,max(secuenciacliente) secuenciacliente,codproducto,modalidadplazo
--from (
          select distinct c.codprestamo,c.codasesor,c.codoficina,c.nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo
		  ,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end
          from tcscartera c with(nolock)
          inner join tcspadroncarteradet p with(nolock) on p.codprestamo=c.codprestamo
		  inner join tcscartera a with(nolock) on a.codprestamo=c.codprestamo and a.fecha=c.fechadesembolso
          where c.fecha=@fec_programado
		  and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
          and c.codoficina not in('97','230','231')
    	  and c.cartera='ACTIVA'
		  and c.nrodiasatraso>=0 and c.nrodiasatraso<90
		  --and c.codoficina=336
--) a
----where codprestamo='303-170-06-00-02889'
--group by codprestamo,codasesor,codoficina,codproducto,modalidadplazo
 
--select *
--from #ptmos
--where codoficina=336

create table #ptmos_Liq (codprestamo varchar(25),codasesor varchar(15),codoficina varchar(4),nrodiasatraso int,ciclo int,codproducto varchar(3),modalidadplazo char(1),cuotas int)
insert into #ptmos_Liq
select p.codprestamo,p.ultimoasesor,p.codoficina,0 nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo
,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo
inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso
--where p.cancelacion>=@fec_programado and cancelacion<=@fec_consulta--@fecha
where p.cancelacion>=@fec_consulta and cancelacion<=@fec_programado
--and c.codoficina=336
union
select p.codprestamo,p.ultimoasesor,p.codoficina,0 nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo
,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo
inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso
--where p.pasecastigado>=@fec_programado and p.pasecastigado<=@fec_consulta--@fecha
where p.pasecastigado>=@fec_consulta and p.pasecastigado<=@fec_programado
--and c.codoficina=336
 
delete from #ptmos
where codprestamo in(select codprestamo from #ptmos_liq with(nolock))
--select * from #ptmos with(nolock)
--select * from #ptmos_liq with(nolock)
 
/*PARTE 2 TABLA DE PAGOS*/
--Para creditos vigentes
select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montocuota) montocuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
into #Pogra1
from tcsplancuotas p with(nolock)
inner join #ptmos c on c.codprestamo=p.codprestamo and p.seccuota>c.cuotas
--where p.fecha=@fec_consulta and
where p.fecha=@fec_programado and
p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos)
--and p.fechavencimiento>=@fec_programado and p.fechavencimiento<=@fec_programado
and p.fechavencimiento>=@fec_consulta and p.fechavencimiento<=@fec_programado
group by c.codoficina,c.codasesor,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota
--select codprestamo from #Pogra1

--Para creditos liquidados
select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montocuota) montocuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
into #Pogra2
from tcspadronplancuotas p with(nolock)
inner join #ptmos_Liq c on c.codprestamo=p.codprestamo and p.seccuota>c.cuotas
where p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos_Liq)
--and p.fechavencimiento>=@fec_programado and p.fechavencimiento<=@fec_programado
and p.fechavencimiento>=@fec_consulta and p.fechavencimiento<=@fec_programado
group by c.codoficina,c.codasesor,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota
--select distinct codprestamo from #Pogra2
 
truncate table tCsACaPagosPrograPromSemana_vs2
insert into tCsACaPagosPrograPromSemana_vs2

/*PARTE 3 consulta final*/
select @fec_programado fechaprogramado,@fec_consulta fechaconsulta,z.nombre region,p.codoficina,o.nomoficina sucursal
,pro.nombrecompleto Promotor
--,p.codprestamo
,case when ca.ciclo<=3 then cast(ciclo as char(1)) else '>=4' end ciclo
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7dm'
           when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30dm'
           when ca.nrodiasatraso>=31 and ca.nrodiasatraso<=89 then '31-89dm'
           when ca.nrodiasatraso>=90 then '90+dm' else '' end Atraso
--,p.codasesor
--,p.fechavencimiento
,ca.codproducto,ca.modalidadplazo
,count(p.codprestamo) Programado_N
,sum(p.montodevengado) Programado_S
,sum(p.montocuota) Programado_S_Cuota
,sum(p.montopagado) Pagado_S
,sum(p.montocondonado) Condonado
,sum(p.montodevengado) - sum(p.montopagado) - sum(p.montocondonado) saldo
,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end) Anticipado
,count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end) Puntual
,count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) Atrasado
,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end)
+ count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end)
+ count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) Pagado_N
,count(p.codprestamo) - count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) SinPago_N
,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.codprestamo else null end) PagoParcial_N
,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago<p.fechavencimiento then p.codprestamo else null end) PagoParcial_N_Ant
,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago=p.fechavencimiento then p.codprestamo else null end) PagoParcial_N_dia
,sum(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) Anticipado_S
,sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) Puntual_S
,sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.montopagado else 0 end) PagoParcial_S
,sum(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.montopagado else 0 end) Atrasado_S

,round(case when count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end)=0 then 0
	else (cast(count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) as decimal(16,2))/cast(count(p.codprestamo) as decimal(16,2)))*100 end,2) PorPagado_N
,round(case when sum(p.montopagado)=0 then 0 else (sum(p.montopagado)/sum(p.montodevengado))*100 end,2) PorPagado_S
--into tCsACaPagosPrograPromSemana_vs2
from (
          select * from #Pogra1 with(nolock)
          union
          select * from #Pogra2 with(nolock)
) p
inner join (
          select * from #ptmos with(nolock)
          union
          select * from #ptmos_Liq with(nolock)
) ca on ca.codprestamo=p.codprestamo --> este siempre estuvo de mas
inner join tcspadronclientes pro with(nolock) on p.codasesor=pro.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
where o.zona not in('ZSC','ZCO')
group by z.nombre,p.codoficina,o.nomoficina
,case when ca.ciclo<=3 then cast(ciclo as char(1)) else '>=4' end
,pro.nombrecompleto
--,p.codprestamo
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7dm'
           when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30dm'
           when ca.nrodiasatraso>=31 and ca.nrodiasatraso<=89 then '31-89dm'
           when ca.nrodiasatraso>=90 then '90+dm' else '' end
,ca.codproducto,ca.modalidadplazo
 
drop table #Pogra1
drop table #Pogra2
drop table #ptmos
drop table #ptmos_Liq


GO