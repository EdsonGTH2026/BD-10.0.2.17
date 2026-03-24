SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vINTFNombreCartera]
AS
SELECT    	'Cartera' AS Tipo, dbo.tCsCarteraDet.Fecha, dbo.tCsCarteraDet.CodPrestamo, dbo.tCsCarteraDet.CodUsuario, 
                      	Case when ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'') = '' Then  ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)),'') Else  ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'')  End AS Paterno, 
	      	Case when ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'') = '' Then  'NO PROPORCIONADO' Else ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)),'')  End As Materno,  
		Case tCsPadronClientes.Sexo When 0 Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') When 1 Then '' End
                      	AS Adicional, ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre2)), '') 
                      + ' ' + ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre3)), '') AS Nombre2,
                      dbo.fduFechaATexto(dbo.tCsPadronClientes.FechaNacimiento, 'DDMMAAAA') AS Nacimiento, RFC.UsRFC, '' AS Prefijo, '' AS Sufijo, 
                      dbo.tClPaises.INTF AS Nacionalidad, dbo.tUsClTipoPropiedad.INTF AS Residencia, CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir, 
                      dbo.tUsClEstadoCivil.INTF AS EstadoCivil, dbo.tUsClSexo.INTF AS Sexo, '' AS CedulaProfesional, CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE, 
                      '' AS ImpuestoOtroPais, '' AS ClaveOtroPais, dbo.tCsPadronClientes.UsNDependientes AS NumeroDependientes, '' AS EdadesDependientes, 
                      '' AS DefuncionFecha, '' AS DefuncionIndicador
FROM        (SELECT     CodUsuario, CASE c WHEN 10 THEN usrfc ELSE usrfcbd END AS UsRFC
                       FROM          (SELECT     CodUsuario, CASE WHEN (isnumeric(SUBSTRING(UsRFC, 1, 1))) 
                                                                      = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 2, 1))) 
                                                                      = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 3, 1))) 
                                                                      = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 4, 1))) 
                                                                      = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 5, 1))) 
                                                                      = 1 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 6, 1))) 
                                                                      = 1 THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 7, 2) >= '01' AND SUBSTRING(UsRFC, 7, 2) 
                                                                      <= '12' THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 9, 2) >= '01' AND SUBSTRING(UsRFC, 9, 2) 
                                                                      <= '31' THEN 1 ELSE 0 END + CASE WHEN len(rtrim(ltrim(usrfc))) = 13 THEN 1 ELSE 0 END + CASE WHEN (SUBSTRING(UsRFC, 
                                                                      5, 6) = dbo.fduFechaATexto(FechaNacimiento, 'AAMMDD')) THEN 1 ELSE 0 END AS C, UsRFC, UsRFCBD, UsRFCVal
                                               FROM          tCsPadronClientes with(nolock)) Datos) RFC INNER JOIN
                      dbo.tCsPadronClientes with(nolock) ON RFC.CodUsuario COLLATE Modern_Spanish_CI_AI = dbo.tCsPadronClientes.CodUsuario LEFT OUTER JOIN
                      dbo.tUsClTipoPropiedad ON ISNULL(dbo.tCsPadronClientes.TipoPropiedadDirFam, dbo.tCsPadronClientes.TipoPropiedadDirNeg) 
                      = dbo.tUsClTipoPropiedad.CodTipoPro LEFT OUTER JOIN
                      dbo.tUsClSexo ON dbo.tCsPadronClientes.Sexo = dbo.tUsClSexo.Sexo LEFT OUTER JOIN
                      dbo.tUsClEstadoCivil ON dbo.tCsPadronClientes.CodEstadoCivil = dbo.tUsClEstadoCivil.CodEstadoCivil LEFT OUTER JOIN
                      dbo.tClPaises ON dbo.tCsPadronClientes.CodPais = dbo.tClPaises.CodPais RIGHT OUTER JOIN
                      dbo.tINTFPeriodo INNER JOIN
                      dbo.tCsCarteraDet with(nolock) ON dbo.tINTFPeriodo.Corte = dbo.tCsCarteraDet.Fecha ON 
                      dbo.tCsPadronClientes.CodUsuario = dbo.tCsCarteraDet.CodUsuario
WHERE     (dbo.tINTFPeriodo.Activo = 1)






GO