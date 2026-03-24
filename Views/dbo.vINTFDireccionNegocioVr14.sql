SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  View dbo.vINTFDireccionNegocioVr14    Script Date: 08/03/2023 09:06:02 pm ******/

CREATE VIEW [dbo].[vINTFDireccionNegocioVr14]
as
select distinct
vINTFNombreVr14.CodUsuario,
finamigoexterno_191115.dbo.fDirCompleta(tCsPadronClientes.DireccionDirNegPri,isnull(tCsPadronClientes.NumExtNeg,isnull(tCsPadronClientes.NumIntNeg,''))) as Direccion1,
ISNULL(RTRIM(LTRIM(UPPER(tClUbigeo.DescUbiGeo))), '') AS Colonia, 
ISNULL(RTRIM(LTRIM(UPPER(Municipios.Municipio))), '') AS Municipio, 
ISNULL(RTRIM(LTRIM(UPPER(tCPClCiudad.Ciudad))), '') AS Ciudad, 
(case Estados.EstadoINTF
when 'DF' then 'CDMX'
else Estados.EstadoINTF
end) AS Estado, 
--tCsPadronClientes.CodPostalNeg as CodigoPostal, 
isnull(tCPLugar.CodigoPostal,tCsPadronClientes.CodPostalNeg) as CodigoPostal, 
'' AS FechaResidencia, 
'' AS Telefono, 
'' AS Extencion, 
'' AS Fax, 
'B' AS Tipo, 

CASE WHEN tCPLugar.Zona = 'Rural' THEN 'R' 
     WHEN rtrim(ltrim(DireccionDirNegPri)) = 'DOMICILIO CONOCIDO' THEN 'K' 
     ELSE ' '
END AS Indicador, 
tCsPadronClientes.CodUbiGeoDirNegPri AS CodUbigeo
,'MX' OrigenDomicilio
from vINTFNombreVr14 with(nolock)
inner join [finamigoconsolidado].dbo.tCsPadronClientes as tCsPadronClientes with(nolock) on tCsPadronClientes.codusuario = vINTFNombreVr14.codusuario
inner join [finamigoconsolidado].dbo.tClUbigeo as tClUbigeo with(nolock) on tClUbigeo.codubigeo = tCsPadronClientes.CodUbiGeoDirNegPri
--INNER JOIN (SELECT codestado, descubigeo estado
--            FROM  [finamigoconsolidado].dbo.tClUbigeo WITH (nolock)
--            WHERE (CodUbiGeoTipo = 'ESTA')) as Estados ON Estados.codestado = tClUbigeo.CodEstado  

INNER JOIN (SELECT  edo.codestado, edo.descubigeo as estado,
			(select INTF from [finamigoconsolidado].dbo.tCPClEstado WITH (nolock) where CodEstado = edo.codestado) as EstadoINTF
            FROM  [finamigoconsolidado].dbo.tClUbigeo as edo WITH (nolock)
            WHERE edo.CodUbiGeoTipo = 'ESTA') as Estados ON Estados.codestado = tClUbigeo.CodEstado  

INNER JOIN (SELECT     CodMunicipio, CodEstado, descubigeo Municipio
            FROM [finamigoconsolidado].dbo.tClUbigeo WITH (nolock)
            WHERE      (CodUbiGeoTipo = 'MUNI')
            ) as Municipios ON tClUbigeo.CodMunicipio = Municipios.CodMunicipio 
                            AND tClUbigeo.CodEstado = Municipios.CodEstado
left join [finamigoconsolidado].dbo.tCPLugar as tCPLugar with(nolock) on tCPLugar.IdLugar = tClUbigeo.IdLugar 
                                                         AND tCPLugar.CodMunicipio = tClUbigeo.CodMunicipio 
                                                         AND tCPLugar.CodEstado = tClUbigeo.CodEstado 
left join [finamigoconsolidado].dbo.tCPClCiudad as tCPClCiudad with(nolock) on tCPClCiudad.CodCiudad = tCPLugar.CodCiudad 
                                                                              AND tCPClCiudad.CodMunicipio = tCPLugar.CodMunicipio 
                                                                              AND tCPClCiudad.CodEstado = tCPLugar.CodEstado
where (tCsPadronClientes.DireccionDirNegPri IS NOT NULL)


GO