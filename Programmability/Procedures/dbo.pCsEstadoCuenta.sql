SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*
	Exec pCsEstadoCuenta 3, '', '5370330032000004'
	Select dbo.fduCATPrestamo(3, 32000, 7.85, 6, 0)
	Select dbo.fduCATPrestamo(3, 18132, 7.85, 4, 0)
*/
CREATE Procedure [dbo].[pCsEstadoCuenta]
	@Dato			Int			,
	@Usuario		Varchar(50)	, 
	@Cuenta			Varchar(25)
As
--	@Dato
--	1	:	Estado de Cuentas de Créditos.
--	2	:	Estado de Cuentas de Ahorros.
--	3	:	Estado de Cuentas de Tarjetas.

--POR EL MOMENTO NO SE UTILIZA LA VARIABLE @DATO
Declare @Firma			Varchar(100)
Declare @Parametro		Varchar(50)
Declare @AnteriorCorte	SmallDateTime
Declare @UltimoCorte	SmallDateTime
Declare @PrimerCorte	SmallDateTime
Declare @LimitePago		Varchar(20)
Declare @Devengado		Decimal(20,4)
Declare @SaldoAnterior	Decimal(20,4)
Declare @CAT			Decimal(10,4)

If Ltrim(Rtrim(@Usuario)) = ''
Begin 
	Select TOP 1 @Usuario = Usuario from tSgUsuarios
	Where Activo = 1 And ltrim(rtrim(Usuario)) <> ''
	Order by NewId()
End
If Ltrim(Rtrim(@Cuenta)) = ''
Begin 
	Select Top 1 @Cuenta = CodPrestamo from (
	Select Distinct CodPrestamo From tCsPadronCarteraDet
	Where EstadoCalculado Not In ('CANCELADO')) Datos
	Order by Newid()
End

If @Dato = 1
Begin
	Select @PrimerCorte = PrimerCorte, @UltimoCorte = UltimoCorte from (
	SELECT     CodPrestamo, EstadoCuenta, PrimerCorte = CAST(dbo.fduFechaATexto(DATEADD(day, 1, DATEADD(Month, - 1, Case When dbo.fduCalculoFinMes(UltimoCorte) = 1 Then Dateadd(day, 1, UltimoCorte) Else UltimoCorte End )), 'AAAAMM') + EstadoCuenta AS SmallDateTime) ,   UltimoCorte, Consolidacion
	FROM         (SELECT     CodPrestamo, EstadoCuenta, CASE WHEN UltimoCorte > Consolidacion THEN DateAdd(Month, - 1, UltimoCorte) ELSE UltimoCorte END AS UltimoCorte, 
												  Consolidacion
						   FROM          (SELECT DISTINCT CodPrestamo, EstadoCuenta = dbo.fduRellena('0', EstadoCuenta, 2, 'D'), DATEADD(day, -1, CAST(dbo.fduFechaATexto
																			  ((SELECT     FechaConsolidacion
																				  FROM         vCsFechaConsolidacion), 'AAAAMM') + dbo.fduRellena('0', EstadoCuenta, 2, 'D') AS SmallDateTime)) AS UltimoCorte,
																			  (SELECT     FechaConsolidacion
																				FROM          vCsFechaConsolidacion) AS Consolidacion
												   FROM          tCsPadronCarteraDet
												   WHERE      (CodPrestamo IN
																			  (@Cuenta))) AS Datos) AS Datos) Datos
--	set @PrimerCorte = '20130601'
--	set @UltimoCorte = '20130630'
End		
If @Dato = 2
Begin
	Select @PrimerCorte = PrimerCorte, @UltimoCorte = UltimoCorte from (
	SELECT     CodPrestamo, EstadoCuenta, PrimerCorte = CAST(dbo.fduFechaATexto(DATEADD(day, 1, DATEADD(Month, - 1, Case When dbo.fduCalculoFinMes(UltimoCorte) = 1 Then Dateadd(day, 1, UltimoCorte) Else UltimoCorte End )), 'AAAAMM') + EstadoCuenta AS SmallDateTime) ,   UltimoCorte, Consolidacion
	FROM         (SELECT     CodPrestamo, EstadoCuenta, CASE WHEN UltimoCorte > Consolidacion THEN DateAdd(Month, - 1, UltimoCorte) ELSE UltimoCorte END AS UltimoCorte, 
												  Consolidacion
						   FROM          (SELECT DISTINCT CodCuenta + '-' + CAST(Renovado AS varchar(5)) + '-' + FraccionCta As CodPrestamo, EstadoCuenta = dbo.fduRellena('0', EstadoCuenta, 2, 'D'), DATEADD(day, -1, CAST(dbo.fduFechaATexto
																			  ((SELECT     FechaConsolidacion
																				  FROM         vCsFechaConsolidacion), 'AAAAMM') + dbo.fduRellena('0', EstadoCuenta, 2, 'D') AS SmallDateTime)) AS UltimoCorte,
																			  (SELECT     FechaConsolidacion
																				FROM          vCsFechaConsolidacion) AS Consolidacion
												   FROM          tCsPadronAhorros
												   WHERE      (CodCuenta  + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) IN
																			  (@Cuenta))) AS Datos) AS Datos) Datos
End	
If @Dato = 3
Begin

	Select @PrimerCorte = PrimerCorte, @UltimoCorte = UltimoCorte from (
	SELECT     CodPrestamo, EstadoCuenta, CAST(dbo.fduFechaATexto(DATEADD(day, 1, DATEADD(Month, - 1, CASE WHEN dbo.fduCalculoFinMes(UltimoCorte) 
						  = 1 THEN Dateadd(day, 1, UltimoCorte) ELSE UltimoCorte END)), 'AAAAMM') + EstadoCuenta AS SmallDateTime) AS PrimerCorte, UltimoCorte, Consolidacion
	FROM         (SELECT     CodPrestamo, EstadoCuenta, CASE WHEN UltimoCorte > Consolidacion THEN DateAdd(Month, - 1, UltimoCorte) ELSE UltimoCorte END AS UltimoCorte, 
												  Consolidacion
						   FROM          (SELECT DISTINCT 
																		  NroTarjeta AS CodPrestamo, dbo.fduRellena('0', EstadoCuenta, 2, 'D') AS EstadoCuenta, DATEADD(day, - 1, CAST(dbo.fduFechaATexto
																			  ((SELECT     FechaConsolidacion
																				  FROM         vCsFechaConsolidacion), 'AAAAMM') + dbo.fduRellena('0', EstadoCuenta, 2, 'D') AS SmallDateTime)) AS UltimoCorte,
																			  (SELECT     FechaConsolidacion
																				FROM          vCsFechaConsolidacion) AS Consolidacion
												   FROM          tTaCuentas
												   WHERE      (NroTarjeta = @Cuenta)) AS Datos) AS Datos) Datos
End																		  

Set		@AnteriorCorte	= DateAdd(day,-1,@PrimerCorte)

Exec	pCsEstadoCuentaCronograma		@Dato,	@Cuenta, @UltimoCorte
Exec	pCsEstadoCuentaCronograma		@Dato,	@Cuenta, @AnteriorCorte

Exec	pCsEstadoCuentaCAMovimientos	@Dato,	@Cuenta, @PrimerCorte,		@UltimoCorte

Print	@AnteriorCorte
Print	@UltimoCorte

If @Dato = 1
Begin 
	SELECT @CAT =  Round((power((1+ ( ((Movimiento.D + SaldoK.Saldo + Movimiento.Movimiento) / SaldoKA.Saldo) - 1)), 12) - 1) * 100.0000, 2)  
	FROM         (SELECT     SUM(D) AS D, SUM(Movimiento) AS Movimiento
						   FROM          (SELECT     SUM(AbonoD) AS D, CASE WHEN CodConcepto = 'CAPI' THEN 0 ELSE SUM(CargoD - AbonoD) END AS Movimiento
												   FROM          tCsEstadoCuentaMO
												   WHERE      (Cuenta = @Cuenta) AND (Fecha >= @AnteriorCorte + 1) AND (Fecha <= @UltimoCorte) AND (CodConcepto NOT LIKE 'IVA%')
												   GROUP BY CodConcepto) AS Dtaos) AS Movimiento CROSS JOIN
							  (SELECT     Corte, DescConcepto AS Concepto, D AS Devengado, P AS Pagado, D - P AS Saldo
								FROM          (SELECT     tCsEstadoCuentaCronograma.Corte, tCsEstadoCuentaCronograma.CodConcepto, SUM(tCsEstadoCuentaCronograma.Devengado) AS D, SUM(tCsEstadoCuentaCronograma.Pago) 
																			   AS P, tCaClConcepto.DescConcepto, tCaClConcepto.Orden
														FROM          tCsEstadoCuentaCronograma INNER JOIN
																			   tCaClConcepto ON tCsEstadoCuentaCronograma.CodConcepto = tCaClConcepto.CodConcepto
														WHERE      (tCsEstadoCuentaCronograma.CodPrestamo = @Cuenta) AND (tCsEstadoCuentaCronograma.Corte = @UltimoCorte) AND 
																			   (tCsEstadoCuentaCronograma.CodConcepto IN ('CAPI'))
														GROUP BY tCsEstadoCuentaCronograma.Corte, tCsEstadoCuentaCronograma.CodConcepto, tCaClConcepto.DescConcepto, tCaClConcepto.Orden) AS Datos) 
						  AS SaldoK CROSS JOIN
							  (SELECT     Corte, DescConcepto AS Concepto, D AS Devengado, P AS Pagado, D - P AS Saldo
								FROM          (SELECT     tCsEstadoCuentaCronograma_1.Corte, tCsEstadoCuentaCronograma_1.CodConcepto, SUM(tCsEstadoCuentaCronograma_1.Devengado) AS D, 
																			   SUM(tCsEstadoCuentaCronograma_1.Pago) AS P, tCaClConcepto_1.DescConcepto, tCaClConcepto_1.Orden
														FROM          tCsEstadoCuentaCronograma AS tCsEstadoCuentaCronograma_1 INNER JOIN
																			   tCaClConcepto AS tCaClConcepto_1 ON tCsEstadoCuentaCronograma_1.CodConcepto = tCaClConcepto_1.CodConcepto
														WHERE      (tCsEstadoCuentaCronograma_1.CodPrestamo = @Cuenta) AND (tCsEstadoCuentaCronograma_1.Corte = @AnteriorCorte) AND 
																			   (tCsEstadoCuentaCronograma_1.CodConcepto IN ('CAPI'))
														GROUP BY tCsEstadoCuentaCronograma_1.Corte, tCsEstadoCuentaCronograma_1.CodConcepto, tCaClConcepto_1.DescConcepto, tCaClConcepto_1.Orden) AS Datos_1) 
						  AS SaldoKA
End
If @Dato = 2
Begin
	SELECT    @CAT = dbo.fduCATPrestamo(4, SaldoCuenta, DATEDIFF(Day, @PrimerCorte, @UltimoCorte), TasaInteres, 0) 
	FROM         tCsAhorros
	WHERE     (CodCuenta  + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta) AND (Fecha = @UltimoCorte)
End
If @Dato = 3
Begin
	Select @CAT = dbo.fduCATPrestamo(4, Sum(Devengado-Pago) , DATEDIFF(Day, @PrimerCorte, @UltimoCorte), 0, 0) 
	From tCsEstadoCuentaCronograma
	Where Corte = @UltimoCorte and CodPrestamo = @Cuenta
End
CREATE TABLE #Saldos(
	[CodPrestamo]		[varchar](25) NOT NULL,
	[Concepto]			[varchar](100) NULL,
	[SaldoCapital]		[money] NULL,
	[InteresOrdinario]	[money] NULL,
	[InteresMoratorio]	[money] NULL,
	[OtrosCargos]		[money] NULL,
	[ComisionIVA]		[money] NULL
) ON [PRIMARY]

Insert Into #Saldos
Exec pCsEstadoCuentaCASaldos 1, @Cuenta, @UltimoCorte,		'Vigente Actual'
Insert Into #Saldos
Exec pCsEstadoCuentaCASaldos 2, @Cuenta, @UltimoCorte,		'Atraso Actual'

Set @Parametro	= Replace(@Cuenta, '-', '')
Exec pCsFirmaElectronica @Usuario, 'EC', @Parametro, @Firma Out, 'ESTADO DE CUENTA MENSUAL PRUEBA'

Set @Parametro	= Upper(dbo.fduNombreMes(Month(@UltimoCorte)) + ' ' + Cast(Year(@UltimoCorte) as Varchar(4)))

Select @SaldoAnterior = Sum(Devengado-Pago) from tCsEstadoCuentaCronograma
Where Corte = @AnteriorCorte and CodPrestamo = @Cuenta

Print @SaldoAnterior

If @Dato = 1 
Begin
	SELECT     @LimitePago =  Case When LimitePago < @UltimoCorte Then 'INMEDIATO' Else dbo.fduFechaATexto(LimitePago, 'DD') +  '-' + upper(Left(dbo.fduNombreMes(Month(LimitePago)), 3)) + '-' + dbo.fduFechaATexto(LimitePago, 'AAAA') End , @Devengado = SUM(Devengado + Devengado * PIVA) + AVG(Capital)
	FROM      (SELECT     pv.FechaVencimiento AS LimitePago, (tCsCarteraDet.InteresDevengado + tCsCarteraDet.MoratorioDevengado) * (DATEDIFF(Day, CASE WHEN
													  (SELECT     FechaUltimoMovimiento
														FROM          tCsCartera
														WHERE      (CodPrestamo = @Cuenta) AND (Fecha = @UltimoCorte)) > pv.FechaVencimiento THEN pv.FechaVencimiento + 1 ELSE
													  (SELECT     FechaUltimoMovimiento
														FROM          tCsCartera
														WHERE      (CodPrestamo = @Cuenta) AND (Fecha = @UltimoCorte)) END, pv.FechaVencimiento) + 1) AS Devengado,
													  (SELECT     dbo.fduPIVAPrestamo(0, @Cuenta, @UltimoCorte) AS IVA) AS PIVA, pv.Capital
						   FROM          tCsCarteraDet INNER JOIN
													  (SELECT     CodPrestamo, MAX(FechaVencimiento) AS FechaVencimiento, SUM(Capital) AS Capital
														FROM          (SELECT     CodPrestamo, MAX(FechaVencimiento) AS FechaVencimiento, CASE WHEN CodConcepto = 'CAPI' And MAX(Corte) < MAX(FechaVencimiento) THEN SUM(Devengado - Pago) 
																									   ELSE 0 END AS Capital
																				FROM          tCsEstadoCuentaCronograma
																				WHERE      (Corte = @UltimoCorte) AND (CodPrestamo = @Cuenta) AND (Corte >= FechaInicio)
																				GROUP BY CodPrestamo, CodConcepto) AS Datos
														GROUP BY CodPrestamo) AS pv ON tCsCarteraDet.CodPrestamo = pv.CodPrestamo
						   WHERE      (tCsCarteraDet.CodPrestamo = @Cuenta) AND (tCsCarteraDet.Fecha = @UltimoCorte)) AS Datos
	GROUP BY LimitePago
End
If @Dato = 2
Begin
	Set @LimitePago = 'INMEDIATO'
End

If @Dato = 1 
Begin
	SELECT     @PrimerCorte AS Inicio, @UltimoCorte AS Corte, DATEDIFF(Day, @PrimerCorte, @UltimoCorte) AS Dias, @Parametro AS Periodo, @Firma AS Firma, 
						  tCsPadronCarteraDet_3.CodPrestamo, tCsPadronCarteraDet_3.CodUsuario, tCaProducto.NombreProdCorto, tCaProducto.NombreProd, tCsPadronClientes.UsRFCBD, 
						  ISNULL(Atrasado.SaldoCapital, 0) AS ASaldoCapital, ISNULL(Atrasado.InteresOrdinario, 0) AS AInteresOrdinario, ISNULL(Atrasado.InteresMoratorio, 0) 
						  AS AInteresMoratorio, ISNULL(Atrasado.OtrosCargos, 0) AS AOtrosCargos, ISNULL(Atrasado.ComisionIVA, 0) AS AComisionIVA, ISNULL(Vigente.SaldoCapital, 0) 
						  AS VSaldoCapital, ISNULL(Vigente.InteresOrdinario, 0) AS VInteresOrdinario, ISNULL(Vigente.InteresMoratorio, 0) AS VInteresMoratorio, ISNULL(Vigente.OtrosCargos, 0)
						   AS VOtrosCargos, ISNULL(Vigente.ComisionIVA, 0) AS VComisionIVA, tCsPadronCarteraDet_3.CodOficina, tClOficinas.Tipo, tCsCartera_2.ProximoVencimiento, 
						  tCaClTecnologia.Veridico, General.MontoDesembolso, General.Monto, General.Concentracion, General.Integrantes, LEFT(General.ClienteGrupo, 35) AS ClienteGrupo, 
						  General.DescMoneda, tCsCartera_2.FechaDesembolso, tCsCartera_2.FechaVencimiento, tCsCartera_2.NroCuotas, tCsCartera_2.NroCuotasPagadas, 
						  tCsCartera_2.NroCuotasPorPagar, tCsCartera_2.CuotaActual, tCsCartera_2.TasaIntCorriente, tCsCartera_2.TasaINVE, tCsCartera_2.TasaINPE, @CAT AS CAT, 
						  tCsCartera_2.SaldoCapital, tCsCartera_2.SaldoInteresCorriente, tCsCartera_2.SaldoINVE, tCsCartera_2.SaldoINPE, tCsCartera_2.SaldoEnMora, 
						  tCsCartera_2.CargoMora, tCsCartera_2.OtrosCargos, tCsCartera_2.Impuestos, CASE WHEN (ISNULL(Atrasado.SaldoCapital, 0) + ISNULL(Atrasado.InteresOrdinario, 0) 
						  + ISNULL(Atrasado.InteresMoratorio, 0) + ISNULL(Atrasado.OtrosCargos, 0) + ISNULL(Atrasado.ComisionIVA, 0)) 
						  > 0 THEN 'INMEDIATO' ELSE @LimitePago END AS LimitePago, @Devengado AS Devengado, @SaldoAnterior AS SaldoAnterior, Cargos.CK, Cargos.CI, Cargos.CM, 
						  Cargos.CC, Cargos.CIVA, AK = Isnull(Abonos.AK, 0), AI = Isnull(Abonos.AI, 0), AM = Isnull(Abonos.AM, 0), AC = Isnull(Abonos.AC, 0), AIVA = Isnull(Abonos.AIVA, 0), tCsPadronClientes.NombreCompleto
	FROM         tCsPadronCarteraDet AS tCsPadronCarteraDet_3 INNER JOIN
						  tCaProducto ON tCsPadronCarteraDet_3.CodProducto = tCaProducto.CodProducto INNER JOIN
						  tCsPadronClientes ON tCsPadronCarteraDet_3.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN
						  tClOficinas ON tCsPadronCarteraDet_3.CodOficina = tClOficinas.CodOficina INNER JOIN
						  tCsCartera AS tCsCartera_2 ON tCsPadronCarteraDet_3.CodPrestamo = tCsCartera_2.CodPrestamo INNER JOIN
						  tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia INNER JOIN
							  (SELECT     tCsPadronCarteraDet_2.CodPrestamo, tCsPadronCarteraDet_2.CodUsuario, tCsCartera_3.MontoDesembolso, tCsPadronCarteraDet_2.Monto, 
													   tCsPadronCarteraDet_2.Monto / tCsCartera_3.MontoDesembolso * 100.000 AS Concentracion, tCsPadronCarteraDet.Integrantes, 
													   tCsPadronCarteraDet.ClienteGrupo, tClMonedas.DescMoneda
								FROM          tCsPadronCarteraDet AS tCsPadronCarteraDet_2 INNER JOIN
													   tCsCartera AS tCsCartera_3 ON tCsPadronCarteraDet_2.CodPrestamo = tCsCartera_3.CodPrestamo AND 
													   tCsPadronCarteraDet_2.FechaCorte = tCsCartera_3.Fecha INNER JOIN
														   (SELECT     CodPrestamo, COUNT(*) AS Integrantes, MAX(ClienteGrupo) AS ClienteGrupo
															 FROM          (SELECT     tCsPadronCarteraDet_1.CodPrestamo, tCsPadronCarteraDet_1.CodUsuario, ISNULL(tCsCarteraGrupos.NombreGrupo, 
																											tCsPadronClientes_1.NombreCompleto) AS ClienteGrupo
																					 FROM          tCsPadronCarteraDet AS tCsPadronCarteraDet_1 LEFT OUTER JOIN
																											tCsCarteraGrupos ON tCsPadronCarteraDet_1.CodGrupo = tCsCarteraGrupos.CodGrupo LEFT OUTER JOIN
																											tCsPadronClientes AS tCsPadronClientes_1 ON tCsPadronCarteraDet_1.CodUsuario = tCsPadronClientes_1.CodUsuario) 
																					AS Datos_2
															 GROUP BY CodPrestamo) AS tCsPadronCarteraDet ON tCsPadronCarteraDet_2.CodPrestamo = tCsPadronCarteraDet.CodPrestamo INNER JOIN
													   tClMonedas ON tCsCartera_3.CodMoneda = tClMonedas.CodMoneda
								WHERE      (tCsPadronCarteraDet_2.CodPrestamo = @Cuenta)) AS General ON tCsPadronCarteraDet_3.CodPrestamo = General.CodPrestamo AND 
						  tCsPadronCarteraDet_3.CodUsuario = General.CodUsuario LEFT OUTER JOIN
							  (SELECT     CodPrestamo, SUM(AK) AS AK, SUM(AI) AS AI, SUM(AM) AS AM, SUM(AC) AS AC, SUM(AIVA) AS AIVA
								FROM          (SELECT     CodPrestamo, CASE CodConcepto WHEN 'CAPI' THEN Pago ELSE 0 END AS AK, 
																			   CASE CodConcepto WHEN 'INTE' THEN Pago ELSE 0 END AS AI, CASE CodConcepto WHEN 'INPE' THEN Pago ELSE 0 END AS AM, 
																			   CASE CodConcepto WHEN 'MORA' THEN Pago ELSE 0 END AS AC, CASE WHEN CodConcepto IN ('IVAIT', 'IVACM', 'IVAMO') 
																			   THEN Pago ELSE 0 END AS AIVA
														FROM          (SELECT     CodPrestamo, CodConcepto, SUM(MontoPagado) AS Pago
																				FROM          tCsPagoDet AS tCsPagoDet_1
																				WHERE      (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) AND (Extornado = 0) AND (CodPrestamo = @Cuenta)
																				GROUP BY CodPrestamo, CodConcepto
																				UNION ALL
																				SELECT     tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.CodConcepto, SUM(tCsOpRecuperablesDet.MontoOp) AS Pago
																				FROM         tCsOpRecuperablesDet INNER JOIN
																									  tCsOpRecuperables ON tCsOpRecuperablesDet.Fecha = tCsOpRecuperables.Fecha AND 
																									  tCsOpRecuperablesDet.CodOficina = tCsOpRecuperables.CodOficina AND 
																									  tCsOpRecuperablesDet.SecPago = tCsOpRecuperables.SecPago AND 
																									  tCsOpRecuperablesDet.CodPrestamo = tCsOpRecuperables.CodPrestamo
																				WHERE     (tCsOpRecuperablesDet.Fecha >= @PrimerCorte) AND (tCsOpRecuperablesDet.Fecha <= @UltimoCorte) AND 
																									  (tCsOpRecuperablesDet.CodPrestamo = @Cuenta) AND (tCsOpRecuperables.TipoOp = '002')
																				GROUP BY tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.CodConcepto) AS Datos_3) AS Datos_4
								GROUP BY CodPrestamo) AS Abonos ON tCsPadronCarteraDet_3.CodPrestamo = Abonos.CodPrestamo LEFT OUTER JOIN
							  (                         
								
									SELECT     CodPrestamo, CK = sum(CK), CI = Sum(CI), CM= sum(CM), CC = sum(CC), CIVA = sum(CIVA)
									FROM         (SELECT     Cuenta AS CodPrestamo, CASE WHEN CodConcepto IN ('CAPI') THEN CargoD ELSE 0 END AS CK, CASE WHEN CodConcepto IN ('INTE') 
																				  THEN CargoD ELSE 0 END AS CI, CASE WHEN CodConcepto IN ('INPE') THEN CargoD ELSE 0 END AS CM, CASE WHEN CodConcepto IN ('MORA') 
																				  THEN CargoD ELSE 0 END AS CC, CASE WHEN CodConcepto IN ('IVAIT', 'IVACM', 'IVAMO') THEN CargoD ELSE 0 END AS CIVA
														   FROM          tCsEstadoCuentaMO
														   WHERE      (Cuenta = @Cuenta) AND (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) AND (Sistema = 'CA')) AS Datos
									Group by CodPrestamo  
	                                                    
														) AS Cargos ON 
						  tCsPadronCarteraDet_3.CodPrestamo = Cargos.CodPrestamo LEFT OUTER JOIN
							  (SELECT     *
								FROM          [#Saldos]
								WHERE      (Concepto = 'Vigente Actual')) AS Vigente ON tCsPadronCarteraDet_3.CodPrestamo = Vigente.CodPrestamo LEFT OUTER JOIN
							  (SELECT     *
								FROM          [#Saldos] AS [#Saldos_1]
								WHERE      (Concepto = 'Atraso Actual')) AS Atrasado ON tCsPadronCarteraDet_3.CodPrestamo = Atrasado.CodPrestamo
	WHERE     (tCsPadronCarteraDet_3.CodPrestamo = @Cuenta) AND (tCsCartera_2.Fecha = @UltimoCorte)
End
If @Dato = 2
Begin
	SELECT	@PrimerCorte AS Inicio, @UltimoCorte AS Corte, DATEDIFF(Day, @PrimerCorte, @UltimoCorte) AS Dias, @Parametro AS Periodo, @Firma AS Firma, 
			CodPrestamo = @Cuenta, tCsClientesAhorrosFecha_2.CodUsCuenta as CodUsuario, NombreProdCorto = tAhProductos.Abreviatura, NombreProd = tAhProductos.Nombre, 
			tCsPadronClientes.UsRFCBD, 
			ISNULL(Atrasado.SaldoCapital, 0) AS ASaldoCapital, ISNULL(Atrasado.InteresOrdinario, 0) AS AInteresOrdinario, ISNULL(Atrasado.InteresMoratorio, 0) 
			AS AInteresMoratorio, ISNULL(Atrasado.OtrosCargos, 0) AS AOtrosCargos, ISNULL(Atrasado.ComisionIVA, 0) AS AComisionIVA, ISNULL(Vigente.SaldoCapital, 0) 
			AS VSaldoCapital, ISNULL(Vigente.InteresOrdinario, 0) AS VInteresOrdinario, ISNULL(Vigente.InteresMoratorio, 0) AS VInteresMoratorio, ISNULL(Vigente.OtrosCargos, 0)
			AS VOtrosCargos, ISNULL(Vigente.ComisionIVA, 0) AS VComisionIVA, tCsPadronAhorros.CodOficina, tClOficinas.Tipo, ProximoVencimiento = @UltimoCorte, 
			tAhClFormaManejo.Nombre AS Veridico , General.MontoDesembolso, General.Monto, General.Concentracion, General.Integrantes, LEFT(General.ClienteGrupo, 35) AS ClienteGrupo, 
			General.DescMoneda, 
			tCsAhorros.FechaApertura AS FechaDesembolso, 
			FechaVencimiento = Case When tCsAhorros.FechaVencimiento Is Null Then 'INDEFINIDO' Else dbo.fduFechaATexto(tCsAhorros.FechaVencimiento, 'DD') +  '-' + upper(Left(dbo.fduNombreMes(Month(tCsAhorros.FechaVencimiento)), 3)) + '-' + dbo.fduFechaATexto(tCsAhorros.FechaVencimiento, 'AAAA') End, 
			1 AS NroCuotas, 0 AS NroCuotasPagadas, 1 AS NroCuotasPorPagar, 1 AS CuotaActual,
			tCsAhorros.TasaInteres AS TasaIntCorriente, 0 AS TasaINVE, 0 AS TasaINPE, @CAT AS CAT, tCsAhorros.SaldoCuenta AS SaldoCapital, 
			tCsAhorros.IntAcumulado AS SaldoInteresCorriente, 0 AS SaldoINVE, 0 AS SaldoINPE, 0 AS SaldoEnMora, 0 AS CargoMora, 0 AS OtrosCargos, 0 AS Impuestos, 
            CASE WHEN (ISNULL(Atrasado.SaldoCapital, 0) + ISNULL(Atrasado.InteresOrdinario, 0) + ISNULL(Atrasado.InteresMoratorio, 0) + ISNULL(Atrasado.OtrosCargos, 0) 
            + ISNULL(Atrasado.ComisionIVA, 0)) > 0 THEN 'INMEDIATO' ELSE '' END AS LimitePago, 0 AS Devengado, @SaldoAnterior AS SaldoAnterior, Isnull(Cargos.CK, 0) as CK, Isnull(Cargos.CI, 0) as CI, isnull(Cargos.CM, 0) as CM, 
            Isnull(Cargos.CC, 0) as CC, isnull(Cargos.CIVA, 0) as CIVA, ISNULL(Abonos.AK, 0) AS AK, ISNULL(Abonos.AI, 0) AS AI, ISNULL(Abonos.AM, 0) AS AM, ISNULL(Abonos.AC, 0) AS AC, ISNULL(Abonos.AIVA, 0) 
            AS AIVA, tCsPadronClientes.NombreCompleto, tAhProductos.AlternativaUso, cast(Replace(tAhProductos.SaldoMinimo, '$', '') as decimal(8,2)) SaldoMinimo,
            SaldoPromedio	= (Select AVG(SaldoCuenta) from tcsahorros Where CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta AND (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) ),
            MontoBloqueado	= tCsAhorros.MontoBloqueado,
            SaldoDisponible = tCsAhorros.SaldoCuenta - tCsAhorros.MontoBloqueado - --Cast(Replace(Replace(tAhProductos.SaldoMinimo, '$', ''), ',', '') As Decimal(18,4))
				(case when tCsAhorros.SaldoCuenta - tCsAhorros.MontoBloqueado<Cast(Replace(Replace(tAhProductos.SaldoMinimo, '$', ''), ',', '') As Decimal(18,4)) then 0 else Cast(Replace(Replace(tAhProductos.SaldoMinimo, '$', ''), ',', '') As Decimal(18,4)) end)
	FROM         (SELECT     *
						   FROM          [#Saldos] AS [#Saldos_1]
						   WHERE      (Concepto = 'Atraso Actual')) AS Atrasado RIGHT OUTER JOIN
							  (SELECT     *
								FROM          [#Saldos]
								WHERE      (Concepto = 'Vigente Actual')) AS Vigente RIGHT OUTER JOIN
							  (SELECT     CodCuenta, FraccionCta, Renovado, SUM(AK) AS AK, SUM(AI) AS AI, SUM(AM) AS AM, SUM(AC) AS AC, SUM(AIVA) AS AIVA
								FROM          (SELECT     CodCuenta, FraccionCta, Renovado, CASE CodConcepto WHEN 'CAPI' THEN Pago ELSE 0 END AS AK, 
																			   CASE CodConcepto WHEN 'INTE' THEN Pago ELSE 0 END AS AI, CASE CodConcepto WHEN 'INPE' THEN Pago ELSE 0 END AS AM, 
																			   CASE CodConcepto WHEN 'MORA' THEN Pago ELSE 0 END AS AC, CASE WHEN CodConcepto IN ('IVAIT', 'IVACM', 'IVAMO') 
																			   THEN Pago ELSE 0 END AS AIVA
														FROM          (SELECT     tCsTransaccionDiaria.CodigoCuenta AS CodCuenta, tCsTransaccionDiaria.FraccionCta, 
																									   tCsTransaccionDiaria.Renovado, 'CAPI' AS CodConcepto, SUM(tCsTransaccionDiaria.MontoTotalTran) 
																									   AS Pago
																				FROM          tCsTransaccionDiaria LEFT OUTER JOIN
																									   tClOficinas AS tClOficinas_1 ON tCsTransaccionDiaria.CodOficina = tClOficinas_1.CodOficina LEFT OUTER JOIN
																									   tAhClTipoTrans ON tCsTransaccionDiaria.TipoTransacNivel3 = tAhClTipoTrans.idTipoTrans
																				WHERE      (tCsTransaccionDiaria.TipoTransacNivel1 = 'E') AND (tCsTransaccionDiaria.Fecha >= @PrimerCorte) AND 
																									   (tCsTransaccionDiaria.Fecha <= @UltimoCorte) AND (tCsTransaccionDiaria.CodSistema = 'AH') AND 
																									   (tCsTransaccionDiaria.CodigoCuenta + '-' + CAST(tCsTransaccionDiaria.Renovado AS varchar(5)) 
																									   + '-' + tCsTransaccionDiaria.FraccionCta = @Cuenta)
																				GROUP BY tCsTransaccionDiaria.CodigoCuenta, tCsTransaccionDiaria.FraccionCta, tCsTransaccionDiaria.Renovado) AS Datos_3) 
													   AS Datos_4
								GROUP BY CodCuenta, FraccionCta, Renovado) AS Abonos RIGHT OUTER JOIN
							  (SELECT     CodPrestamo, SUM(CK) AS CK, SUM(CI) AS CI, SUM(CM) AS CM, SUM(CC) AS CC, SUM(CIVA) AS CIVA
								FROM          (SELECT     Cuenta AS CodPrestamo, CASE WHEN CodConcepto IN ('CAPI') THEN CargoD ELSE 0 END AS CK, CASE WHEN CodConcepto IN ('INTE') 
																			   THEN CargoD ELSE 0 END AS CI, CASE WHEN CodConcepto IN ('INPE') THEN CargoD ELSE 0 END AS CM, 
																			   CASE WHEN CodConcepto IN ('MORA') THEN CargoD ELSE 0 END AS CC, CASE WHEN CodConcepto IN ('IVAIT', 'IVACM', 'IVAMO') 
																			   THEN CargoD ELSE 0 END AS CIVA
														FROM          tCsEstadoCuentaMO
														WHERE      (Cuenta = @Cuenta) AND (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) AND (Sistema = 'AH')) AS Datos
								GROUP BY CodPrestamo) AS Cargos RIGHT OUTER JOIN
						  tCsAhorros INNER JOIN
						  tClOficinas INNER JOIN
						  tCsPadronAhorros ON tClOficinas.CodOficina = tCsPadronAhorros.CodOficina INNER JOIN
						  tAhProductos ON tCsPadronAhorros.CodProducto = tAhProductos.idProducto ON tCsAhorros.CodCuenta = tCsPadronAhorros.CodCuenta AND 
						  tCsAhorros.FraccionCta = tCsPadronAhorros.FraccionCta AND tCsAhorros.Renovado = tCsPadronAhorros.Renovado INNER JOIN
							  (SELECT     tCsAhorros_1.CodCuenta, tCsAhorros_1.FraccionCta, tCsAhorros_1.Renovado, tCsClientesAhorrosFecha_1.CodUsCuenta AS CodUsuario, 
													   tCsAhorros_1.SaldoCuenta AS MontoDesembolso, tCsClientesAhorrosFecha_1.Capital AS Monto, 
													   tCsClientesAhorrosFecha_1.Capital / tCsAhorros_1.SaldoCuenta * 100.000 AS Concentracion, tCsPadronCarteraDet.Integrantes, 
													   tCsPadronCarteraDet.ClienteGrupo, tClMonedas.DescMoneda
								FROM          (SELECT     CodCuenta, FraccionCta, Renovado, COUNT(*) AS Integrantes, MAX(ClienteGrupo) AS ClienteGrupo
														FROM          (SELECT     tCsAhorros_2.CodCuenta, tCsAhorros_2.FraccionCta, tCsAhorros_2.Renovado, 
																									   tCsClientesAhorrosFecha.CodUsCuenta AS CodUsuario, ISNULL(tCsPadronClientes_1.NombreCompleto, '') AS ClienteGrupo
																				FROM          tCsClientesAhorrosFecha INNER JOIN
																									   tCsAhorros AS tCsAhorros_2 ON tCsClientesAhorrosFecha.Fecha = tCsAhorros_2.Fecha AND 
																									   tCsClientesAhorrosFecha.CodCuenta = tCsAhorros_2.CodCuenta AND 
																									   tCsClientesAhorrosFecha.FraccionCta = tCsAhorros_2.FraccionCta AND 
																									   tCsClientesAhorrosFecha.Renovado = tCsAhorros_2.Renovado LEFT OUTER JOIN
																									   tCsPadronClientes AS tCsPadronClientes_1 ON tCsAhorros_2.CodUsuario = tCsPadronClientes_1.CodUsuario
																				WHERE      (tCsAhorros_2.Fecha = @UltimoCorte) AND (tCsAhorros_2.CodCuenta + '-' + CAST(tCsAhorros_2.Renovado AS varchar(5)) 
																									   + '-' + tCsAhorros_2.FraccionCta = @Cuenta)) AS Datos_2
														GROUP BY CodCuenta, FraccionCta, Renovado) AS tCsPadronCarteraDet INNER JOIN
													   tClMonedas INNER JOIN
													   tCsClientesAhorrosFecha AS tCsClientesAhorrosFecha_1 INNER JOIN
													   tCsAhorros AS tCsAhorros_1 ON tCsClientesAhorrosFecha_1.CodCuenta = tCsAhorros_1.CodCuenta AND 
													   tCsClientesAhorrosFecha_1.FraccionCta = tCsAhorros_1.FraccionCta AND tCsClientesAhorrosFecha_1.Renovado = tCsAhorros_1.Renovado AND 
													   tCsClientesAhorrosFecha_1.Fecha = tCsAhorros_1.Fecha ON tClMonedas.CodMoneda = tCsAhorros_1.CodMoneda ON 
													   tCsPadronCarteraDet.CodCuenta = tCsAhorros_1.CodCuenta AND tCsPadronCarteraDet.FraccionCta = tCsAhorros_1.FraccionCta AND 
													   tCsPadronCarteraDet.Renovado = tCsAhorros_1.Renovado
								WHERE      (tCsAhorros_1.CodCuenta + '-' + tCsAhorros_1.FraccionCta + '-' + CAST(tCsAhorros_1.Renovado AS varchar(5)) = @Cuenta) AND 
													   (tCsAhorros_1.Fecha = @UltimoCorte)) AS General INNER JOIN
						  tCsClientesAhorrosFecha AS tCsClientesAhorrosFecha_2 ON General.CodCuenta = tCsClientesAhorrosFecha_2.CodCuenta AND 
						  General.FraccionCta = tCsClientesAhorrosFecha_2.FraccionCta AND General.FraccionCta = tCsClientesAhorrosFecha_2.Renovado AND 
						  General.CodUsuario = tCsClientesAhorrosFecha_2.CodUsCuenta INNER JOIN
						  tCsPadronClientes ON tCsClientesAhorrosFecha_2.CodUsCuenta = tCsPadronClientes.CodUsuario INNER JOIN
						  tAhClFormaManejo ON tCsClientesAhorrosFecha_2.FormaManejo = tAhClFormaManejo.FormaManejo ON tCsAhorros.Fecha = tCsClientesAhorrosFecha_2.Fecha AND 
						  tCsAhorros.CodCuenta = tCsClientesAhorrosFecha_2.CodCuenta AND tCsAhorros.FraccionCta = tCsClientesAhorrosFecha_2.FraccionCta AND 
						  tCsAhorros.Renovado = tCsClientesAhorrosFecha_2.Renovado ON 
						  Cargos.CodPrestamo = tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) ON 
						  Abonos.CodCuenta = tCsPadronAhorros.CodCuenta AND Abonos.FraccionCta = tCsPadronAhorros.FraccionCta AND Abonos.Renovado = tCsPadronAhorros.Renovado ON
						   tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) = Vigente.CodPrestamo ON 
						  tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) = Atrasado.CodPrestamo
	WHERE    (tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) = @Cuenta) AND 
			 (tCsClientesAhorrosFecha_2.Fecha = @UltimoCorte)
End
If @Dato = 3
Begin
SELECT     @PrimerCorte AS Inicio, @UltimoCorte AS Corte, DATEDIFF(Day, @PrimerCorte, @UltimoCorte) AS Dias, @Parametro AS Periodo, @Firma AS Firma, 
                      @Cuenta AS CodPrestamo, tTaCuentas_1.CodUsuario, 'TARJETA PREPAGO FINAMIGO' AS NombreProdCorto, 'TARJETA PREPAGO FINAMIGO' AS NombreProd, 
                      tCsPadronClientes_1.UsRFCBD, ISNULL(Atrasado.SaldoCapital, 0) AS ASaldoCapital, ISNULL(Atrasado.InteresOrdinario, 0) AS AInteresOrdinario, 
                      ISNULL(Atrasado.InteresMoratorio, 0) AS AInteresMoratorio, ISNULL(Atrasado.OtrosCargos, 0) AS AOtrosCargos, ISNULL(Atrasado.ComisionIVA, 0) AS AComisionIVA, 
                      ISNULL(Vigente.SaldoCapital, 0) AS VSaldoCapital, ISNULL(Vigente.InteresOrdinario, 0) AS VInteresOrdinario, ISNULL(Vigente.InteresMoratorio, 0) AS VInteresMoratorio,
                       ISNULL(Vigente.OtrosCargos, 0) AS VOtrosCargos, ISNULL(Vigente.ComisionIVA, 0) AS VComisionIVA, tTaCuentas_1.CodOficina, tClOficinas.Tipo, 
                      @UltimoCorte AS ProximoVencimiento, 'INDIVIDUAL' AS Veridico, General.MontoDesembolso, General.Monto, General.Concentracion, General.Integrantes, 
                      LEFT(General.ClienteGrupo, 35) AS ClienteGrupo, General.DescMoneda, tTaCuentas_1.FecEmision AS FechaDesembolso, CASE WHEN FecExpira IS NULL 
                      THEN 'NO APLICA' ELSE dbo.fduFechaATexto(FecExpira, 'DD') + '-' + upper(LEFT(dbo.fduNombreMes(Month(FecExpira)), 3)) + '-' + dbo.fduFechaATexto(FecExpira, 
                      'AAAA') END AS FechaVencimiento, 1 AS NroCuotas, 0 AS NroCuotasPagadas, 1 AS NroCuotasPorPagar, 1 AS CuotaActual, 0 AS TasaIntCorriente, 0 AS TasaINVE, 
                      0 AS TasaINPE, @CAT AS CAT, General.Monto AS SaldoCapital, 0 AS SaldoInteresCorriente, 0 AS SaldoINVE, 0 AS SaldoINPE, 0 AS SaldoEnMora, 0 AS CargoMora, 
                      0 AS OtrosCargos, 0 AS Impuestos, CASE WHEN (ISNULL(Atrasado.SaldoCapital, 0) + ISNULL(Atrasado.InteresOrdinario, 0) + ISNULL(Atrasado.InteresMoratorio, 0) 
                      + ISNULL(Atrasado.OtrosCargos, 0) + ISNULL(Atrasado.ComisionIVA, 0)) > 0 THEN 'INMEDIATO' ELSE '' END AS LimitePago, 0 AS Devengado, 
                      isnull(@SaldoAnterior, 0) AS SaldoAnterior, ISNULL(Cargos.CK, 0) AS CK, ISNULL(Cargos.CI, 0) AS CI, ISNULL(Cargos.CM, 0) AS CM, ISNULL(Cargos.CC, 0) AS CC, 
                      ISNULL(Cargos.CIVA, 0) AS CIVA, ISNULL(Abonos.AK, 0) AS AK, ISNULL(Abonos.AI, 0) AS AI, ISNULL(Abonos.AM, 0) AS AM, ISNULL(Abonos.AC, 0) AS AC, 
                      ISNULL(Abonos.AIVA, 0) AS AIVA, tCsPadronClientes_1.NombreCompleto, 'Tarjeta Mastercard' AS AlternativaUso, 0 AS SaldoMinimo, 
                      dbo.fduTaSaldoPromedio(@Cuenta, @PrimerCorte, @UltimoCorte) AS SaldoPromedio, 0 AS MontoBloqueado,
                      SaldoDisponible = General.Monto
FROM         tClOficinas RIGHT OUTER JOIN
                      tCsPadronClientes AS tCsPadronClientes_1 RIGHT OUTER JOIN
                          (SELECT     *
                            FROM          [#Saldos] AS [#Saldos_1]
                            WHERE      (Concepto = 'Atraso Actual')) AS Atrasado RIGHT OUTER JOIN
                      tTaCuentas AS tTaCuentas_1 INNER JOIN
                          (SELECT     CodPrestamo, SUM(CK) AS CK, SUM(CI) AS CI, SUM(CM) AS CM, SUM(CC) AS CC, SUM(CIVA) AS CIVA
                            FROM          (SELECT     Cuenta AS CodPrestamo, CASE WHEN CodConcepto IN ('CAPI') THEN CargoD ELSE 0 END AS CK, CASE WHEN CodConcepto IN ('INTE') 
                                                                           THEN CargoD ELSE 0 END AS CI, CASE WHEN CodConcepto IN ('INPE') THEN CargoD ELSE 0 END AS CM, 
                                                                           CASE WHEN CodConcepto IN ('MORA') THEN CargoD ELSE 0 END AS CC, CASE WHEN CodConcepto IN ('IVAIT', 'IVACM', 'IVAMO') 
                                                                           THEN CargoD ELSE 0 END AS CIVA
                                                    FROM          tCsEstadoCuentaMO AS tCsEstadoCuentaMO_1
                                                    WHERE      (Cuenta = @Cuenta) AND (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) AND (Sistema = 'TA')) AS Datos_1
                            GROUP BY CodPrestamo) AS Cargos ON tTaCuentas_1.NroTarjeta = Cargos.CodPrestamo INNER JOIN
                          (SELECT     CodPrestamo, SUM(CK) AS AK, SUM(CI) AS AI, SUM(CM) AS AM, SUM(CC) AS AC, SUM(CIVA) AS AIVA
                            FROM          (SELECT     Cuenta AS CodPrestamo, CASE WHEN CodConcepto IN ('CAPI') THEN AbonoD ELSE 0 END AS CK, CASE WHEN CodConcepto IN ('INTE') 
                                                                           THEN AbonoD ELSE 0 END AS CI, CASE WHEN CodConcepto IN ('INPE') THEN AbonoD ELSE 0 END AS CM, 
                                                                           CASE WHEN CodConcepto IN ('MORA') THEN AbonoD ELSE 0 END AS CC, CASE WHEN CodConcepto IN ('IVAIT', 'IVACM', 'IVAMO') 
                                                                           THEN AbonoD ELSE 0 END AS CIVA
                                                    FROM          tCsEstadoCuentaMO
                                                    WHERE      (Cuenta = @Cuenta) AND (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) AND (Sistema = 'TA')) AS Datos
                            GROUP BY CodPrestamo) AS Abonos ON tTaCuentas_1.NroTarjeta = Abonos.CodPrestamo LEFT OUTER JOIN
                          (SELECT     *
                            FROM          [#Saldos]
                            WHERE      (Concepto = 'Vigente Actual')) AS Vigente ON tTaCuentas_1.NroTarjeta = Vigente.CodPrestamo ON 
                      tTaCuentas_1.NroTarjeta = Atrasado.CodPrestamo LEFT OUTER JOIN
                          (SELECT     tTaCuentas.NroTarjeta, tTaCuentas.CodUsuario, SUM(tCsEstadoCuentaCronograma.Devengado - tCsEstadoCuentaCronograma.Pago) 
                                                   AS MontoDesembolso, SUM(tCsEstadoCuentaCronograma.Devengado - tCsEstadoCuentaCronograma.Pago) AS Monto, COUNT(*) 
                                                   * 100.00 AS Concentracion, COUNT(*) AS Integrantes, tCsPadronClientes.NombreCompleto AS ClienteGrupo, tClMonedas.DescMoneda
                            FROM          tTaCuentas INNER JOIN
                                                   tCsEstadoCuentaCronograma ON tTaCuentas.NroTarjeta = tCsEstadoCuentaCronograma.CodPrestamo LEFT OUTER JOIN
                                                   tCsPadronClientes ON tTaCuentas.CodUsuario = tCsPadronClientes.CodUsuario CROSS JOIN
                                                   tClMonedas
                            WHERE      (tTaCuentas.NroTarjeta = @Cuenta) AND (tCsEstadoCuentaCronograma.Corte = @UltimoCorte) AND (tClMonedas.CodMoneda = '6')
                            GROUP BY tTaCuentas.NroTarjeta, tTaCuentas.CodUsuario, tCsPadronClientes.NombreCompleto, tClMonedas.DescMoneda) AS General ON 
                      tTaCuentas_1.NroTarjeta = General.NroTarjeta AND tTaCuentas_1.CodUsuario = General.CodUsuario ON 
                      tCsPadronClientes_1.CodUsuario = tTaCuentas_1.CodUsuario ON tClOficinas.CodOficina = tTaCuentas_1.CodOficina
WHERE     (tTaCuentas_1.NroTarjeta = @Cuenta)
End
Drop Table #Saldos
GO