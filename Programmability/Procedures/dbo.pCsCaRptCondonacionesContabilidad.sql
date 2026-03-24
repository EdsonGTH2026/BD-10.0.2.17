SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaRptCondonacionesContabilidad] @FecIni smalldatetime, @FecFin smalldatetime, @codoficina varchar(200) AS
--declare @FecIni smalldatetime
--declare @FecFin smalldatetime
--declare @codoficina varchar(200)
declare @csql varchar(8000)

--set @codoficina = '2,3,4,5'
--set @FecIni = '20090601'
--set @FecFin = '20090630'

set @csql = 'SELECT NomOficina, CodPrestamo, NombreCompleto, Estado, NroDiasAtraso, Fecha, CONDONADO, CAPITAL, INTERES, '
set @csql = @csql + 'MORATORIO, CARGOxMORA, SaldoCapital, CapitalVigente, CapitalVencido, InteresVigente, InteresVencido, InteresCtaOrden, '
set @csql = @csql + 'MoratorioVigente, MoratorioVencido, MoratorioCtaOrden, OtrosCargos, Impuestos, CargoMora '
set @csql = @csql + 'FROM (SELECT NomOficina, CodPrestamo, NombreCompleto, Estado, NroDiasAtraso, Fecha, SUM(MontoOp) AS CONDONADO, '
set @csql = @csql + 'SUM(CAPITAL) AS CAPITAL, SUM(INTERES) AS INTERES, SUM(MORATORIO) AS MORATORIO, SUM(CARGOxMORA) AS CARGOxMORA, '
set @csql = @csql + 'SaldoCapital, CapitalVigente, CapitalVencido, InteresVigente, InteresVencido, InteresCtaOrden, MoratorioVigente, '
set @csql = @csql + 'MoratorioVencido, MoratorioCtaOrden, OtrosCargos, Impuestos, CargoMora FROM (SELECT tClOficinas.NomOficina, '
set @csql = @csql + 'ope.CodPrestamo, tCsPadronClientes.NombreCompleto, ca.Estado, ca.NroDiasAtraso,ope.Fecha, oped.CodConcepto, oped.MontoOp, '
set @csql = @csql + 'CASE oped.CodConcepto WHEN ''CAPI'' THEN oped.MontoOp ELSE 0 END AS CAPITAL,  '
set @csql = @csql + 'CASE oped.CodConcepto WHEN ''INTE'' THEN oped.MontoOp ELSE 0 END AS INTERES, '
set @csql = @csql + 'CASE oped.CodConcepto WHEN ''INPE'' THEN oped.MontoOp ELSE 0 END AS MORATORIO, '
set @csql = @csql + 'CASE oped.CodConcepto WHEN ''MORA'' THEN oped.MontoOp ELSE 0 END AS CARGOxMORA, '
set @csql = @csql + 'oped.SecCuota, cad.SaldoCapital, cad.SaldoCapital - cad.CapitalVencido AS CapitalVigente, '
set @csql = @csql + 'cad.CapitalVencido, cad.InteresVigente, cad.InteresVencido, cad.InteresCtaOrden, '
set @csql = @csql + 'cad.MoratorioVigente, cad.MoratorioVencido, cad.MoratorioCtaOrden, cad.OtrosCargos, '
set @csql = @csql + 'cad.Impuestos, cad.CargoMora FROM tCsPadronClientes RIGHT OUTER JOIN tCsCartera ca INNER JOIN '
set @csql = @csql + 'tCsCarteraDet cad ON ca.Fecha = cad.Fecha AND ca.CodPrestamo = cad.CodPrestamo INNER JOIN '
set @csql = @csql + 'tCsOpRecuperables ope INNER JOIN tCsOpRecuperablesDet oped ON ope.Fecha = oped.Fecha AND '
set @csql = @csql + 'ope.CodOficina = oped.CodOficina AND ope.SecPago = oped.SecPago AND '
set @csql = @csql + 'ope.CodPrestamo = oped.CodPrestamo INNER JOIN tClOficinas ON ope.CodOficina = '
set @csql = @csql + 'tClOficinas.CodOficina ON cad.CodUsuario = oped.CodUsuario AND cad.CodPrestamo = '
set @csql = @csql + 'oped.CodPrestamo AND cad.Fecha = DATEADD([DAY], - 1, oped.Fecha) ON '
set @csql = @csql + 'tCsPadronClientes.CodUsuario = cad.CodUsuario WHERE ope.codoficina in('+@codoficina+') AND (ope.TipoOp = ''002'') '
set @csql = @csql + 'AND (ope.Fecha >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''') AND (ope.Fecha <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''') AND '
set @csql = @csql + '(oped.CodConcepto IN (''CAPI'', ''INTE'', ''INPE'', ''MORA''))) A '
set @csql = @csql + 'GROUP BY NomOficina, CodPrestamo, NombreCompleto, Estado, NroDiasAtraso, Fecha, SaldoCapital, CapitalVigente, '
set @csql = @csql + 'CapitalVencido, InteresVigente, InteresVencido, InteresCtaOrden, MoratorioVigente, MoratorioVencido, MoratorioCtaOrden, '
set @csql = @csql + 'OtrosCargos, Impuestos, CargoMora) B ORDER BY NomOficina, Fecha '
set @csql = @csql + ''

exec (@csql)
GO