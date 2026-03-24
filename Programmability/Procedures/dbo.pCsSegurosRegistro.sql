SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsSegurosRegistro]
@CodPrestamo	Varchar(30),
@Firma			Varchar(100)
As

Print @Firma
Print @CodPrestamo

Insert Into tCsSeguros
SELECT        Datos.CodAseguradora, Datos.CodOficina, Datos.NumPoliza, Datos.Fecha, Datos.Hora, Datos.codprodseguro, Datos.CodUsuarioAse, Datos.CodUsuarioPag, 
                         Datos.primaanual, Datos.sumaasegurada, Datos.Estado, Datos.Asegurado, Datos.Usuario, Datos.Pagador, Datos.interrulab, Datos.Enfermo, Datos.Actividad, 
                         Direccion = Datos.Direccion, Telefono = Datos.Telefono,
                         Datos.Incorporado, Datos.IdeAce, Datos.Error, Datos.Firma                       
FROM            (SELECT        tCsSegurosAseguradora.CodAseguradora, Oficina.CodOficina, dbo.fduRellena('0', LTRIM(RTRIM(tCsFirmaReporteDetalle_1.Identificador)), 13, 'D') 
                                                    AS NumPoliza, tCsFirmaReporte.Fecha1 AS Fecha, GETDATE() AS Hora, tCsSegurosProd.codprodseguro, 
                                                    tCsFirmaReporteDetalle_1.Identificador AS CodUsuarioAse, tCsFirmaReporteDetalle_1.Identificador AS CodUsuarioPag, tCsSegurosProd.primaanual, 
                                                    tCsSegurosProd.sumaasegurada, 1 AS Estado, tCsFirmaReporteDetalle_1.Sujeto AS Asegurado, tCsFirmaElectronica.Usuario, 
                                                    tCsFirmaReporteDetalle_1.Sujeto AS Pagador, CASE WHEN charindex('no he interrumpido mis actividades', Texto, 1) 
                                                    > 0 THEN 0 ELSE 1 END AS interrulab, 0 AS Enfermo, tCsFirmaReporteDetalle_1.Actividad, 0 AS Incorporado, NULL AS IdeAce, NULL AS Error,
                                                    tCsFirmaElectronica.Firma, tCsFirmaReporteDetalle_1.Direccion, tCsFirmaReporteDetalle_1.Telefono
                          FROM            tCsFirmaElectronica INNER JOIN
                                                    tCsFirmaReporte INNER JOIN
                                                    tCsFirmaReporteDetalle AS tCsFirmaReporteDetalle_1 ON tCsFirmaReporte.Firma = tCsFirmaReporteDetalle_1.Firma ON 
                                                    tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma CROSS JOIN
                                                    tCsSegurosProd INNER JOIN
                                                    tCsSegurosAseguradora ON tCsSegurosProd.codaseguradora = tCsSegurosAseguradora.CodAseguradora CROSS JOIN
                                                        (SELECT        MAX(tCsFirmaReporteDetalle.EstadoCivil) AS CodOficina
                                                          FROM            tCsFirmaReporteDetalle INNER JOIN
                                                                                    tCsFirmaElectronica AS tCsFirmaElectronica_1 ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica_1.Firma
                                                          WHERE        (tCsFirmaReporteDetalle.Grupo = 'G') AND (tCsFirmaElectronica_1.Dato = @CodPrestamo)) AS Oficina
                          WHERE        (tCsSegurosAseguradora.CodAseguradora = '02') AND (tCsFirmaReporteDetalle_1.Grupo = 'A') AND (tCsSegurosProd.codprodseguro = 1) AND 
                                                    (tCsFirmaElectronica.Firma = @Firma)) AS Datos LEFT OUTER JOIN
                         tCsSeguros ON Datos.CodAseguradora = tCsSeguros.codaseguradora AND Datos.CodOficina = tCsSeguros.codoficina AND 
                         Datos.NumPoliza = tCsSeguros.numpoliza
WHERE        (tCsSeguros.codaseguradora IS NULL)

/*                         
Insert Into tCsSegurosBene
SELECT        Datos.CodAseguradora, Datos.CodOficina, Datos.NumPoliza, Datos.CodUsuario, Datos.Orden, Datos.Porcentaje, Datos.NombreCompleto, 
                         Datos.CodParentesco
FROM            (SELECT        tCsSegurosAseguradora.CodAseguradora, Oficina.CodOficina, dbo.fduRellena('0', LTRIM(RTRIM(tCsFirmaReporteDetalle_1.Identificacion)), 13, 'D') 
                                                    AS NumPoliza, tCsFirmaReporteDetalle_1.Identificador AS CodUsuario, NULL AS Orden, 100 AS Porcentaje, 
                                                    tCsFirmaReporteDetalle_1.Sujeto AS NombreCompleto, 1 AS CodParentesco
                          FROM            tCsFirmaElectronica INNER JOIN
                                                    tCsFirmaReporte INNER JOIN
                                                    tCsFirmaReporteDetalle AS tCsFirmaReporteDetalle_1 ON tCsFirmaReporte.Firma = tCsFirmaReporteDetalle_1.Firma ON 
                                                    tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma CROSS JOIN
                                                    tCsSegurosProd INNER JOIN
                                                    tCsSegurosAseguradora ON tCsSegurosProd.codaseguradora = tCsSegurosAseguradora.CodAseguradora CROSS JOIN
                                                        (SELECT        MAX(tCsFirmaReporteDetalle.EstadoCivil) AS CodOficina
                                                          FROM            tCsFirmaReporteDetalle INNER JOIN
                                                                                    tCsFirmaElectronica AS tCsFirmaElectronica_1 ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica_1.Firma
                                                          WHERE        (tCsFirmaReporteDetalle.Grupo = 'G') AND (tCsFirmaElectronica_1.Dato = @CodPrestamo)) AS Oficina
                          WHERE        (tCsSegurosAseguradora.CodAseguradora = '02') AND (tCsFirmaReporteDetalle_1.Grupo = 'I') AND (tCsSegurosProd.codprodseguro = 1) AND 
                                                    (tCsFirmaElectronica.Firma = @Firma)) AS Datos LEFT OUTER JOIN
                         tCsSegurosBene ON Datos.CodAseguradora = tCsSegurosBene.codaseguradora AND Datos.CodOficina = tCsSegurosBene.codoficina AND 
                         Datos.NumPoliza = tCsSegurosBene.numpoliza AND Datos.CodUsuario = tCsSegurosBene.codusuario
WHERE        (tCsSegurosBene.codaseguradora IS NULL)    

GO
*/
GO