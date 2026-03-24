SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsRptFlujoCajaxAgencia] @CodOficina varchar(10), @FecIni smalldatetime, @FecFin smalldatetime  AS
SELECT  a.Fecha, a.CodSistema, a.CodOficina,a.tipotransaccion,a.Montototaltran, a.transaccion, a.tipotransacnivel3, a.descripcion, tcloficinas.nomoficina  FROM(

SELECT     Fecha, CodSistema, CodOficina, CASE TipoTransacNivel1 WHEN 'E' THEN 'EGRESOS' ELSE 'INGRESOS' END AS TipoTransaccion, MontoTotalTran, 
                      CASE WHEN CHARINDEX('//', DescripcionTran) >= 1 THEN SUBSTRING(DescripcionTran, 1, CHARINDEX('//', DescripcionTran) - 1) 
                      ELSE DescripcionTran END AS Transaccion, TipoTransacNivel3, CASE codsistema WHEN 'TC' THEN CASE WHEN CHARINDEX('//', DescripcionTran) 
                      >= 1 THEN SUBSTRING(DescripcionTran, 1, CHARINDEX('//', DescripcionTran) - 1) 
                      ELSE DescripcionTran END WHEN 'CA' THEN (CASE WHEN TipoTransacNivel3 IN ('104', '105') 
                      THEN 'Recuperación de Cartera' WHEN TipoTransacNivel3 = '101' THEN 'Comisión Desembolso' WHEN TipoTransacNivel3 = '102' THEN 'Desembolso'  ELSE '' END) 
                      ELSE (CASE WHEN TipoTransacNivel3 IN ('1', '7','14') THEN 'Retiro de Ahorro' ELSE 'Depósitos de Ahorros' END) END AS Descripcion
FROM         tCsTransaccionDiaria
WHERE     (CodOficina = @CodOficina) AND (Extornado = 0) AND (Fecha >= @FecIni AND Fecha <= @FecFin)  AND TipoTransacNivel2 <> 'OTRO' AND (TipoTransacNivel3 IN ('1','2', '14', '54',  '104', '101', '105','102'))   AND (TipoTransacNivel2 = 'EFEC')
UNION ALL
SELECT     Fecha, 'TC' AS codsistema, CodOficina, 'SALDO INICIAL' AS tipotransaccion, SaldoIniSis AS Montototaltran, 
                      'Saldo de bóveda al inicio del día' AS transaccion, '0' AS tipotransacnivel3, 'Saldo de bóveda al inicio del día' AS descripcion
FROM         tCsBovedaSaldos
WHERE     (CodOficina = @CodOficina) AND (Fecha >= @FecIni) AND (Fecha <= @FecFin) 
UNION ALL
SELECT     Fecha, 'TC' AS codsistema, CodOficina, CASE WHEN montoentrada = 0 THEN 'EGRESOS' ELSE 'INGRESOS' END AS tipotransaccion, 
                      CASE WHEN montoentrada = 0 THEN  montoSALIDA  ELSE montoentrada END AS Montototaltran, 'Movimiento PANAMERICANO' AS transaccion, 
                      '0' AS tipotransacnivel3, 'Movimiento PANAMERICANO' AS descripcion
FROM         tCsBovTransac
WHERE     (Observaciones LIKE '%pana%') AND (CodOficina = @CodOficina) AND (Fecha >= @FecIni) AND (Fecha <= @FecFin) 

) A
INNER JOIN tcloficinas on a.codoficina=tcloficinas.codoficina

UNION ALL

SELECT fecha, 'TC' CodSistema,@CodOficina CodOficina,'SALDO FINAL' tipotransaccion,sum(OPESALINI)+sum(OPEINGRESOS)-sum(OPEEGRESOS) Montototaltran, 'Saldo de bóveda al final del día' transaccion,
0 tipotransacnivel3,'Saldo de bóveda al final del día' descripcion, nomoficina
FROM (SELECT fecha,CASE tipotransaccion WHEN 'SALDO INICIAL' THEN sum(Montototaltran) ELSE 0 END OPESALINI,
CASE tipotransaccion WHEN 'INGRESOS' THEN sum(Montototaltran) ELSE 0 END OPEINGRESOS,
CASE tipotransaccion WHEN 'EGRESOS' THEN sum(Montototaltran) ELSE 0 END OPEEGRESOS, nomoficina FROM (
SELECT  a.Fecha, a.CodSistema, a.CodOficina,a.tipotransaccion,a.Montototaltran, a.transaccion, a.tipotransacnivel3, a.descripcion, tcloficinas.nomoficina  FROM(
SELECT     Fecha, CodSistema, CodOficina, CASE TipoTransacNivel1 WHEN 'E' THEN 'EGRESOS' ELSE 'INGRESOS' END AS TipoTransaccion, MontoTotalTran, 
                      CASE WHEN CHARINDEX('//', DescripcionTran) >= 1 THEN SUBSTRING(DescripcionTran, 1, CHARINDEX('//', DescripcionTran) - 1) 
                      ELSE DescripcionTran END AS Transaccion, TipoTransacNivel3, CASE codsistema WHEN 'TC' THEN CASE WHEN CHARINDEX('//', DescripcionTran) 
                      >= 1 THEN SUBSTRING(DescripcionTran, 1, CHARINDEX('//', DescripcionTran) - 1) 
                      ELSE DescripcionTran END WHEN 'CA' THEN (CASE WHEN TipoTransacNivel3 IN ('104', '105') 
                      THEN 'Recuperación de Cartera' WHEN TipoTransacNivel3 = '101' THEN 'Comisión Desembolso' WHEN TipoTransacNivel3 = '102' THEN 'Desembolso'  ELSE '' END) 
                      ELSE (CASE WHEN TipoTransacNivel3 IN ('1', '7','14') THEN 'Retiro de Ahorro' ELSE 'Depósitos de Ahorros' END) END AS Descripcion
FROM         tCsTransaccionDiaria
WHERE     (CodOficina = @CodOficina) AND (Extornado = 0) AND (Fecha >= @FecIni AND Fecha <= @FecFin)  AND TipoTransacNivel2 <> 'OTRO' AND (TipoTransacNivel3 IN ('1','2', '14', '54',  '104', '101', '105','102'))   AND (TipoTransacNivel2 = 'EFEC')
UNION all
SELECT     Fecha, 'TC' AS codsistema, CodOficina, 'SALDO INICIAL' AS tipotransaccion, SaldoIniSis AS Montototaltran, 
                      'Saldo de bóveda al inicio del día' AS transaccion, '0' AS tipotransacnivel3, 'Saldo de bóveda al inicio del día' AS descripcion
FROM         tCsBovedaSaldos
WHERE     (CodOficina = @CodOficina) AND (Fecha >= @FecIni) AND (Fecha <= @FecFin) 
UNION all
SELECT     Fecha, 'TC' AS codsistema, CodOficina, CASE WHEN montoentrada = 0 THEN 'EGRESOS' ELSE 'INGRESOS' END AS tipotransaccion, 
                      CASE WHEN montoentrada = 0 THEN  montoSALIDA  ELSE montoentrada END AS Montototaltran, 'Movimiento PANAMERICANO' AS transaccion, 
                      '0' AS tipotransacnivel3, 'Movimiento PANAMERICANO' AS descripcion
FROM         tCsBovTransac
WHERE     (Observaciones LIKE '%pana%') AND (CodOficina = @CodOficina) AND (Fecha >= @FecIni) AND (Fecha <= @FecFin) 
) A
INNER JOIN tcloficinas on a.codoficina=tcloficinas.codoficina) B 
GROUP BY fecha,tipotransaccion,nomoficina) C
GROUP BY fecha,nomoficina
GO