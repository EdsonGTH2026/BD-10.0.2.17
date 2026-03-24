SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vGnlUbigeo]
AS
SELECT CodUbiGeo, Ruta, CP1_Estado, CP2_Municipio, CP3_Colonia, ZonaLugar, TipoLugar, Lugar, CodPostal, CASE LEFT(CP1_Estado, 6) 
 WHEN '000009' THEN 'Delegación' ELSE 'Municipio' END AS DelMun, 'Col. ' + Lugar + ', ' + SUBSTRING(CASE LEFT(CP1_Estado, 6) 
 WHEN '000009' THEN 'Delegación' ELSE 'Municipio' END, 1, 3) + '. ' + dbo.fduCambiarFormato(SUBSTRING(CP2_Municipio, 8, 100)) 
 + ', Edo. ' + dbo.fduCambiarFormato(SUBSTRING(CP1_Estado, 8, 100)) AS Direccion, MunicipioSITI, EstadoSITI
FROM (SELECT        tClUbigeo.DescUbiGeo + '/' + TUbigeo_1.DescUbiGeo + '/' + TUbigeo_2.DescUbiGeo AS Ruta, tClUbigeo.CodUbiGeo, 
TUbigeo_2.CodUbiGeo + '-' + TUbigeo_2.DescUbiGeo AS CP1_Estado, TUbigeo_1.CodUbiGeo + '-' + TUbigeo_1.DescUbiGeo AS CP2_Municipio, 
tClUbigeo.CodUbiGeo + '-' + tClUbigeo.DescUbiGeo AS CP3_Colonia, SUBSTRING(tClUbigeo.Campo3, 1, CHARINDEX(':', tClUbigeo.Campo3, 1) - 2) 
AS ZonaLugar, dbo.fduCambiarFormato(LTRIM(RTRIM(SUBSTRING(tClUbigeo.Campo3, CHARINDEX(':', tClUbigeo.Campo3, 1) + 2, 100)))) AS TipoLugar, 
dbo.fduCambiarFormato(tClUbigeo.DescUbiGeo) AS Lugar, tCPLugar.CodigoPostal AS CodPostal, tCPClEstado.SITI AS EstadoSITI, 
tCPClMunicipio.SITI AS MunicipioSITI
FROM tClUbigeo with(nolock) INNER JOIN
tClUbigeo AS TUbigeo_1 with(nolock) ON LEFT(tClUbigeo.CodArbolConta, LEN(tClUbigeo.CodArbolConta) - 6) = TUbigeo_1.CodArbolConta INNER JOIN
tClUbigeo AS TUbigeo_2 with(nolock) ON LEFT(TUbigeo_1.CodArbolConta, LEN(TUbigeo_1.CodArbolConta) - 6) = TUbigeo_2.CodArbolConta INNER JOIN
tCPLugar with(nolock) ON tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND tClUbigeo.CodEstado = tCPLugar.CodEstado AND 
tClUbigeo.IdLugar = tCPLugar.IdLugar INNER JOIN
tCPClMunicipio with(nolock) ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN
tCPClEstado with(nolock) ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado) AS Ubigeo
GO