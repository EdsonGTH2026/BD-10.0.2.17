SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[pCsResponsablesActuales]
As
Select * from (
SELECT     NomOficina, CodOficina, Responsable
FROM         (SELECT DISTINCT tClOficinas.NomOficina, dbo.fduRellena('0', Datos_2.CodOficina, 3, 'D') AS CodOficina, Datos_2.Responsable
                       FROM          (SELECT     Datos_1.Firma, Datos_1.EstadoCivil AS CodOficina, Datos_1.Direccion AS Responsable
                                               FROM          (SELECT     Firma, EstadoCivil, Direccion
                                                                       FROM          tCsFirmaReporteDetalle
                                                                       WHERE      (Grupo = 'G') AND (EstadoCivil IS NOT NULL)) AS Datos_1 INNER JOIN
                                                                      tCsFirmaElectronica ON Datos_1.Firma = tCsFirmaElectronica.Firma
                                               WHERE      (tCsFirmaElectronica.Registro >= DATEADD(DAy, - 30, GETDATE()))) AS Datos_2 INNER JOIN
                                              tClOficinas ON Datos_2.CodOficina = tClOficinas.CodOficina) AS DAtos
Union
SELECT     tClZona.Nombre, tClZona.Zona, tCsPadronClientes.NombreCompleto
FROM         tClZona INNER JOIN
                      tCsPadronClientes ON tClZona.Responsable = tCsPadronClientes.CodUsuario) Datos
Order by CodOficina
GO