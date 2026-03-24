SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Exec pCsEstadoCuentaCASaldos 2, '009-159-06-00-00006', '20110430', 'Atraso Anterior'

CREATE Procedure [dbo].[pCsEstadoCuentaCASaldos]
	@Dato			Int,
	@CodPrestamo	Varchar(25),
	@Corte			SmallDateTime,
	@Motivo			Varchar(100)
As
--1:	Es para Saldo Vigente.
--2:	Es para Saldo Atrasado.
---------------------------------------------
--Set @Dato			=	2
--Set @CodPrestamo	=	'009-159-06-00-00006'
--Set @Corte		=	'20110430'
--Set @Motivo		=	'Atraso Anterior'
---------------------------------------------
If @Dato	in (1)
Begin
	SELECT     CodPrestamo, Concepto, SUM(SaldoCapital) AS VSaldoCapital, SUM(SaldoInteres) AS VInteresOrdinario, SUM(SaldoMoratorio) AS VInteresMoratorio, SUM(SaldoOtros) 
						  AS VOtrosCargos, SUM(ComisionIVA) AS VComisionIVA
	FROM         (SELECT     CodPrestamo, @Motivo AS Concepto, CASE WHEN CodConcepto IN ('CAPI') THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoCapital, 
												  CASE WHEN CodConcepto IN ('INTE') THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoInteres, CASE WHEN CodConcepto IN ('INPE') 
												  THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoMoratorio, CASE WHEN CodConcepto NOT IN ('CAPI', 'INTE', 'INPE', 'IVACM', 'IVAIT', 'IVAMO') 
												  THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoOtros, CASE WHEN CodConcepto IN ('IVACM', 'IVAIT', 'IVAMO') THEN SUM(Devengado - Pago) 
												  ELSE 0 END AS ComisionIVA
						   FROM          tCsEstadoCuentaCronograma
						   WHERE      (Corte = @Corte) AND (CodPrestamo = @CodPrestamo) AND (Estado = 'VIGENTE')
						   GROUP BY CodPrestamo, CodConcepto
						   UNION
						   SELECT     CodPrestamo, @Motivo AS Concepto, 0 AS SaldoCapital, 0 AS SaldoInteres, 0 AS SaldoMoratorio, 0 AS SaldoOtros, 0 AS ComisionIVA
						   FROM         tCsEstadoCuentaCronograma
						   WHERE     (Corte = @Corte) AND (CodPrestamo = @CodPrestamo)
						   GROUP BY CodPrestamo) AS Datos
	GROUP BY CodPrestamo, Concepto
End
If @Dato	in (2)
Begin
	SELECT     CodPrestamo, Concepto, SUM(SaldoCapital) AS ASaldoCapital, SUM(SaldoInteres) AS AInteresOrdinario, SUM(SaldoMoratorio) AS AInteresMoratorio, SUM(SaldoOtros) 
						  AS AOtrosCargos, SUM(ComisionIVA) AS AComisionIVA
	FROM         (SELECT     CodPrestamo, @Motivo AS Concepto, CASE WHEN CodConcepto IN ('CAPI') THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoCapital, 
												  CASE WHEN CodConcepto IN ('INTE') THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoInteres, CASE WHEN CodConcepto IN ('INPE') 
												  THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoMoratorio, CASE WHEN CodConcepto NOT IN ('CAPI', 'INTE', 'INPE', 'IVACM', 'IVAIT', 'IVAMO') 
												  THEN SUM(Devengado - Pago) ELSE 0 END AS SaldoOtros, CASE WHEN CodConcepto IN ('IVACM', 'IVAIT', 'IVAMO') THEN SUM(Devengado - Pago) 
												  ELSE 0 END AS ComisionIVA
						   FROM          tCsEstadoCuentaCronograma
						   WHERE      (Corte = @Corte) AND (CodPrestamo = @CodPrestamo) AND (Estado = 'ATRASADO')
						   GROUP BY CodPrestamo, CodConcepto
						   UNION
						   SELECT     CodPrestamo, @Motivo AS Concepto, 0 AS SaldoCapital, 0 AS SaldoInteres, 0 AS SaldoMoratorio, 0 AS SaldoOtros, 0 AS ComisionIVA
						   FROM         tCsEstadoCuentaCronograma
						   WHERE     (Corte = @Corte) AND (CodPrestamo = @CodPrestamo)
						   GROUP BY CodPrestamo) AS Datos
	GROUP BY CodPrestamo, Concepto
End
GO