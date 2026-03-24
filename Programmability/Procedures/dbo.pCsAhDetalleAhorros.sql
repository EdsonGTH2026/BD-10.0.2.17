SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsAhDetalleAhorros
--pCsAhDetalleAhorros '20170131','72'
CREATE PROCEDURE  [dbo].[pCsAhDetalleAhorros] @fecha smalldatetime, @oficina varchar(1200) 
AS
SELECT     ah.Fecha, ah.CodOficina, o.NomOficina, o.DescOficina, ah.CodProducto, tAhProductos.Abreviatura, 
                      tAhClTipoProducto.DescTipoProd, tAhClFormaManejo.Descripcion, ah.CodUsuario, cl.NombreCompleto, ah.CodCuenta, 
                      ah.Renovado, ah.CodMoneda, ah.FechaApertura, ah.FechaVencimiento, ah.FechaCierre, ah.TasaInteres, 
                      ah.FechaUltMov, ah.SaldoCuenta, ah.MontoInteres, ah.IntAcumulado, ah.MontoInteresCapitalizado, 
                      ah.MontoBloqueado, ah.MontoRetenido, ah.InteresCalculado, ah.Plazo, ah.Lucro, ah.CodAsesor, 
                      tCsPadronClientes_1.NombreCompleto AS AsesordeAhorro, cl.FechaIngreso, cl.FechaNacimiento, cl.CodEstadoCivil, 
                      cl.CodConyuge, cl.Sexo, cl.CodUbiGeoDirFamPri, cl.DireccionDirFamPri, 
                      cl.TelefonoDirFamPri, ah.FechaUltCapitalizacion, ah.idEstadoCta, ah.NomCuenta, 
                      tAhClEstadoCuenta.Descripcion AS EstadoCTa, ah.FondoConfirmar, replace(replace(ah.Observacion,char(13),''),char(10),'') Observacion, ah.EnGarantia, ah.Garantia, 
                      ah.CuentaPreferencial, ah.CuentaReservada, ah.CodCuentaAnt, ah.FechaCambioEstado, ah.FechaInactivacion, 
                      ah.NroSolicitud, tAhClTipoInteres.Descripcion AS TipoInteresExpr1, tAhClTipoInteres.Estado
FROM tCsAhorros ah with(nolock) INNER JOIN tClOficinas o with(nolock) ON ah.CodOficina = o.CodOficina 
INNER JOIN tCsPadronClientes cl with(nolock) ON ah.CodUsuario = cl.CodUsuario 
LEFT OUTER  JOIN tCsPadronClientes tCsPadronClientes_1 with(nolock) ON ah.CodAsesor = tCsPadronClientes_1.CodUsuario 
INNER JOIN tAhProductos with(nolock) ON ah.CodProducto = tAhProductos.idProducto 
INNER JOIN tAhClTipoProducto with(nolock) ON tAhProductos.idTipoProd = tAhClTipoProducto.idTipoProd 
INNER JOIN tAhClFormaManejo with(nolock) ON ah.FormaManejo = tAhClFormaManejo.FormaManejo 
INNER JOIN tAhClEstadoCuenta with(nolock) ON ah.idEstadoCta = tAhClEstadoCuenta.idEstadoCta 
INNER JOIN tAhClTipoInteres with(nolock) ON ah.CodTipoInteres = tAhClTipoInteres.CodTipoInteres
WHERE    ah.Fecha = @fecha  AND  ah.idEstadoCta <> 'cc'  --AND tClOficinas.CodOficina =  @oficina
and ah.codoficina in (select cast(campo as int) codoficina from dbo.fduCAT_SplitString(@oficina))
GO