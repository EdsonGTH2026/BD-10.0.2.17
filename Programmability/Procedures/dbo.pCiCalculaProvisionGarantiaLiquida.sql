SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCiCalculaProvisionGarantiaLiquida]
as
set nocount on
Declare @Fecha SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion

--declare @fecha smalldatetime
--set @fecha='20200531'
--set nocount on

--if exists(select 1 from tclperiodo where ultimodia=@fecha)
--begin
--print 'listo'

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo from tcscartera with(nolock)
where fecha=@fecha and cartera='ACTIVA' 
and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))

delete from tCsCarteraReserva where fecha=@fecha

create table #Ga(codprestamo char(19),montogar money)
insert into #Ga
select codprestamo,sum(montogar) montogar
from (
	SELECT codigo codprestamo,sum(g.garantia) montogar 
	--SELECT g.codigo codprestamo,g.garantia,g.docpropiedad,a.codcuenta,a.saldocuenta,a.saldocuenta-g.garantia d,g.estado
	FROM tCsDiaGarantias g with(nolock)
	inner join tcsahorros a with(nolock) on a.codcuenta=g.docpropiedad and a.fecha=g.fecha
	where g.fecha=@fecha--'20170630'--
	and g.TipoGarantia IN ('GADPF', 'GARAH') --'-A-',
	and g.estado in('ACTIVO','MODIFICADO')--estado not in('LIBERADO','') 
	and (a.saldocuenta-g.garantia)>=0
	and len(g.codigo)>18
	and codigo in(select codprestamo from #ptmos with(nolock))
	group by g.codigo
	union
	select g.codigo codprestamo,sum(g.garantia)	garantia
	from tCsDiaGarantias g with(nolock)
	where g.fecha=@fecha and g.estado='ACTIVO'
	and g.tipogarantia in ('EFECT')
	and len(g.codigo)>18
	and codigo in(select codprestamo from #ptmos with(nolock))
	group by g.codigo
	) a
group by codprestamo


insert into tCsCarteraReserva
(fecha,codprestamo,codusuario,nrodiasatraso,tiporeprog,MontoGarLiq,SaldoCalificacion,ParteCubierta,ParteExpuesta
,PorcParteCubierta,PorcParteExpuesta,EPRC_ParteCubierta,EPRC_parteExpuesta,EPRC_interesesVencidos)

SELECT @fecha fecha,c.codprestamo,d.codusuario,c.nrodiasatraso
,c.tiporeprog
,(case when c.saldocapital=0 then 0 else d.SaldoCapital/c.saldocapital end)*isnull(g.montogar,0) MontoGarLiq

,case when c.codfondo=20 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.3
	  when c.codfondo=21 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.25
	else d.saldocapital + d.interesvigente+d.moratoriovigente end SaldoCalificacion

,case when ((case when c.saldocapital=0 then 0 else d.SaldoCapital/c.saldocapital end)*isnull(g.montogar,0))<=(
																case when c.codfondo=20 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.3
																	 when c.codfondo=21 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.25
																	else d.saldocapital + d.interesvigente+d.moratoriovigente end)
	  then ((case when c.saldocapital=0 then 0 else d.SaldoCapital/c.saldocapital end)*isnull(g.montogar,0)) else (
																case when c.codfondo=20 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.3
																	 when c.codfondo=21 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.25
																		else d.saldocapital + d.interesvigente+d.moratoriovigente end) end ParteCubierta
,case when (case when c.codfondo=20 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.3
				 when c.codfondo=21 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.25
			else d.saldocapital + d.interesvigente+d.moratoriovigente end)-((case when c.saldocapital=0 then 0 else d.SaldoCapital/c.saldocapital end)*isnull(g.montogar,0))>0
	  then (case when c.codfondo=20 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.3
				 when c.codfondo=21 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.25
			else d.saldocapital + d.interesvigente+d.moratoriovigente end)-((case when c.saldocapital=0 then 0 else d.SaldoCapital/c.saldocapital end)*isnull(g.montogar,0)) else 0 end ParteExpuesta

,case when c.CodTipoCredito=3 then 0.01 else
	--case when c.tiporeprog='REEST' then 0.1 else 0.005 end
	0.005
 end 'PorcParteCubierta'
--,cast(PR.Capital as decimal(16,2))/100 'PorcParteExpuesta'
,isnull(cast(PR.Capital as decimal(16,2))/100,0) 'PorcParteExpuesta' --OSC

,(case when c.CodTipoCredito=3 then 0.01 else
	--case when c.tiporeprog='REEST' then 0.1 else 0.005 end
	0.005
  end) * (case when ((case when c.saldocapital=0 then 0 else d.SaldoCapital/c.saldocapital end)*isnull(g.montogar,0))<=(
																				case when c.codfondo=20 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.3
																					 when c.codfondo=21 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.25
																				else d.saldocapital + d.interesvigente+d.moratoriovigente end)
	  then ((case when c.saldocapital=0 then 0 else d.SaldoCapital/c.saldocapital end)*isnull(g.montogar,0)) else (
																				case when c.codfondo=20 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.3
																					 when c.codfondo=21 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.25
																				else d.saldocapital + d.interesvigente+d.moratoriovigente end) end) EPRC_ParteCubierta
,isnull((case when (case when c.codfondo=20 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.3
				  when c.codfondo=21 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.25
				else d.saldocapital + d.interesvigente+d.moratoriovigente end)-((case when c.saldocapital=0 then 0 else d.SaldoCapital/c.saldocapital end)*isnull(g.montogar,0))>0
	  then (case when c.codfondo=20 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.3
				 when c.codfondo=21 then (d.saldocapital + d.interesvigente+d.moratoriovigente)*0.25
				else d.saldocapital + d.interesvigente+d.moratoriovigente end)-((case when c.saldocapital=0 then 0 else d.SaldoCapital/c.saldocapital end)*isnull(g.montogar,0)) else 0 end) * (cast(PR.Capital as decimal(16,2))/100)
			,0)	as EPRC_parteExpuesta  --OSC, correccion

,case when c.codfondo=20 then isnull((d.interesvencido+d.moratoriovencido),0)*0.3
	  when c.codfondo=21 then isnull((d.interesvencido+d.moratoriovencido),0)*0.25
	else isnull(d.interesvencido+d.moratoriovencido,0) end EPRC_interesesVencidos

FROM tCsCarteraDet d with(nolock)
inner join tcscartera c with(nolock) on d.codprestamo=c.codprestamo and d.fecha=c.fecha
left outer join #ga g with(nolock) on g.codprestamo=d.codprestamo
LEFT JOIN tCaClProvision PR with(nolock) ON C.CodTipoCredito = PR.CodTipoCredito AND (case when C.TipoReprog='REEST' then 'SINRE' else C.TipoReprog end)= PR.TipoReprog 
							  AND C.Fecha <= PR.VigenciaFin AND C.Fecha >= PR.VigenciaInicio 
							  AND C.NroDiasAtraso <= PR.DiasMaximo AND C.NroDiasAtraso >= PR.DiasMinimo 
							  AND C.Estado = PR.Estado
where c.fecha=@fecha
and c.codprestamo in(select codprestamo from #ptmos with(nolock))

drop table #ptmos
drop table #ga
set nocount off
--end
GO