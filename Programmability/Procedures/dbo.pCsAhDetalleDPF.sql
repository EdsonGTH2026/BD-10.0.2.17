SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsAhDetalleDPF] @fecIni  smalldatetime, @fecFin  smalldatetime,  @oficina varchar(1500)  as


/*
DECLARE @fecIni smalldatetime
DECLARE @fecFin smalldatetime
declare @oficina varchar(1500)
set @fecIni = '20171101'
set @fecFin = '20171130'
set @oficina =''
*/
DECLARE @Fecha smalldatetime

select @Fecha = fechaconsolidacion from vCsFechaConsolidacion

SELECT     a.Fecha, a.CodOficina, o.NomOficina, o.DescOficina, a.CodProducto, tAhProductos.Abreviatura, 
                      tAhClTipoProducto.DescTipoProd, tAhClFormaManejo.Descripcion, a.CodUsuario, tCsPadronClientes.NombreCompleto, a.CodCuenta, 
                      a.Renovado, a.CodMoneda, a.FechaApertura, a.FechaVencimiento, a.FechaCierre, a.TasaInteres, 
                      a.FechaUltMov, a.SaldoCuenta, a.MontoInteres, a.IntAcumulado, a.MontoInteresCapitalizado, 
                      a.MontoBloqueado, a.MontoRetenido, a.InteresCalculado, a.Plazo, a.Lucro, a.CodAsesor, 
                      tCsPadronClientes_1.NombreCompleto AS AsesordeAhorro, tCsPadronClientes.FechaIngreso, tCsPadronClientes.FechaNacimiento, tCsPadronClientes.CodEstadoCivil, 
                      tCsPadronClientes.CodConyuge, tCsPadronClientes.Sexo, tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.DireccionDirFamPri, 
                      tCsPadronClientes.TelefonoDirFamPri, a.FechaUltCapitalizacion, a.idEstadoCta, a.NomCuenta, 
                      tAhClEstadoCuenta.Descripcion AS EstadoCTa, a.FondoConfirmar, a.Observacion, a.EnGarantia, a.Garantia, 
                      a.CuentaPreferencial, a.CuentaReservada, a.CodCuentaAnt, a.FechaCambioEstado, a.FechaInactivacion, 
                      a.NroSolicitud, tAhClTipoInteres.Descripcion AS TipoInteresExpr1, tAhClTipoInteres.Estado
					  ,case when a.idtiporenova=1 then 'Manual' else 'Automatica' end TipoRenovacion
FROM         tCsAhorros a with(nolock) 
INNER JOIN tClOficinas o with(nolock) ON a.CodOficina = o.CodOficina 
INNER JOIN tCsPadronClientes with(nolock) ON a.CodUsuario = tCsPadronClientes.CodUsuario 
LEFT OUTER JOIN tCsPadronClientes tCsPadronClientes_1 with(nolock) ON a.CodAsesor = tCsPadronClientes_1.CodUsuario 
INNER JOIN tAhProductos with(nolock) ON a.CodProducto = tAhProductos.idProducto 
INNER JOIN tAhClTipoProducto with(nolock) ON tAhProductos.idTipoProd = tAhClTipoProducto.idTipoProd 
INNER JOIN tAhClFormaManejo with(nolock) ON a.FormaManejo = tAhClFormaManejo.FormaManejo 
INNER JOIN tAhClEstadoCuenta with(nolock) ON a.idEstadoCta = tAhClEstadoCuenta.idEstadoCta 
INNER JOIN tAhClTipoInteres with(nolock) ON a.CodTipoInteres = tAhClTipoInteres.CodTipoInteres
WHERE a.Fecha=@Fecha AND a.idEstadoCta<>'cc'
and a.FechaVencimiento>= @FecIni and a.FechaVencimiento<=@FecFin
--AND   tClOficinas.CodOficina =  @Oficina
AND a.CodOficina in(select codigo from dbo.fduTablaValores(@oficina))
GO