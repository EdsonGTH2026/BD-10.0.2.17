SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vINTFCierreVr14CP]
AS
SELECT     Datos.Periodo, COUNT(*) AS Contador, RTRIM(LTRIM(STR(SUM(Datos.SaldoActual), 18, 0))) AS SaldoActual, 
                      RTRIM(LTRIM(STR(SUM(Datos.SaldoVencido), 18, 0))) AS SaldoVencido, dbo.vINTFCabeceraCP.Abreviatura, dbo.vINTFCabeceraCP.Direccion, 1 AS Cabecera, 
                      0 AS Empleo, 0 AS Bloques
FROM         (SELECT     NomVr14.Periodo, tCueVr14.CodPrestamo, tCueVr14.CodUsuario, CAST(SUBSTRING(tCueVr14.SaldoActual, 5, 100) AS Decimal(18, 0)) 
                                              AS SaldoActual, (CASE WHEN len(tCueVr14.SaldoVencido) = 4 THEN 0 ELSE CAST(SUBSTRING(tCueVr14.SaldoVencido, 5, 100) 
                                              AS decimal(18, 0)) END) AS SaldoVencido
                       FROM          tINTFNombreCP AS NomVr14 WITH (nolock) INNER JOIN
                                              tINTFDireccionCP AS tDirV14 WITH (nolock) ON NomVr14.CodUsuario = tDirV14.CodUsuario AND 
                                              NomVr14.Periodo = tDirV14.Periodo INNER JOIN
                                              tINTFCuentaCP AS tCueVr14 WITH (nolock) ON NomVr14.CodUsuario = tCueVr14.CodUsuario AND NomVr14.Periodo = tCueVr14.Periodo AND 
                                              NomVr14.Codprestamo = tCueVr14.Codprestamo INNER JOIN
                                              tINTFEmpleoCP AS emp ON emp.codusuario = NomVr14.Codusuario AND emp.periodo = NomVr14.periodo
                       WHERE      tDirV14.Estado <> '0400' AND NomVr14.periodo = '20240226' AND tCueVr14.Responsabilidad = '0501I' AND RIGHT(tCueVr14.Codprestamo, 19) 
                                              NOT IN
                                                  (SELECT     CodPrestamo
                                                    FROM          finamigoconsolidado..tCsBuroDepuLey WITH (nolock)) AND RIGHT(tCueVr14.Codprestamo, 19) NOT LIKE '%098-171-06-%') 
                      Datos INNER JOIN
                      dbo.vINTFCabeceraCP WITH (nolock) ON Datos.Periodo = dbo.vINTFCabeceraCP.Periodo
GROUP BY Datos.Periodo, dbo.vINTFCabeceraCP.Abreviatura, dbo.vINTFCabeceraCP.Direccion


GO