SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsAhProxVencimientosDPF] @fecIni  smalldatetime, @fecFin  smalldatetime
--declare @fecIni  smalldatetime
--declare @fecFin  smalldatetime
--set @fecIni='20160501'
--set @fecFin='20160531'
as
	DECLARE @Fecha smalldatetime
	select @Fecha = fechaconsolidacion from vCsFechaConsolidacion

	SELECT a.Fecha, a.CodOficina, o.NomOficina sucursal, a.CodProducto, tAhProductos.Abreviatura, 
	a.CodUsuario, cl.NombreCompleto, a.CodCuenta, a.fraccioncta,
	a.Renovado, a.CodMoneda, a.FechaApertura, a.FechaVencimiento, a.TasaInteres, 
	a.SaldoCuenta, a.MontoInteres, a.IntAcumulado, a.MontoBloqueado, a.Plazo, cl.FechaIngreso, cl.FechaNacimiento, cl.CodEstadoCivil, 
	cl.CodConyuge, cl.Sexo, cl.CodUbiGeoDirFamPri, cl.DireccionDirFamPri, 
	replace(cl.TelefonoDirFamPri,'_','') TelefonoDirFamPri, a.idEstadoCta, tAhClEstadoCuenta.Descripcion AS EstadoCTa, 
	tAhClTipoInteres.Descripcion AS TipoInteres
	FROM tCsAhorros a with(nolock) INNER JOIN
	tClOficinas o with(nolock) ON a.CodOficina = o.CodOficina INNER JOIN
	tCsPadronClientes cl with(nolock) ON a.CodUsuario = cl.CodUsuario LEFT OUTER JOIN
	tAhProductos with(nolock) ON a.CodProducto = tAhProductos.idProducto INNER JOIN
	tAhClTipoProducto with(nolock) ON tAhProductos.idTipoProd = tAhClTipoProducto.idTipoProd INNER JOIN
	tAhClFormaManejo with(nolock) ON a.FormaManejo = tAhClFormaManejo.FormaManejo INNER JOIN
	tAhClEstadoCuenta with(nolock) ON a.idEstadoCta = tAhClEstadoCuenta.idEstadoCta INNER JOIN
	tAhClTipoInteres with(nolock) ON a.CodTipoInteres = tAhClTipoInteres.CodTipoInteres
	WHERE a.Fecha =  @Fecha   AND  a.idEstadoCta <> 'cc' 
	and  a.FechaVencimiento>= @FecIni and   a.FechaVencimiento <= @FecFin
GO

GRANT EXECUTE ON [dbo].[pCsAhProxVencimientosDPF] TO [jarriagaa]
GO