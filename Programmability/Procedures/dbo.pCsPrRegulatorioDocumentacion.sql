SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE Procedure [dbo].[pCsPrRegulatorioDocumentacion]
@Dato		Int,
@Reporte 	Varchar(50)
As
If @Dato = 1
Begin
	SELECT     tCsPrReporte.Reporte, tCsPrReporte.Nombre, tCsPrReporte.Descripcion, tCsPrReporte.Sistema, tCsPrReporte.Archivo, tSgReportes.CodReporte, 
	                      tSgReportes.Fuentedatos, tSgReportes.Nombre AS NombreReporte, tSgOptions.Nombre AS Opcion, tSgReportesParametros.CodParametro, 
	                      tSgReportesParametros.Nombre AS NombreParametro, tSgTipoDato.Nombre AS tipoDato, tSgReportesParametros.Etiqueta, 
	                      tSgReportesParametros.FuenteDatos AS FuenteParametro, tSgReportesParametros.PorDefecto, tSgReportesParametros.CampoMostrar, 
	                      tSgReportesParametros.CampoValor, CASE tSgReportesParametros.Visible WHEN 1 THEN 'Si' ELSE 'No' END AS Visible, tSgReportes.UsuarioRegistro, 
	                      tSgReportes.FechaCreacion, tSgReportes.FechaUltModificacion, tSgReportes.RutaUbicacion, Tiempo.Promedio
	FROM         (SELECT     REporte, dbo.fduFormatoHora(AVG(Ma)) AS Promedio
	                       FROM          (SELECT     REporte, Fecha, DATEDIFF([second], MIN(Generacion), MAX(Generacion)) AS Ma
	                                               FROM          tCsPrRegulatorios
	                                               WHERE      (Reporte = @Reporte)
	                                               GROUP BY Reporte, Fecha) Datos
	                       GROUP BY REporte) Tiempo RIGHT OUTER JOIN
	                      tCsPrReporte ON Tiempo.REporte COLLATE Modern_Spanish_CI_AI = tCsPrReporte.Reporte LEFT OUTER JOIN
	                      tSgOptions INNER JOIN
	                      tSgReportes ON tSgOptions.Objeto = tSgReportes.CodReporte INNER JOIN
	                      tSgReportesParametros ON tSgReportes.CodReporte = tSgReportesParametros.CodReporte INNER JOIN
	                      tSgTipoDato ON tSgReportesParametros.TipoDato = tSgTipoDato.TipoDato ON tSgReportes.RutaUbicacion LIKE '%' + tCsPrReporte.Archivo + '%'
	WHERE     (tCsPrReporte.Reporte = @Reporte)
	ORDER BY tSgReportesParametros.CodParametro
end
If @Dato = 2
Begin
	SELECT DISTINCT 
	                      tCsPrReporte.Reporte, tCsPrReporte.Nombre, Columna.Identificador, Columna.Columna, tCsPrReportesAnexos.OtroDato, 
	                      tCsPrReportesAnexos.Descripcion AS Descripcion, tCsPrReportesAnexos.MostrarCuenta, tCsPrReportesAnexos.pInicio, tCsPrReportesAnexos.PFin, 
	                      ISNULL(tCsPrReportesAnexos.Formula, tCsPrReportesAnexos.Procedimiento) + ISNULL(' @Fecha, ' + tCsPrReportesAnexos.Parametros, '') AS Formula, 
	                      CASE WHEN tCsPrReportesAnexos.PeriodoAnterior = 1 THEN 'Si' ELSE 'No' END AS PeriodoAnterior, tCsPrReportesAnexos.Identificador AS I, 
	                      tCsPrReportesAnexos.Nivel, TN.TN
	FROM         tCsPrReportesAnexos RIGHT OUTER JOIN
	                      tCsPrReporte ON tCsPrReportesAnexos.Reporte = tCsPrReporte.Reporte LEFT OUTER JOIN
	                          (SELECT     Reporte, Columna, descidentificador Identificador
	                            FROM          tCsPrReportesAnexos
	                            WHERE      (Nivel = 1)) Columna ON tCsPrReportesAnexos.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI AND 
	                      tCsPrReportesAnexos.DescIdentificador = Columna.Identificador COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN
	                          (SELECT     Reporte, Nivel, dbo.fduFormatoHora(AVG(D)) AS TN
	                            FROM          (SELECT     Reporte, Fecha, Nivel, DATEDIFF([second], MIN(Generacion), MAX(Generacion)) AS D
	                                                    FROM          tCsPrRegulatorios
	                                                    WHERE      (Reporte = @Reporte)
	                                                    GROUP BY Reporte, Fecha, Nivel) Datos
	                            GROUP BY Reporte, Nivel) TN ON tCsPrReportesAnexos.Nivel = TN.Nivel
	WHERE     (tCsPrReporte.Reporte = @Reporte)
	End
GO