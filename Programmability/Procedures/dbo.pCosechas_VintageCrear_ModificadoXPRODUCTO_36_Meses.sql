SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCosechas_VintageCrear_ModificadoXPRODUCTO_36_Meses] (@Ubicacion Varchar(100), @ClaseCartera Varchar(100), @producto varchar(5))
AS
--Declare @Ubicacion	Varchar(100) 
--Declare @ClaseCartera	Varchar(100) 
Declare @Dato		Int 
Declare @PAna		Int
--Declare @producto varchar(5)
--------------------------------------------
Set @Dato				= 2			-- 1: Detalles, 2: Resumen
--Set @Ubicacion 			= 'ZZZ'		-- Ubicacion, Oficinas, Regiones o "ZZZ"
--Set @ClaseCartera		= 'ACTIVA'	-- "ACTIVA", "CASTIGADA", "ADMINISTRATIVA"
--set @producto				='302'
Set @PAna 				= 36		-- Rango que se desea Analizar.
------------------------------------
--DROP TABLE #Temporal
-- 1: Detalle
-- 2: Resumen

Declare @PUbicacion		Varchar(50)
Declare @PClaseCartera	Varchar(50)

Set @PUbicacion		=	@Ubicacion
Set @PClaseCartera 	=	@ClaseCartera + ' '+ @producto


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

--Exec pGnlCalculaParametros 1, @Ubicacion, 		@CUbicacion 	Out, 	@Ubicacion 		Out,  @OtroDato Out
--Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera 	Out, 	@ClaseCartera 	Out,  @OtroDato Out

IF @Ubicacion = 'ZZZ'
BEGIN
Exec pGnlCalculaParametros 1, @Ubicacion, 		@CUbicacion 	Out, 	@Ubicacion 		Out,  @OtroDato Out
Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera 	Out, 	@ClaseCartera 	Out,  @OtroDato Out
SET @CUbicacion = (SELECT SUBSTRING(@CUbicacion,1,218)+ ', 98')
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
--CALCULANDO LOS PERIODOS LIMITES DEL ANALISIS
--Set @Cadena = 'Insert Into #Temporal (IG) SELECT MIN(Desembolso) AS IG FROM tCsPadronCarteraDet with(nolock) WHERE (CarteraOrigen IN ('+ @CClaseCartera +')) AND (CodOficina IN ('+ @CUbicacion +'))'
Set @Cadena = 'Insert Into #Temporal (IG) SELECT MIN(Desembolso) AS IG FROM tCsPadronCarteraDet WHERE (CarteraOrigen IN ('+
 @CClaseCartera +')) AND (CodOficina IN ('+ @CUbicacion +')) and desembolso >=''20110101'' '
Print @Cadena
Exec(@Cadena)

Select @Proceso = FechaConsolidacion From vCsFechaConsolidacion 
Select @IG 	= dbo.fduFechaATexto(IG, 'AAAAMM') From #Temporal
Select @FG	= dbo.fduFechaATexto(FechaConsolidacion, 'AAAAMM') From vCsFechaConsolidacion

UPDATE    tCsVintage_Nuevo
SET       Proceso = ultimodia
--select *
FROM      tCsVintage_Nuevo INNER JOIN
          tClPeriodo ON tCsVintage_Nuevo.Periodo COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo
WHERE     (tCsVintage_Nuevo.Proceso IS NULL)

DELETE FROM tCsVintage_Nuevo
--select * from  tCsVintage_Nuevo
WHERE ((CAST(Item AS Varchar(10)) + Ubicacion + Cartera + Desembolso + Periodo + Corte) IN
      (SELECT CAST(tCsVintage_Nuevo.Item AS Varchar(10)) + tCsVintage_Nuevo.Ubicacion + tCsVintage_Nuevo.Cartera + tCsVintage_Nuevo.Desembolso + tCsVintage_Nuevo.Periodo + tCsVintage_Nuevo.Corte
       FROM tCsVintage_Nuevo INNER JOIN
       tClPeriodo ON tCsVintage_Nuevo.Periodo COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo AND tCsVintage_Nuevo.Proceso <> tClPeriodo.UltimoDia
       WHERE (tCsVintage_Nuevo.Proceso <> @Proceso)))
       
DELETE FROM tCsVintage_Nuevo
--select * FROM tCsVintage_Nuevo
WHERE Periodo <> dbo.fduFechaAtexto(Proceso, 'AAAAMM') 

DELETE FROM tCsVintage_Nuevo
--select *  FROM tCsVintage_Nuevo
WHERE Proceso > @Proceso

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
	FROM    tCsVintage_Nuevo with(nolock)
	WHERE   (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera) AND (Desembolso = @PeriodoN)
	
	SELECT  @Contador1 = COUNT(*) 
	FROM         tClPeriodo with(nolock)
	WHERE     (Periodo >= @Periodo) AND (Periodo <= @FG)
	
	If @Contador1 > @PAna Begin Set @Contador1 = @PAna End
	--Print '@Contador :' + Cast(@Contador As Varchar(10))
	--Print '@Contador1 :' + Cast(@Contador1 As Varchar(10))
	If @Contador <> @Contador1	
	Begin 
		Truncate Table #Temporal
		Set @Cadena = 'Insert Into #Temporal (IG, CodPrestamo) SELECT DISTINCT IG = '''+ @IG + '01'  +''', CodPrestamo FROM tCsPadronCarteraDet with(nolock) WHERE (CarteraOrigen IN ('+ @CClaseCartera +')) AND (CodOficina IN ('+ @CUbicacion +')) AND (dbo.fduFechaATexto(Desembolso, ''AAAAMM'') = '''+ @Periodo +''')'
		Print @Cadena
		Exec(@Cadena)
		Set @Contador 	= 0
		
		--DELETE FROM tCsVintage
		--WHERE   (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera) AND (Desembolso = @PeriodoN)
	
		Declare curCadena Cursor For	
			SELECT    Periodo
			FROM  tClPeriodo with(nolock)
			WHERE (dbo.fduFechaATexto(UltimoDia, 'AAAAMM') >= @PI) 
			AND (dbo.fduFechaATexto(UltimoDia, 'AAAAMM') <= dbo.fduFechaATexto(DATEADD([month], @PAna - 1, CAST(@PI + '01' AS smalldatetime)), 'AAAAMM'))
		Open curCadena
		Fetch Next From curCadena Into @Cadena
		While @@Fetch_Status = 0
		Begin
			Set @Contador = @Contador + 1

			If Not Exists (SELECT 1 FROM tCsVintage_Nuevo WHERE   (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera ) AND (Desembolso = @PeriodoN) AND Item = @Contador) 
			Begin
				Print '@Contador: ' + Cast(@Contador as Varchar(10))
				Insert Into tCsVintage_Nuevo
				SELECT  Item 	= @Contador, Ubicacion = @PUbicacion, Cartera = @PClaseCartera , 
        Desembolso, Periodo, Corte,Proceso = Max(Fecha)
        ,SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos) AS Total
        ,SUM(Buenos) AS Buenos
        ,SUM(Malos) AS Malos
        ,SUM(Terminados) AS Terminados, SUM(Vencidos) AS Vencidos
        ,Ratio1 = (Sum(Malos) + Sum(Vencidos))/
                  Case When Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5))= 0 Then 1 
                  Else Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) END 
        ,Ratio2 = Sum(Vencidos)/
					        Case When Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) = 0 Then 1 
					        Else Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) End

        ,SUM(MntoBuenos) + SUM(MntoMalos) + SUM(MntoTerminados) + SUM(MntoVencidos) AS MntoTotal
        ,SUM(MntoBuenos) AS MntoBuenos
        ,SUM(MntoMalos) AS MntoMalos
        ,SUM(MntoTerminados) AS MntoTerminados
        ,SUM(MntoVencidos) AS MntoVencidos

        ,sum(MntoNuevosBuenos) as MntoNuevosBuenos
        ,sum(MntoNuevosMalos) as MntoNuevosMalos
        ,sum(MntoNuevosTerminados) as MntoNuevosTerminados
        ,sum(MntoNuevosVencidos) as MntoNuevosVencidos

        ,sum(MntoRepresBuenos) as MntoRepresBuenos
        ,sum(MntoRepresMalos) as MntoRepresMalos
        ,sum(MntoRepresTerminados) as MntoRepresTerminados
        ,sum(MntoRepresVencidos) as MntoRepresVencidos

        ,SUM(SaldoBuenos) + SUM(SaldoMalos) + SUM(SaldoTerminados) + SUM(SaldoVencidos) AS SaldoTotal
        ,SUM(SaldoBuenos) AS SaldoBuenos
        ,SUM(SaldoMalos) AS SaldoMalos
        ,SUM(SaldoTerminados) AS SaldoTerminados
        ,SUM(SaldoVencidos) AS SaldoVencidos

        FROM (

          SELECT Desembolso, Periodo, Corte, Fecha
          ,CASE WHEN Vintage = 'BUENO' THEN COUNT(*) ELSE 0 END AS Buenos
          ,CASE WHEN Vintage = 'MALO' THEN COUNT(*) ELSE 0 END AS Malos
          ,CASE WHEN Vintage = 'TERMINADO' THEN COUNT(*) ELSE 0 END AS Terminados
          ,CASE WHEN Vintage = 'VENCIDO' THEN COUNT(*) ELSE 0 END AS Vencidos

          ,CASE WHEN Vintage = 'BUENO' THEN sum(mntodesem) ELSE 0 END AS MntoBuenos
          ,CASE WHEN Vintage = 'MALO' THEN sum(mntodesem) ELSE 0 END AS MntoMalos
          ,CASE WHEN Vintage = 'TERMINADO' THEN sum(mntodesem) ELSE 0 END AS MntoTerminados
          ,CASE WHEN Vintage = 'VENCIDO' THEN sum(mntodesem) ELSE 0 END AS MntoVencidos
          
          ,CASE WHEN Vintage = 'BUENO' THEN sum(mntonuevos) ELSE 0 END AS MntoNuevosBuenos
          ,CASE WHEN Vintage = 'MALO' THEN sum(mntonuevos) ELSE 0 END AS MntoNuevosMalos
          ,CASE WHEN Vintage = 'TERMINADO' THEN sum(mntonuevos) ELSE 0 END AS MntoNuevosTerminados
          ,CASE WHEN Vintage = 'VENCIDO' THEN sum(mntonuevos) ELSE 0 END AS MntoNuevosVencidos
          
          ,CASE WHEN Vintage = 'BUENO' THEN sum(mntoreprestamos) ELSE 0 END AS MntoRepresBuenos
          ,CASE WHEN Vintage = 'MALO' THEN sum(mntoreprestamos) ELSE 0 END AS MntoRepresMalos
          ,CASE WHEN Vintage = 'TERMINADO' THEN sum(mntoreprestamos) ELSE 0 END AS MntoRepresTerminados
          ,CASE WHEN Vintage = 'VENCIDO' THEN sum(mntoreprestamos) ELSE 0 END AS MntoRepresVencidos
          
          ,CASE WHEN Vintage = 'BUENO' THEN sum(saldo) ELSE 0 END AS SaldoBuenos
          ,CASE WHEN Vintage = 'MALO' THEN sum(saldo) ELSE 0 END AS SaldoMalos
          ,CASE WHEN Vintage = 'TERMINADO' THEN sum(saldo) ELSE 0 END AS SaldoTerminados
          ,CASE WHEN Vintage = 'VENCIDO' THEN sum(saldo) ELSE 0 END AS SaldoVencidos

	        FROM (
        	
	              SELECT Datos.*, tCsCartera.NroDiasAtraso, tCsCartera.Estado,PV.PV
	              ,CASE WHEN PV IS NOT NULL THEN 'VENCIDO' 
	                    WHEN nrodiasatraso = 0 THEN 'BUENO' 
	                    WHEN nrodiasatraso < 90 AND nrodiasatraso > 1 THEN 'MALO' 
	                    WHEN tCsCartera.NroDiasAtraso IS NULL AND tCsCartera.Estado IS NULL THEN 'TERMINADO' 
	                    ELSE 'POR CALCULAR' END AS Vintage
	              ,tCsCartera.Fecha
	              ,tCsCartera.saldo --> 619 registros
				        FROM (
				              SELECT Datos.Desembolso, Datos.CodPrestamo, UPPER(SUBSTRING(Periodo.Descripcion, 1, 3)) + ' ' + CAST(Periodo.Año AS varchar(4)) AS Corte
				              ,Periodo.UltimoDia, Periodo.Periodo, Datos.mntodesem, datos.MntoNuevos, datos.MntoReprestamos
				              FROM (
				                    SELECT UPPER(SUBSTRING(tClPeriodo.Descripcion, 1, 3)) + ' ' + CAST(tClPeriodo.Año AS varchar(4)) AS Desembolso
				                    ,Datos.CodPrestamo, Datos.mntodesem, datos.MntoNuevos, datos.MntoReprestamos
				                    FROM (
				                          --SELECT DISTINCT dbo.fduFechaATexto(Desembolso, 'AAAAMM') AS Periodo, CodPrestamo,monto mntodesem
				                          SELECT dbo.fduFechaATexto(Desembolso, 'AAAAMM') AS Periodo, CodPrestamo,sum(monto) mntodesem
				                          ,sum(case when secuenciacliente=1 then monto else 0 end) MntoNuevos
				                          ,sum(case when secuenciacliente<>1 then monto else 0 end) MntoReprestamos
				                          FROM tCsPadronCarteraDet with(nolock)
				                          --WHERE CodPrestamo IN (Select Codprestamo from #Temporal)    /* ORIGINAL*/
				                          WHERE CodPrestamo IN (Select Codprestamo from #Temporal) and codproducto=@producto
				                          group by dbo.fduFechaATexto(Desembolso, 'AAAAMM'), CodPrestamo
        				                  				                  
				                          ) Datos 
	                          INNER JOIN tClPeriodo ON Datos.Periodo COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo
	                    ) Datos
	                    CROSS JOIN (
	                                SELECT *
	                                FROM tClPeriodo
	                                WHERE Periodo = @Cadena AND (dbo.fduFechaATexto(UltimoDia, 'AAAAMM') >= @PI)
	                                      AND (dbo.fduFechaATexto(UltimoDia, 'AAAAMM')
	                                      <= dbo.fduFechaATexto(DATEADD([year], 3, CAST(@PI + '01' AS smalldatetime)), 'AAAAMM')
	                                  )
	                    )Periodo
				        ) Datos 
				        LEFT OUTER JOIN
				        (
				         SELECT CodPrestamo, MIN(PV) AS PV
				         FROM (
				               SELECT DISTINCT dbo.fdufechaatexto(Fecha, 'AAAAMM') AS PV, CodPrestamo, NroDiasAtraso
				               FROM tCsCartera with(nolock)
				              /* WHERE (NroDiasAtraso = 90) AND (dbo.fduFechaATexto(FechaDesembolso, 'AAAAMM') = @PI) ----ORIGINAL
				               AND (dbo.fduFechaATexto(Fecha, 'AAAAMM') >= @PI)*/----ORIGINAL
				              WHERE (NroDiasAtraso = 90) AND (dbo.fduFechaATexto(FechaDesembolso, 'AAAAMM') = @PI)
				               AND (dbo.fduFechaATexto(Fecha, 'AAAAMM') >= @PI) AND CODPRODUCTO=@PRODUCTO
				               	               
				               ) Datos
				         GROUP BY CodPrestamo
				         ) PV ON Datos.Periodo >= PV.PV AND Datos.CodPrestamo = PV.CodPrestamo 
				         LEFT OUTER JOIN 
				         --tCsCartera with(nolock) 
				         (
				          select c.fecha,c.codprestamo,c.nrodiasatraso,c.estado,sum(d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido) saldo
                  from tCsCartera c with(nolock) 
                  /*inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo */ ----ORIGINAL
                  inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo AND CODPRODUCTO=@pRODUCTO
                  --where c.fecha='20140611' and c.codprestamo='033-156-06-00-00409'
                  group by c.fecha,c.codprestamo,c.nrodiasatraso,c.estado
                  ) tCsCartera
				         ON (CASE WHEN datos.Periodo = @FG THEN @Proceso Else Datos.UltimoDia END)=tCsCartera.Fecha 
				         AND Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo 
        				 
	        )Datos
	        WHERE (Periodo = @Cadena)
	        GROUP BY Desembolso, Periodo, Corte, Vintage, Fecha

        ) Datos
        GROUP BY Desembolso, Periodo, Corte

				--SELECT  Item 	= @Contador, Ubicacion = @PUbicacion, Cartera = @PClaseCartera, Desembolso, Periodo, Corte, 
				--	Proceso = Max(Fecha),
				--	SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos) AS Total, SUM(Buenos) AS Buenos, SUM(Malos) AS Malos, 
				--        SUM(Terminados) AS Terminados, SUM(Vencidos) AS Vencidos, 
				--	    Ratio1 = (Sum(Malos) + Sum(Vencidos))/
				--		Case When Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5))= 0 Then 1 Else Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) END ,
				--	    Ratio2 = Sum(Vencidos)/
				--		Case When Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) = 0 Then 1 Else Cast((SUM(Buenos) + SUM(Malos) + SUM(Terminados) + SUM(Vencidos)) as Decimal(20,5)) End
				--FROM         (SELECT     Desembolso, Periodo, Corte, CASE WHEN Vintage = 'BUENO' THEN COUNT(*) ELSE 0 END AS Buenos, CASE WHEN Vintage = 'MALO' THEN COUNT(*) 
				--                                              ELSE 0 END AS Malos, CASE WHEN Vintage = 'TERMINADO' THEN COUNT(*) ELSE 0 END AS Terminados, 
				--                                              CASE WHEN Vintage = 'VENCIDO' THEN COUNT(*) ELSE 0 END AS Vencidos, Fecha
				--                       FROM          (SELECT     Datos.*, tCsCartera.NroDiasAtraso, tCsCartera.Estado, PV.PV, CASE WHEN PV IS NOT NULL 
				--                                                                      THEN 'VENCIDO' WHEN nrodiasatraso = 0 THEN 'BUENO' WHEN nrodiasatraso < 90 AND 
				--                                                                      nrodiasatraso > 1 THEN 'MALO' WHEN tCsCartera.NroDiasAtraso IS NULL AND tCsCartera.Estado IS NULL 
				--                                                                      THEN 'TERMINADO' ELSE 'POR CALCULAR' END AS Vintage, tCsCartera.Fecha
				--                                               FROM          (SELECT     Datos.Desembolso, Datos.CodPrestamo, UPPER(SUBSTRING(Periodo.Descripcion, 1, 3)) + ' ' + CAST(Periodo.Año AS varchar(4)) 
				--                                                                                              AS Corte, Periodo.UltimoDia, Periodo.Periodo
				--                                                                       FROM          (SELECT     UPPER(SUBSTRING(tClPeriodo.Descripcion, 1, 3)) + ' ' + CAST(tClPeriodo.Año AS varchar(4)) AS Desembolso, 
				--                                                                                                                      Datos.CodPrestamo
				--                                                                                               FROM          (SELECT DISTINCT dbo.fduFechaATexto(Desembolso, 'AAAAMM') AS Periodo, CodPrestamo
				--                                                                                                                       FROM          tCsPadronCarteraDet with(nolock)
				--                                                                                                                       WHERE      CodPrestamo IN (Select Codprestamo from #Temporal)) Datos INNER JOIN
				--                                                                                                                      tClPeriodo ON Datos.Periodo COLLATE Modern_Spanish_CI_AS = tClPeriodo.Periodo) Datos CROSS JOIN
				--                                                                                                  (SELECT *
				--                                                                                                    FROM tClPeriodo
				--                                                                                                    WHERE Periodo = @Cadena AND (dbo.fduFechaATexto(UltimoDia, 'AAAAMM') >= @PI) AND (dbo.fduFechaATexto(UltimoDia, 
				--                                                                                                                           'AAAAMM') <= dbo.fduFechaATexto(DATEADD([year], 3, CAST(@PI + '01' AS smalldatetime)), 'AAAAMM'))) Periodo) 
				--                                                                      Datos LEFT OUTER JOIN
				--                                                                          (SELECT     CodPrestamo, MIN(PV) AS PV
				--                                                                            FROM          (SELECT DISTINCT dbo.fdufechaatexto(Fecha, 'AAAAMM') AS PV, CodPrestamo, NroDiasAtraso
				--                                                                                                    FROM          tCsCartera with(nolock)
				--                                                                                                    WHERE      (NroDiasAtraso = 90) AND (dbo.fduFechaATexto(FechaDesembolso, 'AAAAMM') = @PI) AND 
				--                                                                                                                           (dbo.fduFechaATexto(Fecha, 'AAAAMM') >= @PI)) Datos
				--                                                                            GROUP BY CodPrestamo) PV ON Datos.Periodo >= PV.PV AND Datos.CodPrestamo = PV.CodPrestamo LEFT OUTER JOIN
				--                                                                      tCsCartera with(nolock) ON CASE WHEN Periodo = @FG THEN @Proceso Else Datos.UltimoDia END  =tCsCartera.Fecha AND Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo) 
				--                                              Datos
				--                       WHERE (Periodo = @Cadena)
				--                       GROUP BY Desembolso, Periodo, Corte, Vintage, Fecha) Datos
				--GROUP BY Desembolso, Periodo, Corte
				
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

--select * from #Temporal
Drop Table #Temporal

UPDATE tCsVintage_Nuevo
SET Proceso = Datos.proceso
FROM (SELECT Datos.Ubicacion, Datos.Cartera, Datos.Periodo, MAX(tCsVintage_Nuevo.Proceso) AS Proceso
      FROM (SELECT DISTINCT Ubicacion, Cartera, Periodo
            FROM tCsVintage_Nuevo
            WHERE (Ubicacion = @PUbicacion) AND (Cartera = @PClaseCartera+' '+ @PRODUCTO) AND (Proceso IS NULL)) Datos 
            INNER JOIN tCsVintage_Nuevo ON Datos.Ubicacion COLLATE Modern_Spanish_CI_AI = tCsVintage_Nuevo.Ubicacion 
            AND Datos.Cartera COLLATE Modern_Spanish_CI_AI = tCsVintage_Nuevo.Cartera 
            AND Datos.Periodo COLLATE Modern_Spanish_CI_AI = tCsVintage_Nuevo.Periodo
            GROUP BY Datos.Ubicacion, Datos.Cartera, Datos.Periodo
            ) Datos 
            INNER JOIN tCsVintage_Nuevo ON Datos.Ubicacion COLLATE Modern_Spanish_CI_AI = tCsVintage_Nuevo.Ubicacion 
            AND Datos.Cartera COLLATE Modern_Spanish_CI_AI = tCsVintage_Nuevo.Cartera 
            AND Datos.Periodo COLLATE Modern_Spanish_CI_AI = tCsVintage_Nuevo.Periodo
WHERE     (tCsVintage_Nuevo.Proceso IS NULL)

If @Dato = 1
Begin
	SELECT  tCsVintage_Nuevo.Item, Ubicacion = @Ubicacion, Cartera = @ClaseCartera, tCsVintage_Nuevo.Desembolso, tCsVintage_Nuevo.Corte
	, tCsVintage_Nuevo.Total, tCsVintage_Nuevo.Buenos, tCsVintage_Nuevo.Malos, tCsVintage_Nuevo.Terminados, tCsVintage_Nuevo.Vencidos
	, tCsVintage_Nuevo.Ratio1, tCsVintage_Nuevo.Ratio2, tCsVintage_Nuevo.Proceso
	FROM (SELECT Ubicacion, Cartera, Desembolso, MAX(Item) AS Item
	      FROM tCsVintage_Nuevo with(nolock)
			  WHERE Ubicacion = @PUbicacion AND Cartera = @PClaseCartera
	      GROUP BY Ubicacion, Cartera, Desembolso) filtro INNER JOIN
	                      tCsVintage_Nuevo ON filtro.Item = tCsVintage_Nuevo.Item AND filtro.Ubicacion COLLATE Modern_Spanish_CI_AI = tCsVintage_Nuevo.Ubicacion AND 
	                      filtro.Cartera COLLATE Modern_Spanish_CI_AI = tCsVintage_Nuevo.Cartera AND filtro.Desembolso COLLATE Modern_Spanish_CI_AI = tCsVintage_Nuevo.Desembolso 
	                      INNER JOIN tClPeriodo ON tCsVintage_Nuevo.Desembolso COLLATE Modern_Spanish_CI_AS = UPPER(SUBSTRING(tClPeriodo.Descripcion, 1, 3)) + ' ' + CAST(tClPeriodo.Año AS varchar(4))
	WHERE     (tCsVintage_Nuevo.Periodo = @FG) 
	--ORDER BY tCsVintage.Item
	ORDER BY tClPeriodo.Periodo
End
If @Dato = 2
Begin
	SELECT Ubicacion = @Ubicacion, Cartera = @ClaseCartera, Año, SUM(MR101) AS MR101, SUM(MR102) AS MR102, SUM(MR103) AS MR103, SUM(MR104) AS MR104
	, SUM(MR105) AS MR105, SUM(MR106) AS MR106, SUM(MR107) AS MR107, SUM(MR108) AS MR108, SUM(MR109) AS MR109, SUM(MR110) AS MR110
	, SUM(MR111) AS MR111, SUM(MR112) AS MR112, SUM(MR113) AS MR113, SUM(MR114) AS MR114, SUM(MR115) AS MR115, SUM(MR116) AS MR116
	, SUM(MR117) AS MR117, SUM(MR118) AS MR118, SUM(MR119) AS MR119, SUM(MR120) AS MR120, SUM(MR121) AS MR121, SUM(MR122) AS MR122
	, SUM(MR123) AS MR123, SUM(MR124) AS MR124
	FROM (SELECT Ubicacion, Cartera, Año, CASE WHEN item = 1 THEN Mratio1 ELSE 0 END AS MR101, CASE WHEN item = 1 THEN Mratio1 ELSE 0 END AS MR102, 
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
	      FROM (SELECT Ubicacion, Cartera, tClPeriodo.Año, tCsVintage_Nuevo.Item, AVG(tCsVintage_Nuevo.Ratio1) AS MRatio1
	            FROM tCsVintage_Nuevo with(nolock) INNER JOIN
	            tClPeriodo ON tCsVintage_Nuevo.Desembolso COLLATE Modern_Spanish_CI_AS  = UPPER(SUBSTRING(tClPeriodo.Descripcion, 1, 3)) + ' ' + CAST(tClPeriodo.Año AS varchar(4))
	            WHERE      Ubicacion = @PUbicacion AND Cartera = @PClaseCartera +' '+ @PRODUCTO
	            GROUP BY Ubicacion, Cartera, tClPeriodo.Año, tCsVintage_Nuevo.Item) Datos) Datos
	GROUP BY Año, Ubicacion, Cartera
	Having 	Round(SUM(MR101) + SUM(MR102) + SUM(MR103) + SUM(MR104) + SUM(MR105) + SUM(MR106) + SUM(MR107) + SUM(MR108) + SUM(MR109) + SUM(MR110) + SUM(MR111) + SUM(MR112) +
		SUM(MR113) + SUM(MR114) + SUM(MR115) + SUM(MR116) + SUM(MR117) + SUM(MR118) + SUM(MR119) + SUM(MR120) + SUM(MR121) + SUM(MR122) + SUM(MR123) + SUM(MR124), 2) > 0
End
GO