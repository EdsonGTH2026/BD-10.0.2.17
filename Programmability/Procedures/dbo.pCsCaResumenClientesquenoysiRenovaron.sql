SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaResumenClientesquenoysiRenovaron]   @Periodo 	Varchar(6), @Analisis	Varchar(6) As

--Declare @Periodo 	Varchar(6)
--Declare @Analisis	Varchar(6)

--CLIENTES QUE NO RENOVARON
--Analisis	= Es la fecha desde donde deseas analizar los créditos. 
--Periodo 	= Es el periodo en donde observaras si el cliente tiene o no tiene credito activo y con el cual determinaras si renovo o no.

--Set @Periodo 	= @Periodo
--Set @Analisis	= @Analisis

Declare @Anterior 	SmallDateTime
Declare @FinMes 	SmallDateTime
Declare @Corte               SmallDateTime

Select @Corte = FechaConsolidacion from vcsfechaconsolidacion
Set @FinMes 	= DateAdd(Day, -1, Cast(dbo.fdufechaatexto(DateAdd(Month, 1, (Cast(@Periodo + '01' as SmallDateTime))), 'AAAAMM') +  '01' as SmallDateTime))
Set @Anterior 	= Cast(@Analisis + '01' As SmallDateTime)
If @finmes <= @Corte
Begin
	set @Corte=@FinMes
End

SELECT     tCaProducto.Tecnologia, tCaClTecnologia.Veridico, tCsCarteraDet.CodOficina, tClOficinas.NomOficina, Renovado.Codigo, Renovado.Renovo, 
                      Ultimo.CodPrestamo AS UltimoPagare, tCsCarteraGrupos.NombreGrupo AS Grupo, tCsPadronClientes.NombreCompleto AS Cliente, tCsCarteraDet.MontoDesembolso, 
                      Ultimo.Cancelacion, tCsPadronClientes.Sexo, tCsPadronClientes.CodEstadoCivil,DireccionDirFamPri = isnull( tCsPadronClientes.DireccionDirFamPri, tCsPadronClientes.DireccionDirNEGPri), 
                      tCsPadronClientes.TelefonoDirFamPri, tCsCartera.CodAsesor, 
                      tCsPadronClientes_1.NombreCompleto AS Asesor, tCPClEstado.Estado, tCPClMunicipio.Municipio, tCPLugar.Lugar, tCsCartera.NroDiasAtraso, 
                      tCsCartera.NroDiasAcumulado
FROM         (SELECT     Cancelacion.Codigo, CASE WHEN activo.codigo IS NOT NULL THEN 1 ELSE 0 END AS Renovo
                       FROM          (SELECT DISTINCT ISNULL(CodGrupo, CodUsuario) AS Codigo
                                               FROM          tCsPadronCarteraDet
                                               WHERE      (Cancelacion >= @Anterior and Cancelacion <= @FinMes)  AND CarteraActual = 'ACTIVA') Cancelacion LEFT OUTER JOIN
                                                  (SELECT DISTINCT ISNULL(CodGrupo, CodUsuario) AS Codigo
                                                    FROM          tCsCartera
                                                    WHERE      (Fecha = @Corte) AND (Cartera = 'ACTIVA')) Activo ON Cancelacion.Codigo = Activo.Codigo) Renovado LEFT OUTER JOIN
                      tClUbigeo INNER JOIN
                      tCPClMunicipio INNER JOIN
                      tCPClEstado ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN
                      tCPLugar ON tCPClMunicipio.CodMunicipio = tCPLugar.CodMunicipio AND tCPClMunicipio.CodEstado = tCPLugar.CodEstado ON 
                      tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND tClUbigeo.CodEstado = tCPLugar.CodEstado RIGHT OUTER JOIN
                      tCsPadronClientes INNER JOIN
                          (SELECT DISTINCT 
                                                   ISNULL(tCsPadronCarteraDet.CodGrupo, tCsPadronCarteraDet.CodUsuario) AS Codigo, CodOficina, tCsPadronCarteraDet.CodUsuario, 
                                                   tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.FechaCorte, codProducto, Cancelacion
                            FROM          (SELECT DISTINCT CodPrestamo AS CodPrestamo
                                                    FROM          tCsPadronCarteraDet
                                                    WHERE      (Cancelacion >= @Anterior  AND Cancelacion <=  @FinMes ) AND CarteraActual = 'ACTIVA') Datos INNER JOIN
                                                   tCsPadronCarteraDet ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo) Ultimo ON 
                      tCsPadronClientes.CodUsuario = Ultimo.CodUsuario COLLATE Modern_Spanish_CI_AI INNER JOIN
                      tCsCarteraDet ON Ultimo.FechaCorte = tCsCarteraDet.Fecha AND Ultimo.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodUsuario AND 
                      Ultimo.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodPrestamo INNER JOIN
                      tClOficinas ON tCsCarteraDet.CodOficina = tClOficinas.CodOficina ON tClUbigeo.CodUbiGeo = ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, 
                      tCsPadronClientes.CodUbiGeoDirNegPri) LEFT OUTER JOIN
                      tCsCartera ON tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsCarteraDet.Fecha = tCsCartera.Fecha LEFT OUTER JOIN
                      tCsPadronClientes tCsPadronClientes_1 ON tCsCartera.CodAsesor = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN
                      tCaClTecnologia RIGHT OUTER JOIN
                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia ON 
                      Ultimo.codProducto COLLATE Modern_Spanish_CI_AI = tCaProducto.CodProducto LEFT OUTER JOIN
                      tCsCarteraGrupos ON Ultimo.CodOficina COLLATE Modern_Spanish_CI_AI = tCsCarteraGrupos.CodOficina AND 
                      Ultimo.Codigo COLLATE Modern_Spanish_CI_AI = tCsCarteraGrupos.CodGrupo ON Renovado.Codigo = Ultimo.Codigo
--Where Renovo= 0  and   tCsCarteraDet.CodOficina = @CodOficina
--Where  tCsCarteraDet.CodOficina = @CodOficina
ORDER BY tCaProducto.Tecnologia, CAST(tCsCarteraDet.CodOficina AS Int)
GO