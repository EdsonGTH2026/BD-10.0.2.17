SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROCEDURE pCsPrRXXAXX11
--Exec pCsPrRXXAXX11 '20110531', 'REDECAR', 'C1', 'S'
CREATE Procedure [dbo].[pCsPrRXXAXX11]
	@Fecha 			SmallDateTime,
	@Reporte		Varchar(10),
	@Cuadro			Varchar(2),
	@Generar		Varchar(1)
As
Declare @Contador 	Decimal(13, 0)
Declare @Cadena 	Varchar(4000)
Declare @Cadena1 	Varchar(4000)
Declare @Cadena2 	Varchar(4000)
Declare @Cadena3 	Varchar(4000)
Declare @Cadena4 	Varchar(4000)
Declare @Cadena5 	Varchar(4000)
Declare @Cadena6 	Varchar(4000)
Declare @Cadena7 	Varchar(4000)
Declare @Cadena8 	Varchar(4000)
Declare @Cadena9 	Varchar(4000)
Declare @Cadena10 	Varchar(4000)
Declare @Cadena11 	Varchar(4000)
Declare @Cadena12 	Varchar(4000)

Declare @F			SmallDateTime 
Declare @BTemp		Int
Declare @Valor		Decimal(18, 8)

Select @F = FechaConsolidacion
From vCsFechaConsolidacion

Set @F = CAST(dbo.fduFechaATexto(DATEADD([day], - 1, CAST(dbo.fduFechaATexto(@F, 'AAAAMM') + '01' AS SmallDateTime)), 'AAAAMM') + '01' AS SmallDateTime)

If @Fecha < @F
Begin
	SELECT @Contador = COUNT(*) 
	FROM      tCsPrRegulatorios
	WHERE     (Reporte = @Reporte) AND (Fecha = @Fecha)

	If @Contador Is null Begin Set @Contador = 0 End
	
	If @Contador = 0 	Begin Set @Generar = 'S' End 
	Else			Begin Set @Generar = 'N' End
End

Print @Generar

If @Generar = 'S' 
Begin
	Select @BTemp = Count(*)
	From (SELECT DISTINCT Reporte
		FROM         tCsPrReportesAnexos
		WHERE     (Procedimiento = 'pCsPrCaOtroOrganismo')
		Union
	Select 'REDECAR' as Reporte) Datos
	Where Reporte = @Reporte

	If @BTemp Is null Begin Set @BTemp = 0 end

	If @BTemp <> 0
	Begin
		Print '@BTemp es diferente de 0'
		Delete From tCsCaOtrosOrganismosValor
		Where Fecha = @Fecha
		
		Exec pCsPrCaOtroOrganismo @Fecha, 'LC01S', 0, 365, 0, 9999999, @Valor Out
	End
End

If @Generar = 'S'  And @Reporte <> 'R08B0821'
Begin 
	Select @Contador = Count(*)
	From tCsDiaGarantias Where Fecha = @Fecha

	If @Contador is null begin set @Contador = 0 end	

	If @Contador = 0
	Begin
		Exec pCsDiaGarantias @Fecha
	End
	If @Reporte = 'BCONOPE'
	Begin
		Print 'Se ejecuta pCsPrRegulatorios1'
		Exec pCsPrRegulatorios1 @Fecha , @Reporte
	End
	Else
	Begin
		Print 'Se ejecuta pCsPrRegulatorios'
		Exec pCsPrRegulatorios @Fecha , @Reporte
	End
End
If @Reporte = 'R21A2111'
Begin
	SELECT     *, 'N' AS Generar
	FROM         tCsPrRegulatorios
	WHERE     (SUBSTRING(DescIdentificador, 1, 2) = @Cuadro) AND (Fecha = @Fecha) AND (Reporte = @Reporte)
End
If @Reporte = 'R04A0411'
Begin
	SELECT     Uno.Fecha, Uno.Reporte, Uno.Descripcion, Uno.Identificador, Uno.DescIdentificador, Uno.Nivel, Uno.OtroDato, Uno.SaldoCapital, Dos.SaldoIntereses, 
                      Tres.SaldoTotal, Cuatro.InteresMes, Cinco.ComisionMes, Uno.Nombre, Columna1, Columna2, Columna3, Columna4, Columna5 
	FROM         (SELECT      tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) AS Identificador, 
                      tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, tCsPrRegulatorios.OtroDato, 
                                              Saldo AS SaldoCapital, tCsPrReporte.Nombre, 
		                      Columna.Columna as Columna1
		FROM         tCsPrRegulatorios with(nolock) INNER JOIN
		                      tCsPrReporte with(nolock) ON tCsPrRegulatorios.Reporte = tCsPrReporte.Reporte INNER JOIN
		                          (SELECT     Reporte, Columna
		                            FROM         tCsPrRegulatorios with(nolock)
		                            WHERE   (Fecha = @Fecha) AND (Reporte = @Reporte) AND (Nivel = 1) AND identificador = 1) Columna ON 
		                      tCsPrRegulatorios.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI
	                       WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (Fecha = @Fecha) AND (Identificador LIKE '1%')) Uno INNER JOIN
	                          (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) AS Identificador, 
                      tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, Saldo AS SaldoIntereses, tCsPrReporte.Nombre, 
		                      Columna.Columna as Columna2
		FROM         tCsPrRegulatorios with(nolock) INNER JOIN
		                      tCsPrReporte with(nolock) ON tCsPrRegulatorios.Reporte = tCsPrReporte.Reporte INNER JOIN
		                          (SELECT     Reporte, Columna
		                            FROM          tCsPrRegulatorios with(nolock)
		                            WHERE      (Fecha = @Fecha) AND (Reporte = @Reporte) AND (Nivel = 1) AND identificador = 2) Columna ON 
		                      tCsPrRegulatorios.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI
	                            WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (Fecha = @Fecha) AND (Identificador LIKE '2%')) Dos ON Uno.Fecha = Dos.Fecha AND 
	                      Uno.Reporte = Dos.Reporte AND Uno.Identificador = Dos.Identificador INNER JOIN
	                          (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) AS Identificador, 
                      tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, Saldo AS SaldoTotal, tCsPrReporte.Nombre, 
		                      Columna.Columna as Columna3
		FROM         tCsPrRegulatorios with(nolock) INNER JOIN
		                      tCsPrReporte with(nolock) ON tCsPrRegulatorios.Reporte = tCsPrReporte.Reporte INNER JOIN
		                          (SELECT     Reporte, Columna
		                            FROM          tCsPrRegulatorios with(nolock)
		                            WHERE    (Fecha = @Fecha) AND (Reporte = @Reporte) AND (Nivel = 1) AND identificador = 3) Columna ON 
		                      tCsPrRegulatorios.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI
	                            WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (Fecha = @Fecha) AND (Identificador LIKE '3%')) Tres ON Uno.Fecha = Tres.Fecha AND 
	                      Uno.Reporte = Tres.Reporte AND Uno.Identificador = Tres.Identificador INNER JOIN
	                          (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) AS Identificador, 
                      tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, Saldo AS InteresMes, tCsPrReporte.Nombre, 
		                      Columna.Columna as Columna4
		FROM         tCsPrRegulatorios with(nolock) INNER JOIN
		                      tCsPrReporte with(nolock) ON tCsPrRegulatorios.Reporte = tCsPrReporte.Reporte INNER JOIN
		                          (SELECT     Reporte, Columna
		                            FROM          tCsPrRegulatorios with(nolock)
		                            WHERE   (Fecha = @Fecha) AND (Fecha = @Fecha) AND  (Reporte = @Reporte) AND (Nivel = 1) AND identificador = 4) Columna ON 
		                      tCsPrRegulatorios.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI
	                            WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (Fecha = @Fecha) AND (Identificador LIKE '4%')) Cuatro ON Uno.Fecha = Cuatro.Fecha AND 
	                      Uno.Reporte = Cuatro.Reporte AND Uno.Identificador = Cuatro.Identificador INNER JOIN
	                          (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) AS Identificador, 
                      tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, Saldo AS ComisionMes, tCsPrReporte.Nombre, 
		                      Columna.Columna as Columna5
		FROM         tCsPrRegulatorios with(nolock) INNER JOIN
		                      tCsPrReporte with(nolock) ON tCsPrRegulatorios.Reporte = tCsPrReporte.Reporte INNER JOIN
		                          (SELECT     Reporte, Columna
		                            FROM          tCsPrRegulatorios with(nolock)
		                            WHERE     (Fecha = @Fecha) AND (Reporte = @Reporte) AND (Nivel = 1) AND identificador = 5) Columna ON 
		                      tCsPrRegulatorios.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI
	                            WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (Fecha = @Fecha) AND (Identificador LIKE '5%')) Cinco ON Uno.Fecha = Cinco.Fecha AND 
	                      Uno.Reporte = Cinco.Reporte AND Uno.Identificador = Cinco.Identificador
End
If @Reporte = 'R04B0417'
Begin
	SELECT     SaldoCartera.Fecha, SaldoCartera.Reporte, SaldoCartera.Descripcion, SaldoCartera.Identificador, SaldoCartera.DescIdentificador, SaldoCartera.Nivel, 
	                      SaldoCartera.OtroDato, SaldoCartera.SaldoCartera, Estimacion.Estimacion, SUBSTRING(SaldoCartera.Identificador, 1, 3) AS Grupo, tCsPrReporte.Nombre, 
	                      tCsPrReporte.Descripcion AS DReporte, CS, CE
	FROM         (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion + ISNULL(' ' + tCsPrRegulatorios.Comentario, '') AS Descripcion, 
	                                              tCsPrRegulatorios.Identificador, tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, tCsPrRegulatorios.OtroDato, 
	                                              tCsPrRegulatorios.Saldo * CAST(tCsPrReportesAnexos.Signo + ' 1 ' AS Int) AS SaldoCartera, CS = tCsPrRegulatorios.Columna
	                       FROM          tCsPrRegulatorios INNER JOIN
	                                              tCsPrReportesAnexos ON tCsPrRegulatorios.Reporte = tCsPrReportesAnexos.Reporte AND 
	                                              tCsPrRegulatorios.Identificador = tCsPrReportesAnexos.Identificador AND tCsPrRegulatorios.Agrupado = tCsPrReportesAnexos.Agrupado
	                       WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (tCsPrRegulatorios.Fecha = @Fecha) AND (SUBSTRING(tCsPrRegulatorios.Identificador, 1, 1) <= 3)) 
	                      SaldoCartera INNER JOIN
	                          (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion + ISNULL(' ' + tCsPrRegulatorios.Comentario, '') AS Descripcion, 
	                                                   tCsPrRegulatorios.Identificador, tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, tCsPrRegulatorios.OtroDato, 
	                                                   tCsPrRegulatorios.Saldo * CAST(tCsPrReportesAnexos.Signo + ' 1 ' AS Int) AS Estimacion, CE = tCsPrRegulatorios.Columna
	                            FROM          tCsPrRegulatorios INNER JOIN
	                                                   tCsPrReportesAnexos ON tCsPrRegulatorios.Reporte = tCsPrReportesAnexos.Reporte AND 
	                                                   tCsPrRegulatorios.Identificador = tCsPrReportesAnexos.Identificador AND tCsPrRegulatorios.Agrupado = tCsPrReportesAnexos.Agrupado
	                            WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (tCsPrRegulatorios.Fecha = @Fecha) AND (SUBSTRING(tCsPrRegulatorios.Identificador, 1, 1) >= 4)) 
	                      Estimacion ON SaldoCartera.Fecha = Estimacion.Fecha AND SaldoCartera.Reporte = Estimacion.Reporte AND SUBSTRING(SaldoCartera.Identificador, 2, 100) 
	                      = SUBSTRING(Estimacion.Identificador, 2, 100) AND SaldoCartera.Descripcion = Estimacion.Descripcion INNER JOIN
	                      tCsPrReporte ON SaldoCartera.Reporte COLLATE Modern_Spanish_CI_AI = tCsPrReporte.Reporte
End
If @Reporte = 'R08A0811'
Begin
	SELECT     Uno.Fecha, Uno.Reporte, Uno.Descripcion + ISNULL(' ' + Uno.Comentario, '') AS Descripcion, Uno.Identificador, Uno.DescIdentificador, Uno.Nivel, Uno.OtroDato, 
	                      Uno.SaldoCapital, Dos.SaldoIntereses, Tres.SaldoTotal, Cuatro.InteresMes, Cinco.ComisionMes, Uno.Comentario, Uno.Nombre, Uno.DReporte, Uno.C1, Dos.C2, 
	                      Tres.C3, Cuatro.C4, Cinco.C5
	FROM         (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) AS Identificador, 
	                                              tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, tCsPrRegulatorios.OtroDato, tCsPrRegulatorios.Saldo AS SaldoCapital, 
	                                              tCsPrRegulatorios.Comentario, tCsPrReporte.Nombre, tCsPrReporte.Descripcion AS DReporte, Columna.Columna AS C1
	                       FROM          tCsPrRegulatorios INNER JOIN
	                                              tCsPrReporte ON tCsPrRegulatorios.Reporte = tCsPrReporte.Reporte INNER JOIN
	                                                  (SELECT     Reporte, Columna
	                                                    FROM          tCsPrRegulatorios
	                                                    WHERE      Fecha = @Fecha AND (Reporte = @Reporte) AND (Nivel = 1) AND (Identificador = 1)) Columna ON 
	                                              tCsPrRegulatorios.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI
	                       WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (tCsPrRegulatorios.Fecha = @Fecha) AND (tCsPrRegulatorios.Identificador LIKE '1%')) Uno INNER JOIN
	                          (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) 
	                                                   AS Identificador, tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, tCsPrRegulatorios.OtroDato, tCsPrRegulatorios.Saldo AS SaldoIntereses, 
	                                                   tCsPrRegulatorios.Comentario, tCsPrReporte.Nombre, tCsPrReporte.Descripcion AS DReporte, Columna.Columna AS C2
	                            FROM          tCsPrRegulatorios INNER JOIN
	                                                   tCsPrReporte ON tCsPrRegulatorios.Reporte = tCsPrReporte.Reporte INNER JOIN
	                                                       (SELECT     Reporte, Columna
	                                                         FROM          tCsPrRegulatorios
	                                                         WHERE      Fecha = @Fecha AND (Reporte = @Reporte) AND (Nivel = 1) AND (Identificador = 2)) Columna ON 
	                                                   tCsPrRegulatorios.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI
	                            WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (tCsPrRegulatorios.Fecha = @Fecha) AND (tCsPrRegulatorios.Identificador LIKE '2%')) Dos ON 
	                      Uno.Fecha = Dos.Fecha AND Uno.Reporte = Dos.Reporte AND Uno.Identificador = Dos.Identificador INNER JOIN
	                          (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) 
	                                                   AS Identificador, tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, tCsPrRegulatorios.OtroDato, tCsPrRegulatorios.Saldo AS SaldoTotal, 
	                                                   tCsPrRegulatorios.Comentario, tCsPrReporte.Nombre, tCsPrReporte.Descripcion AS DReporte, Columna.Columna AS C3
	                            FROM          tCsPrRegulatorios INNER JOIN
	                                                   tCsPrReporte ON tCsPrRegulatorios.Reporte = tCsPrReporte.Reporte INNER JOIN
	                                                       (SELECT     Reporte, Columna
	                                                         FROM          tCsPrRegulatorios
	                                                         WHERE      Fecha = @Fecha AND (Reporte = @Reporte) AND (Nivel = 1) AND (Identificador = 3)) Columna ON 
	                                                   tCsPrRegulatorios.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI
	                            WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (tCsPrRegulatorios.Fecha = @Fecha) AND (tCsPrRegulatorios.Identificador LIKE '3%')) Tres ON 
	                      Uno.Fecha = Tres.Fecha AND Uno.Reporte = Tres.Reporte AND Uno.Identificador = Tres.Identificador INNER JOIN
	                          (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) 
	                                                   AS Identificador, tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, tCsPrRegulatorios.OtroDato, tCsPrRegulatorios.Saldo AS InteresMes, 
	                                                   tCsPrRegulatorios.Comentario, tCsPrReporte.Nombre, tCsPrReporte.Descripcion AS DReporte, Columna.Columna AS C4
	                            FROM          tCsPrRegulatorios INNER JOIN
	                                                   tCsPrReporte ON tCsPrRegulatorios.Reporte = tCsPrReporte.Reporte INNER JOIN
	                                                       (SELECT     Reporte, Columna
	                                                         FROM          tCsPrRegulatorios
	                                                         WHERE      Fecha = @Fecha AND (Reporte = @Reporte) AND (Nivel = 1) AND (Identificador = 4)) Columna ON 
	                                                   tCsPrRegulatorios.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI
	                            WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (tCsPrRegulatorios.Fecha = @Fecha) AND (tCsPrRegulatorios.Identificador LIKE '4%')) Cuatro ON 
	                      Uno.Fecha = Cuatro.Fecha AND Uno.Reporte = Cuatro.Reporte AND Uno.Identificador = Cuatro.Identificador INNER JOIN
	                          (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) 
	                                                   AS Identificador, tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Nivel, tCsPrRegulatorios.OtroDato, tCsPrRegulatorios.Saldo AS ComisionMes, 
	                                                   tCsPrRegulatorios.Comentario, tCsPrReporte.Nombre, tCsPrReporte.Descripcion AS DReporte, Columna.Columna AS C5
	                            FROM          tCsPrRegulatorios INNER JOIN
	                                                   tCsPrReporte ON tCsPrRegulatorios.Reporte = tCsPrReporte.Reporte INNER JOIN
	                                                       (SELECT     Reporte, Columna
	                                                         FROM          tCsPrRegulatorios
	                                                         WHERE      Fecha = @Fecha AND (Reporte = @Reporte) AND (Nivel = 1) AND (Identificador = 5)) Columna ON 
	                                                   tCsPrRegulatorios.Reporte = Columna.Reporte COLLATE Modern_Spanish_CI_AI
	                            WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (tCsPrRegulatorios.Fecha = @Fecha) AND (tCsPrRegulatorios.Identificador LIKE '5%')) Cinco ON 
	                      Uno.Fecha = Cinco.Fecha AND Uno.Reporte = Cinco.Reporte AND Uno.Identificador = Cinco.Identificador
End
If @Reporte = 'R08A0815'
Begin
	SELECT DISTINCT 
	                      Uno.Fecha, Uno.Reporte, Uno.OtroDato, Uno.Identificador, Uno.Campo, Uno.Nivel, Uno.Saldo, Dos.Cuentas, Uno.C1, Dos.C2, tCsPrReporte.Nombre, 
	                      tCsPrReporte.Descripcion
	FROM         (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.OtroDato, SUBSTRING(tCsPrRegulatorios.Identificador, 2, 100) AS Identificador, 
	                                              tCsPrRegulatorios.Descripcion + ISNULL(' ' + tCsPrRegulatorios.Comentario, '') AS Campo, tCsPrRegulatorios.Nivel, 
	                                              CASE WHEN substring(tCsPrRegulatorios.Identificador, 1, 1) = '2' THEN tCsPrRegulatorios.Saldo * Udi ELSE tCsPrRegulatorios.Saldo END AS Saldo, 
	                                              Columna AS C1
	                       FROM          tCsPrRegulatorios INNER JOIN
	                                              tCsUDIS ON tCsPrRegulatorios.Fecha = tCsUDIS.Fecha
	                       WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (tCsPrRegulatorios.Fecha = @Fecha) AND (tCsPrRegulatorios.Nivel = '1') AND 
	                                              (tCsPrRegulatorios.Identificador LIKE '1%' OR
	                                              tCsPrRegulatorios.Identificador LIKE '2%')) Uno INNER JOIN
	                          (SELECT     Fecha, Reporte, OtroDato, SUBSTRING(Identificador, 2, 100) AS Identificador, Descripcion + ISNULL(' ' + Comentario, '') AS Campo, Nivel, 
	                                                   Saldo AS Cuentas, Columna AS C2
	                            FROM          tCsPrRegulatorios
	                            WHERE      (Reporte = @Reporte) AND (Fecha = @Fecha) AND (Nivel = 1) AND (Identificador LIKE '3%' OR
	                                                   Identificador LIKE '4%')) Dos ON Uno.Reporte = Dos.Reporte AND Uno.Fecha = Dos.Fecha AND Uno.Identificador = Dos.Identificador AND 
	                      Uno.Campo = Dos.Campo INNER JOIN
	                      tCsPrReporte ON Uno.Reporte COLLATE Modern_Spanish_CI_AI = tCsPrReporte.Reporte
End
If @Reporte = 'DATESTA'
Begin
	SELECT     Fecha, Reporte, Descripcion, Identificador, DescIdentificador, Agrupado, Nivel, Comentario, DetComentario, CASE WHEN Otrodato IS NOT NULL 
	                      THEN Otrodato ELSE Saldo END AS Saldo, OtroDato, Generacion
	FROM         (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Descripcion, tCsPrRegulatorios.Identificador, 
	                                              tCsPrRegulatorios.DescIdentificador, tCsPrRegulatorios.Agrupado, tCsPrRegulatorios.Nivel, tCsPrRegulatorios.Comentario, 
	                                              tCsPrRegulatorios.DetComentario, dbo.fduNumeroTexto(tCsPrRegulatorios.Saldo, tCsPrReportesAnexos.Redondeo) AS Saldo, 
	                                              tCsPrRegulatorios.OtroDato, tCsPrRegulatorios.Generacion
	                       FROM          tCsPrRegulatorios INNER JOIN
	                                              tCsPrReportesAnexos ON tCsPrRegulatorios.Reporte = tCsPrReportesAnexos.Reporte AND 
	                                              tCsPrRegulatorios.Identificador = tCsPrReportesAnexos.Identificador AND 
	                                              tCsPrRegulatorios.Agrupado = tCsPrReportesAnexos.Agrupado AND tCsPrRegulatorios.Nivel = tCsPrReportesAnexos.Nivel
	                       WHERE      (tCsPrRegulatorios.Reporte = @Reporte) AND (tCsPrRegulatorios.Nivel = 1) AND (tCsPrRegulatorios.Fecha = @Fecha)) Datos
	ORDER BY CAST(Identificador AS int)
End
If @Reporte = 'R08B0821'
Begin
	SELECT     Fecha, dbo.fduFechaATexto(Fecha, 'AAAAMM') AS Periodo, '' AS ClaveFederacion, ClaveEntidad, NivelEntidad, CuentaContable, Localidad, COUNT(Cuenta) AS NroCuentas, 
	                      SUM(Saldo) AS Saldo
	FROM         (SELECT     tahproductos.idtipoprod, tCsAhorros.CodOficina, tCsAhorros.Fecha, tClEmpresas.CASFIM AS ClaveEntidad, Nivel AS NivelEntidad, 
	                                              tAhClTipoProducto.CuentaContable, tCPLugar.SITI AS Localidad, 
	                                              tCsAhorros.CodCuenta + '-' + tCsAhorros.FraccionCta + '-' + CAST(tCsAhorros.Renovado AS Varchar(5)) AS Cuenta, 
	                                              tCsAhorros.SaldoCuenta + tCsAhorros.IntAcumulado AS Saldo
	                       FROM          tClEmpresas CROSS JOIN
	                                              tAhProductos LEFT OUTER JOIN
	                                              tAhClTipoProducto ON tAhProductos.idTipoProd = tAhClTipoProducto.idTipoProd RIGHT OUTER JOIN
	                                              tCsAhorros ON tAhProductos.idProducto = tCsAhorros.CodProducto LEFT OUTER JOIN
	                                              tClOficinas INNER JOIN
	                                              tClUbigeo ON tClOficinas.CodUbiGeo = tClUbigeo.CodUbiGeo INNER JOIN
	                                              tCPLugar ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND 
	                                              tClUbigeo.CodEstado = tCPLugar.CodEstado ON tCsAhorros.CodOficina = tClOficinas.CodOficina
	                       WHERE      (tCsAhorros.Fecha = @Fecha) AND (tClEmpresas.CodEmpresa = 1) AND (tCsAhorros.idEstadoCta NOT IN ('CC'))) Datos
	GROUP BY Fecha, ClaveEntidad, NivelEntidad, CuentaContable, Localidad, idtipoprod, CodOficina
End
If @Reporte = 'REDECAR'
Begin
	
	Set @Cadena = 'SELECT Regulatorio.CodFondo, Regulatorio.Recursos, Regulatorio.DescFondo, Regulatorio.Inicio, Regulatorio.Fin, Regulatorio.Monto, '
	Set @Cadena = @Cadena  + 'Regulatorio.MtoCapital, Regulatorio.FondoCartera, Regulatorio.TasaInteres, Regulatorio.Garantia, Regulatorio.Garantizado, '
	Set @Cadena = @Cadena  + 'Regulatorio.Contrato + '' '' + CAST(Regulatorio.Nrocontrato AS Varchar(10)) AS Contrato, ''PAGARÉ '' + dbo.fduRellena(''0'', '
	Set @Cadena = @Cadena  + 'Regulatorio.NroPagare, 2, ''D'')  AS Pagare, tCsCaOtrosOrganismosCuotas.CodPrestamo, tCsCaOtrosOrganismosCuotas.Tipo, '
	Set @Cadena = @Cadena  + 'tCsCaOtrosOrganismosCuotas.NroCuota, tCsCaOtrosOrganismosCuotas.Fecha, tCsCaOtrosOrganismosCuotas.Capital, Regulatorio.CtaCapital '
	Set @Cadena = @Cadena  + 'FROM (SELECT tCsCaOtrosOrganismos.NroPagare, tCsCaOtrosOrganismos.Nrocontrato, tClFondos.CodFondo, tClFondos.Contrato, '
	Set @Cadena = @Cadena  + 'tCsCaOtrosOrganismosValor.Codprestamo, tCsCaOtrosOrganismosValor.Tipo, tCsCaOtrosOrganismos.Recursos, tClFondos.DescFondo, '
	Set @Cadena = @Cadena  + 'tCsCaOtrosOrganismos.Inicio, tCsCaOtrosOrganismos.Fin, tCsCaOtrosOrganismos.Monto, tCsCaOtrosOrganismosValor.MtoCapital, '
	Set @Cadena = @Cadena  + 'Cartera.FondosCartera * tCsCaOtrosOrganismosValor.Porcentaje / 100 AS FondoCartera, tCsCaOtrosOrganismos.TasaInteres, '
	Set @Cadena = @Cadena  + 'tCsCaOtrosOrganismos.Garantia, CAST(100 -  tClFondos.R21Porcentaje AS varchar(10)) + ''%'' AS Garantizado, tCsCaOtrosOrganismosValor.CtaCapital '
	Set @Cadena = @Cadena  + 'FROM tCsCaOtrosOrganismosValor INNER JOIN '
	Set @Cadena = @Cadena  + 'tCsCaOtrosOrganismos ON tCsCaOtrosOrganismosValor.CodPrestamo = tCsCaOtrosOrganismos.CodPrestamo INNER JOIN '
	Set @Cadena = @Cadena  + 'tClFondos ON tCsCaOtrosOrganismos.CodFondo = tClFondos.CodFondo INNER JOIN '
	Set @Cadena = @Cadena  + '(SELECT tCsCartera.Fecha, tCsCartera.CodFondo, '
	Set @Cadena = @Cadena  + 'SUM(tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido) '
	Set @Cadena = @Cadena  + 'AS FondosCartera '
	Set @Cadena = @Cadena  + 'FROM tCsCartera INNER JOIN '
	Set @Cadena = @Cadena  + 'tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo '
	Set @Cadena = @Cadena  + 'WHERE (tCsCartera.Cartera = ''ACTIVA'') AND (tCsCartera.Fecha = '''+ dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') +''') '
	Set @Cadena = @Cadena  + 'GROUP BY tCsCartera.Fecha, tCsCartera.CodFondo) Cartera ON tCsCaOtrosOrganismosValor.Fecha = Cartera.Fecha AND '
	Set @Cadena = @Cadena  + 'tClFondos.CodEntero = Cartera.CodFondo '
	Set @Cadena = @Cadena  + 'WHERE (tCsCaOtrosOrganismosValor.Fecha = ''' + dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') + ''')) Regulatorio INNER JOIN '
	Set @Cadena = @Cadena  + 'tCsCaOtrosOrganismosCuotas ON Regulatorio.Codprestamo COLLATE Modern_Spanish_CI_AI = tCsCaOtrosOrganismosCuotas.CodPrestamo AND '
	Set @Cadena = @Cadena  + 'Regulatorio.Tipo COLLATE Modern_Spanish_CI_AI = tCsCaOtrosOrganismosCuotas.Tipo '
	Set @Cadena = @Cadena  + 'WHERE (tCsCaOtrosOrganismosCuotas.Fecha > ''' + dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') + ''') AND (Regulatorio.Inicio <= ''' + dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') + ''')'
	
	Print @Cadena	
	
	If @Cuadro = 'C1'
	Begin
		Set @Cadena1 = 'SELECT CodPrestamo, CodFondo, Recursos, DescFondo, Inicio, Fin, Monto, Sum(Capital) as Operativo, MtoCapital As Contable, FondoCartera, TasaInteres, Garantia, Garantizado, CtaCapital FROM (' + @Cadena + ') Datos Group BY CodPrestamo, CodFondo, Recursos, DescFondo, Inicio, Fin, Monto, MtoCapital, FondoCartera, TasaInteres, Garantia, Garantizado, CtaCapital Having Sum(Capital) > 0'
 		Exec (@Cadena1)
	End
	If @Cuadro = 'C2'
	Begin
		Exec (@Cadena)
	End	
	
End
If @Reporte = 'BCONOPE'
Begin
	If @Fecha < '20100101' 	Begin Set @Cuadro = '1' End

	If @Cuadro In ('0', '2', '9') 	-- Diferencias, Centro de Costos y Todas
	Begin
		Set @Cadena9 = 'SELECT Fecha, SUBSTRING(Identificador, 2, 2) As CodOficina , OtroDato AS Cuenta, RTRIM(LTRIM(Descripcion)) AS Descripcion, Nivel, Saldo AS '
		Set @Cadena7 = 'SELECT Fecha, ''00'' As CodOficina , OtroDato AS Cuenta, RTRIM(LTRIM(Descripcion)) AS Descripcion, Nivel, Saldo AS '
		Set @Cadena6 = '(Columna = ''1'') AND '
		Set @Cadena10	= @Cadena6
		If @Cuadro In ('2', '9')	-- Centro de Costos y Todas
		Begin
			Set @Cadena6 	= ''
			
		End		
	End
	If @Cuadro = '1'		-- Resumen General
	Begin
		Set @Cadena9 	= 'SELECT Fecha, ''00'' As CodOficina , OtroDato AS Cuenta, RTRIM(LTRIM(Descripcion)) AS Descripcion, Nivel, Saldo AS '
		Set @Cadena7  	= ''
		Set @Cadena6 	= ''
	End
	----------------------------------------------------------------------------------------
	--Para Saldos Contables 	-- @Cadena1 : Calculo Individual  
					-- @Cadena2 : Calculo Total
					-- @Cadena11: Calculo Total
	----------------------------------------------------------------------------------------
	Set @Cadena8 	= 'C1'
	Set @Cadena5 	= 'Contabilidad'
	Set @Cadena1 	= @Cadena9 + @Cadena5 + ' '
	Set @Cadena1 	= @Cadena1 + 'FROM tCsPrRegulatorios '
	Set @Cadena1 	= @Cadena1 + 'WHERE ' + @Cadena6 + '(Reporte = '''+ @Reporte +''') AND (dbo.fduFechaAtexto(Fecha, ''AAAAMMDD'') = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (SUBSTRING(DescIdentificador, 1, 2) = '''+ @Cadena8 +''')'
	If @Cuadro 	= '1'
	Begin
		Set @Cadena1 = 'SELECT Fecha, CodOficina, Cuenta, Descripcion, SUM(' + @Cadena5 + ') AS ' + @Cadena5 + ', Nivel FROM (' + @Cadena1 + ') Datos GROUP BY Fecha, CodOficina, Cuenta, Descripcion, Nivel '
	End
	Set @Cadena1 = '(' + @Cadena1 + ') ' + @Cadena5
	If @Cuadro = '9'		-- Se trabaja para Resumen General y Diferencias
	Begin
		-- Para Resumen General
		Set @Cadena2 = @Cadena7 + @Cadena5 + ' '
		Set @Cadena2 = @Cadena2 + 'FROM tCsPrRegulatorios '
		Set @Cadena2 = @Cadena2 + 'WHERE (Reporte = '''+ @Reporte +''') AND (dbo.fduFechaAtexto(Fecha, ''AAAAMMDD'') = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (SUBSTRING(DescIdentificador, 1, 2) = '''+ @Cadena8 +''')'
		Set @Cadena2 = 'SELECT Fecha, CodOficina, Cuenta, Descripcion, SUM(' + @Cadena5 + ') AS ' + @Cadena5 + ', Nivel FROM (' + @Cadena2 + ') Datos GROUP BY Fecha, CodOficina, Cuenta, Descripcion, Nivel '
		Set @Cadena2 = '(' + @Cadena2 + ') ' + @Cadena5		

		-- Para Diferencias
		Set @Cadena11 = @Cadena9  + @Cadena5 + ' '
		Set @Cadena11 = @Cadena11 + 'FROM tCsPrRegulatorios '
		Set @Cadena11 = @Cadena11 + 'WHERE ' + @Cadena10 + '(Reporte = '''+ @Reporte +''') AND (dbo.fduFechaAtexto(Fecha, ''AAAAMMDD'') = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (SUBSTRING(DescIdentificador, 1, 2) = '''+ @Cadena8 +''')'
		Set @Cadena11 = '(' + @Cadena11 + ') ' + @Cadena5
	End
	Else
	Begin
		Set @Cadena2 	= ''
		Set @Cadena11	= ''
	End
	----------------------------------------------------------------------------------------
	--Para Saldos Operativos 	-- @Cadena3 : Calculo Individual  
					-- @Cadena4 : Calculo Total
					-- @Cadena12: Calculo Total
	----------------------------------------------------------------------------------------
	Set @Cadena8 	= 'C2'
	Set @Cadena5 	= 'Operativo'
	Set @Cadena3 	= @Cadena9 + @Cadena5 + ' '
	Set @Cadena3 	= @Cadena3 + 'FROM tCsPrRegulatorios '
	Set @Cadena3 	= @Cadena3 + 'WHERE ' + @Cadena6 + '(Reporte = '''+ @Reporte +''') AND (dbo.fduFechaAtexto(Fecha, ''AAAAMMDD'') = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (SUBSTRING(DescIdentificador, 1, 2) = '''+ @Cadena8 +''')'
	If @Cuadro 	= '1'
	Begin
		Set @Cadena3 = 'SELECT Fecha, CodOficina, Cuenta, Descripcion, SUM(' + @Cadena5 + ') AS ' + @Cadena5 + ', Nivel FROM (' + @Cadena3 + ') Datos GROUP BY Fecha, CodOficina, Cuenta, Descripcion, Nivel '
	End
	Set @Cadena3 = '(' + @Cadena3 + ') ' + @Cadena5
	If @Cuadro = '9'		-- Se trabaja para Resumen General y Diferencias
	Begin
		-- Para Resumen General
		Set @Cadena4 = @Cadena7 + @Cadena5 + ' '
		Set @Cadena4 = @Cadena4 + 'FROM tCsPrRegulatorios '
		Set @Cadena4 = @Cadena4 + 'WHERE (Reporte = '''+ @Reporte +''') AND (dbo.fduFechaAtexto(Fecha, ''AAAAMMDD'') = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (SUBSTRING(DescIdentificador, 1, 2) = '''+ @Cadena8 +''')'
		Set @Cadena4 = 'SELECT Fecha, CodOficina, Cuenta, Descripcion, SUM(' + @Cadena5 + ') AS ' + @Cadena5 + ', Nivel FROM (' + @Cadena4 + ') Datos GROUP BY Fecha, CodOficina, Cuenta, Descripcion, Nivel '
		Set @Cadena4 = '(' + @Cadena4 + ') ' + @Cadena5

		-- Para Diferencias
		Set @Cadena12 = @Cadena9 + @Cadena5 + ' '
		Set @Cadena12 = @Cadena12 + 'FROM tCsPrRegulatorios '
		Set @Cadena12 = @Cadena12 + 'WHERE ' + @Cadena10 + '(Reporte = '''+ @Reporte +''') AND (dbo.fduFechaAtexto(Fecha, ''AAAAMMDD'') = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (SUBSTRING(DescIdentificador, 1, 2) = '''+ @Cadena8 +''')'
		Set @Cadena12 = '(' + @Cadena12 + ') ' + @Cadena5
	End
	Else
	Begin
		Set @Cadena4 	= ''
		Set @Cadena12	= ''
	End
	-- Calculamos Detalle y Union de Contable y Operativo	(@Cadena10: Datos)
	Set @Cadena10 = '(SELECT ISNULL(Contabilidad.Fecha, Operativo.Fecha) AS Fecha, ISNULL(Contabilidad.CodOficina, Operativo.CodOficina) AS '
	Set @Cadena10 = @Cadena10 + 'CodOficina, ISNULL(Contabilidad.Cuenta, Operativo.Cuenta) AS Cuenta, ISNULL(Contabilidad.Descripcion, '
	Set @Cadena10 = @Cadena10 + 'Operativo.Descripcion) AS Descripcion, ISNULL(Contabilidad.Contabilidad, 0) AS Contabilidad, '
	Set @Cadena10 = @Cadena10 + 'ISNULL(Operativo.Operativo, 0) AS Operativo, Nivel = Isnull(Contabilidad.Nivel, Operativo.Nivel) '
	Set @Cadena10 = @Cadena10 + 'FROM '+ @Cadena1 +' FULL OUTER JOIN '+ @Cadena3 +' ON Contabilidad.CodOficina = Operativo.CodOficina AND Contabilidad.Cuenta = Operativo.Cuenta) Datos'
	
	-- Calculos Finales:
	If @Cuadro In ('0', '2', '9')	-- Diferencias, Centros de Costos y Todos
	Begin
		--Principal
		Set @Cadena9 = 'SELECT Datos.Fecha, Datos.CodOficina, Datos.Cuenta, Datos.Descripcion, Datos.Contabilidad, Datos.Operativo, '
		Set @Cadena9 = @Cadena9 + 'Datos.Contabilidad - Datos.Operativo AS Diferencia, tClOficinas.NomOficina, Datos.Nivel, Orden = ''002'' FROM '
		Set @Cadena9 = @Cadena9 + @Cadena10 + ' INNER JOIN tClOficinas ON CAST(Datos.CodOficina AS int) = CAST(tClOficinas.CodOficina AS Int) '
		Set @Cadena1 = ''
		Set @Cadena5 = ''
	End
	If @Cuadro = '0'		-- Diferencias
	Begin		
		-- Filtro
		Set @Cadena8 = '(SELECT Fecha, CodOficina, NomOficina, Diferencia, MAX(Nivel) AS Nivel FROM ('
		Set @Cadena8 = @Cadena8 + @Cadena9 + ') Datos WHERE (ABS(Diferencia) > 0) GROUP BY Fecha, CodOficina, NomOficina, Diferencia) Filtro '
		-- Final
		Set @Cadena7 = 'SELECT Datos.Fecha, Datos.Cuenta AS CodOficina, Filtro.CodOficina AS Cuenta, Filtro.NomOficina AS Descripcion, '
		Set @Cadena7 = @Cadena7 + 'Datos.Contabilidad, Datos.Operativo, Filtro.Diferencia, Datos.Descripcion AS NomOficina, Filtro.Nivel, Orden = ''000'' FROM '
		Set @Cadena7 = @Cadena7 + @Cadena8 + ' INNER JOIN (' + @Cadena9 + ') Datos ON Filtro.Fecha = Datos.Fecha AND Filtro.CodOficina = '
		Set @Cadena7 = @Cadena7 + 'Datos.CodOficina AND Filtro.NomOficina = Datos.NomOficina AND Filtro.Diferencia = Datos.Diferencia AND Filtro.Nivel = '
		Set @Cadena7 = @Cadena7 + 'Datos.Nivel '
		Set @Cadena1 = ''
		Set @Cadena5 = ''
	End
	If @Cuadro = '1'		-- Resumen General
	Begin
		Set @Cadena7 = 'SELECT Fecha, CodOficina, Cuenta, Descripcion, Contabilidad, Operativo, Contabilidad - Operativo AS Diferencia, '
		Set @Cadena7 = @Cadena7 + '''RESUMEN GENERAL'' AS NomOficina, Nivel, Orden = ''001'' FROM ' + @Cadena10
		Set @Cadena1 = ''
		Set @Cadena5 = ''
	End
	If @Cuadro In ('2', '9')	-- Centros de Costos y Todos
	Begin
		Set @Cadena7 = @Cadena9
		Set @Cadena1 = ''
		Set @Cadena5 = ''
	End
	If @Cuadro = '9'		-- Todos
	Begin
		-- Trabajamos Calculando Resumen General
		Set @Cadena10 = '(SELECT ISNULL(Contabilidad.Fecha, Operativo.Fecha) AS Fecha, ISNULL(Contabilidad.CodOficina, Operativo.CodOficina) AS '
		Set @Cadena10 = @Cadena10 + 'CodOficina, ISNULL(Contabilidad.Cuenta, Operativo.Cuenta) AS Cuenta, ISNULL(Contabilidad.Descripcion, '
		Set @Cadena10 = @Cadena10 + 'Operativo.Descripcion) AS Descripcion, ISNULL(Contabilidad.Contabilidad, 0) AS Contabilidad, '
		Set @Cadena10 = @Cadena10 + 'ISNULL(Operativo.Operativo, 0) AS Operativo, Nivel = Isnull(Contabilidad.Nivel, Operativo.Nivel) '
		Set @Cadena10 = @Cadena10 + 'FROM '+ @Cadena2 +' FULL OUTER JOIN '+ @Cadena4 +' ON Contabilidad.CodOficina = Operativo.CodOficina AND Contabilidad.Cuenta = Operativo.Cuenta) Datos'

		Set @Cadena5 = ' UNION SELECT Fecha, CodOficina, Cuenta, Descripcion, Contabilidad, Operativo, Contabilidad - Operativo AS Diferencia, '
		Set @Cadena5 = @Cadena5 + '''RESUMEN GENERAL'' AS NomOficina, Nivel, Orden = ''001'' FROM ' + @Cadena10
		Set @Cadena1 = ''
		
		-- Trabajamos Calculando Diferencias
		Set @Cadena10 = '(SELECT ISNULL(Contabilidad.Fecha, Operativo.Fecha) AS Fecha, ISNULL(Contabilidad.CodOficina, Operativo.CodOficina) AS '
		Set @Cadena10 = @Cadena10 + 'CodOficina, ISNULL(Contabilidad.Cuenta, Operativo.Cuenta) AS Cuenta, ISNULL(Contabilidad.Descripcion, '
		Set @Cadena10 = @Cadena10 + 'Operativo.Descripcion) AS Descripcion, ISNULL(Contabilidad.Contabilidad, 0) AS Contabilidad, '
		Set @Cadena10 = @Cadena10 + 'ISNULL(Operativo.Operativo, 0) AS Operativo, Nivel = Isnull(Contabilidad.Nivel, Operativo.Nivel) '
		Set @Cadena10 = @Cadena10 + 'FROM '+ @Cadena11 +' FULL OUTER JOIN '+ @Cadena12 +' ON Contabilidad.CodOficina = Operativo.CodOficina AND Contabilidad.Cuenta = Operativo.Cuenta) Datos'

		Set @Cadena9 = 'SELECT Datos.Fecha, Datos.CodOficina, Datos.Cuenta, Datos.Descripcion, Datos.Contabilidad, Datos.Operativo, '
		Set @Cadena9 = @Cadena9 + 'Datos.Contabilidad - Datos.Operativo AS Diferencia, tClOficinas.NomOficina, Datos.Nivel FROM '
		Set @Cadena9 = @Cadena9 + @Cadena10 + ' INNER JOIN tClOficinas ON CAST(Datos.CodOficina AS int) = CAST(tClOficinas.CodOficina AS Int) '

		-- Filtro
		Set @Cadena8 = '(SELECT Fecha, CodOficina, NomOficina, Diferencia, MAX(Nivel) AS Nivel FROM ('
		Set @Cadena8 = @Cadena8 + @Cadena9 + ') Datos WHERE (ABS(Diferencia) > 0) GROUP BY Fecha, CodOficina, NomOficina, Diferencia) Filtro '
		-- Final
		Set @Cadena1 = ' UNION SELECT Datos.Fecha, Datos.Cuenta AS CodOficina, Filtro.CodOficina AS Cuenta, Filtro.NomOficina AS Descripcion, '
		Set @Cadena1 = @Cadena1 + 'Datos.Contabilidad, Datos.Operativo, Filtro.Diferencia, Datos.Descripcion AS NomOficina, Filtro.Nivel, Orden = ''000'' FROM '
		Set @Cadena1 = @Cadena1 + @Cadena8 + ' INNER JOIN (' + @Cadena9 + ') Datos ON Filtro.Fecha = Datos.Fecha AND Filtro.CodOficina = '
		Set @Cadena1 = @Cadena1 + 'Datos.CodOficina AND Filtro.NomOficina = Datos.NomOficina AND Filtro.Diferencia = Datos.Diferencia AND Filtro.Nivel = '
		Set @Cadena1 = @Cadena1 + 'Datos.Nivel '
		
	End
	Set @Cadena6 = 'Select * From ('
	Set @Cadena3 =  ') Datos'
	Print @Cadena6 + @Cadena7 + @Cadena5 + @Cadena1 + @Cadena3
	Exec (@Cadena6 + @Cadena7 + @Cadena5 + @Cadena1 + @Cadena3)	
End
If @Reporte = 'ANEXOC'
Begin
SELECT     *
FROM         (SELECT     Orden = 1, REporte, Fecha, LEFT(DescIdentificador, 2) AS Cuadro, 'Vencidos' AS Campo, '> ' + LTRIM(RTRIM(STR(Saldo, 5, 0))) + ' días de vencidos' AS Dato,
                                               Saldo1 = 0, Saldo2 = 0, Saldo3 = 0, Saldo4 = 0, Saldo5 = 0
                       FROM          tCsPrRegulatorios
                       WHERE      (Reporte = 'ANEXOC') AND LEFT(DescIdentificador, 2) = 'C1'
                       UNION
                       SELECT     Orden = 2, Reporte, Fecha, LEFT(DescIdentificador, 2) AS Cuadro, 'Vigentes' AS Campo, '<= ' + LTRIM(RTRIM(STR(Saldo, 5, 0))) 
                                             + ' días de vencidos' AS Dato, Saldo1 = 0, Saldo2 = 0, Saldo3 = 0, Saldo4 = 0, Saldo5 = 0
                       FROM         tCsPrRegulatorios
                       WHERE     (Reporte = 'ANEXOC') AND LEFT(DescIdentificador, 2) = 'C1'
                       UNION
                       SELECT     Orden = 1, Reporte, Fecha, Cuadro = 'C2', Campo = 'Activos', Dato = 'no saldados', Saldo1 = 0, Saldo2 = 0, Saldo3 = 0, Saldo4 = 0, Saldo5 = 0
                       FROM         tCsPrRegulatorios
                       WHERE     (Reporte = 'ANEXOC') AND LEFT(DescIdentificador, 2) = 'C1'
                       UNION
                       SELECT     Orden = 2, Reporte, Fecha, Cuadro = 'C2', Campo = 'Vencidos', Dato = 'con vencimientos > ' + LTRIM(RTRIM(STR(Saldo, 5, 0))) + ' días', Saldo1 = 0, 
                                             Saldo2 = 0, Saldo3 = 0, Saldo4 = 0, Saldo5 = 0
                       FROM         tCsPrRegulatorios
                       WHERE     (Reporte = 'ANEXOC') AND LEFT(DescIdentificador, 2) = 'C1'
                       UNION
                       SELECT     Orden = 3, Reporte, Fecha, Cuadro = 'C2', Campo = 'Vigentes', Dato = 'sin vencimientos o vencimientos <=  ' + LTRIM(RTRIM(STR(Saldo, 5, 0))) + ' días', 
                                             Saldo1 = 0, Saldo2 = 0, Saldo3 = 0, Saldo4 = 0, Saldo5 = 0
                       FROM         tCsPrRegulatorios
                       WHERE     (Reporte = 'ANEXOC') AND LEFT(DescIdentificador, 2) = 'C1'
		       UNION
		       SELECT     MAX(Orden) AS Orden, Reporte, Fecha, Cuadro, Campo, Dato, SUM(Saldo1) AS Saldo1, SUM(Saldo2) AS Saldo2, SUM(Saldo3) AS Saldo3, SUM(Saldo4) AS Saldo4, 
			                      SUM(Saldo5) AS Saldo5
			FROM         (SELECT     CAST(tCsPrRegulatorios.Identificador AS Int) AS Orden, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Fecha, LEFT(tCsPrRegulatorios.DescIdentificador, 2) 
			                                              AS Cuadro, REPLACE(tCsPrRegulatorios.Descripcion, 'XX', Fondo.NemFondo) AS Campo, '' AS Dato, 
			                                              CASE Agrupado WHEN 'I' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo1, 
			                                              CASE Agrupado WHEN 'S' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo2, 0 AS Saldo3, 0 AS Saldo4, 0 AS Saldo5
			                       FROM          tCsPrRegulatorios INNER JOIN
			                                                  (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Saldo, tClFondos.NemFondo
			                                                    FROM          tCsPrRegulatorios INNER JOIN
			                                                                           tClFondos ON tCsPrRegulatorios.Saldo = tClFondos.CodEntero
			                                                    WHERE      (tCsPrRegulatorios.Reporte = 'ANEXOC') AND (tCsPrRegulatorios.Agrupado = 'X')) Fondo ON tCsPrRegulatorios.Fecha = Fondo.Fecha AND 
			                                              tCsPrRegulatorios.Reporte = Fondo.Reporte COLLATE Modern_Spanish_CI_AI
			                       WHERE      (tCsPrRegulatorios.Reporte = 'ANEXOC') AND (LEFT(tCsPrRegulatorios.DescIdentificador, 2) = 'C3')) Datos
			GROUP BY Reporte, Fecha, Cuadro, Campo, Dato
			UNION
			SELECT     MAX(Orden) AS Orden, Reporte, Fecha, Cuadro, Campo, Dato, SUM(Saldo1) AS Saldo1, SUM(Saldo2) AS Saldo2, SUM(Saldo3) AS Saldo3, SUM(Saldo4) AS Saldo4, 
			                      SUM(Saldo5) AS Saldo5
			FROM         (SELECT     CAST(tCsPrRegulatorios.Identificador AS Int) AS Orden, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Fecha, LEFT(tCsPrRegulatorios.DescIdentificador, 2) 
			                                              AS Cuadro, REPLACE(tCsPrRegulatorios.Descripcion, 'XX', Fondo.NemFondo) AS Campo, Fondo.NemFondo AS Dato, 
			                                              CASE Agrupado WHEN 'FI' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo1, 
			                                              CASE Agrupado WHEN 'OI' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo2, 
			                                              CASE Agrupado WHEN 'FS' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo3, 
			                                              CASE Agrupado WHEN 'OS' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo4, 0 AS Saldo5
			                       FROM          tCsPrRegulatorios INNER JOIN
			                                                  (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Saldo, tClFondos.NemFondo
			                                                    FROM          tCsPrRegulatorios INNER JOIN
			                                                                           tClFondos ON tCsPrRegulatorios.Saldo = tClFondos.CodEntero
			                                                    WHERE      (tCsPrRegulatorios.Reporte = 'ANEXOC') AND (tCsPrRegulatorios.Agrupado = 'X')) Fondo ON tCsPrRegulatorios.Fecha = Fondo.Fecha AND 
			                                              tCsPrRegulatorios.Reporte = Fondo.Reporte COLLATE Modern_Spanish_CI_AI
			                       WHERE      (tCsPrRegulatorios.Reporte = 'ANEXOC') AND (LEFT(tCsPrRegulatorios.DescIdentificador, 2) = 'C4')) Datos
			GROUP BY Reporte, Fecha, Cuadro, Campo, Dato
			UNION
			SELECT     MAX(Orden) AS Orden, Reporte, Fecha, Cuadro, Campo, Dato, SUM(Saldo1) AS Saldo1, SUM(Saldo2) AS Saldo2, SUM(Saldo3) AS Saldo3, SUM(Saldo4) AS Saldo4, 
                      			SUM(Saldo5) AS Saldo5
			FROM         (SELECT     CAST(tCsPrRegulatorios.Identificador AS Int) AS Orden, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Fecha, LEFT(tCsPrRegulatorios.DescIdentificador, 2) 
			                                              AS Cuadro, REPLACE(tCsPrRegulatorios.Descripcion, 'XX', Fondo.NemFondo) AS Campo, Fondo.NemFondo AS Dato, 
			                                              CASE Agrupado WHEN 'IC' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo1, 
			                                              CASE Agrupado WHEN 'IM' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo2, 
			                                              CASE Agrupado WHEN 'SG' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo3, 
			                                              CASE Agrupado WHEN 'SC' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo4, 
			                                              CASE Agrupado WHEN 'SM' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo5
			                       FROM          tCsPrRegulatorios INNER JOIN
			                                                  (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Saldo, tClFondos.NemFondo
			                                                    FROM          tCsPrRegulatorios INNER JOIN
			                                                                           tClFondos ON tCsPrRegulatorios.Saldo = tClFondos.CodEntero
			                                                    WHERE      (tCsPrRegulatorios.Reporte = 'ANEXOC') AND (tCsPrRegulatorios.Agrupado = 'X')) Fondo ON tCsPrRegulatorios.Fecha = Fondo.Fecha AND 
			                                              tCsPrRegulatorios.Reporte = Fondo.Reporte COLLATE Modern_Spanish_CI_AI
			                       WHERE      (tCsPrRegulatorios.Reporte = 'ANEXOC') AND (LEFT(tCsPrRegulatorios.DescIdentificador, 2) = 'C5')) Datos
			GROUP BY Reporte, Fecha, Cuadro, Campo, Dato
			UNION
			SELECT     1 AS Orden, Reporte, Fecha, LEFT(DescIdentificador, 2) AS Cuadro, Descripcion, '' AS Dato, Saldo AS Saldo1, 0 AS Saldo2, 0 AS Saldo3, 0 AS Saldo4, 0 AS Saldo5
			FROM         tCsPrRegulatorios
			WHERE     (Reporte = 'ANEXOC') AND (LEFT(DescIdentificador, 2) = 'C6')
			UNION
			SELECT     MAX(Orden) AS Orden, Reporte, Fecha, Cuadro, Campo, Dato, SUM(Saldo1) AS Saldo1, SUM(Saldo2) AS Saldo2, SUM(Saldo3) AS Saldo3, SUM(Saldo4) AS Saldo4, 
			                      SUM(Saldo5) AS Saldo5
			FROM         (SELECT     CAST(tCsPrRegulatorios.Identificador AS Int) AS Orden, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Fecha, LEFT(tCsPrRegulatorios.DescIdentificador, 2) 
			                                              AS Cuadro, REPLACE(tCsPrRegulatorios.Descripcion, 'XX', Fondo.NemFondo) AS Campo, Fondo.NemFondo AS Dato, 
			                                              CASE Agrupado WHEN 'FE' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo1, 
			                                              CASE Agrupado WHEN 'FI' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo2, 
			                                              CASE Agrupado WHEN 'OE' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo3, 
			                                              CASE Agrupado WHEN 'OI' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo4, 0 AS Saldo5
			                       FROM          tCsPrRegulatorios INNER JOIN
			                                                  (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Saldo, tClFondos.NemFondo
			                                                    FROM          tCsPrRegulatorios INNER JOIN
			                                                                           tClFondos ON tCsPrRegulatorios.Saldo = tClFondos.CodEntero
			                                                    WHERE      (tCsPrRegulatorios.Reporte = 'ANEXOC') AND (tCsPrRegulatorios.Agrupado = 'X')) Fondo ON tCsPrRegulatorios.Fecha = Fondo.Fecha AND 
			                                              tCsPrRegulatorios.Reporte = Fondo.Reporte COLLATE Modern_Spanish_CI_AI
			                       WHERE      (tCsPrRegulatorios.Reporte = 'ANEXOC') AND (LEFT(tCsPrRegulatorios.DescIdentificador, 2) = 'C7')) Datos
			GROUP BY Reporte, Fecha, Cuadro, Campo, Dato
			UNION
			SELECT     MAX(Orden) AS Orden, Reporte, Fecha, Cuadro, Campo, CASE WHEN SUM(Saldo1) = SUM(Saldo2) THEN 'Ok' ELSE 'No Ok' END AS Dato, SUM(Saldo1) AS Saldo1, 
			                      SUM(Saldo2) AS Saldo2, SUM(Saldo3) AS Saldo3, SUM(Saldo4) AS Saldo4, SUM(Saldo5) AS Saldo5
			FROM         (SELECT     CAST(tCsPrRegulatorios.Identificador AS Int) AS Orden, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Fecha, LEFT(tCsPrRegulatorios.DescIdentificador, 2) 
			                                              AS Cuadro, REPLACE(tCsPrRegulatorios.Descripcion, 'XX', Fondo.NemFondo) AS Campo, Fondo.NemFondo AS Dato, 
			                                              CASE Agrupado WHEN 'C2' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo1, 
			                                              CASE Agrupado WHEN 'C4' THEN tCsPrRegulatorios.Saldo ELSE 0 END AS Saldo2, 0 AS Saldo3, 0 AS Saldo4, 0 AS Saldo5
			                       FROM          tCsPrRegulatorios INNER JOIN
			                                                  (SELECT     tCsPrRegulatorios.Fecha, tCsPrRegulatorios.Reporte, tCsPrRegulatorios.Saldo, tClFondos.NemFondo
			                                                    FROM          tCsPrRegulatorios INNER JOIN
			                                                                           tClFondos ON tCsPrRegulatorios.Saldo = tClFondos.CodEntero
			                                                    WHERE      (tCsPrRegulatorios.Reporte = 'ANEXOC') AND (tCsPrRegulatorios.Agrupado = 'X')) Fondo ON tCsPrRegulatorios.Fecha = Fondo.Fecha AND 
			                                              tCsPrRegulatorios.Reporte = Fondo.Reporte COLLATE Modern_Spanish_CI_AI
			                       WHERE      (tCsPrRegulatorios.Reporte = 'ANEXOC') AND (LEFT(tCsPrRegulatorios.DescIdentificador, 2) = 'C8') AND Nivel = 1) Datos
			GROUP BY Reporte, Fecha, Cuadro, Campo) Datos
	Where Cuadro = @Cuadro And Fecha = @Fecha
End
If @Reporte = 'INCFIN'
Begin
	SELECT     Fecha, Entidad, ClaseCredito, EstadoSITI, MunicipioSITI, COUNT(*) AS NroCreditos, SUM(SaldoCartera) AS SaldoCartera
	FROM         (SELECT     tCsCartera.Fecha, tClEmpresas.DescEmpresa AS Entidad, tCaProdPerTipoCredito.Descripcion AS ClaseCredito, vGnlUbigeo.EstadoSITI, 
                      ISNULL(vGnlUbigeo.MunicipioSITI, vGnlUbigeo.CodUbiGeo) AS MunicipioSITI, tCsCarteraDet.CodPrestamo, tCsCarteraDet.MontoDesembolso AS Monto, 
                      tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido AS SaldoCartera
FROM         vGnlUbigeo RIGHT OUTER JOIN
                      tCsPadronClientes RIGHT OUTER JOIN
                      tCaProdPerTipoCredito INNER JOIN
                      tCsCartera ON tCaProdPerTipoCredito.CodTipoCredito = tCsCartera.CodTipoCredito INNER JOIN
                      tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo ON 
                      tCsPadronClientes.CodUsuario = tCsCarteraDet.CodUsuario ON vGnlUbigeo.CodUbiGeo = ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, 
                      tCsPadronClientes.CodUbiGeoDirNegPri) CROSS JOIN
                      tClEmpresas
WHERE     (tClEmpresas.Activo = 1) AND (tCsCartera.Fecha = @Fecha) AND (tCsCartera.Cartera IN ('ACTIVA'))) Datos
	GROUP BY Fecha, Entidad, ClaseCredito, EstadoSITI, MunicipioSITI
End
GO