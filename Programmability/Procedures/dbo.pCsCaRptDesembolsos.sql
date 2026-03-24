SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaRptDesembolsos] @FecIni smalldatetime, @FecFin smalldatetime AS
SELECT     Fecha, Oficina, Asesor, NombreTec, SUM(MontoDesembolso) AS Monto, COUNT(DISTINCT CodPrestamo) AS NroPtmos, CodOficina
FROM         (SELECT     tCsPadronCarteraDet.Desembolso Fecha, replicate('0', 2 - datalength(tClOficinas.CodOficina)) 
                                              + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina Oficina, tCsCarteraDet.MontoDesembolso, 
                                              tCsPadronClientes.NombreCompleto AS Asesor, tCaClTecnologia.NombreTec, tCsCarteraDet.CodPrestamo, tClOficinas.CodOficina
                       FROM          tCaClTecnologia INNER JOIN
                                              tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia RIGHT OUTER JOIN
                                              tCsCarteraDet INNER JOIN
                                              tCsPadronCarteraDet ON tCsCarteraDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
                                              tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario AND tCsCarteraDet.Fecha = tCsPadronCarteraDet.FechaCorte INNER JOIN
                                              tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN
                                              tCsPadronClientes ON tCsCartera.CodAsesor = tCsPadronClientes.CodUsuario ON 
                                              tCaProducto.CodProducto = tCsCartera.CodProducto LEFT OUTER JOIN
                                              tClOficinas ON tCsCarteraDet.CodOficina = tClOficinas.CodOficina
                       WHERE      (tCsPadronCarteraDet.Desembolso >= @FecIni) AND (tCsPadronCarteraDet.Desembolso <= @FecFin)) a
GROUP BY Fecha, Oficina, Asesor, NombreTec, CodOficina
GO