SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsUsuariosDireccion]
@CodUsuario 		Varchar(50)
AS
--declare @CodUsuario 		Varchar(50)
--set @CodUsuario='CSM1803892'

Select O, CodUsuario, Cliente, Direccion from (
SELECT     1 AS O, tClOficinas.CodUsuario, tClOficinas.Cliente, tClOficinas.Direccion
FROM         tCPLugar with(nolock) INNER JOIN
                      tClUbigeo with(nolock) ON tCPLugar.IdLugar = tClUbigeo.IdLugar AND tCPLugar.CodMunicipio = tClUbigeo.CodMunicipio AND 
                      tCPLugar.CodEstado = tClUbigeo.CodEstado INNER JOIN
                      tCPClMunicipio with(nolock) ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN
                      tCPClEstado with(nolock) ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado RIGHT OUTER JOIN
                          (SELECT     CodUsuario, NombreCompleto AS Cliente, ISNULL(CodUbiGeoDirFamPri, CodUbiGeoDirNegPri) AS CodUbigeo, 
                                                   ISNULL(DireccionDirFamPri + ISNULL(' NÚMERO ' + CASE Ltrim(Rtrim(NumExtFam)) WHEN '' THEN NULL ELSE Ltrim(Rtrim(NumExtFam)) END, ''), 
                                                   DireccionDirNegPri + ISNULL(' NÚMERO ' + CASE Ltrim(Rtrim(NumExtNeg)) WHEN '' THEN NULL ELSE Ltrim(Rtrim(NumExtNeg)) END, '')) AS Direccion
                            FROM          tCsPadronClientes with(nolock)) AS tClOficinas ON tClUbigeo.CodUbiGeo = tClOficinas.CodUbigeo
UNION 
SELECT   O = 2, tClOficinas.CodUsuario, tClOficinas.Cliente, tCPClTipoLugar.TipoLugar + ' ' + tCPLugar.Lugar AS Direccion
FROM      (SELECT     CodUsuario, NombreCompleto AS Cliente, ISNULL(CodUbiGeoDirFamPri, CodUbiGeoDirNegPri) AS CodUbigeo, ISNULL(DireccionDirFamPri, 
                                              DireccionDirNegPri) AS Direccion
                       FROM          tCsPadronClientes with(nolock))    tClOficinas INNER JOIN
                      tClUbigeo with(nolock) ON tClOficinas.CodUbiGeo = tClUbigeo.CodUbiGeo INNER JOIN
                      tCPLugar with(nolock) ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND 
                      tClUbigeo.CodEstado = tCPLugar.CodEstado INNER JOIN
                      tCPClMunicipio with(nolock) ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN
                      tCPClEstado with(nolock) ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN
                      tCPClTipoLugar with(nolock) ON tCPLugar.CodTipoLugar = tCPClTipoLugar.CodTipoLugar
UNION
SELECT  O = 3, tClOficinas.CodUsuario, tClOficinas.Cliente, Case When tCPClEstado.CodEstado = '09' Then 'Delegación ' Else 'Municipio '  end + tCPClMunicipio.Municipio + ', ' + Case When tCPClEstado.CodEstado = '09' Then '' Else 'Estado '  end + 
		tCPClEstado.Estado AS Direccion
FROM        (SELECT     CodUsuario, NombreCompleto AS Cliente, ISNULL(CodUbiGeoDirFamPri, CodUbiGeoDirNegPri) AS CodUbigeo, ISNULL(DireccionDirFamPri, 
                                              DireccionDirNegPri) AS Direccion
                       FROM          tCsPadronClientes with(nolock)) tClOficinas INNER JOIN
                      tClUbigeo with(nolock) ON tClOficinas.CodUbiGeo = tClUbigeo.CodUbiGeo INNER JOIN
                      tCPLugar with(nolock) ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND 
                      tClUbigeo.CodEstado = tCPLugar.CodEstado INNER JOIN
                      tCPClMunicipio with(nolock) ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN
                      tCPClEstado with(nolock) ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN
                      tCPClTipoLugar with(nolock) ON tCPLugar.CodTipoLugar = tCPClTipoLugar.CodTipoLugar
UNION
SELECT  O = 4, tClOficinas.CodUsuario, tClOficinas.Cliente, 'CP: ' + CodigoPostal AS Direccion
FROM       (SELECT     CodUsuario, NombreCompleto AS Cliente, ISNULL(CodUbiGeoDirFamPri, CodUbiGeoDirNegPri) AS CodUbigeo, ISNULL(DireccionDirFamPri, 
                                              DireccionDirNegPri) AS Direccion
                  FROM          tCsPadronClientes with(nolock)) tClOficinas INNER JOIN
                      tClUbigeo with(nolock) ON tClOficinas.CodUbiGeo = tClUbigeo.CodUbiGeo INNER JOIN
                      tCPLugar with(nolock) ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND 
                      tClUbigeo.CodEstado = tCPLugar.CodEstado INNER JOIN
                      tCPClMunicipio with(nolock) ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN
                      tCPClEstado with(nolock) ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN
                      tCPClTipoLugar with(nolock) ON tCPLugar.CodTipoLugar = tCPClTipoLugar.CodTipoLugar) Datos
Where CodUsuario = @CodUsuario
Order By  o


GO