SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaRptCarteraGeografico] @Fecha smalldatetime AS
SELECT     tCsBsCartera.*, tCsPadronClientes.NombreCompleto AS Asesor, tClOficinas.NomOficina, tCPClEstado.Estado, 'Mexico' AS Pais, 
                      tClUbigeo.NomUbiGeo
FROM         tClUbigeo LEFT OUTER JOIN
                      tCPClEstado ON tClUbigeo.CodEstado = tCPClEstado.CodEstado RIGHT OUTER JOIN
                      tClOficinas ON tClUbigeo.CodUbiGeo = tClOficinas.CodUbiGeo RIGHT OUTER JOIN
                      tCsBsCartera LEFT OUTER JOIN
                      tCsPadronClientes ON tCsBsCartera.CodAsesor = tCsPadronClientes.CodUsuario ON tClOficinas.CodOficina = tCsBsCartera.CodOficina
WHERE     (tCsBsCartera.Fecha = @Fecha)
GO