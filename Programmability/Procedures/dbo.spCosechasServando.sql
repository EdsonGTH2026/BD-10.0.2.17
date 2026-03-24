SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROCEDURE  [dbo].[spCosechasServando]
@Ubicacion Varchar(100), 
@ClaseCartera Varchar(100),
@CodProducto varchar(100)

as

Declare /*@Ubicacion Varchar(100), @ClaseCartera Varchar(100),*/ @Dato Int, @PAna Int
--------------------------------------------
Set @Dato				= 2			-- 1: Detalles, 2: Resumen
--Set @Ubicacion 			= '79'		-- Ubicacion, Oficinas, Regiones o "ZZZ"
--Set @ClaseCartera		= 'ACTIVA'	-- "ACTIVA", "CASTIGADA", "ADMINISTRATIVA","TODAS"
Set @PAna 				= 24		-- Rango que se desea Analizar.
------------------------------------
--DROP TABLE #Temporal
-- 1: Detalle
-- 2: Resumen


Declare @PUbicacion		Varchar(50)
Declare @PClaseCartera	Varchar(50)

Set @PUbicacion		=	@Ubicacion
Set @PClaseCartera 	=	@ClaseCartera

Declare @Cadena			Varchar(4000)
Declare @CUbicacion		Varchar(500)
Declare @CClaseCartera 	Varchar(500)
Declare @OtroDato		Varchar(100)
	
Declare @IG				Varchar(6)
Declare @FG				Varchar(6)		
Declare @Periodo		Varchar(6)
Declare @PeriodoN		Varchar(10)
Declare @PI 			Varchar(6)
Declare @Contador		Int
Declare @Contador1		Int
Declare @Proceso 		SmallDateTime

IF @Ubicacion = 'ZZZ'
BEGIN
Exec pGnlCalculaParametros 1, @Ubicacion, 		@CUbicacion 	Out, 	@Ubicacion 		Out,  @OtroDato Out
Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera 	Out, 	@ClaseCartera 	Out,  @OtroDato Out
SET @CUbicacion = (SELECT SUBSTRING(@CUbicacion,1,218)+ ' 98')
END
ELSE 
BEGIN
Exec pGnlCalculaParametros 1, @Ubicacion, 		@CUbicacion 	Out, 	@Ubicacion 		Out,  @OtroDato Out
Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera 	Out, 	@ClaseCartera 	Out,  @OtroDato Out
END

CREATE TABLE #Temporal
	(
	[IG] [smalldatetime] NULL ,
	[CodPrestamo] [varchar] (25) COLLATE Modern_Spanish_CI_AI NULL 
	) 


If @CodProducto =  ''
Begin


--CALCULANDO LOS PERIODOS LIMITES DEL ANALISIS

/*Set @Cadena = 'Insert Into #Temporal (IG) SELECT MIN(Desembolso) AS IG FROM tCsPadronCarteraDet WHERE (CarteraOrigen IN ('+
@CClaseCartera +')) AND (CodOficina IN ('+ @CUbicacion +'))'*/

Set @Cadena = 'Insert Into #Temporal (IG) SELECT MIN(Desembolso) AS IG FROM tCsPadronCarteraDet WHERE (CarteraOrigen IN ('+
 @CClaseCartera +')) AND (CodOficina IN ('+ @CUbicacion +')) and desembolso >=''20110101'' '



Print @Cadena
Exec(@Cadena)

Select @Proceso = FechaConsolidacion From vCsFechaConsolidacion 
Select @IG 	= dbo.fduFechaATexto(IG, 'AAAAMM') From #Temporal
Select @FG	= dbo.fduFechaATexto(FechaConsolidacion, 'AAAAMM') From vCsFechaConsolidacion

UPDATE    tCsVintage_prueba
SET       Proceso = ultimodia
FROM      tCsVintage_prueba INNER JOIN
          tClPeriodo ON tCsVintage_prueba.Periodo COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo
WHERE     (tCsVintage_prueba.Proceso IS NULL) and tCsVintage_prueba.Producto=@CodProducto and tCsVintage_prueba.Ubicacion=@Ubicacion

DELETE FROM tCsVintage_prueba
WHERE     ((CAST(Item AS Varchar(10)) + Ubicacion + Cartera + Desembolso + Periodo + Corte) IN
                          (SELECT     CAST(tCsVintage_prueba.Item AS Varchar(10)) + tCsVintage_prueba.Ubicacion + 
				tCsVintage_prueba.Cartera + tCsVintage_prueba.Desembolso + tCsVintage_prueba.Periodo + tCsVintage_prueba.Corte
                            FROM          tCsVintage_prueba INNER JOIN
                                                   tClPeriodo ON tCsVintage_prueba.Periodo
			 COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo AND tCsVintage_prueba.Proceso <> tClPeriodo.UltimoDia
                           WHERE      (tCsVintage_prueba.Proceso <> @Proceso) and tCsVintage_prueba.Producto=@CodProducto and tCsVintage_prueba.Ubicacion=@Ubicacion )) 
 
DELETE FROM tCsVintage_prueba
WHERE Periodo <> dbo.fduFechaAtexto(Proceso, 'AAAAMM') and tCsVintage_prueba.Producto=@CodProducto and tCsVintage_prueba.Ubicacion=@Ubicacion 

DELETE FROM tCsVintage_prueba
WHERE Proceso > @Proceso and Producto=@CodProducto and tCsVintage_prueba.Ubicacion=@Ubicacion

Declare curPeriodo Cursor For
	SELECT  Periodo, UPPER(SUBSTRING(Descripcion, 1, 3)) + ' ' + CAST(Año AS varchar(4)) as N
	FROM    tClPeriodo
	--WHERE 	Periodo = '200711' 
	WHERE     (Periodo >= @IG) AND (Periodo <= @FG)
Open curPeriodo
Fetch Next From curPeriodo Into @Periodo, @PeriodoN
While @@Fetch_Status = 0
Begin
	Print 'PERIODO: ' + @Periodo
	Set @PI 	= @Periodo	
	Set @Contador 	= 0
	
	SELECT  @Contador = COUNT(*) 
	FROM    tCsVintage_prueba
	WHERE   (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera) AND (Desembolso = @PeriodoN) and producto=@codproducto 
	
	SELECT  @Contador1 = COUNT(*) 
	FROM         tClPeriodo with(nolock)
	WHERE     (Periodo >= @Periodo) AND (Periodo <= @FG)
	
	If @Contador1 > @PAna Begin Set @Contador1 = @PAna End
	--Print '@Contador :' + Cast(@Contador As Varchar(10))
	--Print '@Contador1 :' + Cast(@Contador1 As Varchar(10))
	If @Contador <> @Contador1	
	Begin 
		Truncate Table #Temporal
Set @Cadena = 'Insert Into #Temporal (IG, CodPrestamo) SELECT DISTINCT IG = '''+ @IG + '01'  +''', CodPrestamo 
FROM tCsPadronCarteraDet WHERE (CarteraOrigen IN ('+ @CClaseCartera +')) AND (CodOficina IN ('+ @CUbicacion +')) 
AND (dbo.fduFechaATexto(Desembolso, ''AAAAMM'') = '''+ @Periodo +''')'
	

		Print @Cadena
		Exec(@Cadena)
		Set @Contador 	= 0
		
		--DELETE FROM tCsVintage_prueba
		--WHERE   (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera) AND (Desembolso = @PeriodoN)
	
		Declare curCadena Cursor For	
			SELECT    Periodo
			FROM      tClPeriodo with(nolock)
			WHERE     (dbo.fduFechaATexto(UltimoDia, 'AAAAMM') >= @PI) AND (dbo.fduFechaATexto(UltimoDia, 'AAAAMM') <= dbo.fduFechaATexto(DATEADD([month], @PAna - 1, 
			                      CAST(@PI + '01' AS smalldatetime)), 'AAAAMM'))
		Open curCadena
		Fetch Next From curCadena Into @Cadena
		While @@Fetch_Status = 0
		Begin
			Set @Contador = @Contador + 1

			If Not Exists (SELECT 1 FROM tCsVintage_prueba WHERE   (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera) AND (Desembolso = @PeriodoN) AND Item = @Contador and Producto= @codproducto) 
			Begin
				Print '@Contador: ' + Cast(@Contador as Varchar(10))
				Insert Into tCsVintage_prueba 
				SELECT  Item 	= @Contador, Ubicacion = @PUbicacion, Cartera = @PClaseCartera, Desembolso, Periodo, Corte, 
					Proceso = Max(Fecha),
					SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos) AS Total, SUM(Buenos) AS Buenos, SUM(Malos) AS Malos, 
				        SUM(Terminados) AS Terminados, SUM(Vencidos) AS Vencidos, 
					    Ratio1 = (Sum(Malos) + Sum(Vencidos))/
						Case When Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5))= 0 Then 1 Else Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) END ,
					    Ratio2 = Sum(Vencidos)/
						Case When Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) = 0 Then 1 Else Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) End,@codproducto,convert(datetime,CONVERT(varchar(10), GETDATE(), 103),103)
				FROM         (SELECT     Desembolso, Periodo, Corte, CASE WHEN Vintage = 'BUENO' THEN COUNT(*) ELSE 0 END AS Buenos, CASE WHEN Vintage = 'MALO' THEN COUNT(*) 
				                                              ELSE 0 END AS Malos, CASE WHEN Vintage = 'TERMINADO' THEN COUNT(*) ELSE 0 END AS Terminados, 
				                                              CASE WHEN Vintage = 'VENCIDO' THEN COUNT(*) ELSE 0 END AS Vencidos, Fecha
				                       FROM          (SELECT     Datos.*, tCsCartera.NroDiasAtraso, tCsCartera.Estado, PV.PV, CASE WHEN PV IS NOT NULL 
				                                                                      THEN 'VENCIDO' WHEN nrodiasatraso = 0 THEN 'BUENO' WHEN nrodiasatraso < 90 AND 
				                                                                      nrodiasatraso > 1 THEN 'MALO' WHEN tCsCartera.NroDiasAtraso IS NULL AND tCsCartera.Estado IS NULL 
				                                                                      THEN 'TERMINADO' ELSE 'POR CALCULAR' END AS Vintage, tCsCartera.Fecha
				                                               FROM          (SELECT     Datos.Desembolso, Datos.CodPrestamo, UPPER(SUBSTRING(Periodo.Descripcion, 1, 3)) + ' ' + CAST(Periodo.Año AS varchar(4)) 
				                                                                                              AS Corte, Periodo.UltimoDia, Periodo.Periodo
				                                                                       FROM          (SELECT     UPPER(SUBSTRING(tClPeriodo.Descripcion, 1, 3)) + ' ' + CAST(tClPeriodo.Año AS varchar(4)) AS Desembolso, 
				                                                                                                                      Datos.CodPrestamo
				                                                                                               FROM          (SELECT DISTINCT dbo.fduFechaATexto(Desembolso, 'AAAAMM') AS Periodo, CodPrestamo
				                                                                                                                       FROM          tCsPadronCarteraDet with(nolock)
				                                                                                                                       WHERE      /*CODPRODUCTO=@codproducto and*/ CodPrestamo IN (Select Codprestamo from #Temporal)) Datos INNER JOIN
				                                                                                                                      tClPeriodo ON Datos.Periodo COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo) Datos CROSS JOIN
				                                                                                                  (SELECT *
				                                                                                                    FROM tClPeriodo with(nolock)
				                                                                                                    WHERE Periodo = @Cadena AND (dbo.fduFechaATexto(UltimoDia, 'AAAAMM') >= @PI) AND (dbo.fduFechaATexto(UltimoDia, 
				                                                                                                                           'AAAAMM') <= dbo.fduFechaATexto(DATEADD([year], 3, CAST(@PI + '01' AS smalldatetime)), 'AAAAMM'))) Periodo) 
				                                                                      Datos LEFT OUTER JOIN
				                                                                          (SELECT     CodPrestamo, MIN(PV) AS PV
				                                                                            FROM          (SELECT DISTINCT dbo.fdufechaatexto(Fecha, 'AAAAMM') AS PV, CodPrestamo, NroDiasAtraso
				                                                                                                    FROM          tCsCartera with(nolock)
				                                                                                                    WHERE      (NroDiasAtraso = 90) AND (dbo.fduFechaATexto(FechaDesembolso, 'AAAAMM') = @PI)  and --CODPRODUCTO=@codproducto  AND 
				                                                                                                                           (dbo.fduFechaATexto(Fecha, 'AAAAMM') >= @PI)) Datos
				                                                                            GROUP BY CodPrestamo) PV ON Datos.Periodo >= PV.PV AND Datos.CodPrestamo = PV.CodPrestamo LEFT OUTER JOIN
				                                                                      tCsCartera ON CASE WHEN Periodo = @FG THEN @Proceso Else Datos.UltimoDia END  =tCsCartera.Fecha AND Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo) 
				                                              Datos
				                       WHERE (Periodo = @Cadena)
				                       GROUP BY Desembolso, Periodo, Corte, Vintage, Fecha) Datos
				GROUP BY Desembolso, Periodo, Corte
			End
		Fetch Next From curCadena Into @Cadena
		End
		Close 		curCadena
		Deallocate 	curCadena
	End
Fetch Next From curPeriodo Into @Periodo, @PeriodoN
End
Close 		curPeriodo
Deallocate 	curPeriodo	

Drop Table #Temporal

UPDATE    tCsVintage_prueba
SET              Proceso = Datos.proceso
FROM         (SELECT     Datos.Ubicacion, Datos.Cartera, Datos.Periodo, MAX(tCsVintage_prueba.Proceso) AS Proceso
                       FROM          (SELECT DISTINCT Ubicacion, Cartera, Periodo
                                               FROM          tCsVintage_prueba
                                               WHERE      (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera) AND (Proceso IS NULL)) Datos INNER JOIN
                                              tCsVintage_prueba ON Datos.Ubicacion COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Ubicacion AND 
                                              Datos.Cartera COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Cartera AND Datos.Periodo COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Periodo
                       GROUP BY Datos.Ubicacion, Datos.Cartera, Datos.Periodo) Datos INNER JOIN
                      tCsVintage_prueba ON Datos.Ubicacion COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Ubicacion AND Datos.Cartera COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Cartera AND
                       Datos.Periodo COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Periodo
WHERE     (tCsVintage_prueba.Proceso IS NULL)

--If @Dato = 1
--Begin
--	SELECT  tCsVintage_prueba.Item, Ubicacion = @Ubicacion, Cartera = @ClaseCartera, tCsVintage_prueba.Desembolso, tCsVintage_prueba.Corte, tCsVintage_prueba.Total, tCsVintage_prueba.Buenos, tCsVintage_prueba.Malos, 
--	                      tCsVintage_prueba.Terminados, tCsVintage_prueba.Vencidos, tCsVintage_prueba.Ratio1, tCsVintage_prueba.Ratio2, tCsVintage_prueba.Proceso
--	FROM         (SELECT     Ubicacion, Cartera, Desembolso, MAX(Item) AS Item
--	                       FROM          tCsVintage_prueba
--			       WHERE Ubicacion = @PUbicacion AND Cartera = @PClaseCartera
--	                       GROUP BY Ubicacion, Cartera, Desembolso) filtro INNER JOIN
--	                      tCsVintage_prueba ON filtro.Item = tCsVintage_prueba.Item AND filtro.Ubicacion COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Ubicacion AND 
--	                      filtro.Cartera COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Cartera AND filtro.Desembolso COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Desembolso INNER JOIN
--	                      tClPeriodo ON tCsVintage_prueba.Desembolso COLLATE Modern_Spanish_CI_AS = UPPER(SUBSTRING(tClPeriodo.Descripcion, 1, 3)) + ' ' + CAST(tClPeriodo.Año AS varchar(4))
--	WHERE     (tCsVintage_prueba.Periodo = @FG) 
--	--ORDER BY tCsVintage_prueba.Item
--	ORDER BY tClPeriodo.Periodo
--End
--If @Dato = 2
--Begin
--	SELECT     Ubicacion = @Ubicacion, Cartera = @ClaseCartera, Año, SUM(MR101) AS MR101, SUM(MR102) AS MR102, SUM(MR103) AS MR103, SUM(MR104) AS MR104, SUM(MR105) AS MR105, SUM(MR106) 
--	                      AS MR106, SUM(MR107) AS MR107, SUM(MR108) AS MR108, SUM(MR109) AS MR109, SUM(MR110) AS MR110, SUM(MR111) AS MR111, SUM(MR112) AS MR112, 
--	                      SUM(MR113) AS MR113, SUM(MR114) AS MR114, SUM(MR115) AS MR115, SUM(MR116) AS MR116, SUM(MR117) AS MR117, SUM(MR118) AS MR118, SUM(MR119) 
--	                      AS MR119, SUM(MR120) AS MR120, SUM(MR121) AS MR121, SUM(MR122) AS MR122, SUM(MR123) AS MR123, SUM(MR124) AS MR124
--	FROM         (SELECT     Ubicacion, Cartera, Año, CASE WHEN item = 1 THEN Mratio1 ELSE 0 END AS MR101, CASE WHEN item = 1 THEN Mratio1 ELSE 0 END AS MR102, 
--	                                              CASE WHEN item = 3 THEN Mratio1 ELSE 0 END AS MR103, CASE WHEN item = 4 THEN Mratio1 ELSE 0 END AS MR104, 
--	                                              CASE WHEN item = 5 THEN Mratio1 ELSE 0 END AS MR105, CASE WHEN item = 6 THEN Mratio1 ELSE 0 END AS MR106, 
--	                                              CASE WHEN item = 7 THEN Mratio1 ELSE 0 END AS MR107, CASE WHEN item = 8 THEN Mratio1 ELSE 0 END AS MR108, 
--	                                              CASE WHEN item = 9 THEN Mratio1 ELSE 0 END AS MR109, CASE WHEN item = 10 THEN Mratio1 ELSE 0 END AS MR110, 
--	                                              CASE WHEN item = 11 THEN Mratio1 ELSE 0 END AS MR111, CASE WHEN item = 12 THEN Mratio1 ELSE 0 END AS MR112, 
--	                                              CASE WHEN item = 13 THEN Mratio1 ELSE 0 END AS MR113, CASE WHEN item = 14 THEN Mratio1 ELSE 0 END AS MR114, 
--	                                              CASE WHEN item = 15 THEN Mratio1 ELSE 0 END AS MR115, CASE WHEN item = 16 THEN Mratio1 ELSE 0 END AS MR116, 
--	                                              CASE WHEN item = 17 THEN Mratio1 ELSE 0 END AS MR117, CASE WHEN item = 18 THEN Mratio1 ELSE 0 END AS MR118, 
--	                                              CASE WHEN item = 19 THEN Mratio1 ELSE 0 END AS MR119, CASE WHEN item = 20 THEN Mratio1 ELSE 0 END AS MR120, 
--	                                              CASE WHEN item = 21 THEN Mratio1 ELSE 0 END AS MR121, CASE WHEN item = 22 THEN Mratio1 ELSE 0 END AS MR122, 
--	                                              CASE WHEN item = 23 THEN Mratio1 ELSE 0 END AS MR123, CASE WHEN item = 24 THEN Mratio1 ELSE 0 END AS MR124
--	                       FROM          (SELECT     Ubicacion, Cartera, tClPeriodo.Año, tCsVintage_prueba.Item, AVG(tCsVintage_prueba.Ratio1) AS MRatio1
--	                                               FROM tCsVintage_prueba INNER JOIN
--	                                               tClPeriodo ON tCsVintage_prueba.Desembolso COLLATE Modern_Spanish_CI_AS  = UPPER(SUBSTRING(tClPeriodo.Descripcion, 1, 3)) + ' ' + CAST(tClPeriodo.Año AS varchar(4))
--	                                               WHERE      Ubicacion = @PUbicacion AND Cartera = @PClaseCartera
--	                                               GROUP BY Ubicacion, Cartera, tClPeriodo.Año, tCsVintage_prueba.Item) Datos) Datos
--	GROUP BY Año, Ubicacion, Cartera
--	Having 	Round(SUM(MR101) + SUM(MR102) + SUM(MR103) + SUM(MR104) + SUM(MR105) + SUM(MR106) + SUM(MR107) + SUM(MR108) + SUM(MR109) + SUM(MR110) + SUM(MR111) + SUM(MR112) +
--		SUM(MR113) + SUM(MR114) + SUM(MR115) + SUM(MR116) + SUM(MR117) + SUM(MR118) + SUM(MR119) + SUM(MR120) + SUM(MR121) + SUM(MR122) + SUM(MR123) + SUM(MR124), 2) > 0
--End

end

else

If @CodProducto <> ''
Begin

--CALCULANDO LOS PERIODOS LIMITES DEL ANALISIS
--Set @Cadena = 'Insert Into #Temporal (IG) SELECT MIN(Desembolso) AS IG FROM tCsPadronCarteraDet WHERE (CarteraOrigen IN ('+
--@CClaseCartera +')) AND (CodOficina IN ('+ @CUbicacion +'))'

Set @Cadena = 'Insert Into #Temporal (IG) SELECT MIN(Desembolso) AS IG FROM tCsPadronCarteraDet WHERE (CarteraOrigen IN ('+
 @CClaseCartera +')) AND (CodOficina IN ('+ @CUbicacion +')) and desembolso >=''20110101'' '


Exec(@Cadena)

Select @Proceso = FechaConsolidacion From vCsFechaConsolidacion 
Select @IG 	= dbo.fduFechaATexto(IG, 'AAAAMM') From #Temporal
Select @FG	= dbo.fduFechaATexto(FechaConsolidacion, 'AAAAMM') From vCsFechaConsolidacion

UPDATE    tCsVintage_prueba
SET       Proceso = ultimodia
FROM      tCsVintage_prueba INNER JOIN
          tClPeriodo ON tCsVintage_prueba.Periodo COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo
WHERE     (tCsVintage_prueba.Proceso IS NULL) and tCsVintage_prueba.Producto=@CodProducto and tCsVintage_prueba.Ubicacion=@Ubicacion

DELETE FROM tCsVintage_prueba
WHERE     ((CAST(Item AS Varchar(10)) + Ubicacion + Cartera + Desembolso + Periodo + Corte) IN
                          (SELECT     CAST(tCsVintage_prueba.Item AS Varchar(10)) + tCsVintage_prueba.Ubicacion + 
				tCsVintage_prueba.Cartera + tCsVintage_prueba.Desembolso + tCsVintage_prueba.Periodo + tCsVintage_prueba.Corte
                            FROM          tCsVintage_prueba INNER JOIN
                                                   tClPeriodo ON tCsVintage_prueba.Periodo
			 COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo AND tCsVintage_prueba.Proceso <> tClPeriodo.UltimoDia
                           WHERE      (tCsVintage_prueba.Proceso <> @Proceso) and tCsVintage_prueba.Producto=@CodProducto and tCsVintage_prueba.Ubicacion=@Ubicacion )) 
 
DELETE FROM tCsVintage_prueba
WHERE Periodo <> dbo.fduFechaAtexto(Proceso, 'AAAAMM') and tCsVintage_prueba.Producto=@CodProducto and tCsVintage_prueba.Ubicacion=@Ubicacion 

DELETE FROM tCsVintage_prueba
WHERE Proceso > @Proceso and Producto=@CodProducto and tCsVintage_prueba.Ubicacion=@Ubicacion


Declare curPeriodo Cursor For
	SELECT  Periodo, UPPER(SUBSTRING(Descripcion, 1, 3)) + ' ' + CAST(Año AS varchar(4)) as N
	FROM    tClPeriodo with(nolock)
	--WHERE 	Periodo = '200711' 
	WHERE     (Periodo >= @IG) AND (Periodo <= @FG)
Open curPeriodo
Fetch Next From curPeriodo Into @Periodo, @PeriodoN
While @@Fetch_Status = 0
Begin
	Print 'PERIODO: ' + @Periodo
	Set @PI 	= @Periodo	
	Set @Contador 	= 0
	
	SELECT  @Contador = COUNT(*) 
	FROM    tCsVintage_prueba
	WHERE   (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera) AND (Desembolso = @PeriodoN)and producto=@codproducto
	
	SELECT  @Contador1 = COUNT(*) 
	FROM         tClPeriodo with(nolock)
	WHERE     (Periodo >= @Periodo) AND (Periodo <= @FG)
	
	If @Contador1 > @PAna Begin Set @Contador1 = @PAna End
	--Print '@Contador :' + Cast(@Contador As Varchar(10))
	--Print '@Contador1 :' + Cast(@Contador1 As Varchar(10))
	If @Contador <> @Contador1	
	Begin 
		Truncate Table #Temporal

Set @Cadena = 'Insert Into #Temporal (IG, CodPrestamo) SELECT DISTINCT IG = '''+ @IG + '01'  +''', 
CodPrestamo FROM tCsPadronCarteraDet WHERE (CarteraOrigen IN ('+ @CClaseCartera +')) 
AND (CodOficina IN ('+ @CUbicacion +')) AND (dbo.fduFechaATexto(Desembolso, ''AAAAMM'') = '''+ @Periodo +''')'


		Print @Cadena
		Exec(@Cadena)
		Set @Contador 	= 0
		
		--DELETE FROM tCsVintage_prueba
		--WHERE   (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera) AND (Desembolso = @PeriodoN)
	
		Declare curCadena Cursor For	
			SELECT    Periodo
			FROM      tClPeriodo with(nolock)
			WHERE     (dbo.fduFechaATexto(UltimoDia, 'AAAAMM') >= @PI) AND (dbo.fduFechaATexto(UltimoDia, 'AAAAMM') <= dbo.fduFechaATexto(DATEADD([month], @PAna - 1, 
			                      CAST(@PI + '01' AS smalldatetime)), 'AAAAMM'))
		Open curCadena
		Fetch Next From curCadena Into @Cadena
		While @@Fetch_Status = 0
		Begin
			Set @Contador = @Contador + 1

print @PUbicacion
			print @PClaseCartera
			print @PeriodoN
			print @Contador
			print @CodProducto

			If Not Exists (SELECT 1 FROM tCsVintage_prueba WHERE   (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera) AND (Desembolso = @PeriodoN) AND Item = @Contador and Producto = @CodProducto ) 

					Begin
				Print '@Contador: ' + Cast(@Contador as Varchar(10))
				Insert Into tCsVintage_prueba
				SELECT  Item 	= @Contador, Ubicacion = @PUbicacion, Cartera = @PClaseCartera, Desembolso, Periodo, Corte, 
					Proceso = Max(Fecha),
					SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos) AS Total, SUM(Buenos) AS Buenos, SUM(Malos) AS Malos, 
				        SUM(Terminados) AS Terminados, SUM(Vencidos) AS Vencidos, 
					    Ratio1 = (Sum(Malos) + Sum(Vencidos))/
						Case When Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5))= 0 Then 1 Else Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) END ,
					    Ratio2 = Sum(Vencidos)/
						Case When Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) = 0 Then 1 Else Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) End, @codproducto,getdate()
				FROM         (SELECT     Desembolso, Periodo, Corte, CASE WHEN Vintage = 'BUENO' THEN COUNT(*) ELSE 0 END AS Buenos, CASE WHEN Vintage = 'MALO' THEN COUNT(*) 
				                                              ELSE 0 END AS Malos, CASE WHEN Vintage = 'TERMINADO' THEN COUNT(*) ELSE 0 END AS Terminados, 
				                                              CASE WHEN Vintage = 'VENCIDO' THEN COUNT(*) ELSE 0 END AS Vencidos, Fecha
				                       FROM          (SELECT     Datos.*, tCsCartera.NroDiasAtraso, tCsCartera.Estado, PV.PV, CASE WHEN PV IS NOT NULL 
				                                                                      THEN 'VENCIDO' WHEN nrodiasatraso = 0 THEN 'BUENO' WHEN nrodiasatraso < 90 AND 
				                                                                      nrodiasatraso > 1 THEN 'MALO' WHEN tCsCartera.NroDiasAtraso IS NULL AND tCsCartera.Estado IS NULL 
				                                                                      THEN 'TERMINADO' ELSE 'POR CALCULAR' END AS Vintage, tCsCartera.Fecha
				                                               FROM          (SELECT     Datos.Desembolso, Datos.CodPrestamo, UPPER(SUBSTRING(Periodo.Descripcion, 1, 3)) + ' ' + CAST(Periodo.Año AS varchar(4)) 
				                                                                                              AS Corte, Periodo.UltimoDia, Periodo.Periodo
				                                                                       FROM          (SELECT     UPPER(SUBSTRING(tClPeriodo.Descripcion, 1, 3)) + ' ' + CAST(tClPeriodo.Año AS varchar(4)) AS Desembolso, 
				                                                                                                                      Datos.CodPrestamo
				                                                                                               FROM          (SELECT DISTINCT dbo.fduFechaATexto(Desembolso, 'AAAAMM') AS Periodo, CodPrestamo
				                                                                                                                       FROM          tCsPadronCarteraDet with(nolock)
				                                                                                                                       WHERE     codproducto=@CODPRODUCTO and CodPrestamo IN (Select Codprestamo from #Temporal)) Datos INNER JOIN
				                                                                                                                      tClPeriodo ON Datos.Periodo COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo) Datos CROSS JOIN
				                                                                                                  (SELECT *
				                                                                                                    FROM tClPeriodo with(nolock)
				                                                                                                    WHERE Periodo = @Cadena AND (dbo.fduFechaATexto(UltimoDia, 'AAAAMM') >= @PI) AND (dbo.fduFechaATexto(UltimoDia, 
				                                                                                                                           'AAAAMM') <= dbo.fduFechaATexto(DATEADD([year], 3, CAST(@PI + '01' AS smalldatetime)), 'AAAAMM'))) Periodo) 
				                                                                      Datos LEFT OUTER JOIN
				                                                                          (SELECT     CodPrestamo, MIN(PV) AS PV
				                                                                            FROM          (SELECT DISTINCT dbo.fdufechaatexto(Fecha, 'AAAAMM') AS PV, CodPrestamo, NroDiasAtraso
				                                                                                                    FROM          tCsCartera with(nolock)
				                                                                                                    WHERE      (NroDiasAtraso = 90) AND (dbo.fduFechaATexto(FechaDesembolso, 'AAAAMM') = @PI)  and codproducto=@CODPRODUCTO  AND
				                                                                                                                           (dbo.fduFechaATexto(Fecha, 'AAAAMM') >= @PI)) Datos
				                                                                            GROUP BY CodPrestamo) PV ON Datos.Periodo >= PV.PV AND Datos.CodPrestamo = PV.CodPrestamo LEFT OUTER JOIN
				                                                                      tCsCartera ON CASE WHEN Periodo = @FG THEN @Proceso Else Datos.UltimoDia END  =tCsCartera.Fecha AND Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo) 
				                                              Datos
				                       WHERE (Periodo = @Cadena)
				                       GROUP BY Desembolso, Periodo, Corte, Vintage, Fecha) Datos
				GROUP BY Desembolso, Periodo, Corte
			End
		Fetch Next From curCadena Into @Cadena
		End
		Close 		curCadena
		Deallocate 	curCadena
	End
Fetch Next From curPeriodo Into @Periodo, @PeriodoN
End
Close 		curPeriodo
Deallocate 	curPeriodo	

Drop Table #Temporal

UPDATE    tCsVintage_prueba
SET              Proceso = Datos.proceso
FROM         (SELECT     Datos.Ubicacion, Datos.Cartera, Datos.Periodo, MAX(tCsVintage_prueba.Proceso) AS Proceso
                       FROM          (SELECT DISTINCT Ubicacion, Cartera, Periodo
                                               FROM          tCsVintage_prueba
                                               WHERE      (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera) AND (Proceso IS NULL)) Datos INNER JOIN
                                              tCsVintage_prueba ON Datos.Ubicacion COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Ubicacion AND 
                                              Datos.Cartera COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Cartera AND Datos.Periodo COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Periodo
                       GROUP BY Datos.Ubicacion, Datos.Cartera, Datos.Periodo) Datos INNER JOIN
                      tCsVintage_prueba ON Datos.Ubicacion COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Ubicacion AND Datos.Cartera COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Cartera AND
                       Datos.Periodo COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Periodo
WHERE     (tCsVintage_prueba.Proceso IS NULL)

/*If @Dato = 1
Begin
	SELECT  tCsVintage_prueba.Item, Ubicacion = @Ubicacion, Cartera = @ClaseCartera, tCsVintage_prueba.Desembolso, tCsVintage_prueba.Corte, tCsVintage_prueba.Total, tCsVintage_prueba.Buenos, tCsVintage_prueba.Malos, 
	                      tCsVintage_prueba.Terminados, tCsVintage_prueba.Vencidos, tCsVintage_prueba.Ratio1, tCsVintage_prueba.Ratio2, tCsVintage_prueba.Proceso
	FROM         (SELECT     Ubicacion, Cartera, Desembolso, MAX(Item) AS Item
	                       FROM          tCsVintage_prueba
			       WHERE Ubicacion = @PUbicacion AND Cartera = @PClaseCartera
	                       GROUP BY Ubicacion, Cartera, Desembolso) filtro INNER JOIN
	                      tCsVintage_prueba ON filtro.Item = tCsVintage_prueba.Item AND filtro.Ubicacion COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Ubicacion AND 
	                      filtro.Cartera COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Cartera AND filtro.Desembolso COLLATE Modern_Spanish_CI_AI = tCsVintage_prueba.Desembolso INNER JOIN
	                      tClPeriodo ON tCsVintage_prueba.Desembolso COLLATE Modern_Spanish_CI_AS = UPPER(SUBSTRING(tClPeriodo.Descripcion, 1, 3)) + ' ' + CAST(tClPeriodo.Año AS varchar(4))
	WHERE     (tCsVintage_prueba.Periodo = @FG) 
	--ORDER BY tCsVintage_prueba.Item
	ORDER BY tClPeriodo.Periodo
End
If @Dato = 2
Begin
	SELECT     Ubicacion = @Ubicacion, Cartera = @ClaseCartera, Año, SUM(MR101) AS MR101, SUM(MR102) AS MR102, SUM(MR103) AS MR103, SUM(MR104) AS MR104, SUM(MR105) AS MR105, SUM(MR106) 
	                      AS MR106, SUM(MR107) AS MR107, SUM(MR108) AS MR108, SUM(MR109) AS MR109, SUM(MR110) AS MR110, SUM(MR111) AS MR111, SUM(MR112) AS MR112, 
	                      SUM(MR113) AS MR113, SUM(MR114) AS MR114, SUM(MR115) AS MR115, SUM(MR116) AS MR116, SUM(MR117) AS MR117, SUM(MR118) AS MR118, SUM(MR119) 
	                      AS MR119, SUM(MR120) AS MR120, SUM(MR121) AS MR121, SUM(MR122) AS MR122, SUM(MR123) AS MR123, SUM(MR124) AS MR124
	FROM         (SELECT     Ubicacion, Cartera, Año, CASE WHEN item = 1 THEN Mratio1 ELSE 0 END AS MR101, CASE WHEN item = 1 THEN Mratio1 ELSE 0 END AS MR102, 
	                                              CASE WHEN item = 3 THEN Mratio1 ELSE 0 END AS MR103, CASE WHEN item = 4 THEN Mratio1 ELSE 0 END AS MR104, 
	                                              CASE WHEN item = 5 THEN Mratio1 ELSE 0 END AS MR105, CASE WHEN item = 6 THEN Mratio1 ELSE 0 END AS MR106, 
	                                              CASE WHEN item = 7 THEN Mratio1 ELSE 0 END AS MR107, CASE WHEN item = 8 THEN Mratio1 ELSE 0 END AS MR108, 
	                                              CASE WHEN item = 9 THEN Mratio1 ELSE 0 END AS MR109, CASE WHEN item = 10 THEN Mratio1 ELSE 0 END AS MR110, 
	                                              CASE WHEN item = 11 THEN Mratio1 ELSE 0 END AS MR111, CASE WHEN item = 12 THEN Mratio1 ELSE 0 END AS MR112, 
	                                              CASE WHEN item = 13 THEN Mratio1 ELSE 0 END AS MR113, CASE WHEN item = 14 THEN Mratio1 ELSE 0 END AS MR114, 
	                                              CASE WHEN item = 15 THEN Mratio1 ELSE 0 END AS MR115, CASE WHEN item = 16 THEN Mratio1 ELSE 0 END AS MR116, 
	                                              CASE WHEN item = 17 THEN Mratio1 ELSE 0 END AS MR117, CASE WHEN item = 18 THEN Mratio1 ELSE 0 END AS MR118, 
	                                              CASE WHEN item = 19 THEN Mratio1 ELSE 0 END AS MR119, CASE WHEN item = 20 THEN Mratio1 ELSE 0 END AS MR120, 
	                                              CASE WHEN item = 21 THEN Mratio1 ELSE 0 END AS MR121, CASE WHEN item = 22 THEN Mratio1 ELSE 0 END AS MR122, 
	                                              CASE WHEN item = 23 THEN Mratio1 ELSE 0 END AS MR123, CASE WHEN item = 24 THEN Mratio1 ELSE 0 END AS MR124
	                       FROM          (SELECT     Ubicacion, Cartera, tClPeriodo.Año, tCsVintage_prueba.Item, AVG(tCsVintage_prueba.Ratio1) AS MRatio1
	                                               FROM tCsVintage_prueba INNER JOIN
	                                               tClPeriodo ON tCsVintage_prueba.Desembolso COLLATE Modern_Spanish_CI_AS  = UPPER(SUBSTRING(tClPeriodo.Descripcion, 1, 3)) + ' ' + CAST(tClPeriodo.Año AS varchar(4))
	                                               WHERE      Ubicacion = @PUbicacion AND Cartera = @PClaseCartera
	                                               GROUP BY Ubicacion, Cartera, tClPeriodo.Año, tCsVintage_prueba.Item) Datos) Datos
	GROUP BY Año, Ubicacion, Cartera
	Having 	Round(SUM(MR101) + SUM(MR102) + SUM(MR103) + SUM(MR104) + SUM(MR105) + SUM(MR106) + SUM(MR107) + SUM(MR108) + SUM(MR109) + SUM(MR110) + SUM(MR111) + SUM(MR112) +
		SUM(MR113) + SUM(MR114) + SUM(MR115) + SUM(MR116) + SUM(MR117) + SUM(MR118) + SUM(MR119) + SUM(MR120) + SUM(MR121) + SUM(MR122) + SUM(MR123) + SUM(MR124), 2) > 0
End*/

end








GO