SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsDetalleServicios] @fecini smalldatetime,  @fecfin smalldatetime, @oficinas varchar(100), @sistema varchar(2)  AS

--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--declare @oficinas varchar(100)
--declare @sistema varchar(2)

--set @fecin		= '20090101'
--set @fecfin		= '20090131'
--set @oficinas		= '2,3,4,19,20'
--set @sistema		= 'CA'

declare @csql varchar(8000)

set @csql = 'SELECT tr.Fecha, REPLICATE(''0'', 2 - LEN(LTRIM(RTRIM(tr.TranHora)))) + LTRIM(RTRIM(tr.TranHora))  '
set @csql = @csql + '+ '':'' + REPLICATE(''0'', 2 - LEN(LTRIM(RTRIM(tr.TranMinuto)))) + LTRIM(RTRIM(tr.TranMinuto)) + '':'' + REPLICATE(''0'', '
set @csql = @csql + '2 - LEN(LTRIM(RTRIM(tr.TranSegundo)))) + LTRIM(RTRIM(tr.TranSegundo)) AS Hora, tClOficinas.CodOficina, '
set @csql = @csql + 'tClOficinas.NomOficina AS OficinaTrans, tr.CodigoCuenta, tr.CodSistema, OficinaCuenta.NomOficina AS OficinaCuenta, '
set @csql = @csql + 'tr.NroTransaccion, CASE tr.TipoTransacNivel1 WHEN ''I'' THEN ''INGRESO'' WHEN ''E'' THEN ''EGRESO'' WHEN ''O'' THEN ''OTROS'' '
set @csql = @csql + 'ELSE tr.TipoTransacNivel1 END AS TipoTransacNivel1, tr.TipoTransacNivel2, tr.Extornado, '
set @csql = @csql + 'tr.NombreCliente, tr.DescripcionTran, tr.MontoCapitalTran, tr.MontoInteresTran, '
set @csql = @csql + 'tr.MontoINPETran, tr.MontoOtrosTran, tr.MontoTotalTran, tr.NroCuenta,tr.NroCheque '

if(@sistema<>'TC') set @csql = @csql + ',Producto.Nombre AS Producto '
if(@sistema='TC')  set @csql = @csql + ', '''' AS Producto '
if(@sistema='CA')  set @csql = @csql + ', ase.NomAsesor '


set @csql = @csql + 'FROM tCsTransaccionDiaria tr LEFT OUTER JOIN tClOficinas OficinaCuenta ON tr.CodOficinaCuenta = '
set @csql = @csql + 'OficinaCuenta.CodOficina LEFT OUTER JOIN tClOficinas ON tr.CodOficina = tClOficinas.CodOficina '

if(@sistema='CA') 
	begin
		set @csql = @csql + 'LEFT OUTER JOIN (SELECT CodProducto,NombreProdCorto Nombre FROM tCaProducto) Producto ON tr.CodProducto = Producto.CodProducto '
		set @csql = @csql + 'LEFT OUTER JOIN tCsAsesores ase ON tr.CodOficina = ase.CodOficina AND tr.CodAsesor = ase.CodAsesor '
	end
if(@sistema='AH') set @csql = @csql + 'LEFT OUTER JOIN (SELECT idProducto,nombre FROM tAhProductos) Producto ON tr.CodProducto = Producto.idProducto '

set @csql = @csql + 'WHERE (tr.Fecha >= '''+dbo.fduFechaATexto(@fecini,'aaaammdd')+''') '
set @csql = @csql + ' AND (tr.Fecha <= '''+dbo.fduFechaATexto(@fecfin,'aaaammdd')+''') '
--set @csql = @csql + ' AND (tr.CodSistema = ''TC'') '
--set @csql = @csql + ' AND (tr.CodOficina IN ('+@oficinas+')) '
set @csql = @csql + ''
--print @csql
exec(@csql)
GO