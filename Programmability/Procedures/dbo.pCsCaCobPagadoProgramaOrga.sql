SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaCobPagadoProgramaOrga] @fec_programado smalldatetime, @fec_consulta smalldatetime
as
--declare @fec_programado smalldatetime
--set @fec_programado='20201008' --> FECHA DE CONSULTA EN LA BASE DE DATOS

--declare @fec_consulta smalldatetime
--set @fec_consulta='20201001'--@fec_programado+1--+7 --> FECHA DE VENCIMIENTO A PARTIR DE LA CUAL SE QUIERE CONSULTAR, ACUMULA--

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
and c.nrodiasatraso<=30
and c.tiporeprog<>'REEST'
--select *
--from #ptmos
--where codoficina=336

create table #ptmos_Liq (codprestamo varchar(25),codasesor varchar(15),codoficina varchar(4),nrodiasatraso int,ciclo int,codproducto varchar(3),modalidadplazo char(1),cuotas int, tiporeprog varchar(10))
insert into #ptmos_Liq
select p.codprestamo,p.ultimoasesor,p.codoficina,0 nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo
,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end,p.tiporeprog
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo
inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso
--where p.cancelacion>=@fec_programado and cancelacion<=@fec_consulta--@fecha
where p.cancelacion>=@fec_consulta and cancelacion<=@fec_programado
and c.nrodiasatraso<=30
and p.tiporeprog<>'REEST'
union
select p.codprestamo,p.ultimoasesor,p.codoficina,0 nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo
,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end,p.tiporeprog
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo
inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso
--where p.pasecastigado>=@fec_programado and p.pasecastigado<=@fec_consulta--@fecha
where p.pasecastigado>=@fec_consulta and p.pasecastigado<=@fec_programado
and c.nrodiasatraso<=30
and p.tiporeprog<>'REEST'

delete from #ptmos
where codprestamo in(select codprestamo from #ptmos_liq with(nolock))
--select * from #ptmos with(nolock)
--select * from #ptmos_liq with(nolock)

/*PARTE 2 TABLA DE PAGOS*/
--Para creditos vigentes
create table #Pogra1(
	codoficina varchar(3),
	codasesor varchar(15),
	codprestamo varchar(20),
	seccuota int,
	montocuota money,
	montodevengado money,
	montopagado money,
	montocondonado money,
	fechavencimiento smalldatetime,
	fechapago smalldatetime,
	estadocuota varchar(20)
)
insert into #Pogra1
select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montocuota) montocuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
--into #Pogra1
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
create table #Pogra2(
	codoficina varchar(3),
	codasesor varchar(15),
	codprestamo varchar(20),
	seccuota int,
	montocuota money,
	montodevengado money,
	montopagado money,
	montocondonado money,
	fechavencimiento smalldatetime,
	fechapago smalldatetime,
	estadocuota varchar(20)
)
insert into #Pogra2
select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montocuota) montocuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
--into #Pogra2
from tcspadronplancuotas p with(nolock)
inner join #ptmos_Liq c on c.codprestamo=p.codprestamo and p.seccuota>c.cuotas
where p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos_Liq)
--and p.fechavencimiento>=@fec_programado and p.fechavencimiento<=@fec_programado
and p.fechavencimiento>=@fec_consulta and p.fechavencimiento<=@fec_programado
group by c.codoficina,c.codasesor,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota
--select distinct codprestamo from #Pogra2

/*PARTE 3 consulta final*/
create table #CO(
	codoficina varchar(3),
	codasesor varchar(15),
	Promotor varchar(250),
	Programado_N money,
	Programado_S money,
	Programado_S_Cuota money,
	Pagado_S money,
	PorPagado_S money,
)
insert into #CO
select p.codoficina,p.codasesor
,pro.nombrecompleto Promotor
,count(p.codprestamo) Programado_N
,sum(p.montodevengado) Programado_S
,sum(p.montocuota) Programado_S_Cuota
,sum(p.montopagado) Pagado_S
,round(case when sum(p.montopagado)=0 then 0 else (sum(p.montopagado)/sum(p.montodevengado))*100 end,2) PorPagado_S
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
group by p.codoficina,p.codasesor,pro.nombrecompleto

select codoficina,codasesor,Promotor,Programado_N,Programado_S,Programado_S_Cuota,Pagado_S,PorPagado_S
,case	when PorPagado_S>=97 then 'EXCELENTE'
		when PorPagado_S>=95 and PorPagado_S<97 then 'BUENO'
		when PorPagado_S>=93 and PorPagado_S<95 then 'ACEPTABLE'
		when PorPagado_S>=90 and PorPagado_S<93 then 'INADECUADO'
		when PorPagado_S>=85 and PorPagado_S<90 then 'MALO'
		when PorPagado_S<85 then 'PESIMO' end nivel
,case	when PorPagado_S>=97 then 5
		when PorPagado_S>=95 and PorPagado_S<97 then 4
		when PorPagado_S>=93 and PorPagado_S<95 then 3
		when PorPagado_S>=90 and PorPagado_S<93 then 2
		when PorPagado_S>=85 and PorPagado_S<90 then 1
		when PorPagado_S<85 then 0 end puntos
from #CO

drop table #CO
drop table #Pogra1
drop table #Pogra2
drop table #ptmos
drop table #ptmos_Liq
GO