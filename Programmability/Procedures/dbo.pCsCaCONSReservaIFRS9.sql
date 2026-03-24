SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/****** Object:  StoredProcedure [dbo].[pCsCaCONSReservaIFRS9]    Script Date: 28/11/2025 08:38:01 am ******/
----------------SET ANSI_NULLS ON
----------------GO

----------------SET QUOTED_IDENTIFIER ON
----------------GO

------------------+++++++++++++++++++   CALCULO DE LAS RESERVAS CON LA NUEVA METODOLOGIA IFRS9   +++++++++++++++++++++++++++
------------------Sil - 2025.12.04
------------------SE CONSIDERA LA CARTERA CONSUMO Y LA CARTERA ACTIVA.
------------------IMPLEMENTACIÓN EN EL CIERRE DIARIO, GENERA LA TABLA:tCsCaCONSReservaIFRS9 
 
CREATE PROCEDURE [dbo].[pCsCaCONSReservaIFRS9] 
AS  
SET NOCOUNT ON   
BEGIN 


Declare @Fecha SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion

--declare @fecha smalldatetime
--set @fecha='20251203'
--set nocount on

--if exists(select 1 from tclperiodo where ultimodia=@fecha)
--begin
--print 'listo'




	--SE CALCULA LA CARTERA VIGENTE: UNICAMENTE DE CREDITOS CONSUMO: 

create table #ptmos (fecha SmallDateTime, codprestamo varchar(25))
insert into #ptmos
select distinct fecha, codprestamo from tcscartera with(nolock)
where fecha=@fecha and cartera='ACTIVA' 
and codoficina not in('97','230','231','999')
AND SUBSTRING (CodPrestamo,5,1)= 3      --- tipo consumo
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
AND CodPrestamo NOT IN (SELECT CUENTA FROM tCreditosExcluidos WITH(NOLOCK))

--select * from #ptmos



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

--select * from #Ga



	----********** ETAPA DEL CREDITO **************

	----Exposicion al incumplimiento: saldo insoluto + intereses
	---* Exposicion al incumplimineto Ajustado: se compara el saldo+ intereses VS la garantía

	SELECT CA.FECHA,CA.CodPrestamo
	,[dbo].[fduCAAsignaEtapaCredito_IFRS9] (CA.CodPrestamo,CA.FECHA) 'ETAPA_Detalle'
	INTO #EtapaCredito
	FROM #ptmos CA WITH(NOLOCK)
	--LEFT OUTER JOIN #GA GA WITH(NOLOCK)ON CA.CodPrestamo = GA.CodPrestamo

	--select * from #EtapaCredito



		------ GENERA EL DETALLE DEL PUNTAJE CREDITICIO
	SELECT E.CodPrestamo
	,CAST(CASE WHEN PATINDEX('%Etapa:%',E.ETAPA_Detalle)> 0 then substring(E.ETAPA_Detalle,PATINDEX('%Etapa:%',E.ETAPA_Detalle)+6,PATINDEX('%_Fecha Etapa 3:%',E.ETAPA_Detalle)-(PATINDEX('%Etapa:%',E.ETAPA_Detalle)+6)) ELSE '' END AS INT) 'Etapa_credito'
	,CASE WHEN PATINDEX('%_Fecha Etapa 3:%',E.ETAPA_Detalle)> 0 then substring(E.ETAPA_Detalle,PATINDEX('%_Fecha Etapa 3:%',E.ETAPA_Detalle)+15,PATINDEX('%.%',E.ETAPA_Detalle)-(PATINDEX('%_Fecha Etapa 3:%',E.ETAPA_Detalle)+15)) ELSE '' END 'Fecha_Etapa3'
	INTO #DetalleEtapa
	FROM #EtapaCredito E WITH(NOLOCK)

	--select * from #DetalleEtapa


delete from tCsCaConsReservaIFRS9 where fecha=@fecha
insert into tCsCaConsReservaIFRS9
(fecha,codusuario,codprestamo,CodProducto,TipoCredito, nrodiasatraso,tiporeprog,MontoGarLiq,EtapaCredito,IngresoTerceraEtapa,MesesTerceraEtapa
,SaldoCalificacion,ParteCubierta,ParteExpuesta
,PorcParteCubierta,PorcParteExpuesta,EPRC_ParteCubierta,EPRC_parteExpuesta,EPRC_InteresesTerceraEtapa)

SELECT @fecha fecha,d.codusuario,c.codprestamo
,SUBSTRING (C.CodPrestamo,5,3) CodProducto
,CASE  WHEN SUBSTRING (C.CodPrestamo,5,1)= 3 THEN 'CONSUMO' 
				WHEN CodProducto IN ('168','123') THEN 'VIVIENDA' ELSE 'COMERCIAL' END AS TipoCredito
,c.nrodiasatraso
,c.tiporeprog
,(case when c.saldocapital=0 then 0 else d.SaldoCapital/c.saldocapital end)*isnull(g.montogar,0) MontoGarLiq
,E.Etapa_credito, E.Fecha_Etapa3
,CASE WHEN E.Etapa_credito in (1,2) THEN 0 
	 ELSE DATEDIFF(MONTH ,E.Fecha_Etapa3 ,@Fecha )END 'MesesEtapa3'
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
	else isnull(d.interesvencido+d.moratoriovencido,0) end EPRC_InteresesTerceraEtapa

FROM tCsCarteraDet d with(nolock)
inner join tcscartera c with(nolock) on d.codprestamo=c.codprestamo and d.fecha=c.fecha
inner join #DetalleEtapa E with(nolock) on E.codprestamo=c.codprestamo
left outer join #ga g with(nolock) on g.codprestamo=d.codprestamo
LEFT JOIN tCaClProvisionIFRS9 PR with(nolock) ON C.CodTipoCredito = PR.CodTipoCredito AND (case when C.TipoReprog='REEST' then 'SINRE' else C.TipoReprog end)= PR.TipoReprog 
							  AND C.Fecha <= PR.VigenciaFin AND C.Fecha >= PR.VigenciaInicio 
							  AND C.NroDiasAtraso <= PR.DiasMaximo AND C.NroDiasAtraso >= PR.DiasMinimo 
							  AND C.Estado = PR.Estado
where c.fecha=@fecha
and c.codprestamo in(select codprestamo from #ptmos with(nolock))



drop table #ptmos
drop table #ga
drop table #EtapaCredito
drop table #DetalleEtapa
set nocount off



--select * from tCsCaConsReservaIFRS9  where fecha=@Fecha


END;
GO