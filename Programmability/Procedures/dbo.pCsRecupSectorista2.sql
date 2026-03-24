SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[pCsRecupSectorista2] @FechaIni smalldatetime,@FechaFin smalldatetime AS

SELECT     tCsTransaccionDiaria.Fecha, tCsTransaccionDiaria.MontoCapitalTran, tCsTransaccionDiaria.MontoInteresTran, tCsTransaccionDiaria.MontoINVETran, 
                      tCsTransaccionDiaria.MontoINPETran, tCsTransaccionDiaria.MontoOtrosTran, tCsTransaccionDiaria.MontoTotalTran, a.CodPrestamo, a.asesor, a.NomOficina, a.Zona, 
                      a.Nombre, a.cartera, a.nrodiasatraso, tCsTransaccionDiaria.DescripcionTran, diasanteriores.AtrasoAntPago, a.codgrupo, a.NombreGrupo
FROM         (SELECT DISTINCT 
                                              tCsPadronCarteraDet.CodPrestamo, asesores.asesor, tClOficinas.NomOficina, tClOficinas.Zona, tClZona.Nombre, tCsCartera.cartera, 
                                              tCsCartera.nrodiasatraso, tCsCartera.codgrupo, tCsCarteraGrupos.NombreGrupo
                       FROM          tCsCartera INNER JOIN
                                              tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                                              tCsPadronCarteraDet ON tCsCarteraDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
                                              tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario AND tCsCarteraDet.Fecha = tCsPadronCarteraDet.FechaCorte INNER JOIN
                                              tClOficinas ON tCsPadronCarteraDet.CodOficina = tClOficinas.CodOficina INNER JOIN
                                              tClZona ON tClOficinas.Zona = tClZona.Zona LEFT OUTER JOIN
                                                  (SELECT     codusuario, nombrecompleto asesor
                                                    FROM          tcspadronclientes) asesores ON tCsCartera.Sectorista2 = asesores.codusuario LEFT OUTER JOIN
                                              tCsCarteraGrupos ON tCsCarteraGrupos.CodOficina = tCsCartera.CodOficina AND tCsCarteraGrupos.CodGrupo = tCsCartera.CodGrupo
                       WHERE      (NOT (tCsCartera.Sectorista2 IS NULL))
		and tcscartera.codprestamo in (SELECT CodPrestamo FROM tCsCartera WHERE (Fecha = '20101031') AND (NroDiasAtraso >= 30))
		) a INNER JOIN
                      tCsTransaccionDiaria ON a.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsTransaccionDiaria.CodigoCuenta INNER JOIN
                          (SELECT     Fecha, CodPrestamo, NroDiasAtraso AtrasoAntPago
                            FROM          tCsCartera) diasanteriores ON DATEADD([day], - 1, tCsTransaccionDiaria.Fecha) = diasanteriores.Fecha AND 
                      tCsTransaccionDiaria.CodigoCuenta = diasanteriores.CodPrestamo COLLATE Modern_Spanish_CI_AI
WHERE     (tCsTransaccionDiaria.Fecha >= @FechaIni) AND (tCsTransaccionDiaria.Fecha <= @FechaFin) AND (tCsTransaccionDiaria.TipoTransacNivel1 = 'I') AND 
                      (tCsTransaccionDiaria.Extornado = 0)
GO