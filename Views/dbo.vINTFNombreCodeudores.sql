SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vINTFNombreCodeudores]
AS
SELECT     'Codeudor' AS Tipo, dbo.tCsCarteraDet.Fecha, dbo.tCsCarteraDet.CodPrestamo, dbo.tCsCarteraDet.CodUsuario, 
                      CASE WHEN ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)), '') = '' THEN ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)), '') 
                      ELSE ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)), '') END AS Paterno, CASE WHEN ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)), '') 
                      = '' THEN 'NO PROPORCIONADO' ELSE ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)), '') END AS Materno, 
                      CASE tCsPadronClientes.Sexo WHEN 0 THEN ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') WHEN 1 THEN '' END AS Adicional, 
                      ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre2)), '') 
                      + ' ' + ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre3)), '') AS Nombre2, dbo.fduFechaATexto(dbo.tCsPadronClientes.FechaNacimiento, 'DDMMAAAA') 
                      AS Nacimiento, RFC.UsRFC, '' AS Prefijo, '' AS Sufijo, dbo.tClPaises.INTF AS Nacionalidad, dbo.tUsClTipoPropiedad.INTF AS Residencia, 
                      CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir, dbo.tUsClEstadoCivil.INTF AS EstadoCivil, dbo.tUsClSexo.INTF AS Sexo, '' AS CedulaProfesional, 
                      CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE, '' AS ImpuestoOtroPais, '' AS ClaveOtroPais, 
                      dbo.tCsPadronClientes.UsNDependientes AS NumeroDependientes, '' AS EdadesDependientes, '' AS DefuncionFecha, '' AS DefuncionIndicador
FROM         dbo.tClPaises RIGHT OUTER JOIN
                          (SELECT     CodUsuario, CASE c WHEN 10 THEN usrfc ELSE usrfcbd END AS UsRFC
                            FROM          (SELECT     CodUsuario, CASE WHEN (isnumeric(SUBSTRING(UsRFC, 1, 1))) = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 2, 
                                                                           1))) = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 3, 1))) 
                                                                           = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 4, 1))) 
                                                                           = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 5, 1))) 
                                                                           = 1 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 6, 1))) = 1 THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 7, 
                                                                           2) >= '01' AND SUBSTRING(UsRFC, 7, 2) <= '12' THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 9, 2) >= '01' AND 
                                                                           SUBSTRING(UsRFC, 9, 2) <= '31' THEN 1 ELSE 0 END + CASE WHEN len(rtrim(ltrim(usrfc))) 
                                                                           = 13 THEN 1 ELSE 0 END + CASE WHEN (SUBSTRING(UsRFC, 5, 6) = dbo.fduFechaATexto(FechaNacimiento, 'AAMMDD')) 
                                                                           THEN 1 ELSE 0 END AS C, UsRFC, UsRFCBD, UsRFCVal
                                                    FROM          tCsPadronClientes with(nolock)) Datos) RFC INNER JOIN
                      dbo.tCsPadronClientes with(nolock) ON RFC.CodUsuario COLLATE Modern_Spanish_CI_AI = dbo.tCsPadronClientes.CodUsuario INNER JOIN
                      dbo.tCsPrestamoCodeudor with(nolock) INNER JOIN
                      dbo.tINTFPeriodo INNER JOIN
                      dbo.tCsCarteraDet with(nolock) ON dbo.tINTFPeriodo.Corte = dbo.tCsCarteraDet.Fecha ON dbo.tCsPrestamoCodeudor.CodPrestamo = dbo.tCsCarteraDet.CodPrestamo ON 
                      dbo.tCsPadronClientes.CodUsuario = dbo.tCsPrestamoCodeudor.CodUsuario LEFT OUTER JOIN
                      dbo.tUsClTipoPropiedad ON ISNULL(dbo.tCsPadronClientes.TipoPropiedadDirFam, dbo.tCsPadronClientes.TipoPropiedadDirNeg) 
                      = dbo.tUsClTipoPropiedad.CodTipoPro LEFT OUTER JOIN
                      dbo.tUsClSexo ON dbo.tCsPadronClientes.Sexo = dbo.tUsClSexo.Sexo LEFT OUTER JOIN
                      dbo.tUsClEstadoCivil ON dbo.tCsPadronClientes.CodEstadoCivil = dbo.tUsClEstadoCivil.CodEstadoCivil ON 
                      dbo.tClPaises.CodPais = dbo.tCsPadronClientes.CodPais
WHERE     (dbo.tINTFPeriodo.Activo = 1)

GO