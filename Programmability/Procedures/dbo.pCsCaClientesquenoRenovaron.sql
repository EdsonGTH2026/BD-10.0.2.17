SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
--Exec pCsCaClientesquenoRenovaron '2', '201106', '201101'
CREATE PROCEDURE [dbo].[pCsCaClientesquenoRenovaron]  @CodOficina Varchar(4) , @Analisis	Varchar(6), @Periodo 	Varchar(6) As

--Declare @Periodo 	Varchar(6)
--Declare @Analisis	Varchar(6)

--CLIENTES QUE NO RENOVARON
--Analisis	= Es la fecha desde donde deseas analizar los créditos. 
--Periodo 	= Es el periodo en donde observaras si el cliente tiene o no tiene credito activo y con el cual determinaras si renovo o no.

--Set @Periodo 	= @Periodo
--Set @Analisis	= @Analisis

Declare @Anterior 	SmallDateTime
Declare @FinMes 	SmallDateTime
Declare @Corte		SmallDateTime
Declare @AnalisisC	Decimal(10,0)
Declare @Cadena		Varchar(8000)

Select @Corte	=	FechaConsolidacion from vcsfechaconsolidacion
Set @FinMes 	=	DateAdd(Day, -1, Cast(dbo.fdufechaatexto(DateAdd(Month, 1, (Cast(@Periodo + '01' as SmallDateTime))), 'AAAAMM') +  '01' as SmallDateTime))
Set @Anterior 	=	Cast(@Analisis + '01' As SmallDateTime)

If @FinMes		<=	@Corte
Begin
	Set @Corte=@FinMes
End

If @FinMes		>=	@Corte
Begin
	Set @FinMes=@Corte
End

Select @AnalisisC = Count(*) From (
SELECT DISTINCT CodUsuario
FROM          tCsPadronCarteraDet AS tCsPadronCarteraDet_2
WHERE      (Cancelacion >= @Anterior) AND (Cancelacion <= @FinMes) AND (CarteraActual = 'ACTIVA')
And CodOficina = @CodOficina 
	) Datos

SELECT  AnalisisI = @Anterior, AnalisisF = @FinMes, AnalisisC = @AnalisisC, 
		Corte = @Corte, 
		tCaProducto.Tecnologia, tCaClTecnologia.Veridico, tCsCarteraDet.CodOficina, tClOficinas.NomOficina, Renovado.Codigo, Renovado.Renovo, 
                      Ultimo.CodPrestamo AS UltimoPagare, tCsCarteraGrupos.NombreGrupo AS Grupo, Left(ltrim(rtrim(tCsPadronClientes.NombreCompleto)), 30) AS Cliente, tCsCarteraDet.MontoDesembolso, 
                      Ultimo.Desembolso as Apertura, Ultimo.Cancelacion, tCsPadronClientes.Sexo, tCsPadronClientes.CodEstadoCivil, ISNULL(tCsPadronClientes.DireccionDirFamPri, 
                      tCsPadronClientes.DireccionDirNegPri) + ', ' + vGnlUbigeo.Direccion AS Direccion, tCsCartera_1.CodAsesor, tCsPadronClientes_1.NombreCompleto AS Asesor, 
                      tCsCartera_1.NroDiasAtraso, tCsCartera_1.NroDiasAcumulado, Replace(LTRIM(RTRIM(ISNULL(tCsPadronClientes.TelefonoDirFamPri, ''))), ' ', '') 
                      + '  ' + replace(LTRIM(RTRIM(ISNULL(tCsPadronClientes.TelefonoDirNegPri, ''))), ' ', '') + '  ' + Replace(LTRIM(RTRIM(ISNULL(tCsPadronClientes.TelefonoMovil, ''))), ' ', '') AS Telefono
FROM         vGnlUbigeo RIGHT OUTER JOIN
                      tCsPadronClientes INNER JOIN
                          (SELECT DISTINCT 
                                                   ISNULL(tCsPadronCarteraDet_1.CodGrupo, tCsPadronCarteraDet_1.CodUsuario) AS Codigo, tCsPadronCarteraDet_1.CodOficina, 
                                                   tCsPadronCarteraDet_1.CodUsuario, tCsPadronCarteraDet_1.CodPrestamo, tCsPadronCarteraDet_1.FechaCorte, tCsPadronCarteraDet_1.CodProducto, 
                                                   tCsPadronCarteraDet_1.Cancelacion,  tCsPadronCarteraDet_1.Desembolso
                            FROM          (SELECT DISTINCT CodPrestamo
                                                    FROM          tCsPadronCarteraDet AS tCsPadronCarteraDet_2
                                                    WHERE      (Cancelacion >= @Anterior) AND (Cancelacion <= @FinMes) AND (CarteraActual = 'ACTIVA')) AS Datos INNER JOIN
                                                   tCsPadronCarteraDet AS tCsPadronCarteraDet_1 ON Datos.CodPrestamo = tCsPadronCarteraDet_1.CodPrestamo) AS Ultimo ON 
                      tCsPadronClientes.CodUsuario = Ultimo.CodUsuario INNER JOIN
                      tCsCarteraDet ON Ultimo.FechaCorte = tCsCarteraDet.Fecha AND Ultimo.CodUsuario = tCsCarteraDet.CodUsuario AND 
                      Ultimo.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                      tClOficinas ON tCsCarteraDet.CodOficina = tClOficinas.CodOficina ON vGnlUbigeo.CodUbiGeo = ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, 
                      tCsPadronClientes.CodUbiGeoDirNegPri) LEFT OUTER JOIN
                      tCsCartera AS tCsCartera_1 ON tCsCarteraDet.CodPrestamo = tCsCartera_1.CodPrestamo AND tCsCarteraDet.Fecha = tCsCartera_1.Fecha LEFT OUTER JOIN
                      tCsPadronClientes AS tCsPadronClientes_1 ON tCsCartera_1.CodAsesor = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN
                      tCaClTecnologia RIGHT OUTER JOIN
                      tCaProducto ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia ON Ultimo.CodProducto = tCaProducto.CodProducto LEFT OUTER JOIN
                      tCsCarteraGrupos ON Ultimo.CodOficina = tCsCarteraGrupos.CodOficina AND 
                      Ultimo.Codigo COLLATE Modern_Spanish_CI_AI = tCsCarteraGrupos.CodGrupo RIGHT OUTER JOIN
                          (SELECT     Cancelacion.Codigo, CASE WHEN activo.codigo IS NOT NULL THEN 1 ELSE 0 END AS Renovo
                            FROM          (SELECT DISTINCT ISNULL(CodGrupo, CodUsuario) AS Codigo
                                                    FROM          tCsPadronCarteraDet
                                                    WHERE      (Cancelacion >= @Anterior) AND (Cancelacion <= @FinMes) AND (CarteraActual = 'ACTIVA')) AS Cancelacion LEFT OUTER JOIN
                                                       (SELECT DISTINCT ISNULL(CodGrupo, CodUsuario) AS Codigo
                                                         FROM          tCsCartera
                                                         WHERE      (Fecha = @Corte) AND (Cartera = 'ACTIVA')) AS Activo ON Cancelacion.Codigo = Activo.Codigo) AS Renovado ON 
                      Ultimo.Codigo = Renovado.Codigo
WHERE     (tCsCarteraDet.CodOficina = @CodOficina)
ORDER BY tCaProducto.Tecnologia, CAST(tCsCarteraDet.CodOficina AS Int)
GO