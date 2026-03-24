SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*
	Exec pCsEstadoCuentaCAMovimientos 0, '004-105-06-2-5-03517-0-0', '20110901', '20110930'
	Exec pCsEstadoCuentaCAMovimientos 0, '013-158-06-09-00047', '20110819', '20110918'
	Exec pCsEstadoCuentaCAMovimientos 0, '5370330032000004', '20111001', '20111031'
*/
CREATE Procedure [dbo].[pCsEstadoCuentaCAMovimientos]
	@Dato			Int,
	@Cuenta 		Varchar(25),
	@Inicio			SmallDateTime,
	@Fin			SmallDateTime
As

Declare @SaldoAnterior	Decimal(20,4)
Declare @SaldoActual	Decimal(20,4)
Declare @CodConcepto	Varchar(10)
Declare @PIVA			Decimal(10,4)
Declare @Sistema		Varchar(2)

If @Dato = 1 Or Len(@Cuenta) = 19
Begin
	Set @Sistema	= 'CA'
End
If @Dato = 2 Or Len(@Cuenta) > 19
Begin
	Set @Sistema	= 'AH'
End
If @Dato = 3 Or Len(@Cuenta) < 19
Begin
	Set @Sistema	= 'TA'
End

Print @Sistema

If @Dato <> 0
Begin
	Delete From tCsEstadoCuentaMO
	Where Sistema = @Sistema and Cuenta = @Cuenta and Fecha >= @Inicio And Fecha <= @Fin

	Select @SaldoAnterior = Sum(Devengado-Pago) from tCsEstadoCuentaCronograma
	Where Corte = @Inicio - 1 and CodPrestamo = @Cuenta

	Select @SaldoActual = Sum(Devengado-Pago) from tCsEstadoCuentaCronograma
	Where Corte = @Fin and CodPrestamo = @Cuenta
End

If @Dato = 1
Begin	

	Set @PIVA = Round(dbo.fduPIVAPrestamo(0, @Cuenta, @Fin), 2)

	Print @PIVA

	CREATE TABLE #MovimientoD(
		[SaldoAnterior] [decimal](20, 4) NULL,
		[SaldoActual] [decimal](20, 4) NULL,
		[CodPrestamo] [varchar](25) NOT NULL,
		[Fecha] [smalldatetime] NULL,
		[SecPago] [int] NULL,
		[Concepto] [varchar](2087) NOT NULL,
		[Cargo] [decimal](38, 4) NULL,
		[Abono] [int] NULL,
		[CodConcepto] [varchar](6) NOT NULL,
		[ConceptoD] [varchar](103) NOT NULL,
		[Orden] [tinyint] NOT NULL
	) ON [PRIMARY]

	Insert Into tCsEstadoCuentaMO
	SELECT  Sistema = 'CA',	Cabecera.CodPrestamo,	Cabecera.Fecha,		Cabecera.SecPago,	Detalle.CodConcepto,				Cabecera.Concepto,	
			Cabecera.Cargo, Cabecera.Abono,			Detalle.ConceptoD,	Detalle.CargoD,		Detalle.AbonoD,						@SaldoAnterior AS SaldoAnterior,
			@SaldoActual AS SaldoActual,			Detalle.Orden
	FROM         (SELECT     tCsPagoDet_1.Fecha, tCsPagoDet_1.CodPrestamo, tCsPagoDet_1.SecPago, tCsPagoDet_1.CodConcepto, 0 AS CargoD, SUM(tCsPagoDet_1.Pago) 
												  AS AbonoD, '	* ' + tCaClConcepto.DescConcepto AS ConceptoD, tCaClConcepto.Orden
						   FROM          (SELECT     'Condonación' AS Tipo, tCsOpRecuperablesDet.Fecha, tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.SecPago, 
																		  tCsOpRecuperablesDet.CodConcepto, SUM(tCsOpRecuperablesDet.MontoOp) AS Pago, 
																		  tCsOpRecuperables.CodOfiOperacion AS OficinaTransaccion
												   FROM          tCsOpRecuperablesDet INNER JOIN
																		  tCsOpRecuperables ON tCsOpRecuperablesDet.Fecha = tCsOpRecuperables.Fecha AND 
																		  tCsOpRecuperablesDet.CodOficina = tCsOpRecuperables.CodOficina AND tCsOpRecuperablesDet.SecPago = tCsOpRecuperables.SecPago AND 
																		  tCsOpRecuperablesDet.CodPrestamo = tCsOpRecuperables.CodPrestamo
												   WHERE      (tCsOpRecuperables.TipoOp = '002') AND (tCsOpRecuperablesDet.Fecha >= @Inicio) AND (tCsOpRecuperablesDet.Fecha <= @Fin) AND 
																		  (tCsOpRecuperablesDet.CodPrestamo = @Cuenta)
												   GROUP BY tCsOpRecuperablesDet.Fecha, tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.SecPago, tCsOpRecuperablesDet.CodConcepto, 
																		  tCsOpRecuperables.CodOfiOperacion
												   UNION
												   SELECT     'Pago' AS Tipo, Fecha, CodPrestamo, SecPago, CodConcepto, SUM(MontoPagado) AS Pago, OficinaTransaccion
												   FROM         tCsPagoDet
												   WHERE     (Extornado = 0) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (CodPrestamo = @Cuenta)
												   GROUP BY Fecha, CodPrestamo, SecPago, CodConcepto, OficinaTransaccion) AS tCsPagoDet_1 INNER JOIN
												  tCaClConcepto ON tCsPagoDet_1.CodConcepto = tCaClConcepto.CodConcepto
						   GROUP BY tCsPagoDet_1.CodPrestamo, tCsPagoDet_1.CodConcepto, tCsPagoDet_1.Fecha, tCsPagoDet_1.SecPago, tCaClConcepto.DescConcepto, 
												  tCaClConcepto.Orden) AS Detalle INNER JOIN
							  (SELECT     tCsPagoDet_1_1.CodPrestamo, tCsPagoDet_1_1.Fecha, tCsPagoDet_1_1.SecPago, tCsPagoDet_1_1.Tipo + ' Cuota [' + CASE WHEN dbo.fduRellena('0', 
													   MIN(SecCuota), 2, 'D') = dbo.fduRellena('0', MAX(SecCuota), 2, 'D') THEN dbo.fduRellena('0', MIN(SecCuota), 2, 'D') ELSE dbo.fduRellena('0', 
													   MIN(SecCuota), 2, 'D') + ' a ' + dbo.fduRellena('0', MAX(SecCuota), 2, 'D') 
													   END + '] en Ofic. ' + tClOficinas.NomOficina + '. Oper. Nro. ' + LTRIM(RTRIM(STR(tCsPagoDet_1_1.SecPago, 10, 0))) + '.' AS Concepto, 0 AS Cargo, 
													   SUM(tCsPagoDet_1_1.Pago) AS Abono
								FROM          (SELECT     'Condonación' AS Tipo, tCsOpRecuperablesDet_1.Fecha, tCsOpRecuperablesDet_1.CodPrestamo, tCsOpRecuperablesDet_1.SecPago, 
																			   tCsOpRecuperablesDet_1.CodConcepto, SUM(tCsOpRecuperablesDet_1.MontoOp) AS Pago, 
																			   tCsOpRecuperables_1.CodOfiOperacion AS OficinaTransaccion, tCsOpRecuperablesDet_1.SecCuota
														FROM          tCsOpRecuperablesDet AS tCsOpRecuperablesDet_1 INNER JOIN
																			   tCsOpRecuperables AS tCsOpRecuperables_1 ON tCsOpRecuperablesDet_1.Fecha = tCsOpRecuperables_1.Fecha AND 
																			   tCsOpRecuperablesDet_1.CodOficina = tCsOpRecuperables_1.CodOficina AND 
																			   tCsOpRecuperablesDet_1.SecPago = tCsOpRecuperables_1.SecPago AND 
																			   tCsOpRecuperablesDet_1.CodPrestamo = tCsOpRecuperables_1.CodPrestamo
														WHERE      (tCsOpRecuperables_1.TipoOp = '002') AND (tCsOpRecuperablesDet_1.Fecha >= @Inicio) AND (tCsOpRecuperablesDet_1.Fecha <= @Fin) AND
																				(tCsOpRecuperablesDet_1.CodPrestamo = @Cuenta)
														GROUP BY tCsOpRecuperablesDet_1.Fecha, tCsOpRecuperablesDet_1.CodPrestamo, tCsOpRecuperablesDet_1.SecPago, 
																			   tCsOpRecuperablesDet_1.CodConcepto, tCsOpRecuperables_1.CodOfiOperacion, tCsOpRecuperablesDet_1.SecCuota
														UNION
														SELECT     'Pago' AS Tipo, Fecha, CodPrestamo, SecPago, CodConcepto, SUM(MontoPagado) AS Pago, OficinaTransaccion, SecCuota
														FROM         tCsPagoDet AS tCsPagoDet_2
														WHERE     (Extornado = 0) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (CodPrestamo = @Cuenta)
														GROUP BY Fecha, CodPrestamo, SecPago, CodConcepto, OficinaTransaccion, SecCuota) AS tCsPagoDet_1_1 INNER JOIN
													   tClOficinas ON tCsPagoDet_1_1.OficinaTransaccion = tClOficinas.CodOficina
								GROUP BY tCsPagoDet_1_1.CodPrestamo, tCsPagoDet_1_1.Fecha, tCsPagoDet_1_1.SecPago, tCsPagoDet_1_1.OficinaTransaccion, tClOficinas.NomOficina, 
													   tCsPagoDet_1_1.Tipo) AS Cabecera ON Detalle.Fecha = Cabecera.Fecha AND Detalle.CodPrestamo = Cabecera.CodPrestamo AND 
						  Detalle.SecPago = Cabecera.SecPago


	Set @CodConcepto = 'INTE'
	
	Print @CodConcepto
	
	INsert Into #MovimientoD
	SELECT     SaldoAnterior, SaldoActual, CodPrestamo, Fecha, SecPago, Concepto, SUM(Cargo) AS Cargo, SUM(Abono) AS Abono, CodConcepto, ConceptoD, Orden
	FROM         (SELECT DISTINCT 
												  Detalle.Fecha AS F, ISNULL(Movimientos_2.SaldoAnterior, M.SaldoAnterior) AS SaldoAnterior, ISNULL(Movimientos_2.SaldoActual, M.SaldoActual) 
												  AS SaldoActual, ISNULL(Movimientos_2.Cuenta, M.CodPrestamo) AS CodPrestamo, Origen.Fin AS Fecha, Origen.SecPago, 
												  ISNULL(Movimientos_2.Concepto, M.Concepto) AS Concepto, Detalle.ID AS Cargo, 0 AS Abono, Origen.CodConcepto, ISNULL(Movimientos_2.ConceptoD, 
												  M.ConceptoD) AS ConceptoD, ISNULL(Movimientos_2.Orden, M.Orden) AS Orden
						   FROM          (SELECT     Inicio.Inicio, MIN(Fin.Fin) AS Fin
												   FROM          (SELECT     Fecha + 1 AS Inicio, MIN(SecPago) AS SecPago

																		   FROM          tCsEstadoCuentaMO
																		   WHERE      (CodConcepto = @CodConcepto) AND (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (Sistema = 'CA')
																		   GROUP BY Fecha
																		   UNION
																		   SELECT     CAST(@Inicio AS SmallDateTime) AS Fecha, 9999 AS SecPago) AS Inicio INNER JOIN
																			  (SELECT     Fecha AS Fin, MIN(SecPago) AS SecPago
																				FROM          tCsEstadoCuentaMO AS Movimientos_1
																				WHERE      (CodConcepto = @CodConcepto) AND (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (Sistema = 'CA')
																				GROUP BY Fecha
																				UNION
																				SELECT     CAST(@Fin AS SmallDateTime) AS Fecha, 0 AS SecPago) AS Fin ON Inicio.Inicio <= Fin.Fin
												   GROUP BY Inicio.Inicio) AS Datos INNER JOIN
													  (SELECT     Fecha AS Fin, MIN(SecPago) AS SecPago, CodConcepto
														FROM          tCsEstadoCuentaMO AS Movimientos_1
														WHERE      (CodConcepto = @CodConcepto) AND (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (Sistema = 'CA')
														GROUP BY Fecha, CodConcepto
														UNION
														SELECT     Fin, MIN(SecPago) AS Secpago, CodConcepto
														FROM         (SELECT     Fecha AS Fin, MIN(SecPago) AS SecPago, CodConcepto
																			   FROM          tCsEstadoCuentaMO AS Movimientos_1
																			   WHERE      (CodConcepto = @CodConcepto) AND (Fecha = @Fin) AND (Cuenta = @Cuenta) AND (Sistema = 'CA')
																			   GROUP BY Fecha, CodConcepto
																			   UNION
																			   SELECT     CAST(@Fin AS SmallDateTime) AS Fecha, 9999 AS SecPago, @CodConcepto AS CodConcepto) AS Datos
														GROUP BY Fin, CodConcepto) AS Origen ON Datos.Fin = Origen.Fin INNER JOIN
													  (SELECT     Fecha, CodPrestamo, SUM(InteresDevengado) AS ID, SUM(MoratorioDevengado) AS MD
														FROM          tCsCarteraDet
														WHERE      (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (CodPrestamo = @Cuenta)
														GROUP BY Fecha, CodPrestamo) AS Detalle ON Datos.Inicio <= Detalle.Fecha AND Datos.Fin >= Detalle.Fecha LEFT OUTER JOIN
												  (Select * from tCsEstadoCuentaMO
												  Where (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND 
																			   (Fecha <= @Fin) AND (Sistema = 'CA')
												  ) AS Movimientos_2 ON Origen.CodConcepto = Movimientos_2.CodConcepto AND Origen.SecPago = Movimientos_2.SecPago AND 
												  Origen.Fin = Movimientos_2.Fecha CROSS JOIN
													  (
													     Select SaldoAnterior = @SaldoAnterior, SaldoActual = @SaldoActual, CodPrestamo = @Cuenta, 'Cargo por concepto de Intereses.' AS Concepto,
															 '	* ' + tCaClConcepto.DescConcepto AS ConceptoD, tCaClConcepto.Orden  
															 from tCaClConcepto Where CodConcepto = @CodConcepto
																			   
																			   ) AS M
														
																			   ) AS Datos
	GROUP BY SaldoAnterior, SaldoActual, CodPrestamo, Fecha, SecPago, Concepto, CodConcepto, ConceptoD, Orden 

	Insert Into #MovimientoD
	SELECT     MovimientoD.SaldoAnterior, MovimientoD.SaldoActual, MovimientoD.CodPrestamo, MovimientoD.Fecha, MovimientoD.SecPago, MovimientoD.Concepto, 
						  Cargo = MovimientoD.Cargo * @PIVA, Abono = MovimientoD.Abono * @PIVA, tCaClConcepto.CodConcepto, ConceptoD = ' * ' + tCaClConcepto.DescConcepto, tCaClConcepto.Orden
	FROM        #MovimientoD MovimientoD CROSS JOIN
						  tCaClConcepto
	WHERE     (tCaClConcepto.CodConcepto = 'IVAIT') And MovimientoD.CodConcepto = @CodConcepto

	Set @CodConcepto = 'INPE'
	Print @CodConcepto
	
	INsert Into #MovimientoD
	SELECT     SaldoAnterior, SaldoActual, CodPrestamo, Fecha, SecPago, Concepto, Sum(Cargo) as Cargo, Sum(Abono) as Abono, CodConcepto, ConceptoD, Orden
	FROM         (SELECT DISTINCT 
												  Detalle.Fecha AS F, ISNULL(Movimientos_2.SaldoAnterior, M.SaldoAnterior) AS SaldoAnterior, ISNULL(Movimientos_2.SaldoActual, M.SaldoActual) 
												  AS SaldoActual, ISNULL(Movimientos_2.Cuenta, M.CodPrestamo) AS CodPrestamo, Origen.Fin AS Fecha, Origen.SecPago, 
												  ISNULL(Movimientos_2.Concepto, M.Concepto) AS Concepto, Detalle.ID AS Cargo, 0 AS Abono, Origen.CodConcepto, ISNULL(Movimientos_2.ConceptoD, 
												  M.ConceptoD) AS ConceptoD, ISNULL(Movimientos_2.Orden, M.Orden) AS Orden
						   FROM          (SELECT     Inicio.Inicio, MIN(Fin.Fin) AS Fin
												   FROM          (SELECT     Fecha + 1 AS Inicio, MIN(SecPago) AS SecPago
																		   FROM          tCsEstadoCuentaMO
																		   WHERE      (CodConcepto = @CodConcepto) AND Cuenta =  @Cuenta And Fecha >= @Inicio And Fecha <= @Fin and Sistema = 'CA'
																		   GROUP BY Fecha
																		   UNION
																		   SELECT     CAST(@Inicio AS SmallDateTime) AS Fecha, 9999 AS SecPago) AS Inicio INNER JOIN
																			  (SELECT     Fecha AS Fin, MIN(SecPago) AS SecPago
																				FROM          tCsEstadoCuentaMO AS Movimientos_1
																				WHERE      (CodConcepto = @CodConcepto) AND Cuenta =  @Cuenta And Fecha >= @Inicio And Fecha <= @Fin and Sistema = 'CA'
																				GROUP BY Fecha
																				UNION
																				SELECT     CAST(@Fin AS SmallDateTime) AS Fecha, 0 AS SecPago) AS Fin ON Inicio.Inicio <= Fin.Fin
												   GROUP BY Inicio.Inicio) AS Datos INNER JOIN
													  (SELECT     Fecha AS Fin, MIN(SecPago) AS SecPago, CodConcepto
														FROM          tCsEstadoCuentaMO AS Movimientos_1
														WHERE      (CodConcepto = @CodConcepto) AND Cuenta =  @Cuenta And Fecha >= @Inicio And Fecha <= @Fin and Sistema = 'CA'
														GROUP BY Fecha, CodConcepto
														UNION
														Select Fin ,min(Secpago) as Secpago, CodConcepto From (
														SELECT     Fecha AS Fin, MIN(SecPago) AS SecPago, CodConcepto
																					FROM          tCsEstadoCuentaMO AS Movimientos_1
																					WHERE      (CodConcepto = @CodConcepto) and Fecha = @Fin AND Cuenta =  @Cuenta ANd Sistema = 'CA'
																					GROUP BY Fecha, CodConcepto
														UNION
														SELECT     CAST(@Fin AS SmallDateTime) AS Fecha, 9999 AS SecPago, @CodConcepto AS CodConcepto) Datos
														Group by Fin, CodConcepto    ) AS Origen ON Datos.Fin = Origen.Fin INNER JOIN
													  (SELECT     Fecha, CodPrestamo, SUM(MoratorioDevengado) AS ID
														FROM          tCsCarteraDet
														WHERE      (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (CodPrestamo = @Cuenta)
														GROUP BY Fecha, CodPrestamo) AS Detalle ON Datos.Inicio <= Detalle.Fecha AND Datos.Fin >= Detalle.Fecha LEFT OUTER JOIN
												  (Select * from tCsEstadoCuentaMO
												  Where (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND 
																			   (Fecha <= @Fin) AND (Sistema = 'CA')
												  ) AS Movimientos_2 ON Origen.CodConcepto = Movimientos_2.CodConcepto AND Origen.SecPago = Movimientos_2.SecPago AND 
												  Origen.Fin = Movimientos_2.Fecha CROSS JOIN
													  ( Select SaldoAnterior = @SaldoAnterior, SaldoActual = @SaldoActual, CodPrestamo = @Cuenta, 'Cargo por concepto de Intereses.' AS Concepto,
															 '	* ' + tCaClConcepto.DescConcepto AS ConceptoD, tCaClConcepto.Orden  
															 from tCaClConcepto Where CodConcepto = @CodConcepto) AS M
														
														) AS Datos
	Group by SaldoAnterior, SaldoActual, CodPrestamo, Fecha, SecPago, Concepto, CodConcepto, ConceptoD, Orden    

	Insert Into #MovimientoD
	SELECT     MovimientoD.SaldoAnterior, MovimientoD.SaldoActual, MovimientoD.CodPrestamo, MovimientoD.Fecha, MovimientoD.SecPago, MovimientoD.Concepto, 
						  Cargo = MovimientoD.Cargo * @PIVA, Abono = MovimientoD.Abono * @PIVA, tCaClConcepto.CodConcepto, ConceptoD = ' * ' + tCaClConcepto.DescConcepto, tCaClConcepto.Orden
	FROM         #MovimientoD As MovimientoD CROSS JOIN
						  tCaClConcepto
	WHERE     (tCaClConcepto.CodConcepto = 'IVAMO') And MovimientoD.CodConcepto = @CodConcepto

	Set @CodConcepto = 'MORA'
	Print @CodConcepto 
	
	INsert Into #MovimientoD
	SELECT  Distinct MovimientoD.SaldoAnterior, MovimientoD.SaldoActual, MovimientoD.CodPrestamo, tCsCartera.Fecha,
	Secpago = 9999, Concepto = 'Cargo por concepto de Comisiones.', Cargo = CargoMora, Abono = 0, tcaclconcepto.CodConcepto, ConceptoD = ' * ' + tCaClConcepto.DescConcepto, tcaclconcepto.Orden
	FROM         tCsCartera CROSS JOIN
						  #MovimientoD As MovimientoD, tcaclconcepto
	WHERE     (tCsCartera.Fecha >= @Inicio) AND (tCsCartera.Fecha <= @Fin) AND (tCsCartera.CodPrestamo = @Cuenta) AND (tCsCartera.NroDiasAtraso = 1)
	And tcaclconcepto.CodConcepto = @CodConcepto

	Insert Into #MovimientoD
	SELECT     MovimientoD.SaldoAnterior, MovimientoD.SaldoActual, MovimientoD.CodPrestamo, MovimientoD.Fecha, MovimientoD.SecPago, MovimientoD.Concepto, 
						  Cargo = MovimientoD.Cargo * @PIVA, Abono = MovimientoD.Abono * @PIVA, tCaClConcepto.CodConcepto, ConceptoD = ' * ' + tCaClConcepto.DescConcepto, tCaClConcepto.Orden
	FROM         #MovimientoD As MovimientoD CROSS JOIN
						  tCaClConcepto
	WHERE     (tCaClConcepto.CodConcepto = 'IVACM') And MovimientoD.CodConcepto = @CodConcepto

	/*
	Sistema = 'CA',	Cabecera.CodPrestamo,	Cabecera.Fecha,		Cabecera.SecPago,	Detalle.CodConcepto,				Cabecera.Concepto,	
			Cabecera.Cargo, Cabecera.Abono,			Detalle.ConceptoD,	Detalle.CargoD,		Detalle.AbonoD,						@SaldoAnterior AS SaldoAnterior,
			@SaldoActual AS SaldoActual,			Detalle.Orden
	*/

	--Select * from #MovimientoD

	Print 'INSERCCION'
	
	
	Insert Into  tCsEstadoCuentaMO		
	SELECT  Sistema = @Sistema, MovimientoD.CodPrestamo, MovimientoD.Fecha, MovimientoD.SecPago, MovimientoD.CodConcepto, MovimientoD.Concepto, 0 AS Cargo, 
						  0 AS Abono, MovimientoD.ConceptoD, MovimientoD.Cargo AS CargoD, MovimientoD.Abono AS AbonoD,
						  MovimientoD.SaldoAnterior, MovimientoD.SaldoActual , MovimientoD.Orden
	FROM         #MovimientoD As MovimientoD  LEFT OUTER JOIN
						  tCsEstadoCuentaMO As Movimientos ON MovimientoD.CodPrestamo = Movimientos.Cuenta AND MovimientoD.Fecha = Movimientos.Fecha AND 
						  MovimientoD.SecPago = Movimientos.SecPago AND MovimientoD.CodConcepto = Movimientos.CodConcepto
	WHERE     (Movimientos.Cuenta IS NULL) --AND Movimientos.Cuenta =  @Cuenta  and Movimientos.Fecha >= @Inicio And Movimientos.Fecha <= @Fin and Movimientos.Sistema = 'CA'

	Update tCsEstadoCuentaMO
	Set CargoD = MovimientoD.Cargo
	FROM         #MovimientoD As MovimientoD INNER JOIN
						  tCsEstadoCuentaMO ON MovimientoD.CodPrestamo = tCsEstadoCuentaMO.Cuenta AND MovimientoD.Fecha = tCsEstadoCuentaMO.Fecha AND 
						  MovimientoD.SecPago = tCsEstadoCuentaMO.SecPago AND MovimientoD.CodConcepto = tCsEstadoCuentaMO.CodConcepto

	Delete From tCsEstadoCuentaMO where Cargod + AbonoD = 0 And tCsEstadoCuentaMO.Cuenta = @Cuenta And tCsEstadoCuentaMO.Fecha >= @Inicio And tCsEstadoCuentaMO.Fecha <= @Fin And tCsEstadoCuentaMO.Sistema = 'CA'

	If (SELECT     SAn + CD - AB - SAc
			FROM         (SELECT     Cuenta, ROUND(SaldoAnterior, 2) AS SAn, ROUND(SaldoActual, 2) AS SAc, Round(SUM(CargoD), 2) AS CD, Round(SUM(AbonoD), 2) AS AB
								   FROM          tCsEstadoCuentaMO
								   WHERE      (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (Sistema = 'CA')
								   GROUP BY Cuenta, SaldoAnterior, SaldoActual) AS Datos
			Where Abs(SAn + CD - AB - SAc)  = 0.01) > 0
	Begin		
		
		UPDATE tCsEstadoCuentaMO
		Set CargoD = CargoD - Factor.Factor
		FROM         tCsEstadoCuentaMO CROSS JOIN
								  (SELECT     0.01 / COUNT(*) AS Factor
									FROM          tCsEstadoCuentaMO
									WHERE       (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (Sistema = 'CA') AND (ROUND(CargoD, 2) 
														   * 100 <> CAST(CargoD * 100 AS Int))) AS Factor
		WHERE      (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (Sistema = 'CA') AND (ROUND(tCsEstadoCuentaMO.CargoD, 2) * 100 <> CAST(tCsEstadoCuentaMO.CargoD * 100 AS Int))
	End			

		If (SELECT     SAn + CD - AB - SAc
			FROM         (SELECT     Cuenta, ROUND(SaldoAnterior, 2) AS SAn, ROUND(SaldoActual, 2) AS SAc, Round(SUM(CargoD), 2) AS CD, Round(SUM(AbonoD), 2) AS AB
								   FROM          tCsEstadoCuentaMO
								   WHERE      (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (Sistema = 'CA')
								   GROUP BY Cuenta, SaldoAnterior, SaldoActual) AS Datos
			Where Abs(SAn + CD - AB - SAc)  = 0.01) < 0
	Begin		
		
		UPDATE tCsEstadoCuentaMO
		Set CargoD = CargoD + Factor.Factor
		FROM         tCsEstadoCuentaMO CROSS JOIN
								  (SELECT     0.01 / COUNT(*) AS Factor
									FROM          tCsEstadoCuentaMO
									WHERE       (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (Sistema = 'CA') AND (ROUND(CargoD, 2) 
														   * 100 <> CAST(CargoD * 100 AS Int))) AS Factor
		WHERE      (Cuenta = @Cuenta) AND (Fecha >= @Inicio) AND (Fecha <= @Fin) AND (Sistema = 'CA') AND (ROUND(tCsEstadoCuentaMO.CargoD, 2) * 100 <> CAST(tCsEstadoCuentaMO.CargoD * 100 AS Int))
	End	

	UPDATE tCsEstadoCuentaMO
	Set Cargo = Total.Cargo,
		Abono = Total.Abono
	FROM         (SELECT     Cuenta As CodPrestamo, Fecha, SecPago, SUM(CargoD) AS Cargo, SUM(AbonoD) AS Abono
						   FROM          tCsEstadoCuentaMO
						   Where tCsEstadoCuentaMO.Cuenta = @Cuenta And tCsEstadoCuentaMO.Fecha >= @Inicio And tCsEstadoCuentaMO.Fecha <= @Fin And tCsEstadoCuentaMO.Sistema = 'CA'
						   GROUP BY Cuenta, Fecha, SecPago) AS Total INNER JOIN
						  tCsEstadoCuentaMO AS Movimientos_1 ON Total.CodPrestamo = Movimientos_1.Cuenta AND Total.Fecha = Movimientos_1.Fecha AND 
						  Total.SecPago = Movimientos_1.SecPago   
	Where Movimientos_1.Cuenta = @Cuenta And Movimientos_1.Fecha >= @Inicio And Movimientos_1.Fecha <= @Fin And Movimientos_1.Sistema = 'CA'						    
	Drop Table #MovimientoD   						                
End        
If @Dato = 2
Begin
	Insert Into  tCsEstadoCuentaMO
	SELECT     @Sistema AS Sistema, tCsTransaccionDiaria.CodigoCuenta + '-' + CAST(tCsTransaccionDiaria.Renovado AS varchar(5)) + '-' + tCsTransaccionDiaria.FraccionCta AS Cuenta, 
						tCsTransaccionDiaria.Fecha, tCsTransaccionDiaria.NroTransaccion, 'CAPI' AS CodConcepto, ISNULL(tAhClTipoTrans.Descripcion, tCsTransaccionDiaria.DescripcionTran) 
						--+ ' en ' + tClOficinas.NomOficina + '. ' + LTRIM(RTRIM(STR(tCsTransaccionDiaria.NroTransaccion, 10, 0))) + '.' AS Concepto, 
						+ ' en Oficina ' + tClOficinas.NomOficina + '. Operación ' + LTRIM(RTRIM(STR(tCsTransaccionDiaria.NroTransaccion, 10, 0))) + '.' AS Concepto, 
						CASE tCsTransaccionDiaria.TipoTransacNivel1 WHEN 'I' THEN tCsTransaccionDiaria.MontoTotalTran ELSE 0 END AS Deposito, 
						CASE tCsTransaccionDiaria.TipoTransacNivel1 WHEN 'E' THEN tCsTransaccionDiaria.MontoTotalTran ELSE 0 END AS Retiro, tCsTransaccionDiaria.DescripcionTran, 
						CASE tCsTransaccionDiaria.TipoTransacNivel1 WHEN 'I' THEN tCsTransaccionDiaria.MontoTotalTran ELSE 0 END AS DepositoD, 
						CASE tCsTransaccionDiaria.TipoTransacNivel1 WHEN 'E' THEN tCsTransaccionDiaria.MontoTotalTran ELSE 0 END AS RetiroD,
						isnull(@SaldoAnterior,0) AS SaldoAnterior,
						isnull(@SaldoActual,0) AS SaldoActual,  Orden = (Year(tCsTransaccionDiaria.Fecha)*1000) + (Month(tCsTransaccionDiaria.Fecha)*10000) + (Day(tCsTransaccionDiaria.Fecha)* 1000) +
                        (tCsTransaccionDiaria.TranHora*100) +  (tCsTransaccionDiaria.TranMinuto*10) + tCsTransaccionDiaria.TranSegundo + tCsTransaccionDiaria.TranMicroSegundo
	FROM         tCsTransaccionDiaria with(nolock) LEFT OUTER JOIN
						  tClOficinas with(nolock) ON tCsTransaccionDiaria.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
						  tAhClTipoTrans with(nolock) ON tCsTransaccionDiaria.TipoTransacNivel3 = tAhClTipoTrans.idTipoTrans
	WHERE     (tCsTransaccionDiaria.Fecha >= @Inicio) AND (tCsTransaccionDiaria.Fecha <= @Fin) AND (tCsTransaccionDiaria.CodSistema = 'AH') AND 
						  (tCsTransaccionDiaria.CodigoCuenta + '-' + CAST(tCsTransaccionDiaria.Renovado AS varchar(5)) + '-' + tCsTransaccionDiaria.FraccionCta = @Cuenta)
End    
If @Dato = 3
Begin
	Insert Into  tCsEstadoCuentaMO
	SELECT     @Sistema AS Sistema, tTaMovimientos.nrotarjeta AS Cuenta, tTaMovimientos.fecha AS Fecha, tTaMovimientos.documento1 AS SecPago, 'CAPI' AS CodConcepto, 
						  tTaTipoMovimientos.Descripcion + ' en ' + CASE LEFT(Usuario, 3) 
						  WHEN 'FNA' THEN 'Finamigo.' ELSE 'Establecimiento Externo.' END + ' Oper. Nro. ' + tTaMovimientos.documento1 AS Concepto, 
						  CASE ltrim(rtrim(tTaTipoMovimientos.operacion)) WHEN '+' THEN Monto ELSE 0 END AS Cargo, CASE ltrim(rtrim(tTaTipoMovimientos.operacion)) 
						  WHEN '-' THEN Monto ELSE 0 END AS Abono, 'Ref.: ' + tTaMovimientos.documento2 AS ConceptoD, 
						  CASE ltrim(rtrim(tTaTipoMovimientos.operacion)) WHEN '+' THEN Monto ELSE 0 END AS CargoD, CASE ltrim(rtrim(tTaTipoMovimientos.operacion)) 
						  WHEN '-' THEN Monto ELSE 0 END AS AbonoD,
						  Isnull(@SaldoAnterior, 0) AS SaldoAnterior,
						  @SaldoActual AS SaldoActual,
						  (((YEAR(tTaMovimientos.fecha) 
						  * 1000 + MONTH(tTaMovimientos.fecha) * 10000) + DAY(tTaMovimientos.fecha) * 1000) + DATEPART(Hour, tTaMovimientos.hora) * 100) + DATEPART(Minute, 
						  tTaMovimientos.hora) * 10 + DATEPART(Second, tTaMovimientos.hora) + DATEPART(MilliSecond, tTaMovimientos.hora) AS Orden
	FROM         tTaMovimientos INNER JOIN
						  tTaTipoMovimientos ON tTaMovimientos.codtipomov = tTaTipoMovimientos.CodTipoMov
	WHERE     (tTaMovimientos.nrotarjeta = @Cuenta) AND (tTaMovimientos.fecha >= @Inicio) AND (tTaMovimientos.fecha <= @Fin)
End          
If @Dato = 0
Begin
	Print @Cuenta
	Print @Inicio
	Print @Fin
	Print @Sistema
	
	Select * 
	From tCsEstadoCuentaMO
	Where Cuenta =  @Cuenta  and Fecha >= @Inicio And Fecha <= @Fin and Sistema = @Sistema
	
End         
--Drop Table Movimientos
GO