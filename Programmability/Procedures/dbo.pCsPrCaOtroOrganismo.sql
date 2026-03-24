SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- DROP Procedure pCsPrCaOtroOrganismo

CREATE Procedure [dbo].[pCsPrCaOtroOrganismo]
@Fecha 			SmallDateTime,
@Indicador		Varchar(5),
@DI			Int,
@DF			Int,
@MI			Decimal(18,4),
@MF			Decimal(18,4),
@Valor 			Decimal(18,5) OUTPUT
As

Declare @ValorI			Decimal(18,5) 
Declare @Servidor		Varchar(50)
Declare @BaseDatos		Varchar(50)
Declare @Cadena			Varchar(4000)
Declare @Tabla			Varchar(50)
Declare @Temporal		Varchar(4000)
Declare @F				SmallDateTime

Declare @CodPrestamo	Varchar(25)
Declare @CtaCapital		Varchar(25)
Declare @CtaInteres		Varchar(25)
Declare @Tipo			Varchar(2)
Declare @Porcentaje		Decimal(18,10)	

Declare @Contador 		Int

Select @Contador = Count(*)
From tCsCaOtrosOrganismosValor
Where Fecha = @Fecha And IsNull(MtoCapital, 0) <> 0 And IsNull(MtoInteres, 0) <> 0

If @Contador is null Begin Set @Contador = 0 End

CREATE TABLE #AQQQQQ2 (	[Valor]	[decimal]	(18,4) 	NULL) 

If @Contador = 0
Begin

	Delete From tCsCaOtrosOrganismosValor
	Where Fecha = @Fecha

	SELECT     @Servidor = NombreIP, @BaseDatos = NombreBD
	FROM         tCsServidores
	WHERE     (Tipo = 2) AND (IdTextual = dbo.fduFechaATexto(@Fecha, 'AAAA'))

	CREATE TABLE #B ( [Cadena] [varchar] (1157) COLLATE Modern_Spanish_CI_AI NULL )
	
	Set @Cadena = 'NBTSTAT -a '+ Ltrim(rTrim(@Servidor))
	Insert Into #B
	Exec master..xp_cmdshell @Cadena
	
	SELECT   @Servidor =  RTRIM(LTRIM(SUBSTRING(LTRIM(RTRIM(Cadena)), 1, CHARINDEX('<00>', LTRIM(RTRIM(Cadena)), 1) - 1))) 
	FROM         #B
	WHERE     (Cadena LIKE '%<00>  UNIQUE%') OR (Cadena LIKE '%<00>  Único%')
	
	Drop Table #B

	Print @Servidor	
	Set @Servidor = '[' + @Servidor + '].'	
	
	Declare curFragmento3 Cursor For 
		SELECT     Datos_3.CodPrestamo, Datos_3.Tipo, REPLACE(Datos_3.CtaCapital, 'E', tClFondos.CCCapital) AS CtaCapital, Datos_3.CtaInteres, 
							  CASE WHEN Contador.Contador = 1 THEN 100 ELSE tCsCaOtrosOrganismos_1.Porcentaje END AS Porcentaje
		FROM         (SELECT     CtaCapital, COUNT(*) AS Contador
							   FROM          (SELECT     CodPrestamo, Tipo, REPLACE(CtaCapital, PComodin, Comodin) AS CtaCapital, CtaInteres
													   FROM          (SELECT     CodPrestamo, Tipo, Inicio, Fin, Monto, CtaCapital, CtaInteres, PComodin, PCComodin, PDiasCI, PDiasCF, PLComodin, PDiasLI, 
																									  PDiasLF, C, L, CASE WHEN c = 1 THEN pccomodin WHEN l = 1 THEN plcomodin END AS Comodin
																			   FROM          (SELECT     tCsCaOtrosOrganismos.CodPrestamo, tCsCaOtrosOrganismos.Tipo, tCsCaOtrosOrganismos.Inicio, 
																															  tCsCaOtrosOrganismos.Fin, tCsCaOtrosOrganismos.Monto, tCsCaClOtrosOrganismos.CtaCapital, 
																															  tCsCaClOtrosOrganismos.CtaInteres, tCsCaClOtrosOrganismos.PComodin, tCsCaClOtrosOrganismos.PCComodin, 
																															  tCsCaClOtrosOrganismos.PDiasCI, tCsCaClOtrosOrganismos.PDiasCF, tCsCaClOtrosOrganismos.PLComodin, 
																															  tCsCaClOtrosOrganismos.PDiasLI, tCsCaClOtrosOrganismos.PDiasLF, CASE WHEN DATEDIFF([day], @Fecha, Fin) 
																															  <= pdiascf AND DATEDIFF([day], @Fecha, Fin) >= pdiascI THEN 1 ELSE 0 END AS C, CASE WHEN DATEDIFF([day], 
																															  @Fecha, Fin) <= pdiasLf AND DATEDIFF([day], @Fecha, Fin) >= pdiasLI THEN 1 ELSE 0 END AS L
																									   FROM          tCsCaOtrosOrganismos INNER JOIN
																															  tCsCaClOtrosOrganismos ON tCsCaOtrosOrganismos.Tipo = tCsCaClOtrosOrganismos.Tipo) AS Datos_4) AS Datos_5) 
													  AS Datos
							   GROUP BY CtaCapital) AS Contador INNER JOIN
								  (SELECT     CodPrestamo, Tipo, REPLACE(CtaCapital, PComodin, Comodin) AS CtaCapital, CtaInteres
									FROM          (SELECT     CodPrestamo, Tipo, Inicio, Fin, Monto, CtaCapital, CtaInteres, PComodin, PCComodin, PDiasCI, PDiasCF, PLComodin, PDiasLI, PDiasLF, C, L, 
																				   CASE WHEN c = 1 THEN pccomodin WHEN l = 1 THEN plcomodin END AS Comodin
															FROM          (SELECT     tCsCaOtrosOrganismos_2.CodPrestamo, tCsCaOtrosOrganismos_2.Tipo, tCsCaOtrosOrganismos_2.Inicio, 
																										   tCsCaOtrosOrganismos_2.Fin, tCsCaOtrosOrganismos_2.Monto, tCsCaClOtrosOrganismos_1.CtaCapital, 
																										   tCsCaClOtrosOrganismos_1.CtaInteres, tCsCaClOtrosOrganismos_1.PComodin, tCsCaClOtrosOrganismos_1.PCComodin, 
																										   tCsCaClOtrosOrganismos_1.PDiasCI, tCsCaClOtrosOrganismos_1.PDiasCF, tCsCaClOtrosOrganismos_1.PLComodin, 
																										   tCsCaClOtrosOrganismos_1.PDiasLI, tCsCaClOtrosOrganismos_1.PDiasLF, CASE WHEN DATEDIFF([day], @Fecha, Fin) 
																										   <= pdiascf AND DATEDIFF([day], @Fecha, Fin) >= pdiascI THEN 1 ELSE 0 END AS C, CASE WHEN DATEDIFF([day], @Fecha, 
																										   Fin) <= pdiasLf AND DATEDIFF([day], @Fecha, Fin) >= pdiasLI THEN 1 ELSE 0 END AS L
																					FROM          tCsCaOtrosOrganismos AS tCsCaOtrosOrganismos_2 INNER JOIN
																										   tCsCaClOtrosOrganismos AS tCsCaClOtrosOrganismos_1 ON tCsCaOtrosOrganismos_2.Tipo = tCsCaClOtrosOrganismos_1.Tipo) 
																				   AS Datos_1) AS Datos_2) AS Datos_3 ON Contador.CtaCapital = Datos_3.CtaCapital INNER JOIN
							  tCsCaOtrosOrganismos AS tCsCaOtrosOrganismos_1 ON Datos_3.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCaOtrosOrganismos_1.CodPrestamo AND 
							  Datos_3.Tipo COLLATE Modern_Spanish_CI_AI = tCsCaOtrosOrganismos_1.Tipo INNER JOIN
							  tClFondos ON tCsCaOtrosOrganismos_1.CodFondo = tClFondos.CodFondo
	Open curFragmento3
	Fetch Next From curFragmento3 Into @CodPrestamo, @Tipo, @CtaCapital, @CtaInteres, @Porcentaje
	While @@Fetch_Status = 0
	Begin 
		Set @Valor		= 0
		Set @Porcentaje	= 100
		Insert Into tCsCaOtrosOrganismosValor (Fecha, CodPrestamo, Tipo, CtaCapital, CtaInteres, Porcentaje)
		Values(@Fecha, @CodPrestamo, @Tipo, @CtaCapital, @CtaInteres, @Porcentaje)

		--CODIGO PARA CAPITAL
		Set @Cadena = 'Exec ' + @Servidor +'['+ @BaseDatos +'].dbo.pCsCoCuentaContable ''' + dbo.fduFechaATexto(@Fecha,  'AAAAMMDD') + ''', '''+ @CtaCapital +''''
		Exec(@Cadena)
		Print @Cadena
		
		Set @Cadena = 'INSERT INTO #AQQQQQ2 (Valor) SELECT Isnull(SUM(KRptID_Tabla.Saldo), 0) AS Saldo '
		Set @Cadena = @Cadena + 'FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora '
		Set @Cadena = @Cadena + 'FROM ' + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla '
		Set @Cadena = @Cadena + 'WHERE (Parametro = '''+ @CtaCapital +''') AND (Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') '
		Set @Cadena = @Cadena + 'GROUP BY Fecha, Parametro) Datos INNER JOIN '
		Set @Cadena = @Cadena + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla ON Datos.Fecha = KRptID_Tabla.Fecha AND Datos.Parametro COLLATE Modern_Spanish_CI_AI = KRptID_Tabla.Parametro AND '
		Set @Cadena = @Cadena + 'Datos.Hora = KRptID_Tabla.Hora GROUP BY KRptID_Tabla.Fecha, KRptID_Tabla.Parametro '
			
		Print @Cadena
		Exec (@Cadena)
		
		Select @Valor = abs(Valor) * @Porcentaje/100
		From #AQQQQQ2

		Print 'CUENTA CONTABLE CAPITAL ' + Cast(@Valor as Varchar(40)) 
		
		--ANALIZAMOS Diferencia de decimales

		SELECT     @ValorI = SUM(Capital) 
		FROM         tCsCaOtrosOrganismosCuotas
		WHERE     CodPrestamo = @CodPrestamo And Tipo = @Tipo AND (Fecha > @Fecha)

		If @ValorI <> @Valor 
		Begin
			If Ceiling(@Valor) = @ValorI and Round(Ceiling(@Valor) -  @Valor, 1) <= 0.1
			Begin
				Set @Valor = @ValorI 
			End
		End	

		Update tCsCaOtrosOrganismosValor
		Set MtoCapital = @Valor 
		Where Fecha = @Fecha And CodPrestamo = @CodPrestamo And Tipo = @Tipo

		Delete From #AQQQQQ2
		
		--CODIGO PARA INTERES
		Set @Cadena = 'Exec ' + @Servidor +'['+ @BaseDatos +'].dbo.pCsCoCuentaContable ''' + dbo.fduFechaATexto(@Fecha,  'AAAAMMDD') + ''', '''+ @CtaInteres +''''
		Exec(@Cadena)
		Print @Cadena
		
		Set @Cadena = 'INSERT INTO #AQQQQQ2 (Valor) SELECT Isnull(SUM(KRptID_Tabla.Saldo), 0) AS Saldo '
		Set @Cadena = @Cadena + 'FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora '
		Set @Cadena = @Cadena + 'FROM ' + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla '
		Set @Cadena = @Cadena + 'WHERE (Parametro = '''+ @CtaInteres +''') AND (Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') '
		Set @Cadena = @Cadena + 'GROUP BY Fecha, Parametro) Datos INNER JOIN '
		Set @Cadena = @Cadena + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla ON Datos.Fecha = KRptID_Tabla.Fecha AND Datos.Parametro COLLATE Modern_Spanish_CI_AI = KRptID_Tabla.Parametro AND '
		Set @Cadena = @Cadena + 'Datos.Hora = KRptID_Tabla.Hora GROUP BY KRptID_Tabla.Fecha, KRptID_Tabla.Parametro '
			
		Print @Cadena
		Exec (@Cadena)
		
		Select @Valor = abs(Valor)
		From #AQQQQQ2

		Print 'CUENTA CONTABLE INTERES ' + Cast(@Valor as Varchar(40)) 

		Update tCsCaOtrosOrganismosValor
		Set MtoInteres = @Valor * @Porcentaje/100
		Where Fecha = @Fecha And CodPrestamo = @CodPrestamo And Tipo = @Tipo

		Delete From #AQQQQQ2

	Fetch Next From curFragmento3 Into @CodPrestamo, @Tipo, @CtaCapital, @CtaInteres, @Porcentaje
	End 
	Close 		curFragmento3
	Deallocate 	curFragmento3

	UPDATE    tCsCaOtrosOrganismos
	SET              Porcentaje = Porcentaje.porcentaje
	FROM         (SELECT     Detalle.CodPrestamo, Detalle.Tipo, Detalle.CodFondo, CAST(Detalle.Capital / Total.Capital AS Decimal(30, 15)) * 100 AS PorCentaje
						   FROM          (SELECT     tCsCaOtrosOrganismosCuotas.Tipo, tCsCaOtrosOrganismos.CodFondo, CAST(SUM(tCsCaOtrosOrganismosCuotas.Capital) AS Decimal(30, 15)) 
																		  AS Capital, tCsCaOtrosOrganismosValor.CtaCapital
												   FROM          tCsCaOtrosOrganismosCuotas INNER JOIN
																		  tCsCaOtrosOrganismos ON tCsCaOtrosOrganismosCuotas.Tipo = tCsCaOtrosOrganismos.Tipo AND 
																		  tCsCaOtrosOrganismosCuotas.CodPrestamo = tCsCaOtrosOrganismos.CodPrestamo INNER JOIN
																		  tCsCaOtrosOrganismosValor ON tCsCaOtrosOrganismos.Tipo = tCsCaOtrosOrganismosValor.Tipo AND 
																		  tCsCaOtrosOrganismos.CodPrestamo = tCsCaOtrosOrganismosValor.CodPrestamo
												   WHERE      (tCsCaOtrosOrganismosCuotas.Fecha > @Fecha) AND (tCsCaOtrosOrganismosValor.Fecha = @Fecha)
												   GROUP BY tCsCaOtrosOrganismosCuotas.Tipo, tCsCaOtrosOrganismos.CodFondo, tCsCaOtrosOrganismosValor.CtaCapital) AS Total INNER JOIN
													  (SELECT     tCsCaOtrosOrganismosCuotas_1.CodPrestamo, tCsCaOtrosOrganismosCuotas_1.Tipo, tCsCaOtrosOrganismos_1.CodFondo, 
																			   CAST(SUM(tCsCaOtrosOrganismosCuotas_1.Capital) AS Decimal(30, 15)) AS Capital, tCsCaOtrosOrganismosValor_1.CtaCapital
														FROM          tCsCaOtrosOrganismosCuotas AS tCsCaOtrosOrganismosCuotas_1 INNER JOIN
																			   tCsCaOtrosOrganismos AS tCsCaOtrosOrganismos_1 ON tCsCaOtrosOrganismosCuotas_1.Tipo = tCsCaOtrosOrganismos_1.Tipo AND 
																			   tCsCaOtrosOrganismosCuotas_1.CodPrestamo = tCsCaOtrosOrganismos_1.CodPrestamo INNER JOIN
																			   tCsCaOtrosOrganismosValor AS tCsCaOtrosOrganismosValor_1 ON 
																			   tCsCaOtrosOrganismos_1.CodPrestamo = tCsCaOtrosOrganismosValor_1.CodPrestamo AND 
																			   tCsCaOtrosOrganismos_1.Tipo = tCsCaOtrosOrganismosValor_1.Tipo
														WHERE      (tCsCaOtrosOrganismosCuotas_1.Fecha > @Fecha) AND (tCsCaOtrosOrganismosValor_1.Fecha = @Fecha)
														GROUP BY tCsCaOtrosOrganismosCuotas_1.CodPrestamo, tCsCaOtrosOrganismosCuotas_1.Tipo, tCsCaOtrosOrganismos_1.CodFondo, 
																			   tCsCaOtrosOrganismosValor_1.CtaCapital) AS Detalle ON Total.Tipo = Detalle.Tipo AND Total.CodFondo = Detalle.CodFondo AND 
												  Total.CtaCapital = Detalle.CtaCapital) AS Porcentaje INNER JOIN
						  tCsCaOtrosOrganismos ON Porcentaje.CodPrestamo = tCsCaOtrosOrganismos.CodPrestamo AND Porcentaje.Tipo = tCsCaOtrosOrganismos.Tipo	

	UPDATE	tCsCaOtrosOrganismosValor
	SET		Porcentaje = tCsCaOtrosOrganismos.Porcentaje
	FROM    tCsCaOtrosOrganismos INNER JOIN
			tCsCaOtrosOrganismosValor ON tCsCaOtrosOrganismos.CodPrestamo = tCsCaOtrosOrganismosValor.CodPrestamo AND 
			tCsCaOtrosOrganismos.Tipo = tCsCaOtrosOrganismosValor.Tipo
	WHERE   (tCsCaOtrosOrganismosValor.Fecha = @Fecha)

	UPDATE	tCsCaOtrosOrganismosValor
	SET		MtoCapital	= MtoCapital * Porcentaje/100.0000,
			MtoInteres	= MtoInteres * Porcentaje/100.0000  
	WHERE   (tCsCaOtrosOrganismosValor.Fecha = @Fecha)
	
	UPDATE    tCsCaOtrosOrganismosValor
	SET              Porcentaje = 0, Mtointeres = 0
	FROM         (SELECT     Fecha, CtaInteres, Mtointeres, COUNT(*) AS Contador
	                       FROM          tCsCaOtrosOrganismosValor
	                       WHERE      (Fecha = @Fecha)
	                       GROUP BY Fecha, CtaInteres, mtointeres) Filtro INNER JOIN
	                      tCsCaOtrosOrganismosValor ON Filtro.Fecha = tCsCaOtrosOrganismosValor.Fecha AND Filtro.CtaInteres = tCsCaOtrosOrganismosValor.CtaInteres
	WHERE     (tCsCaOtrosOrganismosValor.Porcentaje = 100) AND (tCsCaOtrosOrganismosValor.MtoCapital = 0)

End
Set @Temporal = 'SELECT tCsCaOtrosOrganismos.CodPrestamo, tCsCaOtrosOrganismos.Tipo, DATEDIFF([day], tCsCaOtrosOrganismosValor.Fecha, '
Set @Temporal = @Temporal + 'tCsCaOtrosOrganismos.Fin) AS L, DATEDIFF([day], tCsCaOtrosOrganismos.Inicio, tCsCaOtrosOrganismos.Fin) AS N, MtoCapital as C, '
Set @Temporal = @Temporal + 'MtoInteres as I, tCsUDIS.UDI, MtoCapital / tCsUDIS.UDI As U '
Set @Temporal = @Temporal + 'FROM tCsCaOtrosOrganismosValor INNER JOIN '
Set @Temporal = @Temporal + 'tCsCaOtrosOrganismos ON tCsCaOtrosOrganismosValor.CodPrestamo = tCsCaOtrosOrganismos.CodPrestamo AND '
Set @Temporal = @Temporal + 'tCsCaOtrosOrganismosValor.Tipo = tCsCaOtrosOrganismos.Tipo INNER JOIN '
Set @Temporal = @Temporal + 'tCsUDIS ON tCsCaOtrosOrganismosValor.Fecha = tCsUDIS.Fecha '

Set @Temporal = @Temporal + 'WHERE (tCsCaOtrosOrganismosValor.Tipo = '''+ Substring(@Indicador, 3, 2) +''') AND (tCsCaOtrosOrganismosValor.Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''')'

If Substring(@Indicador, 5, 1) = 'S'
Begin
Set @Cadena = 'INSERT INTO #AQQQQQ2 (Valor) SELECT SUM('+ Substring(@Indicador, 2, 1) +') AS Saldo FROM ('+ @Temporal +') Datos WHERE ('+ Substring(@Indicador, 1, 1) +' >= '+ Cast(@DI as Varchar(10)) +') AND ('+ Substring(@Indicador, 1, 1) +' <= '+ Cast(@DF as Varchar(10)) +') AND '+ Substring(@Indicador, 2, 1) +' >= '+ Cast(@MI as Varchar(20)) +' AND '+ Substring(@Indicador, 2, 1) +' <= '+ Cast(@MF as Varchar(20)) +' '
End
If Substring(@Indicador, 5, 1) = 'C'
Begin
Set @Cadena = 'INSERT INTO #AQQQQQ2 (Valor) SELECT COUNT(*) AS Valor FROM (SELECT DISTINCT CodPrestamo FROM ('+ @Temporal +') Datos WHERE ('+ Substring(@Indicador, 1, 1) +' >= '+ Cast(@DI as Varchar(10)) +') AND ('+ Substring(@Indicador, 1, 1) +' <= '+ Cast(@DF as Varchar(10)) +') AND '+ Substring(@Indicador, 2, 1) +' >= '+ Cast(@MI as Varchar(20)) +' AND '+ Substring(@Indicador, 2, 1) +' <= '+ Cast(@MF as Varchar(20)) +') Datos '
End

Print @Cadena
Exec (@Cadena)

Select @Valor = abs(Valor)
From #AQQQQQ2

If @Valor Is Null Begin Set @Valor = 0 End 

DROP TABLE #AQQQQQ2
GO