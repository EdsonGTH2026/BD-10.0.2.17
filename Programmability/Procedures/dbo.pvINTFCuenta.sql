SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--exec pvINTFCuenta '20141031'

CREATE PROCEDURE [dbo].[pvINTFCuenta] @fecha smalldatetime AS
	SET NOCOUNT ON
  
--declare @fecha smalldatetime
--set @fecha='20121231'
--CREATE VIEW [dbo].[vINTFCuenta] actual más de 4:37min lo corte no lo deje termimar
--demora 04:30min en generar
--AS
--SELECT     CodPrestamo, CodUsuario= Ltrim(Rtrim(CodUsuario)), ClaveUsuario, NombreUsuario, Responsabilidad, TipoCuenta, TipoContrato, UnidadMonetaria, Rtrim(Ltrim(STR(ImporteAvaluo, 18, 0))) 
--                      AS ImporteAvaluo, NumeroPagos, FrecuenciaPagos, Rtrim(Ltrim(STR(MontoPagar, 18, 0))) AS MontoPagar, Apertura, UltimoPago, Disposicion, Cancelacion, Reporte, 
--                      Garantia, Rtrim(Ltrim(STR(CreditoMaximo, 18, 0))) AS CreditoMaximo, Rtrim(Ltrim(STR(SaldoActual, 18, 0))) AS SaldoActual,  LimiteCredito, Rtrim(Ltrim(STR(SaldoVencido, 18, 0))) 
--                      AS SaldoVencido, PagosVencidos, MOP, HistoricoPagos, Observacion, PagosReportados, MOP02, MOP03, MOP04, MOP05mas, AOClave, AONombre, 
--                      AOCuenta, FinSegmento
--FROM         (SELECT     *
--                       FROM          vINTFCuentaCartera
--                       UNION
--                       SELECT     *
--                       FROM         vINTFCuentaAvales
--                       UNION
--                       SELECT     *
--                       FROM         vINTFCuentaCancelados
--	          UNION
--                       SELECT     *
--                       FROM         vINTFCuentaCodeudores) Datos

--con esta temporal baja a 02:03min
create table #tblmop(
  codprestamo varchar(25),
  codusuario varchar(15),
  numeroplan int,
  seccuota int,
  MOP varchar(3)
)

insert into #tblmop
SELECT DISTINCT tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.CodUsuario, tCsPadronPlanCuotas.NumeroPlan
,tCsPadronPlanCuotas.SecCuota, CASE WHEN substring(tCsPadronPlanCuotas.codprestamo, 5, 3) = '303' THEN '01' 
ELSE dbo.tCsBuroMOP.MOP END MOP
FROM tCsPadronPlanCuotas with(nolock) 
--INNER JOIN vINTFCabecera
--ON tCsPadronPlanCuotas.FechaVencimiento <=(SELECT Corte FROM vINTFCabecera) --demora 48segs
INNER JOIN tCsBuroMOP 
ON tCsPadronPlanCuotas.DiasAtrCuota >= tCsBuroMOP.Inicio AND tCsPadronPlanCuotas.DiasAtrCuota <= tCsBuroMOP.Fin
where tCsPadronPlanCuotas.FechaVencimiento <=@fecha--demora 29seg; 972,383reg
--and tCsPadronPlanCuotas.codprestamo='018-158-06-04-00037'
--son 33054 reg
--con esta temporal baja a 01:24min
create table #tblmesgar(
  fecha       smalldatetime,
  codigo varchar(25),
  ImporteAvaluo decimal(16,4),
  DescGarantia varchar(300)
)

insert into #tblmesgar
SELECT Filtro.Fecha, Datos.Codigo, sum(Filtro.Garantia) AS ImporteAvaluo
,'CREDITO GARANTIZADO' DescGarantia
--, tGaClTipoGarantias.DescGarantia
FROM (SELECT Fecha, Codigo, MAX(Garantia) AS Garantia
     FROM (SELECT Fecha, Codigo, TipoGarantia, Round(SUM(moComercial), 0) AS Garantia
           FROM tCsMesGarantias tCsGarantias with(nolock)
           WHERE (Estgarantia NOT IN ('INACTIVO')) and fecha=@fecha
           GROUP BY Fecha, Codigo, TipoGarantia) Datos
     GROUP BY Fecha, Codigo) Filtro 
INNER JOIN
    (SELECT Fecha, Codigo, TipoGarantia, Round(SUM(mocomercial), 0) AS Garantia
     FROM tCsMesGarantias tCsGarantias with(nolock)
     WHERE (Estgarantia NOT IN ('INACTIVO')) and fecha=@fecha
     GROUP BY FEcha, Codigo, TipoGarantia) Datos 
     ON Filtro.Codigo = Datos.Codigo AND Filtro.Garantia = Datos.Garantia AND Filtro.Fecha = Datos.Fecha 
LEFT OUTER JOIN tGaClTipoGarantias ON Datos.TipoGarantia = tGaClTipoGarantias.TipoGarantia
group by Filtro.Fecha, Datos.Codigo

create table #tCsMesPlanCuotas(
  fecha smalldatetime,
  codprestamo varchar(25),
  MontoDevengado decimal(16,4),
  MontoPagado decimal(16,4),
  MontoCondonado decimal(16,4),
  DiasAtrCuota int
)

insert into #tCsMesPlanCuotas
SELECT Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado, CASE WHEN DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota
FROM tCsMesPlanCuotas with(nolock) --demora 01:32 min
WHERE (CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')) AND (EstadoConcepto NOT IN ('ANULADO', 'CANCELADO'))
and fecha=@fecha

create table #PrimerIncumplimiento(
  codprestamo varchar(25),
  fechapi smalldatetime
)

insert into #PrimerIncumplimiento
SELECT CodPrestamo, min(fechavencimiento) fechavencimiento
FROM tCsPadronPlanCuotas with(nolock) --demora 00:01 min tCsMesPlanCuotas
WHERE (CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE'))
and DiasAtrCuota>0
and fechavencimiento<=@fecha
group by CodPrestamo

truncate table tCsBuroxTblReICue

insert into tCsBuroxTblReICue
/************************************vINTFCuentaCartera****************************************/
--despues de los cambios demora 1:49min con 22,635reg
SELECT VISTA.CodPrestamo, VISTA.CodUsuario, vINTFCabecera.ClaveUsuario, vINTFCabecera.NombreUsuario, 
--RESPONSABILIDAD:
case when tCsCartera.FechaDesembolso>='20130101' then
  CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'C' ELSE tCaClTecnologia.Responsabilidad END
else
  CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'J' ELSE tCaClTecnologia.Responsabilidad END 
end
AS Responsabilidad,
'I' AS TipoCuenta
,--tCaProducto.TipoContrato
case when tCsCartera.FechaDesembolso>='20130101' then
  case when tCsCartera.codoficina='97' then 'PN' else 'SE' end
else
  tCaProducto.TipoContrato
end 
as TipoContrato
, CASE WHEN tipo = 'Aval' THEN tClMonedas_1.INTF ELSE tClMonedas.INTF END AS UnidadMonetaria, 
CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END AS ImporteAvaluo, 
CASE WHEN tipo = 'Aval' THEN tCsCartera.NroCuotas ELSE tCsCartera_1.NroCuotas END AS NumeroPagos, 
CASE WHEN Tipo = 'Aval' THEN tCaClModalidadPlazo_1.INTF ELSE tCaClModalidadPlazo.INTF END AS FrecuenciaPagos, 
--CASE WHEN Tipo = 'Cancelados' or (CV.codprestamo is not null) THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar, --> aqui venta
CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar,
CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Apertura, 
--CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
--ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') END AS UltimoPago,
dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA')  UltimoPago,
CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Disposicion, 
--case when CV.codprestamo is not null then
--  dbo.fduFechaATexto(CV.fecha, 'DDMMAAAA')
--else
  CASE WHEN Tipo = 'Cancelados' THEN dbo.fduFechaATexto(tCsPadronCarteraDet.Cancelacion, 'DDMMAAAA') 
  ELSE '' END 
--end
AS Cancelacion, --> aqui venta FechaCierre
vINTFCabecera.FechaReporte AS Reporte, CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia, 
CreditoMaximo.CreditoMaximo, 
--CASE WHEN Tipo = 'Cancelados' or (CV.codprestamo is not null) THEN 0 --> aqui venta
CASE WHEN Tipo = 'Cancelados' THEN 0
ELSE ROUND(tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE+ tCsCartera.SaldoINPE, 0) END AS SaldoActual
, '' AS LimiteCredito, 
case when tCscartera.codoficina='97' --then 0
	then
	(
	case when tCscartera.codprestamo in (
		  '097-303-06-02-00580',
		  '097-303-06-04-00463',
		  '097-303-06-04-00544',
		  '097-303-06-06-00528',
		  '097-303-06-08-00609',
		  '097-303-06-08-00744',
		  '097-303-06-09-00628') then Vencido.SaldoVencido else 0 end
	)
else
  CASE When tCsCartera.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END 
end
AS SaldoVencido,  
case when tCscartera.codoficina='97' then 0
else
  CASE WHEN tipo = 'Cancelados' THEN 0 ELSE tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas END 
end
AS PagosVencidos, 
----MOP: Manner Of Payment
--case when CV.codprestamo is not null then '96'
--else
  CASE 
  WHEN 	dbo.fdufechaatexto(tCsCartera.FechaDesembolso, 'AAAAMM') = dbo.fdufechaatexto(VISTA.Fecha, 'AAAAMM') AND 
  tCsCartera.FechaDesembolso = dbo.tCsCartera.FechaUltimoMovimiento THEN '00' 
  WHEN 	Tipo = 'Cancelados' Then '01' 
  WHEN tCsCartera.Judicial = 'Judicial' and tCsBuroMOP.MOP = '01' Then '02'
  WHEN tCsCartera.Judicial = 'Judicial' Then tCsBuroMOP.MOP
  WHEN 	tCscartera.Cartera = 'CASTIGADA' Then '97'
  --WHEN dbo.tCsCartera.TipoReprog <> 'SINRE' THEN '02'
  WHEN substring(tCscartera.codprestamo,5, 3) = '303' 
  THEN --'01'
	    case when tCscartera.codprestamo in (
		    '097-303-06-02-00580',
		    '097-303-06-04-00463',
		    '097-303-06-04-00544',
		    '097-303-06-06-00528',
		    '097-303-06-08-00609',
		    '097-303-06-08-00744',
		    '097-303-06-09-00628') then tCsBuroMOP.MOP else '01' end
  ELSE 	tCsBuroMOP.MOP END 
--end
AS MOP-->aqui venta
, '' AS HistoricoPagos, 
--OBSERVACION
--case when CV.codprestamo is not null then 'CV' else 
  CASE WHEN tCsCartera.Judicial = 'Judicial' Then 'SG' 
			 WHEN tCscartera.Cartera = 'CASTIGADA' THEN 'UP' 
			 ELSE '' END 
--end 
			AS Observacion, --> aqui venta
Historico.PagosReportados, 
Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta, 
case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end FprimerIncum,
--CASE WHEN Tipo = 'Cancelados' or (CV.codprestamo is not null) THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END AS SaldoInsoluto, -->aqui venta
CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END AS SaldoInsoluto,
'FIN' AS FinSegmento
/*FROM <----------*/
FROM (SELECT CodPrestamo, Round(SUM(MontoCuota), 0) AS MontoPagar
      FROM tCsPadronPlanCuotas with(nolock)
      WHERE (SecCuota = 1)
      GROUP BY CodPrestamo) MontoPagar 
      RIGHT OUTER JOIN
       (SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04) 
        AS MOP04, SUM(MOP05) AS MOP05
        FROM (SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01, 
              CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03, 
              CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05
              FROM (
                    --SELECT DISTINCT tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.CodUsuario, tCsPadronPlanCuotas.NumeroPlan
                    --,tCsPadronPlanCuotas.SecCuota, CASE WHEN substring(tCsPadronPlanCuotas.codprestamo, 5, 3) = '303' THEN '01' 
                    --ELSE dbo.tCsBuroMOP.MOP END MOP
                    --FROM tCsPadronPlanCuotas with(nolock) 
                    ----INNER JOIN vINTFCabecera
                    ----ON tCsPadronPlanCuotas.FechaVencimiento <=(SELECT Corte FROM vINTFCabecera) --demora 48segs
                    --INNER JOIN tCsBuroMOP 
                    --ON tCsPadronPlanCuotas.DiasAtrCuota >= tCsBuroMOP.Inicio AND tCsPadronPlanCuotas.DiasAtrCuota <= tCsBuroMOP.Fin
                    --where tCsPadronPlanCuotas.FechaVencimiento <='20121231'--@fecha--demora 29seg; 972,383reg
                    select codprestamo,codusuario,numeroplan,seccuota,MOP from #tblmop
              ) Datos
       ) Datos
      GROUP BY CodPrestamo) Historico 
--    RIGHT OUTER JOIN vINTFNombreCartera VISTA 
RIGHT OUTER JOIN (select * from tCsBuroxTblReInom where tipo='Cartera') VISTA 
LEFT OUTER JOIN (
     SELECT Fecha, CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado), 0) AS SaldoVencido
     FROM (
--	SELECT Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado, CASE WHEN DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota
--           	FROM tCsMesPlanCuotas with(nolock) --demora 01:32 min
--	WHERE (CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')) AND (EstadoConcepto NOT IN ('ANULADO', 'CANCELADO'))
--	and fecha=@fecha--'20121231'--demora 2seg al agregar esta linea
	select Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado,DiasAtrCuota from #tCsMesPlanCuotas
           ) Vencido
     WHERE (DiasAtrCuota = 1)
     GROUP BY Fecha, CodPrestamo) Vencido 
     ON VISTA.Fecha = Vencido.Fecha AND VISTA.CodPrestamo = Vencido.CodPrestamo COLLATE Modern_Spanish_CI_AI 
     ON Historico.CodPrestamo COLLATE Modern_Spanish_CI_AI = VISTA.CodPrestamo 
LEFT OUTER JOIN (
     SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
     FROM (--inicialmente demora 04:15min, luego me saco 25seg
           SELECT tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
           FROM tCsPadronCarteraDet with(nolock) 
           --INNER JOIN tCsCarteraDet with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
           --tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
           --INNER JOIN tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
           INNER JOIN tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
           --con esta ultima linea demora 7seg; 70,628 reg, luego me saco 3seg
           ) Datos 
     --INNER JOIN vINTFCabecera ON Datos.FechaDesembolso <= vINTFCabecera.Corte
     where Datos.FechaDesembolso<=@fecha--'20121231'-- con este baja de 7 o 3 seg a 1seg
     GROUP BY Datos.CodUsuario
     ) CreditoMaximo ON VISTA.CodUsuario = CreditoMaximo.CodUsuario 
LEFT OUTER JOIN tCaProducto ON SUBSTRING(VISTA.CodPrestamo, 5, 3) = tCaProducto.CodProducto 
ON MontoPagar.CodPrestamo = VISTA.CodPrestamo 
LEFT OUTER JOIN tCaClModalidadPlazo tCaClModalidadPlazo_1 
RIGHT OUTER JOIN tCsCartera with(nolock) ON tCaClModalidadPlazo_1.ModalidadPlazo = tCsCartera.ModalidadPlazo 
LEFT OUTER JOIN tClMonedas tClMonedas_1 ON tCsCartera.CodMoneda = tClMonedas_1.CodMoneda 
LEFT OUTER JOIN tCsBuroMOP ON tCsCartera.NroDiasAtraso >= tCsBuroMOP.Inicio AND tCsCartera.NroDiasAtraso <= tCsBuroMOP.Fin 
ON VISTA.Fecha = tCsCartera.Fecha AND VISTA.CodPrestamo = tCsCartera.CodPrestamo 
LEFT OUTER JOIN tClMonedas 
RIGHT OUTER JOIN tCsCartera tCsCartera_1 with(nolock) 
INNER JOIN tCsBuroMOP tCsBuroMOP_1 ON tCsCartera_1.NroDiasAtraso >= tCsBuroMOP_1.Inicio AND tCsCartera_1.NroDiasAtraso <= tCsBuroMOP_1.Fin 
LEFT OUTER JOIN tCaClModalidadPlazo ON tCsCartera_1.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo 
ON tClMonedas.CodMoneda = tCsCartera_1.CodMoneda 
RIGHT OUTER JOIN tCsPadronCarteraDet with(nolock) ON tCsCartera_1.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
                      tCsCartera_1.Fecha = tCsPadronCarteraDet.FechaCorte 
ON VISTA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND VISTA.CodUsuario = tCsPadronCarteraDet.CodUsuario 
LEFT OUTER JOIN (
     --demora 8seg
     --SELECT Filtro.Fecha, Datos.Codigo, Filtro.Garantia AS ImporteAvaluo, tGaClTipoGarantias.DescGarantia
     --FROM (SELECT Fecha, Codigo, MAX(Garantia) AS Garantia
     --      FROM (SELECT Fecha, Codigo, TipoGarantia, Round(SUM(moComercial), 0) AS Garantia
     --            FROM tCsMesGarantias tCsGarantias with(nolock)
     --            WHERE (Estgarantia NOT IN ('INACTIVO'))
     --            GROUP BY Fecha, Codigo, TipoGarantia) Datos
     --      GROUP BY Fecha, Codigo) Filtro 
     --INNER JOIN
     --     (SELECT Fecha, Codigo, TipoGarantia, Round(SUM(mocomercial), 0) AS Garantia
     --      FROM tCsMesGarantias tCsGarantias with(nolock)
     --      WHERE (Estgarantia NOT IN ('INACTIVO'))
     --      GROUP BY FEcha, Codigo, TipoGarantia) Datos 
     --      ON Filtro.Codigo = Datos.Codigo AND Filtro.Garantia = Datos.Garantia AND Filtro.Fecha = Datos.Fecha 
     --LEFT OUTER JOIN tGaClTipoGarantias ON Datos.TipoGarantia = tGaClTipoGarantias.TipoGarantia
     select fecha, codigo, ImporteAvaluo, DescGarantia from #tblmesgar
     ) Avaluo 
ON VISTA.Fecha = Avaluo.Fecha AND VISTA.CodPrestamo = Avaluo.Codigo 
LEFT OUTER JOIN tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia 
LEFT OUTER JOIN #PrimerIncumplimiento prin on  prin.codprestamo=VISTA.CodPrestamo
--LEFT OUTER JOIN [10.0.2.14].[Finmas].[dbo].[tCaCtasLiqPago] CV on CV.codprestamo=VISTA.CodPrestamo --> aqui venta
CROSS JOIN [FinAmigoExterno].dbo.vINTFCabecera vINTFCabecera

union
/************************************vINTFCuentaAvales****************************************/
----49 seg con 1,641 reg ojo deberian ser 1703 segun vintnombreavales o 1640 segun tCsBuroxTblReInom
SELECT VISTA.CodPrestamo, VISTA.CodUsuario, vINTFCabecera.ClaveUsuario, vINTFCabecera.NombreUsuario, 
--RESPONSABILIDAD:
--CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'J' ELSE tCaClTecnologia.Responsabilidad END AS Responsabilidad,
case when tCsCartera.FechaDesembolso>='20130101' then
  CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'C' ELSE tCaClTecnologia.Responsabilidad END
else
  CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'J' ELSE tCaClTecnologia.Responsabilidad END 
end
AS Responsabilidad,
'I' AS TipoCuenta
,-- tCaProducto.TipoContrato
case when tCsCartera.FechaDesembolso>='20130101' then
  case when tCsCartera.codoficina='97' then 'PN' else 'SE' end
else
  tCaProducto.TipoContrato
end 
as TipoContrato
, 
CASE WHEN tipo = 'Aval' THEN tClMonedas_1.INTF ELSE tClMonedas.INTF END AS UnidadMonetaria, 
CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END AS ImporteAvaluo, 
CASE WHEN tipo = 'Aval' THEN tCsCartera.NroCuotas ELSE tCsCartera_1.NroCuotas END AS NumeroPagos, 
CASE WHEN Tipo = 'Aval' THEN tCaClModalidadPlazo_1.INTF ELSE tCaClModalidadPlazo.INTF END AS FrecuenciaPagos, 
--CASE WHEN Tipo = 'Cancelados' or (CV.codprestamo is not null) THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar, -->aqui venta
CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar,
CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Apertura, 
CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') END AS UltimoPago, 
CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Disposicion, 
--case when CV.codprestamo is not null then
--  dbo.fduFechaATexto(CV.fecha, 'DDMMAAAA')
--else
  CASE WHEN Tipo = 'Cancelados' THEN dbo.fduFechaATexto(tCsPadronCarteraDet.Cancelacion, 'DDMMAAAA') 
  ELSE '' END 
--end
AS Cancelacion, --> aqui venta fecha cierre

vINTFCabecera.FechaReporte AS Reporte, CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia, 
CreditoMaximo.CreditoMaximo, 
--CASE WHEN Tipo = 'Cancelados' or (CV.codprestamo is not null) THEN 0 
CASE WHEN Tipo = 'Cancelados' THEN 0 
ELSE ROUND(tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE+ tCsCartera.SaldoINPE, 0) END AS SaldoActual --> aqui venta
, '' AS LimiteCredito, --aqui
CASE When tCsCartera.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END AS SaldoVencido, 
CASE WHEN tipo = 'Cancelados' THEN 0 ELSE tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas END AS PagosVencidos, 
----MOP: Manner Of Payment
--case when CV.codprestamo is not null then '96'
--else
  CASE 
		WHEN 	dbo.fdufechaatexto(tCsCartera.FechaDesembolso, 'AAAAMM') = dbo.fdufechaatexto(VISTA.Fecha, 'AAAAMM') AND 
                     		 tCsCartera.FechaDesembolso = tCsCartera.FechaUltimoMovimiento THEN '00' 
		WHEN 	Tipo = 'Cancelados' Then '01' 
		WHEN tCsCartera.Judicial = 'Judicial' and tCsBuroMOP.MOP = '01' Then '02'
		WHEN tCsCartera.Judicial = 'Judicial' Then tCsBuroMOP.MOP
		WHEN 	tCscartera.Cartera = 'CASTIGADA' Then '97'
			--WHEN dbo.tCsCartera.TipoReprog <> 'SINRE' THEN '02'
		ELSE tCsBuroMOP.MOP
    END
--end
AS MOP--> aqui venta
, '' AS HistoricoPagos,
--OBSERVACION
--case when CV.codprestamo is not null then 'CV' else
  CASE 	WHEN tCsCartera.Judicial = 'Judicial' Then 'SG' 
			WHEN tCscartera.Cartera = 'CASTIGADA' THEN 'UP' 
			ELSE '' END
--end 
AS Observacion, --aqui venta
Historico.PagosReportados, 
Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta,
case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end FprimerIncum,
--CASE WHEN Tipo = 'Cancelados' or (CV.codprestamo is not null) THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END AS SaldoInsoluto,-->aqui venta
CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END AS SaldoInsoluto,-->aqui venta
'FIN' AS FinSegmento
/*FROM <----------*/
FROM (SELECT CodPrestamo, Round(SUM(MontoCuota), 0) AS MontoPagar
      FROM tCsPadronPlanCuotas with(nolock)
      WHERE (SecCuota = 1)
      GROUP BY CodPrestamo) MontoPagar 
      RIGHT OUTER JOIN
            (SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04) 
             AS MOP04, SUM(MOP05) AS MOP05
             FROM (SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01, 
                   CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03, 
                   CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05
                   FROM (
                         --SELECT DISTINCT tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.CodUsuario, tCsPadronPlanCuotas.NumeroPlan
                         --, tCsPadronPlanCuotas.SecCuota, tCsBuroMOP.MOP
                         --FROM tCsPadronPlanCuotas with(nolock) 
                         ----INNER JOIN vINTFCabecera 
                         ----ON tCsPadronPlanCuotas.FechaVencimiento <=(SELECT Corte FROM vINTFCabecera) 
                         --INNER JOIN tCsBuroMOP 
                         --ON tCsPadronPlanCuotas.DiasAtrCuota >= tCsBuroMOP.Inicio AND tCsPadronPlanCuotas.DiasAtrCuota <= tCsBuroMOP.Fin
                         --where tCsPadronPlanCuotas.FechaVencimiento <=@fecha
                         select codprestamo,codusuario,numeroplan,seccuota,MOP from #tblmop
                         ) Datos
                    ) Datos
             GROUP BY CodPrestamo) Historico 
--             RIGHT OUTER JOIN vINTFNombreAvales VISTA
RIGHT OUTER JOIN (select * from tCsBuroxTblReInom where tipo='Aval') VISTA 
LEFT OUTER JOIN
     (SELECT Fecha, CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado), 0) AS SaldoVencido
      FROM (
--	SELECT Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado, CASE WHEN DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota
--	FROM tCsMesPlanCuotas with(nolock)--demora 01:32 min
--	WHERE (CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')) AND (EstadoConcepto NOT IN ('ANULADO', 'CANCELADO'))
--	and fecha=@fecha--'20121231'--demora 2seg al agregar esta linea
	select Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado,DiasAtrCuota from #tCsMesPlanCuotas
            ) Vencido
      WHERE (DiasAtrCuota = 1)
      GROUP BY Fecha, CodPrestamo) Vencido 
      ON VISTA.Fecha = Vencido.Fecha AND VISTA.CodPrestamo = Vencido.CodPrestamo COLLATE Modern_Spanish_CI_AI 
      ON Historico.CodPrestamo COLLATE Modern_Spanish_CI_AI = VISTA.CodPrestamo 
      
--LEFT OUTER JOIN
--     (SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
--      FROM (--inicialmente demora 04:15min, luego me saco 25seg
--            SELECT tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
--            FROM tCsPadronCarteraDet with(nolock) 
--            --INNER JOIN tCsCarteraDet with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
--            --tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
--            --INNER JOIN tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
--            INNER JOIN tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
--            --con esta ultima linea demora 7seg; 70,628 reg, luego me saco 3seg
--            ) Datos 
--      --INNER JOIN vINTFCabecera ON Datos.FechaDesembolso <= vINTFCabecera.Corte
--      where Datos.FechaDesembolso<=@fecha--'20121231'-- con este baja de 7 o 3 seg a 1seg
--      GROUP BY Datos.CodUsuario
--      ) CreditoMaximo ON CreditoMaximo.CodUsuario =tCsCartera.codusuario--VISTA.CodUsuario
      
LEFT OUTER JOIN tCaProducto 
ON SUBSTRING(VISTA.CodPrestamo, 5, 3) = tCaProducto.CodProducto 
ON MontoPagar.CodPrestamo = VISTA.CodPrestamo 
LEFT OUTER JOIN tCaClModalidadPlazo tCaClModalidadPlazo_1 
RIGHT OUTER JOIN tCsCartera with(nolock) ON tCaClModalidadPlazo_1.ModalidadPlazo = tCsCartera.ModalidadPlazo 
LEFT OUTER JOIN tClMonedas tClMonedas_1 ON tCsCartera.CodMoneda = tClMonedas_1.CodMoneda 
LEFT OUTER JOIN tCsBuroMOP ON tCsCartera.NroDiasAtraso >= tCsBuroMOP.Inicio AND tCsCartera.NroDiasAtraso <= tCsBuroMOP.Fin 
ON VISTA.Fecha = tCsCartera.Fecha AND VISTA.CodPrestamo = tCsCartera.CodPrestamo 
LEFT OUTER JOIN tClMonedas 
RIGHT OUTER JOIN tCsCartera tCsCartera_1 with(nolock) 
INNER JOIN tCsBuroMOP tCsBuroMOP_1 ON tCsCartera_1.NroDiasAtraso >= tCsBuroMOP_1.Inicio AND 
tCsCartera_1.NroDiasAtraso <= tCsBuroMOP_1.Fin 
LEFT OUTER JOIN tCaClModalidadPlazo ON tCsCartera_1.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo 
ON tClMonedas.CodMoneda = tCsCartera_1.CodMoneda 
RIGHT OUTER JOIN tCsPadronCarteraDet with(nolock) 
ON tCsCartera_1.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND tCsCartera_1.Fecha = tCsPadronCarteraDet.FechaCorte 
ON VISTA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND VISTA.CodUsuario = tCsPadronCarteraDet.CodUsuario 

LEFT OUTER JOIN
     (SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
      FROM (--inicialmente demora 04:15min, luego me saco 25seg
            SELECT tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
            FROM tCsPadronCarteraDet with(nolock) 
            --INNER JOIN tCsCarteraDet with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
            --tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
            --INNER JOIN tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
            INNER JOIN tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
            --con esta ultima linea demora 7seg; 70,628 reg, luego me saco 3seg
            ) Datos 
      --INNER JOIN vINTFCabecera ON Datos.FechaDesembolso <= vINTFCabecera.Corte
      where Datos.FechaDesembolso<=@fecha--'20121231'-- con este baja de 7 o 3 seg a 1seg
      GROUP BY Datos.CodUsuario
      ) CreditoMaximo ON CreditoMaximo.CodUsuario =tCsCartera.codusuario--VISTA.CodUsuario

LEFT OUTER JOIN     (
      --SELECT Filtro.Fecha, Datos.Codigo, Filtro.Garantia AS ImporteAvaluo, tGaClTipoGarantias.DescGarantia
      --FROM (SELECT Fecha, Codigo, MAX(Garantia) AS Garantia
      --      FROM (SELECT Fecha, Codigo, TipoGarantia, Round(SUM(moComercial), 0) AS Garantia
      --            FROM tCsMesGarantias tCsGarantias with(nolock)
      --            WHERE (Estgarantia NOT IN ('INACTIVO'))
      --            GROUP BY Fecha, Codigo, TipoGarantia
      --            ) Datos
      --      GROUP BY Fecha, Codigo
      --      ) Filtro 
      --      INNER JOIN
      --      (SELECT Fecha, Codigo, TipoGarantia, Round(SUM(mocomercial), 0) AS Garantia
      --       FROM tCsMesGarantias tCsGarantias with(nolock)
      --       WHERE (Estgarantia NOT IN ('INACTIVO'))
      --       GROUP BY FEcha, Codigo, TipoGarantia
      --       ) Datos ON Filtro.Codigo = Datos.Codigo AND Filtro.Garantia = Datos.Garantia AND Filtro.Fecha = Datos.Fecha 
      --      LEFT OUTER JOIN tGaClTipoGarantias 
      --      ON Datos.TipoGarantia = tGaClTipoGarantias.TipoGarantia
      select fecha, codigo, ImporteAvaluo, DescGarantia from #tblmesgar
) Avaluo 
ON VISTA.Fecha = Avaluo.Fecha AND VISTA.CodPrestamo = Avaluo.Codigo 
LEFT OUTER JOIN tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia 
LEFT OUTER JOIN #PrimerIncumplimiento prin on  prin.codprestamo=VISTA.CodPrestamo
--LEFT OUTER JOIN [10.0.2.14].[Finmas].[dbo].[tCaCtasLiqPago] CV on CV.codprestamo=VISTA.CodPrestamo-->aqui venta
CROSS JOIN [FinAmigoExterno].dbo.vINTFCabecera vINTFCabecera

union
/************************************vINTFCuentaCancelados****************************************/
--demoro 01:31min con 2,442 reg
SELECT VISTA.CodPrestamo, VISTA.CodUsuario, vINTFCabecera.ClaveUsuario, vINTFCabecera.NombreUsuario, 
--RESPONSABILIDAD:
--CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'J' ELSE tCaClTecnologia.Responsabilidad END AS Responsabilidad,
case when tCsPadronCarteraDet.desembolso>='20130101' then
  CASE Tipo WHEN 'CanceladosT' THEN tCaClTecnologia.Responsabilidad WHEN 'CanceladosA' THEN 'C' WHEN 'CanceladosC' THEN 'C' ELSE '' END
else
  CASE Tipo WHEN 'CanceladosT' THEN tCaClTecnologia.Responsabilidad WHEN 'CanceladosA' THEN 'C' WHEN 'CanceladosC' THEN 'J' ELSE '' END
end
AS Responsabilidad,
'I' AS TipoCuenta
,-- tCaProducto.TipoContrato
case when tCsPadronCarteraDet.desembolso>='20130101' then
  case when tCsCartera.codoficina='97' then 'PN' else 'SE' end
else
  tCaProducto.TipoContrato
end 
as TipoContrato
, CASE WHEN tipo = 'Aval' THEN tClMonedas_1.INTF ELSE tClMonedas.INTF END AS UnidadMonetaria, 
CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END AS ImporteAvaluo, 
CASE WHEN tipo = 'Aval' THEN tCsCartera.NroCuotas ELSE tCsCartera_1.NroCuotas END AS NumeroPagos, 
CASE WHEN Tipo = 'Aval' THEN tCaClModalidadPlazo_1.INTF ELSE tCaClModalidadPlazo.INTF END AS FrecuenciaPagos, 
CASE WHEN left(Tipo,10) = 'Cancelados' THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar, 
CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Apertura, 
CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') END AS UltimoPago, 
CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Disposicion, 
CASE WHEN left(Tipo,10) = 'Cancelados' THEN dbo.fduFechaATexto(tCsPadronCarteraDet.Cancelacion, 'DDMMAAAA') ELSE '' END AS Cancelacion, 
vINTFCabecera.FechaReporte AS Reporte, CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia, 
CreditoMaximo.CreditoMaximo, 
CASE WHEN left(Tipo,10) = 'Cancelados' THEN 0 ELSE ROUND(tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE
+ tCsCartera.SaldoINPE, 0) END AS SaldoActual, '' AS LimiteCredito, 
CASE When tCsCartera.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END AS SaldoVencido, 
CASE WHEN left(Tipo,10) = 'Cancelados' THEN 0 ELSE tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas END AS PagosVencidos, 
----MOP: Manner Of Payment
CASE 
	WHEN 	dbo.fdufechaatexto(tCsCartera.FechaDesembolso, 'AAAAMM') = dbo.fdufechaatexto(VISTA.Fecha, 'AAAAMM') AND 
                   		 tCsCartera.FechaDesembolso = tCsCartera.FechaUltimoMovimiento THEN '00' 
	WHEN 	left(Tipo,10) = 'Cancelados' Then '01' 
	WHEN tCsCartera.Judicial = 'Judicial' and tCsBuroMOP.MOP = '01' Then '02'
	WHEN tCsCartera.Judicial = 'Judicial' Then tCsBuroMOP.MOP
	WHEN 	tCscartera.Cartera = 'CASTIGADA' Then '97'
		--WHEN dbo.tCsCartera.TipoReprog <> 'SINRE' THEN '02'
	ELSE 	tCsBuroMOP.MOP END AS MOP, '' AS HistoricoPagos, 
--OBSERVACION
CASE 	WHEN tCsCartera.Judicial = 'Judicial' Then 'SG' 
			WHEN tCscartera.Cartera = 'CASTIGADA' THEN 'UP' 
			ELSE '' END AS Observacion, 
Historico.PagosReportados, 
Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta, 
case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end FprimerIncum,
CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END AS SaldoInsoluto,
'FIN' AS FinSegmento
/*FROM <----------*/
FROM (SELECT CodPrestamo, Round(SUM(MontoCuota), 0) AS MontoPagar
      FROM tCsPadronPlanCuotas with(nolock)
      WHERE (SecCuota = 1)
      GROUP BY CodPrestamo) MontoPagar 
      RIGHT OUTER JOIN
      (
      SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04) AS MOP04, SUM(MOP05) AS MOP05
      FROM (SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01, 
            CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03, 
            CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05
            FROM (
                  --SELECT DISTINCT 
                  --tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.CodUsuario, tCsPadronPlanCuotas.NumeroPlan, tCsPadronPlanCuotas.SecCuota, tCsBuroMOP.MOP
                  --FROM tCsPadronPlanCuotas with(nolock)
                  ----INNER JOIN vINTFCabecera 
                  ----ON tCsPadronPlanCuotas.FechaVencimiento <=(SELECT Corte FROM vINTFCabecera) 
                  --INNER JOIN tCsBuroMOP ON tCsPadronPlanCuotas.DiasAtrCuota >= tCsBuroMOP.Inicio AND tCsPadronPlanCuotas.DiasAtrCuota <= tCsBuroMOP.Fin
                  --where tCsPadronPlanCuotas.FechaVencimiento <=@fecha
                  select codprestamo,codusuario,numeroplan,seccuota,MOP from #tblmop
                  ) Datos
            ) Datos
            GROUP BY CodPrestamo) Historico 
--RIGHT OUTER JOIN vINTFNombreCancelados VISTA 
RIGHT OUTER JOIN (select * from tCsBuroxTblReInom where tipo IN('CanceladosT','CanceladosC','CanceladosA')) VISTA 
LEFT OUTER JOIN
     (SELECT Fecha, CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado), 0) AS SaldoVencido
      FROM (
--	SELECT Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado, CASE WHEN DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota
--	FROM tCsMesPlanCuotas with(nolock)--demora 01:32 min
--	WHERE (CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')) AND (EstadoConcepto NOT IN ('ANULADO', 'CANCELADO'))
--           	and fecha=@fecha--'20121231'--demora 2seg al agregar esta linea
	select Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado,DiasAtrCuota from #tCsMesPlanCuotas
            ) Vencido
      WHERE      (DiasAtrCuota = 1)
      GROUP BY Fecha, CodPrestamo) Vencido 
ON VISTA.Fecha = Vencido.Fecha AND VISTA.CodPrestamo = Vencido.CodPrestamo COLLATE Modern_Spanish_CI_AI 
ON Historico.CodPrestamo COLLATE Modern_Spanish_CI_AI = VISTA.CodPrestamo 
--LEFT OUTER JOIN
--     (SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
--      FROM (--inicialmente demora 04:15min, luego me saco 25seg
--            SELECT tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
--            FROM tCsPadronCarteraDet with(nolock) 
--            --INNER JOIN tCsCarteraDet with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
--            --tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
--            --INNER JOIN tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
--            INNER JOIN tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
--            --con esta ultima linea demora 7seg; 70,628 reg, luego me saco 3seg
--            ) Datos 
--            --INNER JOIN vINTFCabecera ON Datos.FechaDesembolso <= vINTFCabecera.Corte
--      where Datos.FechaDesembolso<=@fecha--'20121231'-- con este baja de 7 o 3 seg a 1seg
--      GROUP BY Datos.CodUsuario) CreditoMaximo ON VISTA.CodUsuario = CreditoMaximo.CodUsuario --aqui???
LEFT OUTER JOIN tCaProducto ON SUBSTRING(VISTA.CodPrestamo, 5, 3) = tCaProducto.CodProducto 
ON MontoPagar.CodPrestamo = VISTA.CodPrestamo 
LEFT OUTER JOIN tCaClModalidadPlazo tCaClModalidadPlazo_1 
RIGHT OUTER JOIN tCsCartera with(nolock) ON tCaClModalidadPlazo_1.ModalidadPlazo = tCsCartera.ModalidadPlazo 
LEFT OUTER JOIN tClMonedas tClMonedas_1 ON tCsCartera.CodMoneda = tClMonedas_1.CodMoneda 
LEFT OUTER JOIN tCsBuroMOP ON tCsCartera.NroDiasAtraso >= tCsBuroMOP.Inicio AND tCsCartera.NroDiasAtraso <= tCsBuroMOP.Fin 
ON VISTA.Fecha = tCsCartera.Fecha AND VISTA.CodPrestamo = tCsCartera.CodPrestamo 
LEFT OUTER JOIN tClMonedas 
RIGHT OUTER JOIN tCsCartera tCsCartera_1 with(nolock) 
INNER JOIN tCsBuroMOP tCsBuroMOP_1 ON tCsCartera_1.NroDiasAtraso >= tCsBuroMOP_1.Inicio AND tCsCartera_1.NroDiasAtraso <= tCsBuroMOP_1.Fin 
LEFT OUTER JOIN tCaClModalidadPlazo ON tCsCartera_1.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo 
ON tClMonedas.CodMoneda = tCsCartera_1.CodMoneda 
RIGHT OUTER JOIN tCsPadronCarteraDet with(nolock) 
ON tCsCartera_1.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND tCsCartera_1.Fecha = tCsPadronCarteraDet.FechaCorte 
ON VISTA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo --AND tCsPadronCarteraDet.CodUsuario=VISTA.CodUsuario --aqui???

LEFT OUTER JOIN
     (SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
      FROM (--inicialmente demora 04:15min, luego me saco 25seg
            SELECT tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
            FROM tCsPadronCarteraDet with(nolock) 
            --INNER JOIN tCsCarteraDet with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
            --tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
            --INNER JOIN tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
            INNER JOIN tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
            --con esta ultima linea demora 7seg; 70,628 reg, luego me saco 3seg
            ) Datos 
            --INNER JOIN vINTFCabecera ON Datos.FechaDesembolso <= vINTFCabecera.Corte
      where Datos.FechaDesembolso<=@fecha--'20121231'-- con este baja de 7 o 3 seg a 1seg
      GROUP BY Datos.CodUsuario) CreditoMaximo ON CreditoMaximo.CodUsuario = tCsPadronCarteraDet.codusuario -- CreditoMaximo.CodUsuario --aqui???

LEFT OUTER JOIN
     (
      --SELECT Filtro.Fecha, Datos.Codigo, Filtro.Garantia AS ImporteAvaluo, tGaClTipoGarantias.DescGarantia
      --FROM (SELECT Fecha, Codigo, MAX(Garantia) AS Garantia
      --      FROM (SELECT Fecha, Codigo, TipoGarantia, Round(SUM(moComercial), 0) AS Garantia
      --            FROM tCsMesGarantias tCsGarantias with(nolock)
      --            WHERE (Estgarantia NOT IN ('INACTIVO'))
      --            GROUP BY Fecha, Codigo, TipoGarantia
      --            ) Datos
      --      GROUP BY Fecha, Codigo
      --) Filtro INNER JOIN
      --(SELECT Fecha, Codigo, TipoGarantia, Round(SUM(mocomercial), 0) AS Garantia
      -- FROM tCsMesGarantias tCsGarantias with(nolock)
      -- WHERE (Estgarantia NOT IN ('INACTIVO'))
      -- GROUP BY FEcha, Codigo, TipoGarantia
      -- ) Datos ON Filtro.Codigo = Datos.Codigo AND Filtro.Garantia = Datos.Garantia AND Filtro.Fecha = Datos.Fecha 
      --LEFT OUTER JOIN tGaClTipoGarantias ON Datos.TipoGarantia = tGaClTipoGarantias.TipoGarantia
      select fecha, codigo, ImporteAvaluo, DescGarantia from #tblmesgar
      ) Avaluo 
ON VISTA.Fecha = Avaluo.Fecha AND VISTA.CodPrestamo = Avaluo.Codigo 
LEFT OUTER JOIN tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia 
LEFT OUTER JOIN #PrimerIncumplimiento prin on  prin.codprestamo=VISTA.CodPrestamo
CROSS JOIN [FinAmigoExterno].dbo.vINTFCabecera vINTFCabecera

union
/************************************vINTFCuentaCodeudores****************************************/
-- demoro 57 seg con 6,397 reg
SELECT VISTA.CodPrestamo, VISTA.CodUsuario, vINTFCabecera.ClaveUsuario, vINTFCabecera.NombreUsuario, 
--RESPONSABILIDAD:
--CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'J' ELSE tCaClTecnologia.Responsabilidad END AS Responsabilidad,
case when tCsCartera.FechaDesembolso>='20130101' then
  CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'C' ELSE tCaClTecnologia.Responsabilidad END
else
  CASE Tipo WHEN 'Aval' THEN 'C' WHEN 'Codeudor' THEN 'J' ELSE tCaClTecnologia.Responsabilidad END 
end
AS Responsabilidad,
'I' AS TipoCuenta
, --tCaProducto.TipoContrato
case when tCsCartera.FechaDesembolso>='20130101' then
  case when tCsCartera.codoficina='97' then 'PN' else 'SE' end
else
  tCaProducto.TipoContrato
end 
as TipoContrato
, 
--CASE WHEN tipo = 'Aval' THEN tClMonedas_1.INTF ELSE tClMonedas.INTF END AS UnidadMonetaria, 
tClMonedas_1.INTF UnidadMonetaria, 
CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END AS ImporteAvaluo, 
--CASE WHEN tipo = 'Aval' THEN tCsCartera.NroCuotas ELSE tCsCartera_1.NroCuotas END AS NumeroPagos, 
tCsCartera.NroCuotas NumeroPagos,
--CASE WHEN Tipo = 'Aval' THEN tCaClModalidadPlazo_1.INTF ELSE tCaClModalidadPlazo.INTF END AS FrecuenciaPagos, 
tCaClModalidadPlazo_1.INTF FrecuenciaPagos,
--CASE WHEN Tipo = 'Cancelados' or (CV.codprestamo is not null) THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar, --> aqui venta
CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar, --> aqui venta
--CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
--ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Apertura, 
dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA')  Apertura,
--CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
--ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') END AS UltimoPago, 
dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA')  UltimoPago,
--CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
--ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Disposicion,
dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA')  Disposicion,
--case when CV.codprestamo is not null then
--  dbo.fduFechaATexto(CV.fecha, 'DDMMAAAA')
--else
  CASE WHEN Tipo = 'Cancelados' THEN dbo.fduFechaATexto(tCsPadronCarteraDet.Cancelacion, 'DDMMAAAA') 
  ELSE '' END 
--end
AS Cancelacion, -->aqui venta fecha cierre

vINTFCabecera.FechaReporte AS Reporte, CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia, 
CreditoMaximo.CreditoMaximo, 
--CASE WHEN Tipo = 'Cancelados' or (CV.codprestamo is not null) THEN 0 
CASE WHEN Tipo = 'Cancelados' THEN 0 
ELSE ROUND(tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE+ tCsCartera.SaldoINPE, 0) END AS SaldoActual-->aqui venta
, '' AS LimiteCredito, 
CASE When tCsCartera.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END AS SaldoVencido, 
CASE WHEN tipo = 'Cancelados' THEN 0 ELSE tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas END AS PagosVencidos, 
----MOP: Manner Of Payment
--case when CV.codprestamo is not null then '96'
--else
  CASE 
		WHEN 	dbo.fdufechaatexto(tCsCartera.FechaDesembolso, 'AAAAMM') = dbo.fdufechaatexto(VISTA.Fecha, 'AAAAMM') AND 
          tCsCartera.FechaDesembolso = tCsCartera.FechaUltimoMovimiento THEN '00' 
		WHEN 	Tipo = 'Cancelados' Then '01' 
		WHEN tCsCartera.Judicial = 'Judicial' and tCsBuroMOP.MOP = '01' Then '02'
		WHEN tCsCartera.Judicial = 'Judicial' Then tCsBuroMOP.MOP
		WHEN 	tCscartera.Cartera = 'CASTIGADA' Then '97'
			--WHEN dbo.tCsCartera.TipoReprog <> 'SINRE' THEN '02'
		ELSE 	tCsBuroMOP.MOP
    END
--end
AS MOP-->aqui venta
, '' AS HistoricoPagos, 
--OBSERVACION
--case when CV.codprestamo is not null then 'CV' else
    CASE 	WHEN tCsCartera.Judicial = 'Judicial' Then 'SG' 
			WHEN tCscartera.Cartera = 'CASTIGADA' THEN 'UP' 
			ELSE '' END
--end
AS Observacion, -->aqui venta
Historico.PagosReportados, 
Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta, 
case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end FprimerIncum,
--CASE WHEN Tipo = 'Cancelados' or (CV.codprestamo is not null) THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END AS SaldoInsoluto,-->aqui venta
CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE ROUND(isnull(tCsCartera.SaldoCapital,0), 0) END AS SaldoInsoluto,-->aqui venta
'FIN' AS FinSegmento
--/*FROM <----------*/
FROM (SELECT CodPrestamo, Round(SUM(MontoCuota), 0) AS MontoPagar
      FROM tCsPadronPlanCuotas with(nolock)
      WHERE (SecCuota = 1)
      GROUP BY CodPrestamo) MontoPagar 
RIGHT OUTER JOIN
      (SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04) 
       AS MOP04, SUM(MOP05) AS MOP05
       FROM (SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01, 
             CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03, 
             CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05
             FROM (
                   --SELECT DISTINCT tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.CodUsuario, tCsPadronPlanCuotas.NumeroPlan
                   --, tCsPadronPlanCuotas.SecCuota, tCsBuroMOP.MOP
                   --FROM tCsPadronPlanCuotas with(nolock) 
                   ----INNER JOIN vINTFCabecera 
                   ----ON tCsPadronPlanCuotas.FechaVencimiento <= (SELECT Corte FROM vINTFCabecera) 
                   --INNER JOIN tCsBuroMOP ON tCsPadronPlanCuotas.DiasAtrCuota >= tCsBuroMOP.Inicio AND tCsPadronPlanCuotas.DiasAtrCuota <= tCsBuroMOP.Fin
                   --where tCsPadronPlanCuotas.FechaVencimiento <=@fecha
                   select codprestamo,codusuario,numeroplan,seccuota,MOP from #tblmop
                   ) Datos
             ) Datos
             GROUP BY CodPrestamo) Historico 
--RIGHT OUTER JOIN vINTFNombreCodeudores VISTA 
RIGHT OUTER JOIN (select * from tCsBuroxTblReInom where tipo='Codeudor') VISTA 
LEFT OUTER JOIN (
     SELECT Fecha, CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado), 0) AS SaldoVencido
     FROM (
--	SELECT Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado, CASE WHEN DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota
--	FROM tCsMesPlanCuotas with(nolock)--demora 01:32 min
--	WHERE (CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')) AND (EstadoConcepto NOT IN ('ANULADO', 'CANCELADO'))
--	and fecha=@fecha--'20121231'--demora 2seg al agregar esta linea
	select Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado,DiasAtrCuota from #tCsMesPlanCuotas
           ) Vencido
     WHERE (DiasAtrCuota = 1)
     GROUP BY Fecha, CodPrestamo) Vencido
     ON VISTA.Fecha = Vencido.Fecha AND VISTA.CodPrestamo = Vencido.CodPrestamo COLLATE Modern_Spanish_CI_AI 
     ON Historico.CodPrestamo COLLATE Modern_Spanish_CI_AI = VISTA.CodPrestamo 
--LEFT OUTER JOIN(
--     SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
--     FROM (--inicialmente demora 04:15min, luego me saco 25seg
--           SELECT tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
--           FROM tCsPadronCarteraDet with(nolock) 
--           --INNER JOIN tCsCarteraDet with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
--           --tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
--           --INNER JOIN tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
--           INNER JOIN tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
--            --con esta ultima linea demora 7seg; 70,628 reg, luego me saco 3seg
--           ) Datos 
--     --INNER JOIN vINTFCabecera ON Datos.FechaDesembolso <= vINTFCabecera.Corte
--     where Datos.FechaDesembolso<=@fecha--'20121231'-- con este baja de 7 o 3 seg a 1seg     
--     GROUP BY Datos.CodUsuario) CreditoMaximo 
--     ON CreditoMaximo.CodUsuario=tCsCartera.CodUsuario--VISTA.CodUsuario
LEFT OUTER JOIN tCaProducto ON SUBSTRING(VISTA.CodPrestamo, 5, 3) = tCaProducto.CodProducto 
ON MontoPagar.CodPrestamo = VISTA.CodPrestamo 
LEFT OUTER JOIN tCaClModalidadPlazo tCaClModalidadPlazo_1 
RIGHT OUTER JOIN tCsCartera with(nolock) ON tCaClModalidadPlazo_1.ModalidadPlazo = tCsCartera.ModalidadPlazo 
LEFT OUTER JOIN tClMonedas tClMonedas_1 ON tCsCartera.CodMoneda = tClMonedas_1.CodMoneda 
LEFT OUTER JOIN tCsBuroMOP ON tCsCartera.NroDiasAtraso >= tCsBuroMOP.Inicio AND tCsCartera.NroDiasAtraso <= tCsBuroMOP.Fin 
ON VISTA.Fecha = tCsCartera.Fecha AND VISTA.CodPrestamo = tCsCartera.CodPrestamo
LEFT OUTER JOIN tClMonedas 
RIGHT OUTER JOIN tCsCartera tCsCartera_1 with(nolock) 
INNER JOIN tCsBuroMOP tCsBuroMOP_1 ON tCsCartera_1.NroDiasAtraso >= tCsBuroMOP_1.Inicio AND 
                      tCsCartera_1.NroDiasAtraso <= tCsBuroMOP_1.Fin 
LEFT OUTER JOIN tCaClModalidadPlazo ON tCsCartera_1.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo 
ON tClMonedas.CodMoneda = tCsCartera_1.CodMoneda 
RIGHT OUTER JOIN tCsPadronCarteraDet with(nolock) ON tCsCartera_1.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
                      tCsCartera_1.Fecha = tCsPadronCarteraDet.FechaCorte 
ON VISTA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND VISTA.CodUsuario = tCsPadronCarteraDet.CodUsuario 

LEFT OUTER JOIN(
     SELECT Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
     FROM (--inicialmente demora 04:15min, luego me saco 25seg
           SELECT tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
           FROM tCsPadronCarteraDet with(nolock) 
           --INNER JOIN tCsCarteraDet with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
           --tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
           --INNER JOIN tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
           INNER JOIN tCsCartera with(nolock) ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
            --con esta ultima linea demora 7seg; 70,628 reg, luego me saco 3seg
           ) Datos 
     --INNER JOIN vINTFCabecera ON Datos.FechaDesembolso <= vINTFCabecera.Corte
     where Datos.FechaDesembolso<=@fecha--'20121231'-- con este baja de 7 o 3 seg a 1seg     
     GROUP BY Datos.CodUsuario) CreditoMaximo 
     ON CreditoMaximo.CodUsuario=tCsCartera.CodUsuario--VISTA.CodUsuario

LEFT OUTER JOIN
     (
      --SELECT Filtro.Fecha, Datos.Codigo, Filtro.Garantia AS ImporteAvaluo, tGaClTipoGarantias.DescGarantia
      --FROM (SELECT Fecha, Codigo, MAX(Garantia) AS Garantia
      --      FROM (SELECT Fecha, Codigo, TipoGarantia, Round(SUM(moComercial), 0) AS Garantia
      --            FROM tCsMesGarantias tCsGarantias with(nolock)
      --            WHERE (Estgarantia NOT IN ('INACTIVO'))
      --            GROUP BY Fecha, Codigo, TipoGarantia) Datos
      --      GROUP BY Fecha, Codigo) Filtro 
      --      INNER JOIN
      --      (SELECT Fecha, Codigo, TipoGarantia, Round(SUM(mocomercial), 0) AS Garantia
      --       FROM tCsMesGarantias tCsGarantias with(nolock)
      --       WHERE      (Estgarantia NOT IN ('INACTIVO'))
      --       GROUP BY FEcha, Codigo, TipoGarantia) Datos 
      --       ON Filtro.Codigo = Datos.Codigo AND Filtro.Garantia = Datos.Garantia AND Filtro.Fecha = Datos.Fecha 
      --       LEFT OUTER JOIN tGaClTipoGarantias ON Datos.TipoGarantia = tGaClTipoGarantias.TipoGarantia
      select fecha, codigo, ImporteAvaluo, DescGarantia from #tblmesgar
             ) Avaluo 
ON VISTA.Fecha = Avaluo.Fecha AND VISTA.CodPrestamo = Avaluo.Codigo 
LEFT OUTER JOIN tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia 
LEFT OUTER JOIN #PrimerIncumplimiento prin on  prin.codprestamo=VISTA.CodPrestamo
--LEFT OUTER JOIN [10.0.2.14].[Finmas].[dbo].[tCaCtasLiqPago] CV on CV.codprestamo=VISTA.CodPrestamo-->aqui venta
CROSS JOIN [FinAmigoExterno].dbo.vINTFCabecera vINTFCabecera

drop table #tblmop
drop table #tblmesgar
drop table #tCsMesPlanCuotas
drop table #PrimerIncumplimiento
GO