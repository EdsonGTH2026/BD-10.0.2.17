SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsRptRemesasBANSEFI] @FecIni smalldatetime, @FecFin smalldatetime, @CodOficina varchar(200),@codtransac varchar(150)  AS

DECLARE @csql varchar(8000)

SET @csql = 'SELECT t.Fecha, o.NomOficina, t.TipoTransacNivel1, t.TipoTransacNivel2,  '
SET @csql = @csql + 't.TipoTransacNivel3, t.Extornado, t.NombreCliente,t.DescripcionTran, t.MontoTotalTran  '
SET @csql = @csql + 'FROM tCsTransaccionDiaria t with(nolock) LEFT OUTER JOIN tClOficinas o with(nolock) ON t.CodOficina = o.CodOficina '
SET @csql = @csql + 'WHERE (t.Fecha >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''') AND '
SET @csql = @csql + '(t.Fecha <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''') AND (t.CodSistema = ''tc'') AND  '
SET @csql = @csql + '(t.TipoTransacNivel3 = 1) '
SET @csql = @csql + 'AND (t.codoficina in ('+ @CodOficina +')) and t.TipoTransacNivel3 in('+@codtransac+')'
print @csql
exec (@csql)


GO