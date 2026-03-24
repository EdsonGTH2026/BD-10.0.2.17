SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*

Exec pCsEstadoCuentaCronograma 2, '004-105-06-2-5-03517-0-0', '20110930'

*/

CREATE Procedure [dbo].[pCsEstadoCuentaCronograma]
	@Dato			Int,
	@Cuenta			Varchar(25),
	@Corte			SmallDateTime
As
--Set @Cuenta	= @Cuenta
--Set @Corte	= '20110718'

Declare @IVAIT		Decimal(10,4)
Declare @IVAMO		Decimal(10,4)
Declare @Cuotas		Int

If @Dato = 1
Begin
	If (Select Count(*) From tCsEstadoCuentaCronograma Where CodPrestamo = @Cuenta And Corte = @Corte And Validacion = 1) = 0
	Begin 
		
		CREATE TABLE #Resumen(
			[CodPrestamo] [varchar](25) NOT NULL,
			[SecCuota] [smallint] NOT NULL,
			[INTE] [decimal](38, 4) NULL,
			[INPE] [decimal](38, 4) NULL,
			[Estado] [varchar](1) NULL,
			[FechaPago] [SmallDateTime] NULL
		) ON [PRIMARY]
		
		Delete From tCsEstadoCuentaCronograma Where CodPrestamo = @Cuenta And Corte = @Corte
		
		Insert Into tCsEstadoCuentaCronograma (Corte, CodPrestamo, SecCuota, CodConcepto, Devengado, Pago, FechaInicio, FechaVencimiento)
		SELECT     CAST(@Corte AS SmallDateTime) AS Corte, Cronograma_1.CodPrestamo, Cronograma_1.SecCuota, Cronograma_1.CodConcepto, SUM(Cronograma_1.MontoDevengado) AS Devengado, SUM(ISNULL(Pagos_1.Pago, 0)) AS Pago, 
							  Cronograma_1.FechaInicio, Cronograma_1.FechaVencimiento
		FROM         (SELECT     CodPrestamo, CodConcepto, SecCuota, SUM(MontoCuota) AS MontoCuota, SUM(MontoDevengado) AS MontoDevengado, FechaVencimiento, 
													  FechaInicio
							   FROM          tCsPadronPlanCuotas AS tCsPadronPlanCuotas_1
							   WHERE      (CodPrestamo = @Cuenta)
							   GROUP BY CodPrestamo, CodConcepto, SecCuota, FechaVencimiento, FechaInicio) AS Cronograma_1 LEFT OUTER JOIN
								(SELECT     CodPrestamo, CodConcepto, SecCuota, SUM(Pago) AS Pago From 
								  (SELECT     CodPrestamo, CodConcepto, SecCuota, SUM(MontoPagado) AS Pago
									FROM          tCsPagoDet AS tCsPagoDet_1
									WHERE      (Fecha <= @Corte) AND (Extornado = 0) AND (CodPrestamo = @Cuenta)
									GROUP BY CodPrestamo, CodConcepto, SecCuota
									UNION ALL
									SELECT     tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.CodConcepto, tCsOpRecuperablesDet.SecCuota, SUM(tCsOpRecuperablesDet.MontoOp) AS Pago
										FROM         tCsOpRecuperablesDet INNER JOIN
															  tCsOpRecuperables ON tCsOpRecuperablesDet.Fecha = tCsOpRecuperables.Fecha AND tCsOpRecuperablesDet.CodOficina = tCsOpRecuperables.CodOficina AND 
															  tCsOpRecuperablesDet.SecPago = tCsOpRecuperables.SecPago AND tCsOpRecuperablesDet.CodPrestamo = tCsOpRecuperables.CodPrestamo
										WHERE     (tCsOpRecuperablesDet.Fecha <= @Corte) AND (tCsOpRecuperablesDet.CodPrestamo = @Cuenta) AND (tCsOpRecuperables.TipoOp = '002')
										GROUP BY tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.CodConcepto, tCsOpRecuperablesDet.SecCuota
									) as Datos GROUP BY CodPrestamo, CodConcepto, SecCuota) AS Pagos_1 ON Cronograma_1.SecCuota = Pagos_1.SecCuota AND 
							  Cronograma_1.CodPrestamo = Pagos_1.CodPrestamo AND Cronograma_1.CodConcepto = Pagos_1.CodConcepto
		GROUP BY Cronograma_1.CodPrestamo, Cronograma_1.SecCuota, Cronograma_1.FechaVencimiento, Cronograma_1.FechaInicio, Cronograma_1.CodConcepto
		
		Set @Cuotas = (Select Max(Seccuota) From tCsEstadoCuentaCronograma Where CodPrestamo = @Cuenta And Corte = @Corte )
		
		/*
		Select * from tCsEstadoCuentaCronograma 
		Where 	CodPrestamo = @Cuenta And Corte = @Corte
		Order BY seccuota
		--*/
		
		If (SELECT     Count(*)
				FROM         tCsCartera
				WHERE     (Fecha = @Corte) AND (CodPrestamo = @Cuenta) And NroCuotasPagadas < CuotaActual) = 1
		Begin
			Print 'Se actualiza a cero'
			
			UPDATE	tCsEstadoCuentaCronograma
			Set		Devengado = 0
			Where	Seccuota > (Select CuotaActual from tCsCartera Where Fecha = @Corte And CodPrestamo = @Cuenta) 
			And		CodConcepto not in ('CAPI')
			And		CodPrestamo = @Cuenta And Corte = @Corte
		End
		
		--Se pone en cero cuotas futuras, solo para MORA e INPE con sus respectivos IVAS.
		UPDATE	tCsEstadoCuentaCronograma
		Set		Devengado = 0
		Where	Seccuota IN (Select CuotaActual from tCsCartera Where Fecha = @Corte And CodPrestamo = @Cuenta) 
		And		CodConcepto IN ('MORA', 'IVACM', 'INPE', 'IVAMO')
		And		CodPrestamo = @Cuenta And Corte = @Corte And FechaVencimiento > Corte
		
		UPDATE	tCsEstadoCuentaCronograma
		Set		Devengado = 0
		Where	Seccuota IN (Select CuotaActual from tCsCartera Where Fecha = @Corte And CodPrestamo = @Cuenta) 
		And		CodConcepto IN ('INPE', 'IVAMO')
		And		CodPrestamo = @Cuenta And Corte = @Corte And SecCuota = @Cuotas
		
		/*
		Select * from tCsEstadoCuentaCronograma 
		Where 	CodPrestamo = @Cuenta And Corte = @Corte
		Order BY seccuota
		--*/
		
		Insert Into #Resumen
		SELECT     CodPrestamo, SecCuota, SUM(InteresDevengado) AS INTE, SUM(MoratorioDevengado) AS INPE, Estado, FechaPago
		FROM         (SELECT     Devengado.Fecha, Devengado.CodPrestamo, Devengado.InteresDevengado, Devengado.SaldoInteres, Devengado.MoratorioDevengado, 
													  Devengado.SaldoMoratorio, PlanCuotas.SecCuota, PlanCuotas.Estado, PlanCuotas.FechaPago
							   FROM          (SELECT     Fecha, CodPrestamo, SUM(InteresDevengado) AS InteresDevengado, SUM(SaldoInteres) AS SaldoInteres, SUM(MoratorioDevengado) 
																			  AS MoratorioDevengado, SUM(SaldoMoratorio) AS SaldoMoratorio
													   FROM          tCsCarteraDet
													   WHERE      (CodPrestamo = @Cuenta) AND (Fecha <= @Corte)
													   GROUP BY Fecha, CodPrestamo) AS Devengado INNER JOIN
														  (SELECT     PlanCuotas_1.CodPrestamo, PlanCuotas_1.SecCuota, Pagos.FechaPago, Pagos.Estado, 
																		CASE 
																			WHEN Estado = 'V' AND UltimoPago > FechaInicio THEN FechaInicio 
																			WHEN Estado = 'V' THEN UltimoPago 
																			WHEN UltimoPago < FechaInicio AND Estado IS NULL THEN FechaInicio 
																			WHEN FechaPago > FechaVencimiento THEN FechaInicio 
																			WHEN Estado = 'C' AND FechaPago > FechaInicio THEN FechaInicio 
																			WHEN UltimoPago > FechaInicio AND Estado IS NULL THEN FechaInicio  
																		END AS FechaInicio, 
																		CASE 
																			WHEN Estado = 'V' AND FechaVencimiento > FechaPago THEN FechaVencimiento 
																			WHEN UltimoPago < FechaInicio AND Estado IS NULL And PlanCuotas_1.SecCuota < @Cuotas THEN FechaVencimiento 
																			WHEN UltimoPago < FechaInicio AND Estado IS NULL And PlanCuotas_1.SecCuota = @Cuotas THEN @Corte + 1 
																			WHEN FechaPago >= FechaVencimiento AND PlanCuotas_1.SecCuota = UltimoPago.NroCuotas AND Estado = 'V' THEN @Corte + 1 
																			WHEN FechaPago >= FechaVencimiento THEN FechaVencimiento 
																			WHEN Estado = 'C' AND FechaPago < FechaVencimiento THEN FechaPago 
																			WHEN UltimoPago > FechaInicio AND Estado IS NULL THEN FechaVencimiento 
																		END - 1 AS FechaVencimiento
															FROM          (SELECT     CodPrestamo, MAX(UltimoPago) AS UltimoPago, MAX(NroCuotas) AS NroCuotas
																			   FROM          (SELECT     tCsCartera.CodPrestamo, MAX(tCsPagoDet.Fecha) AS UltimoPago, MAX(tCsCartera.NroCuotas) AS NroCuotas
																									   FROM          tCsCartera INNER JOIN
																															  tCsPagoDet ON tCsCartera.NroCuotasPagadas = tCsPagoDet.SecCuota AND tCsCartera.CodPrestamo = tCsPagoDet.CodPrestamo
																									   WHERE      (tCsCartera.CodPrestamo = @Cuenta) AND (tCsCartera.Fecha = @Corte) AND (tCsPagoDet.Extornado = 0)
																									   GROUP BY tCsCartera.CodPrestamo
																									   UNION
																									   SELECT     CodPrestamo, FechaDesembolso, NroCuotas
																									   FROM         tCsCartera AS tCsCartera_2
																									   WHERE     (CodPrestamo = @Cuenta) AND (Fecha = @Corte)) AS Datos
																			   GROUP BY CodPrestamo) AS UltimoPago RIGHT OUTER JOIN
																					   (SELECT DISTINCT CodPrestamo, SecCuota, FechaInicio, FechaVencimiento
																						 FROM          tCsPadronPlanCuotas
																						 WHERE      (CodPrestamo = @Cuenta)) AS PlanCuotas_1 ON 
																				   UltimoPago.CodPrestamo = PlanCuotas_1.CodPrestamo LEFT OUTER JOIN
																					   (SELECT     Pagos_1.CodPrestamo, Pagos_1.SecCuota, Pagos_1.FechaPago, CASE WHEN Vigente.Cuota IS NULL 
																												THEN 'C' ELSE 'V' END AS Estado
																						 FROM          (SELECT     CodPrestamo, SecCuota, MAX(FechaPago) AS FechaPago
																												 FROM          (SELECT     CodPrestamo, SecCuota, MAX(Fecha) AS FechaPago
																																		 FROM          tCsPagoDet AS tCsPagoDet_1
																																		 WHERE      (CodPrestamo = @Cuenta) AND (Fecha <= @Corte) AND (Extornado = 0)
																																		 GROUP BY CodPrestamo, SecCuota
																																		 UNION
																																		 SELECT     CodPrestamo, NroCuotasPagadas + 1 AS Cuota, FechaDesembolso
																																		 FROM         tCsCartera
																																		 WHERE     (CodPrestamo = @Cuenta) AND (Fecha = @Corte)) AS Datos
																												 GROUP BY CodPrestamo, SecCuota) AS Pagos_1 LEFT OUTER JOIN
																													(SELECT     CodPrestamo, MAX(Cuota) AS Cuota
																													  FROM          (SELECT     CodPrestamo, MAX(SecCuota) AS Cuota
																																			  FROM          tCsPagoDet AS tCsPagoDet_1
																																			  WHERE      (CodPrestamo = @Cuenta) AND (Fecha <= @Corte) AND (Extornado = 0)
																																			  GROUP BY CodPrestamo
																																			  UNION
																																			  SELECT     CodPrestamo, NroCuotasPagadas + 1 AS Cuota
																																			  FROM         tCsCartera
																																		      WHERE     (CodPrestamo = @Cuenta) AND (Fecha = @Corte)) AS Datos
																													  GROUP BY CodPrestamo) AS Vigente ON Pagos_1.CodPrestamo = Vigente.CodPrestamo AND 
																												Pagos_1.SecCuota = Vigente.Cuota) AS Pagos ON PlanCuotas_1.CodPrestamo = Pagos.CodPrestamo AND 
																				   PlanCuotas_1.SecCuota = Pagos.SecCuota) AS PlanCuotas ON Devengado.CodPrestamo = PlanCuotas.CodPrestamo AND 
													  Devengado.Fecha <= PlanCuotas.FechaVencimiento AND Devengado.Fecha >= PlanCuotas.FechaInicio) AS Datos
		GROUP BY CodPrestamo, SecCuota, Estado, FechaPago
		
		--Select * from #Resumen
		
		If @Cuotas = (Select Distinct Seccuota from #Resumen Where Estado IN('V'))
		Begin
			Insert Into #Resumen	(CodPrestamo,	Seccuota,		INTE,	INPE, Estado, FechaPago)
			SELECT  CodPrestamo = @Cuenta, Seccuota = @Cuotas + 1,		INTE = 0,	INPE = SUM(Pago), Estado = 'Z', FechaPago = Null
			FROM         (SELECT     SUM(Pago) * - 1 AS Pago
								   FROM          tCsEstadoCuentaCronograma
								   WHERE      (CodPrestamo = @Cuenta) AND (Corte = @Corte) AND (CodConcepto = 'INPE') AND (SecCuota <> @Cuotas)
								   UNION ALL
								   SELECT     SUM(INPE)  AS Pago
								   FROM         #Resumen
								   WHERE     (Seccuota <= @Cuotas)) AS Datos

		End
		
		Update #Resumen Set Estado = 'Z' Where Estado Is Null

		--Select * from #Resumen
		
		UPDATE tCsEstadoCuentaCronograma
		Set Fechapago = Devengado.FechaPago
		FROM         tCsEstadoCuentaCronograma tCsEstadoCuentaCA INNER JOIN
								  (Select * from #Resumen) AS Devengado ON tCsEstadoCuentaCA.CodPrestamo = Devengado.CodPrestamo AND 
							  tCsEstadoCuentaCA.SecCuota = Devengado.SecCuota
		WHERE     tCsEstadoCuentaCA.CodPrestamo = @Cuenta And Corte = @Corte
		
		/*
		Select * from tCsEstadoCuentaCronograma
		Where 	CodPrestamo = @Cuenta And Corte = @Corte
		Order BY seccuota
		--*/
			
		Set @IVAIT = dbo.fduPIVAPrestamo(1, @Cuenta, @Corte)
		Set @IVAMO = dbo.fduPIVAPrestamo(2, @Cuenta, @Corte)                

		Print @IVAIT
		Print @IVAMO

		UPDATE	tCsEstadoCuentaCronograma
		Set		Devengado = Devengado.INTE
		FROM    tCsEstadoCuentaCronograma tCsEstadoCuentaCA INNER JOIN
				(Select * from #Resumen Where Estado IN('V', 'Z')) AS Devengado ON tCsEstadoCuentaCA.CodPrestamo = Devengado.CodPrestamo AND 
				tCsEstadoCuentaCA.SecCuota = Devengado.SecCuota
		WHERE   (tCsEstadoCuentaCA.CodConcepto = 'INTE') And tCsEstadoCuentaCA.CodPrestamo = @Cuenta And Corte = @Corte

		UPDATE	tCsEstadoCuentaCronograma
		Set		Devengado = Devengado.INTE * @IVAIT
		FROM	tCsEstadoCuentaCronograma tCsEstadoCuentaCA INNER JOIN
				(Select * from #Resumen Where Estado IN('V', 'Z')) AS Devengado ON tCsEstadoCuentaCA.CodPrestamo = Devengado.CodPrestamo AND 
				 tCsEstadoCuentaCA.SecCuota = Devengado.SecCuota
		WHERE	(tCsEstadoCuentaCA.CodConcepto = 'IVAIT') And tCsEstadoCuentaCA.CodPrestamo = @Cuenta And Corte = @Corte

		UPDATE  tCsEstadoCuentaCronograma
		SET		Devengado = Devengado.INPE
		FROM    tCsEstadoCuentaCronograma tCsEstadoCuentaCA INNER JOIN
								  (								  
									SELECT     CodPrestamo, SecCuota - 1 AS Seccuota, INTE, INPE, 'V' AS Estado, FechaPago
									FROM          #Resumen
									WHERE      (SecCuota IN
										(	SELECT     SecCuota + 1
											FROM          #Resumen
											WHERE      (Estado IN ('V', 'Z'))))
																 
																 ) AS Devengado ON tCsEstadoCuentaCA.CodPrestamo = Devengado.CodPrestamo AND 
							  tCsEstadoCuentaCA.SecCuota = Devengado.Seccuota
		WHERE     (tCsEstadoCuentaCA.CodConcepto = 'INPE') AND (tCsEstadoCuentaCA.CodPrestamo = @Cuenta) AND (tCsEstadoCuentaCA.Corte = @Corte)
		
		UPDATE	tCsEstadoCuentaCronograma
		SET     Devengado = Devengado.INPE * @IVAMO
		FROM    tCsEstadoCuentaCronograma tCsEstadoCuentaCA INNER JOIN
								  (SELECT     CodPrestamo, SecCuota - 1 AS Seccuota, INTE, INPE, 'V' AS Estado, FechaPago
									FROM          #Resumen
									WHERE      (SecCuota IN
															   (SELECT     SecCuota + 1
																 FROM          #Resumen
																 WHERE      (Estado IN ('V', 'Z'))))) AS Devengado ON tCsEstadoCuentaCA.CodPrestamo = Devengado.CodPrestamo AND 
							  tCsEstadoCuentaCA.SecCuota = Devengado.Seccuota
		WHERE     (tCsEstadoCuentaCA.CodConcepto = 'IVAMO') AND (tCsEstadoCuentaCA.CodPrestamo = @Cuenta) AND (tCsEstadoCuentaCA.Corte = @Corte)

		/*
		Select * from tCsEstadoCuentaCronograma
		Where 	CodPrestamo = @Cuenta And Corte = @Corte
		Order BY seccuota
		--*/
		
		UPDATE tCsEstadoCuentaCronograma
		Set FechaPago = Null
		Where tCsEstadoCuentaCronograma.CodPrestamo = @Cuenta And Corte = @Corte and Pago < Devengado Or Pago = 0
		
		UPDATE tCsEstadoCuentaCronograma
		Set Estado =	Case 
							When Pago				>= Devengado		And Pago	>	0			Then 'PAGADO' 
							When Corte				<= FechaVencimiento And Corte	>=	FechaInicio Then 'VIGENTE'	
							When FechaVencimiento	>  Corte			And FechaPago	Is Null		Then 'PENDIENTE'
							When Estado Is Null And Corte > FechaVencimiento						Then 'ATRASADO'
						End
		Where tCsEstadoCuentaCronograma.CodPrestamo = @Cuenta And Corte = @Corte
		
		SELECT   @IVAIT =  ROUND(SUM(Impuestos), 2) 
		FROM         (SELECT     CodPrestamo, CASE WHEN CodConcepto IN ('CAPI') THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoCapital, CASE WHEN CodConcepto IN ('INTE') 
													  THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoInteres, CASE WHEN CodConcepto IN ('INPE') THEN SUM(Devengado - Pago) 
													  ELSE 0 END AS SaldoMoratorio, CASE WHEN CodConcepto IN ('MORA') THEN SUM(Devengado - Pago) ELSE 0 END AS CargoMora, 
													  CASE WHEN CodConcepto NOT IN ('CAPI', 'INTE', 'INPE', 'MORA', 'IVAIT', 'IVAMO', 'IVACM') THEN SUM(Devengado - Pago) ELSE 0 END AS OtrosCargos, 
													  CASE WHEN CodConcepto IN ('IVAIT', 'IVAMO', 'IVACM') THEN SUM(Devengado - Pago) ELSE 0 END AS Impuestos
							   FROM          tCsEstadoCuentaCronograma tCsEstadoCuentaCA
							   WHERE      (CodPrestamo = @Cuenta) AND (Corte = @Corte)
							   GROUP BY CodPrestamo, CodConcepto) AS Datos
		GROUP BY CodPrestamo
		
		SELECT   @IVAMO =  Round(Impuestos,2) 	FROM         tCsCartera
		Where CodPrestamo = @Cuenta And Fecha = @Corte
		
		WHILE Abs(@IVAIT - @IVAMO) <= 0.02 And Abs(@IVAIT - @IVAMO) > 0
		Begin
			If 	@IVAIT - @IVAMO < 0
			Begin
				Update tCsEstadoCuentaCronograma
				Set Devengado = Devengado + 0.001 
				WHERE     (CodPrestamo = @Cuenta) AND (Corte = @Corte) AND (CodConcepto IN ('IVAIT', 'IVAMO', 'IVACM')) AND (Devengado - Pago > 0)
			End
			If 	@IVAIT - @IVAMO > 0
			Begin
				Update tCsEstadoCuentaCronograma
				Set Devengado = Devengado - 0.001 
				WHERE     (CodPrestamo = @Cuenta) AND (Corte = @Corte) AND (CodConcepto IN ('IVAIT', 'IVAMO', 'IVACM')) AND (Devengado - Pago > 0)
			End
			Print 'ACTUALIZA PAGADO'
			Update tCsEstadoCuentaCronograma
			Set Devengado = Pago 
			WHERE     (CodPrestamo = @Cuenta) AND (Corte = @Corte) AND (CodConcepto IN ('IVAIT', 'IVAMO', 'IVACM')) AND Estado = 'PAGADO' AND (ABS(Round(Devengado - Pago, 2)) > 0) AND (ABS(Round(Devengado - Pago, 2)) <= 0.01)
			
			SELECT   @IVAIT =  ROUND(SUM(Impuestos), 2) 
			FROM         (SELECT     CodPrestamo, CASE WHEN CodConcepto IN ('CAPI') THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoCapital, CASE WHEN CodConcepto IN ('INTE') 
														  THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoInteres, CASE WHEN CodConcepto IN ('INPE') THEN SUM(Devengado - Pago) 
														  ELSE 0 END AS SaldoMoratorio, CASE WHEN CodConcepto IN ('MORA') THEN SUM(Devengado - Pago) ELSE 0 END AS CargoMora, 
														  CASE WHEN CodConcepto NOT IN ('CAPI', 'INTE', 'INPE', 'MORA', 'IVAIT', 'IVAMO', 'IVACM') THEN SUM(Devengado - Pago) ELSE 0 END AS OtrosCargos, 
														  CASE WHEN CodConcepto IN ('IVAIT', 'IVAMO', 'IVACM') THEN SUM(Devengado - Pago) ELSE 0 END AS Impuestos
								   FROM          tCsEstadoCuentaCronograma tCsEstadoCuentaCA
								   WHERE      (CodPrestamo = @Cuenta) AND (Corte = @Corte)
								   GROUP BY CodPrestamo, CodConcepto) AS Datos
			GROUP BY CodPrestamo
			
			SELECT  @IVAMO =  Round(Impuestos,2) 	
			FROM    tCsCartera
			Where	CodPrestamo = @Cuenta And Fecha = @Corte
		End

		If (Select Count(*) From (Select CodPrestamo, 
					Sum(SaldoCapital) as SaldoCapital,
					Sum(SaldoInteres) as SaldoInteres,
					Sum(SaldoMoratorio) as SaldoMoratorio,
					Sum(CargoMora) as CargoMora,
					Sum(OtrosCargos) as OtrosCargos,
					Round(Sum(Impuestos),2) as Impuestos
			 from (
			Select CodPrestamo, 
			SaldoCapital	= Case When CodConcepto IN ('CAPI') Then SUM(Devengado - Pago) Else 0 End,
			SaldoInteres	= Case When CodConcepto IN ('INTE') Then SUM(Devengado - Pago) Else 0 End,
			SaldoMoratorio	= Case When CodConcepto IN ('INPE') Then SUM(Devengado - Pago) Else 0 End,
			CargoMora		= Case When CodConcepto IN ('MORA') Then SUM(Devengado - Pago) Else 0 End,
			OtrosCargos		= Case When CodConcepto NOT IN ('CAPI', 'INTE', 'INPE', 'MORA', 'IVAIT', 'IVAMO', 'IVACM') Then SUM(Devengado - Pago) Else 0 End,
			Impuestos		= Case When CodConcepto IN ('IVAIT', 'IVAMO', 'IVACM') Then SUM(Devengado - Pago) Else 0 End
			From tCsEstadoCuentaCronograma tCsEstadoCuentaCA
			Where CodPrestamo = @Cuenta And Corte = @Corte
			Group by CodPrestamo, CodConcepto) Datos
			Group by CodPrestamo
			UNION
			SELECT     CodPrestamo, SaldoCapital, SaldoInteresCorriente, SaldoINPE, CargoMora, OtrosCargos, Round(Impuestos,2) as Impuestos
			FROM         tCsCartera
			Where CodPrestamo = @Cuenta And Fecha = @Corte) as Datos) = 1
		Begin
			Update tCsEstadoCuentaCronograma
			Set Validacion = 1
			Where CodPrestamo = @Cuenta And Corte = @Corte
		End
		Else
		Begin
			Update tCsEstadoCuentaCronograma
			Set Validacion = 0
			Where CodPrestamo = @Cuenta And Corte = @Corte
			--COMO NO COICIDEN LOS DATOS SE PROCEDE A CONSISTENCIAR
			--1: Primero se verifica las condonaciones.	
			
		End	
		--*/
		Drop Table #Resumen
	End
End
If @Dato = 2
Begin
	If (Select Count(*) From tCsEstadoCuentaCronograma Where CodPrestamo = @Cuenta And Corte = @Corte And Validacion = 1) = 0
	Begin 
		Delete From tCsEstadoCuentaCronograma Where CodPrestamo = @Cuenta And Corte = @Corte
		Insert Into tCsEstadoCuentaCronograma
		SELECT		Fecha, CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) AS Cuenta, 1 AS SecCuota, 'CAPI' AS CodConcepto, SaldoCuenta AS Devengado, 0 AS Pago, 
					Fecha AS FechaInicio, Fecha AS FechaVencimiento, NULL AS FechaPago, 'VIGENTE' AS Estado, 1 AS Validacion
		FROM        tCsAhorros
		WHERE	   (CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5))  = @Cuenta) AND (Fecha = @Corte)
	ENd
End 
If @Dato = 3
Begin
	If (Select Count(*) From tCsEstadoCuentaCronograma Where CodPrestamo = @Cuenta And Corte = @Corte And Validacion = 1) = 0
	Begin 
		Delete From tCsEstadoCuentaCronograma Where CodPrestamo = @Cuenta And Corte = @Corte
		Insert Into tCsEstadoCuentaCronograma
		SELECT     @Corte AS Corte, tTaMovimientos.nrotarjeta AS CodPrestamo, 1 AS SecCuota, 'CAPI' AS CodConcepto, SUM(CAST(tTaTipoMovimientos.operacion + '1' AS Int) 
							  * tTaMovimientos.Monto) AS Devengado, 0 AS Pago, @Corte AS FechaInicio, @Corte AS FechaVencimiento, NULL AS FechaPago, 'VIGENTE' AS Estado, 
							  1 AS Validacion
		FROM         tTaMovimientos LEFT OUTER JOIN
							  tTaTipoMovimientos ON tTaMovimientos.codtipomov = tTaTipoMovimientos.CodTipoMov
		WHERE     (tTaMovimientos.nrotarjeta = @Cuenta) AND (tTaMovimientos.fecha <= @Corte)
		GROUP BY tTaMovimientos.nrotarjeta
	ENd
End
--Select * From tCsEstadoCuentaCA Where CodPrestamo = @Cuenta And Corte = @Corte order by seccuota             
GO