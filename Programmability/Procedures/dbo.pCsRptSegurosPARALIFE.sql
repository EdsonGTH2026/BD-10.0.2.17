SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsRptSegurosPARALIFE] @FecIni smalldatetime, @FecFin smalldatetime, @CodOficina varchar(200)  AS
DECLARE @csql varchar(8000)
SET @csql = 'SELECT tCsTransaccionDiaria.Fecha, tClOficinas.NomOficina, tCsTransaccionDiaria.TipoTransacNivel1, tCsTransaccionDiaria.TipoTransacNivel2, '
SET @csql = @csql + 'tCsTransaccionDiaria.TipoTransacNivel3, tCsTransaccionDiaria.Extornado, tCsTransaccionDiaria.NombreCliente, tCsTransaccionDiaria.DescripcionTran, tCsTransaccionDiaria.MontoTotalTran '
SET @csql = @csql + 'FROM tCsTransaccionDiaria LEFT OUTER JOIN tClOficinas ON tCsTransaccionDiaria.CodOficina = tClOficinas.CodOficina '
SET @csql = @csql + 'WHERE (tCsTransaccionDiaria.Fecha >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''') AND '
SET @csql = @csql + '(tCsTransaccionDiaria.Fecha <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''') AND (tCsTransaccionDiaria.CodSistema = ''tc'') AND  '
SET @csql = @csql + '(tCsTransaccionDiaria.TipoTransacNivel3 in(2,13)) '
SET @csql = @csql + 'AND (tCsTransaccionDiaria.codoficina in ('+ @CodOficina +')) '

exec (@csql)
GO