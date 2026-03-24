SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vINTFDireccionNegocio]
AS
SELECT     dbo.vINTFNombre.CodUsuario, RTRIM(LTRIM(REPLACE(dbo.tCsPadronClientes.DireccionDirNegPri, '  ', ' '))) AS Direccion1, 
                      RTRIM(LTRIM(UPPER(dbo.tCPLugar.Lugar))) AS Colonia, RTRIM(LTRIM(UPPER(dbo.tCPClMunicipio.Municipio))) AS Municipio, 
                      ISNULL(RTRIM(LTRIM(UPPER(dbo.tCPClCiudad.Ciudad))), '') AS Ciudad, dbo.tCPClEstado.INTF AS Estado, dbo.tCPLugar.CodigoPostal, 
                      '' AS FechaResidencia, '' AS Telefono, '' AS Extencion, '' AS Fax, 'B' AS Tipo, 
                      CASE WHEN tCPLugar.Zona = 'Rural' THEN 'R' WHEN rtrim(ltrim(DireccionDirNegPri)) = 'DOMICILIO CONOCIDO' THEN 'K' ELSE '' END AS Indicador, 
                      dbo.tCsPadronClientes.CodUbiGeoDirNegPri AS CodUbigeo
FROM         dbo.tCPClCiudad RIGHT OUTER JOIN
                      dbo.tCPLugar LEFT OUTER JOIN
                      dbo.tCPClEstado RIGHT OUTER JOIN
                      dbo.tCPClMunicipio ON dbo.tCPClEstado.CodEstado = dbo.tCPClMunicipio.CodEstado ON 
                      dbo.tCPLugar.CodMunicipio = dbo.tCPClMunicipio.CodMunicipio AND dbo.tCPLugar.CodEstado = dbo.tCPClMunicipio.CodEstado RIGHT OUTER JOIN
                      dbo.tClUbigeo ON dbo.tCPLugar.IdLugar = dbo.tClUbigeo.IdLugar AND dbo.tCPLugar.CodMunicipio = dbo.tClUbigeo.CodMunicipio AND 
                      dbo.tCPLugar.CodEstado = dbo.tClUbigeo.CodEstado ON dbo.tCPClCiudad.CodCiudad = dbo.tCPLugar.CodCiudad AND 
                      dbo.tCPClCiudad.CodMunicipio = dbo.tCPLugar.CodMunicipio AND dbo.tCPClCiudad.CodEstado = dbo.tCPLugar.CodEstado RIGHT OUTER JOIN
                      dbo.vINTFNombre INNER JOIN
                      dbo.tCsPadronClientes with(nolock) ON dbo.vINTFNombre.CodUsuario = dbo.tCsPadronClientes.CodUsuario ON 
                      dbo.tClUbigeo.CodUbiGeo = dbo.tCsPadronClientes.CodUbiGeoDirNegPri
WHERE     (dbo.tCsPadronClientes.DireccionDirNegPri IS NOT NULL) AND (dbo.tCsPadronClientes.CodUsuario NOT IN
                          (SELECT     Codusuario
                            FROM          dbo.tCsPadronClientes with(nolock)
                            WHERE      dbo.tCsPadronClientes.DireccionDirFamPri IS NOT NULL))



GO