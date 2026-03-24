SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCsArreglarCodigos7]
AS
SELECT DISTINCT Datos.CC, Datos.CodUsuario
FROM         (SELECT     CC
                       FROM          (SELECT     tCsPadronCarteraDet.CodPrestamo, Datos.CC, tCsPadronCarteraDet.CodUsuario, CHARINDEX(LEFT(RIGHT(RTRIM(Datos.CC), 5), 5), 
                                                                      tCsPadronCarteraDet.CodUsuario, 1) AS Valida
                                               FROM          (SELECT DISTINCT 
                                                                                              tCsCarteraDet.CodUsuario AS CC, tCsCarteraDet.CodPrestamo AS PC, tCsPadronCarteraDet.CodUsuario AS CP, 
                                                                                              tCsPadronCarteraDet.CodPrestamo AS PP
                                                                       FROM          tCsPadronCarteraDet FULL OUTER JOIN
                                                                                              tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
                                                                                              tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario
                                                                       WHERE      (tCsPadronCarteraDet.CodUsuario IS NULL) OR
                                                                                              (tCsCarteraDet.CodUsuario IS NULL)) Datos INNER JOIN
                                                                      tCsPadronCarteraDet ON Datos.PC COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo) Datos
                       WHERE      (Valida <> 0)
                       GROUP BY CC
                       HAVING      (COUNT(*) = 1)) corte INNER JOIN
                          (SELECT     tCsPadronCarteraDet.CodPrestamo, Datos.CC, tCsPadronCarteraDet.CodUsuario, CHARINDEX(LEFT(RIGHT(RTRIM(Datos.CC), 5), 5), 
                                                   tCsPadronCarteraDet.CodUsuario, 1) AS Valida
                            FROM          (SELECT DISTINCT 
                                                                           tCsCarteraDet.CodUsuario AS CC, tCsCarteraDet.CodPrestamo AS PC, tCsPadronCarteraDet.CodUsuario AS CP, 
                                                                           tCsPadronCarteraDet.CodPrestamo AS PP
                                                    FROM          tCsPadronCarteraDet FULL OUTER JOIN
                                                                           tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
                                                                           tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario
                                                    WHERE      (tCsPadronCarteraDet.CodUsuario IS NULL) OR
                                                                           (tCsCarteraDet.CodUsuario IS NULL)) Datos INNER JOIN
                                                   tCsPadronCarteraDet ON Datos.PC COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo) Datos ON 
                      corte.CC = Datos.CC
WHERE     (Datos.Valida <> 0)

GO