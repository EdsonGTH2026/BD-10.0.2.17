SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsCaCuadroEstimacionTabla
Create Procedure [dbo].[pCsCaCuadroEstimacionTabla]
@Fecha SmallDateTime
As
SELECT  Fecha = @Fecha, tCaClProvision.Identificador, tCaClProvision.Orden, tCaClProvision.CodTipoCredito, tCaProdPerTipoCredito.Descripcion AS TipoCredito, tCaClProvision.TipoReprog, 
                      tCaClProvision.Estado, tCaClProvision.DiasMinimo, tCaClProvision.DiasMaximo, tCaClProvision.Capital, tCaClProvision.Interes, tCaClProvision.VigenciaInicio, 
                      tCaClProvision.VigenciaFin
FROM         tCaClProvision INNER JOIN
                      tCaProdPerTipoCredito ON tCaClProvision.CodTipoCredito = tCaProdPerTipoCredito.CodTipoCredito
WHERE tCaClProvision.VigenciaInicio <= @Fecha And tCaClProvision.VigenciaFin >= @Fecha
ORDER BY tCaClProvision.Identificador, tCaClProvision.TipoReprog DESC, tCaClProvision.Estado DESC, tCaClProvision.Orden
GO