SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaRptVencimientosxOficina] @Periodo varchar(15) AS
DECLARE @Fecha smalldatetime
Select @Fecha=FechaConsolidacion from vCsFechaConsolidacion

SELECT     CAST(tClOficinas.CodOficina AS decimal(10, 2)) AS CodOFi, tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS Oficina, 
                      Asesor.NombreCompleto AS Asesor, tCaClTecnologia.NombreTec, tCsCartera.CodPrestamo, tCsCartera.FechaVencimiento, 
                      tCsPadronClientes.NombreCompleto AS Cliente, 
                      CASE tcaproducto.tecnologia WHEN 1 THEN tCsPadronClientes.NombreCompleto WHEN 3 THEN tCsPadronClientes.NombreCompleto ELSE tCsCarteraGrupos.NombreGrupo
                       END AS ClienteGrupo, tCsCartera.FechaDesembolso, tCsCarteraDet.MontoDesembolso, tCsPadronCarteraDet.SecuenciaCliente, 
                      tCsCarteraDet.SaldoCapital, DiasAcumulados.DiasAtrCuota AS DiasAtrasoAcumulados, tCsCartera.NroCuotas, tCsCartera.NroCuotasPorPagar, 
                      tCsPadronCarteraDet.SecuenciaGrupo, tCsPadronClientes.CodUsuario, tcsclbis.nombre BIS, 
                      tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido AS Interes, 
                      tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido AS Moratorio, tCsCartera.NroDiasAtraso, tCsCartera.Estado
FROM         tCsPadronCarteraDet INNER JOIN
                      tCsCartera INNER JOIN
                      tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                      tCsPadronClientes Asesor ON tCsCartera.CodAsesor = Asesor.CodUsuario ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
                      tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario INNER JOIN
                          (SELECT     Fecha, CodOficina, CodPrestamo, CodUsuario, SUM(DiasAtrCuota) AS DiasAtrCuota
                            FROM          (SELECT DISTINCT Fecha, CodOficina, CodPrestamo, CodUsuario, CAST(DiasAtrCuota AS decimal(10, 2)) AS DiasAtrCuota, SecCuota
                                                    FROM          tCsPlanCuotas WHERE Fecha = @Fecha ) a
                            GROUP BY Fecha, CodOficina, CodPrestamo, CodUsuario) DiasAcumulados ON tCsCarteraDet.Fecha = DiasAcumulados.Fecha AND 
                      tCsCarteraDet.CodOficina = DiasAcumulados.CodOficina AND 
                      tCsCarteraDet.CodPrestamo = DiasAcumulados.CodPrestamo COLLATE Modern_Spanish_CI_AI AND 
                      tCsCarteraDet.CodUsuario = DiasAcumulados.CodUsuario COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN
                      tCsCarteraGrupos ON tCsCartera.CodOficina = tCsCarteraGrupos.CodOficina AND tCsCartera.CodGrupo = tCsCarteraGrupos.CodGrupo LEFT OUTER JOIN
                      tCsPadronClientes ON tCsCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN
                      tCaClTecnologia INNER JOIN
                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia ON tCsCartera.CodProducto = tCaProducto.CodProducto LEFT OUTER JOIN
                      tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina LEFT OUTER join tcsclbis on tCsCartera.BIS=tcsclbis.bis
WHERE     (tCsCartera.Estado <> 'castigado') AND (tCsCartera.Fecha = @Fecha) AND (dbo.fduFechaAPeriodo(tCsCartera.FechaVencimiento) 
                      = @Periodo) AND (tCsCartera.CodOficina = '2')
GO