SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaIncOrgP23_vs2] @fecha smalldatetime
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20210831'

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'--'20201007'

create table #COB(
	codoficina varchar(3),
	codasesor varchar(15),
	Promotor varchar(250),
	Programado_N money,
	Programado_S money,
	Programado_S_Cuota money,
	Pagado_S money,
	PorPagado_S money,
	nivel varchar(15),
	puntos int
)
--insert into #CO
--exec pCsCaCobPagadoProgramaOrga @fecha, @fecini--'20201001'
declare @fec_programado smalldatetime
set @fec_programado=@fecha--'20201008' --> FECHA DE CONSULTA EN LA BASE DE DATOS

declare @fec_consulta smalldatetime
set @fec_consulta=@fecini--'20201001'--@fec_programado+1--+7 --> FECHA DE VENCIMIENTO A PARTIR DE LA CUAL SE QUIERE CONSULTAR, ACUMULA--

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
and c.nrodiasatraso<=89
and c.tiporeprog<>'REEST'
and c.codoficina not in('230','231')

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
and c.nrodiasatraso<=89
and p.tiporeprog<>'REEST'
and p.codoficina not in('230','231')
union
select p.codprestamo,p.ultimoasesor,p.codoficina,0 nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo
,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end,p.tiporeprog
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo
inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso
--where p.pasecastigado>=@fec_programado and p.pasecastigado<=@fec_consulta--@fecha
where p.pasecastigado>=@fec_consulta and p.pasecastigado<=@fec_programado
and c.nrodiasatraso<=89
and p.tiporeprog<>'REEST'
and p.codoficina not in('230','231')

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

insert into #COB
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


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
--select c.*
--,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor
--,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else Promotor end coordinador
delete from #COB
from #COB c
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha--'20201007'
where case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else Promotor end='HUERFANO'

--select * from #CO

create table #P2Imor(
	codasesor varchar(15),
	coordinador varchar(250),
	codoficina  varchar(3),
	saldo money,
	saldo30 money,
	Imor30 money,
	nivel varchar(15),
	puntos int,
	Imor1 money,
	Imor8 money,
	Imor16 money
)
insert into #P2Imor
select codasesor,coordinador,codoficina,saldo,saldo30,Imor30
,case	when Imor30>=0 and Imor30<=3 then 'EXCELENTE'
		when Imor30>3 and Imor30<=5 then 'BUENO'
		when Imor30>5 and Imor30<=8 then 'ACEPTABLE'
		when Imor30>8 and Imor30<=12 then 'INADECUADO'
		when Imor30>12 and Imor30<=15 then 'MALO'
		when Imor30>15 then 'PESIMO' else '' end nivel
,case	when Imor30>=0 and Imor30<=3 then 5
		when Imor30>3 and Imor30<=5 then 4
		when Imor30>5 and Imor30<=8 then 3
		when Imor30>8 and Imor30<=12 then 2
		when Imor30>12 and Imor30<=15 then 1
		when Imor30>15 then 0 else 0 end puntos,Imor1,Imor8,Imor16
from (
	select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor
	,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador
	,c.codoficina
	,sum(d.saldocapital) saldo
	,sum(case when c.nrodiasatraso>30 then d.saldocapital else 0 end) saldo30
	,(sum(case when c.nrodiasatraso>30 then d.saldocapital else 0 end)
		/sum(d.saldocapital))*100 Imor30
	,(sum(case when c.nrodiasatraso>=1 then d.saldocapital else 0 end)
		/sum(d.saldocapital))*100 Imor1
	,(sum(case when c.nrodiasatraso>=8 then d.saldocapital else 0 end)
		/sum(d.saldocapital))*100 Imor8
	,(sum(case when c.nrodiasatraso>=16 then d.saldocapital else 0 end)
		/sum(d.saldocapital))*100 Imor16
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
	left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=c.fecha
	inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor
	where c.fecha=@fecha--'20201007'
	and c.cartera='ACTIVA' and c.codoficina not in('97','230','231')
	and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
	and c.tiporeprog<>'REEST'
	and case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end<>'HUERFANO'
	group by c.codoficina,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end
	,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end
) a

select codoficina,codasesor,promotor,programado_s,pagado_s,porpagado_s,nivelCO,puntosCO,saldo,saldo30,imor30,nivelp2,puntosp2
,puntosCO+puntosp2 puntaje
,case	when puntosCO+puntosp2>=10 then 'EXCELENTE'
		when puntosCO+puntosp2>=8 AND puntosCO+puntosp2<=9 then 'BUENO'
		when puntosCO+puntosp2>=6 AND puntosCO+puntosp2<=7 then 'ACEPTABLE'
		when puntosCO+puntosp2>=4 AND puntosCO+puntosp2<=5 then 'INADECUADO'
		when puntosCO+puntosp2>=2 AND puntosCO+puntosp2<=3 then 'MALO'
		when puntosCO+puntosp2<2 then 'PESIMO' else '' end nivelBono
,case	when puntosCO+puntosp2>=10 then 100
		when puntosCO+puntosp2>=8 AND puntosCO+puntosp2<=9 then 80
		when puntosCO+puntosp2>=6 AND puntosCO+puntosp2<=7 then 60
		when puntosCO+puntosp2>=4 AND puntosCO+puntosp2<=5 then 40
		when puntosCO+puntosp2>=2 AND puntosCO+puntosp2<=3 then 20
		when puntosCO+puntosp2<2 then 0 else 0 end PorBono
		,Imor1,Imor8,Imor16
from (
	select codoficina,codasesor,promotor
	,sum(programado_s) programado_s,sum(pagado_s) pagado_s,sum(porpagado_s) porpagado_s,max(nivelCO) nivelCO,sum(puntosCO) puntosCO
	,sum(saldo) saldo,sum(saldo30) saldo30,sum(imor30) imor30,max(nivelp2) nivelp2,sum(puntosp2) puntosp2
	,sum(Imor1) Imor1,sum(Imor8) Imor8,sum(Imor16) Imor16
	from (
		select codoficina,codasesor,promotor,programado_s,pagado_s,porpagado_s,nivel nivelCO,puntos puntosCO
		,0 saldo,0 saldo30,0 imor30,'' nivelp2,0 puntosp2,0 Imor1,0 Imor8,0 Imor16
		from #COB
		union
		select codoficina,codasesor,coordinador,0 programado_s,0 pagado_s,0 porpagado_s,'' nivelCO, 0 puntosCO
		,saldo,saldo30,imor30,nivel nivelp2,puntos puntosp2,Imor1,Imor8,Imor16
		from #P2Imor
	) a
	group by codoficina,codasesor,promotor
) b


drop table #P2Imor
drop table #COB
GO