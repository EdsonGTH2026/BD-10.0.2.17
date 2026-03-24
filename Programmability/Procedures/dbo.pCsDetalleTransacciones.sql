SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsDetalleTransacciones] 
@fecini smalldatetime,  
@fecfin smalldatetime, 
@oficinas varchar(1500), 
@sistema varchar(2)  

AS

If @Oficinas = 'ZZZ'
Begin
	Set @Oficinas = 'Select CodOficina From TclOficinas with(nolock)'
End

--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--declare @oficinas varchar(100)
--declare @sistema varchar(2)

--set @fecini		= '20090101'
--set @fecfin		= '20090131'
--set @oficinas		= '2,3,4,19,20'
--set @sistema		= 'CA'

declare @csql	varchar(8000)
declare @csql1	varchar(8000)

set @csql = '
    SELECT DISTINCT tr.Fecha, REPLICATE(''0'', 2 - LEN(LTRIM(RTRIM(tr.TranHora)))) + LTRIM(RTRIM(tr.TranHora))  
           + '':'' + REPLICATE(''0'', 2 - LEN(LTRIM(RTRIM(tr.TranMinuto)))) + LTRIM(RTRIM(tr.TranMinuto)) + '':'' + REPLICATE(''0'', 
           2 - LEN(LTRIM(RTRIM(tr.TranSegundo)))) + LTRIM(RTRIM(tr.TranSegundo)) AS Hora, tClOficinas.CodOficina, 
           tClOficinas.NomOficina AS OficinaTrans, tr.CodigoCuenta, tr.CodSistema, OficinaCuenta.NomOficina AS OficinaCuenta, 
           tr.NroTransaccion, CASE tr.TipoTransacNivel1 WHEN ''I'' THEN ''INGRESO'' WHEN ''E'' THEN ''EGRESO'' WHEN ''O'' THEN ''OTROS'' 
           ELSE tr.TipoTransacNivel1 END AS TipoTransacNivel1, tr.TipoTransacNivel2, tr.Extornado, 
           tr.NombreCliente, tr.DescripcionTran, tr.MontoCapitalTran, tr.MontoInteresTran, 
           tr.MontoINPETran, MontoOtrosTran = tr.MontoOtrosTran + isnull(tr.MontoCargos,0) + isnull(tr.MontoImpuestos, 0), 
           tr.MontoTotalTran, tr.NroCuenta, tr.NroCheque'

if(@sistema<>'TC') set @csql = @csql + ',Producto.Nombre AS Producto '
if(@sistema='TC')  set @csql = @csql + ', '''' AS Producto, ISNULL(tSgUsuarios.NombreCompleto, '''') AS Asesor, '''' AS DiasAtraso, '''' AS Estado '
if(@sistema='CA')  set @csql = @csql + ', ase.NomAsesor, tCsCartera.NroDiasAtraso, tCsCartera.Estado '

If @Sistema = 'TC'
Begin
	Set @csql = @csql + '
    FROM tCsTransaccionDiaria tr with(nolock) 
    LEFT  JOIN tCsPadronClientes with(nolock)    ON tCsPadronClientes.codusuario=tr.codusuario 
    inner join tClOficinas OficinaCuenta with(nolock) ON OficinaCuenta.CodOficina = tr.CodOficinaCuenta 
    LEFT  JOIN tCsPadronClientes tSgUsuarios with(nolock) ON tr.codasesor=tSgUsuarios.codUsuario 
    LEFT  JOIN tClOficinas with(nolock) ON tr.CodOficina = tClOficinas.CodOficina '
End	

If @Sistema In ('CA', 'AH')
Begin
	Set @csql = @csql + '
	FROM tCsTransaccionDiaria tr with(nolock) 
	LEFT OUTER JOIN tClOficinas OficinaCuenta ON tr.CodOficinaCuenta = OficinaCuenta.CodOficina 
	LEFT OUTER JOIN tClOficinas (nolock) ON tr.CodOficina = tClOficinas.CodOficina '
End
if(@sistema='CA') 
	set @csql = @csql + '
	LEFT JOIN (SELECT CodProducto,NombreProdCorto Nombre FROM tCaProducto with(nolock)) Producto ON tr.CodProducto = Producto.CodProducto 
	LEFT JOIN tCsAsesores ase with(nolock) ON tr.CodOficina = ase.CodOficina AND tr.CodAsesor = ase.CodAsesor 
	LEFT JOIN tCsCartera ON DATEADD(day, - 1, tr.Fecha) = tCsCartera.Fecha AND tr.CodigoCuenta = tCsCartera.CodPrestamo '
if(@sistema='AH') 
    set @csql = @csql + '   LEFT OUTER JOIN (SELECT idProducto,nombre FROM tAhProductos with(nolock)) Producto ON tr.CodProducto = Producto.idProducto '

set @csql = @csql + '
    WHERE (tr.Fecha >= '''+dbo.fduFechaATexto(@fecini,'aaaammdd')+''') 
    AND (tr.Fecha <= '''+dbo.fduFechaATexto(@fecfin,'aaaammdd')+''') 
    AND (tr.CodSistema = '''+@sistema+''')'
Set @csql1 = ' AND (tr.CodOficina IN ('+@oficinas+')) '

print @csql + @csql1
exec(@csql + @csql1)


GO