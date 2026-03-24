SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaRptResumenxFinesMesxAsesorPor]  @FecIni smalldatetime, @FecFin smalldatetime,@CodOficina varchar(2), @CodAsesor varchar(100) AS
--DECLARE @FecIni smalldatetime, @FecFin smalldatetime,@CodOficina varchar(2), @Tipo int, @CodAsesor varchar(100)

--SET @FecIni = '20080901'
--SET @FecFin = '20080930' 
--SET @CodOficina = '2'
--SET @Tipo = 1
--SET @CodAsesor = '''CLL0402841'''

DECLARE @csql varchar(8000)
SET @csql = 'SELECT tCsBsCartera.Fecha, tCsBsCartera.CodOficina, SUM(tCsBsCartera.SaldoCartera) AS SaldoCartera, SUM(tCsBsCartera.Saldo0Dias) AS Saldo0Dias, '
SET @csql = @csql + 'SUM(tCsBsCartera.Saldo90Dias) AS Saldo90Dias, tCsPadronClientes.NombreCompleto AS asesor, SUM(tCsBsCartera.Saldo90Dias) / SUM(tCsBsCartera.SaldoCartera) * 100 AS Mora90, '
SET @csql = @csql + 'SUM(tCsBsCartera.Saldo90Dias) / SUM(tCsBsCartera.SaldoCartera) * 100 AS Mora0 '
SET @csql = @csql + 'FROM tClZona INNER JOIN tClOficinas ON tClZona.Zona = tClOficinas.Zona RIGHT OUTER JOIN tCsBsCartera LEFT OUTER JOIN tCsPadronClientes '
SET @csql = @csql + 'ON tCsBsCartera.CodAsesor = tCsPadronClientes.CodUsuario ON tClOficinas.CodOficina = tCsBsCartera.CodOficina '
SET @csql = @csql + 'WHERE   tCsBsCartera.codoficina in ('+@CodOficina+')  AND (tCsBsCartera.CodAsesor IN ('+@CodAsesor+')) and '
SET @csql = @csql + '(tCsBsCartera.Fecha = '''+dbo.fduFechaAAAAMMDD(@FecIni)+''' or '
SET @csql = @csql + ' tCsBsCartera.Fecha = '''+dbo.fduFechaAAAAMMDD(@FecFin)+''' ) '
SET @csql = @csql + 'GROUP BY tCsBsCartera.Fecha, tCsBsCartera.CodOficina, tClOficinas.NomOficina, tClZona.Nombre, tCsPadronClientes.NombreCompleto'

--print @csql

exec (@csql)
GO