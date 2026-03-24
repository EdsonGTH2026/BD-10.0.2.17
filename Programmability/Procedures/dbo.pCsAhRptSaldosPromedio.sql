SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsAhRptSaldosPromedio] @codoficina varchar(50) AS

Declare @Fecha 		SmallDateTime
Declare @Periodo	Varchar(6)
Declare @FechaI		SmallDateTime

Set @Fecha 	= '20080831'

Set @Periodo	= dbo.fduFechaAperiodo(@Fecha)
Set @FechaI 	= Cast(@Periodo + '01' as SmallDateTime)

DECLARE @csql varchar(8000)

SET @csql = ' SELECT   Fecha = '''+ dbo.fduFechaAAAAMMDD(@Fecha)+''', tCsAhorros.CodCuenta, tCsAhorros.FraccionCta, tCsAhorros.Renovado, tCsAhorros.CodUsuario, tCsPadronClientes.NombreCompleto, tAhClTipoProducto.DescTipoProd, tCsAhorros.FechaApertura,  '
SET @csql = @csql + 'tCsAhorros.FechaVencimiento, CASE ISNULL(tCsAhorros.Plazo, 0) WHEN 0 THEN ''A LA VISTA'' ELSE cast(ISNULL(tCsAhorros.Plazo, 0) AS varchar(50))  '
SET @csql = @csql + 'END AS Plazo, DATEDIFF([day], CASE WHEN tCsAhorros.FechaApertura < '''+dbo.fduFechaAAAAMMDD(@FechaI)+''' THEN '''+dbo.fduFechaAAAAMMDD(@FechaI)+''' ELSE tCsAhorros.FechaApertura END,  '''
SET @csql = @csql + dbo.fduFechaAAAAMMDD(@Fecha)+''') + 1 AS PagoRendimiento, tCsAhorros.TasaInteres, tCsAhorros.SaldoCuenta As SaldoBruto, tCsAhorros.IntAcumulado as IntAcumulado1, tCsAhorros.SaldoCuenta + tCsAhorros.IntAcumulado AS SaldoTotal, '
SET @csql = @csql + 'CASE TAhProductos.idTipoProd WHEN 2 THEN saldocuenta END AS MontoDPF, tCsAhorros.IntAcumulado, Mes.DevengadoMes, Mes.SaldoPromedio, '
SET @csql = @csql + 'tClOficinas.NomOficina, Ubigeo = Isnull(CodUbiGeoDirFamPri, CodUbiGeoDirNegPri), tCsPadronClientes.DireccionDirFamPri, tCsPadronClientes.CodUbiGeoDirFamPri, tCPLugar.Lugar, tCPLugar.CodigoPostal '
SET @csql = @csql + 'FROM tClUbigeo LEFT OUTER JOIN tCPLugar ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND '
SET @csql = @csql + ' tClUbigeo.CodEstado = tCPLugar.CodEstado RIGHT OUTER JOIN tCsPadronClientes ON tClUbigeo.CodUbiGeo = ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.CodUbiGeoDirNegPri)  '
SET @csql = @csql + 'RIGHT OUTER JOIN tClOficinas RIGHT OUTER JOIN tCsAhorros ON tClOficinas.CodOficina = tCsAhorros.CodOficina LEFT OUTER JOIN '
SET @csql = @csql + '(SELECT     CodCuenta, FraccionCta, Renovado, SUM(InteresCalculado) AS DevengadoMes, AVG(SaldoCuenta + IntAcumulado)  AS SaldoPromedio '
SET @csql = @csql + 'FROM tCsAhorros WHERE  (dbo.fduFechaAPeriodo(Fecha) = '+@Periodo+') GROUP BY CodCuenta, FraccionCta, Renovado) Mes ON tCsAhorros.CodCuenta = Mes.CodCuenta COLLATE Modern_Spanish_CI_AI AND '
SET @csql = @csql + 'tCsAhorros.FraccionCta = Mes.FraccionCta COLLATE Modern_Spanish_CI_AI AND tCsAhorros.Renovado = Mes.Renovado LEFT OUTER JOIN '
SET @csql = @csql + 'tAhClTipoProducto INNER JOIN tAhProductos ON tAhClTipoProducto.idTipoProd = tAhProductos.idTipoProd ON tCsAhorros.CodProducto = tAhProductos.idProducto ON '
SET @csql = @csql + 'tCsPadronClientes.CodUsuario = tCsAhorros.CodUsuario '
SET @csql = @csql + 'WHERE (tCsAhorros.Fecha = '''+dbo.fduFechaAAAAMMDD(@Fecha)+''') and Mes.SaldoPromedio>2000 and tCsAhorros.codoficina in ('+@codoficina+') '                      
print @csql
exec (@csql )
GO