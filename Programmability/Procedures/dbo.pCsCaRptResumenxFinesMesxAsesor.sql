SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCaRptResumenxFinesMesxAsesor] @FecIni smalldatetime, @FecFin smalldatetime,@CodOficina varchar(2), @Tipo int, @CodAsesor varchar(100) AS

-- @Tipo --> 1: dia 2: meses

DECLARE @csql varchar(8000)

SET @csql = 'SELECT Fecha, CodOficina, MontoDesembolso, SaldoCartera, Saldo0Dias, Saldo90Dias, Recuperacion, Estimacion, NomOficina, Nombre, FechaAnt,  '
SET @csql = @csql + 'MontoDesembolsoAnt, SaldoCarteraAnt, Saldo0DiasAnt, Saldo90DiasAnt, RecuperacionAnt, EstimacionAnt, MontoDesembolsoAnt - MontoDesembolso AS MontoDesembolsoDif,  '
SET @csql = @csql + ' SaldoCarteraAnt - SaldoCartera AS SaldoCarteraDif, Saldo0DiasAnt - Saldo0Dias AS Saldo0DiasDif, Saldo90DiasAnt - Saldo90Dias AS Saldo90DiasDif,  '
SET @csql = @csql + ' RecuperacionAnt - Recuperacion  AS RecuperacionDif, EstimacionAnt - Estimacion AS EstimacionDif, Asesor FROM ( '
SET @csql = @csql + 'SELECT     A.Fecha, A.CodOficina, A.MontoDesembolso, A.SaldoCartera, A.Saldo0Dias, A.Saldo90Dias, A.Recuperacion, A.Estimacion, A.NomOficina, A.Nombre,  '
SET @csql = @csql + 'B.Fecha AS FechaAnt, ISNULL(B.MontoDesembolso, 0) AS MontoDesembolsoAnt, ISNULL(B.SaldoCartera, 0) AS SaldoCarteraAnt,  '
SET @csql = @csql + 'ISNULL(B.Saldo0Dias, 0) AS Saldo0DiasAnt, ISNULL(B.Saldo90Dias, 0) AS Saldo90DiasAnt, ISNULL(B.Recuperacion, 0) AS RecuperacionAnt,ISNULL(B.Estimacion, 0) AS EstimacionAnt, a.Asesor  '

SET @csql = @csql + 'FROM (SELECT     tCsBsCartera.Fecha, tCsBsCartera.CodOficina, SUM(tCsBsCartera.MontoDesembolso) AS MontoDesembolso,  '
SET @csql = @csql + 'SUM(tCsBsCartera.SaldoCartera) AS SaldoCartera, SUM(tCsBsCartera.Saldo0Dias) AS Saldo0Dias, SUM(tCsBsCartera.Saldo90Dias)  '
SET @csql = @csql + 'AS Saldo90Dias, SUM(tCsBsCartera.Recuperacion) AS Recuperacion, SUM(tCsBsCartera.Estimacion) AS Estimacion, tClOficinas.NomOficina, tClZona.Nombre, tCsPadronClientes.NombreCompleto AS asesor '
SET @csql = @csql + 'FROM tClZona INNER JOIN tClOficinas ON tClZona.Zona = tClOficinas.Zona RIGHT OUTER JOIN tCsBsCartera LEFT OUTER JOIN '
SET @csql = @csql + 'tCsPadronClientes ON tCsBsCartera.CodAsesor = tCsPadronClientes.CodUsuario ON tClOficinas.CodOficina = tCsBsCartera.CodOficina '
SET @csql = @csql + 'WHERE   tCsBsCartera.codoficina in ('+@CodOficina+')  AND (tCsBsCartera.CodAsesor IN ('+@CodAsesor+')) and   '

IF (@Tipo=1)
	BEGIN
		SET @csql = @csql + '(tCsBsCartera.Fecha >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''' and '
		SET @csql = @csql + ' tCsBsCartera.Fecha <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''' ) '
	END
ELSE
	BEGIN
		SET @csql = @csql + '(tCsBsCartera.Fecha IN (SELECT  UltimoDia FROM tClPeriodo '
		SET @csql = @csql + 'WHERE (UltimoDia >= '''+dbo.fduFechaAAAAMMDD(@FecIni) +''' '
		SET @csql = @csql + 'and UltimoDia <= '''+dbo.fduFechaAAAAMMDD(@FecFin) +'''))) '
	END


SET @csql = @csql + 'GROUP BY tCsBsCartera.Fecha, tCsBsCartera.CodOficina, tClOficinas.NomOficina, tClZona.Nombre,  tCsPadronClientes.NombreCompleto) A LEFT OUTER JOIN '
SET @csql = @csql + '(SELECT Fecha, CodOficina, MontoDesembolso, SaldoCartera, Saldo0Dias, Saldo90Dias, Recuperacion, Estimacion, NomOficina, Nombre, Asesor '
SET @csql = @csql + 'FROM (SELECT     tCsBsCartera.Fecha, tCsBsCartera.CodOficina, SUM(tCsBsCartera.MontoDesembolso) AS MontoDesembolso,  '
SET @csql = @csql + 'SUM(tCsBsCartera.SaldoCartera) AS SaldoCartera, SUM(tCsBsCartera.Saldo0Dias) AS Saldo0Dias, SUM(tCsBsCartera.Saldo90Dias) AS Saldo90Dias, SUM(tCsBsCartera.Recuperacion) AS Recuperacion, '
SET @csql = @csql + 'SUM(tCsBsCartera.Estimacion) AS Estimacion, tClOficinas.NomOficina, tClZona.Nombre,  tCsPadronClientes.NombreCompleto AS asesor FROM tClZona INNER JOIN tClOficinas ON tClZona.Zona = tClOficinas.Zona RIGHT OUTER JOIN '
SET @csql = @csql + 'tCsBsCartera LEFT OUTER JOIN tCsPadronClientes ON tCsBsCartera.CodAsesor = tCsPadronClientes.CodUsuario ON tClOficinas.CodOficina = tCsBsCartera.CodOficina '
SET @csql = @csql + 'WHERE    tCsBsCartera.codoficina in ('+@CodOficina+') AND (tCsBsCartera.CodAsesor IN ('+@CodAsesor+')) and  '

IF (@Tipo=1)
	BEGIN
		SET @csql = @csql + '(tCsBsCartera.Fecha >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''' and '
		SET @csql = @csql + ' tCsBsCartera.Fecha <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''' ) '
	END
ELSE
	BEGIN
		SET @csql = @csql + '(tCsBsCartera.Fecha IN (SELECT  UltimoDia FROM tClPeriodo '
		SET @csql = @csql + 'WHERE (UltimoDia >= '''+dbo.fduFechaAAAAMMDD(@FecIni) +''' '
		SET @csql = @csql + 'and UltimoDia <= '''+dbo.fduFechaAAAAMMDD(@FecFin) +'''))) '
	END

SET @csql = @csql + 'GROUP BY tCsBsCartera.Fecha, tCsBsCartera.CodOficina, tClOficinas.NomOficina, tClZona.Nombre, tCsPadronClientes.NombreCompleto) A) B ON A.CodOficina = B.CodOficina AND B.Fecha = '

IF (@Tipo=1)
	BEGIN
		SET @csql = @csql + ' dateadd(day, - 1, A.Fecha) '
	END
ELSE
	BEGIN
		SET @csql = @csql + ' (SELECT dateadd(day, - 1, primerDia) FROM tClPeriodo WHERE UltimoDia = A.Fecha) '
	END

SET @csql = @csql + ' ) C '
print @csql
exec (@csql)
GO