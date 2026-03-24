SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*
Select dbo.fduPIVAPrestamo(0, '013-158-06-09-00047', '20110818')
Select dbo.fduPIVAPrestamo(0, '013-158-06-09-00047', '20110918')
*/
CREATE Function [dbo].[fduPIVAPrestamo]
(
	@Dato			Int,			
	@CodPrestamo	Varchar(25),
	@Corte			SmallDateTime
)
Returns Decimal(10,4)
AS
--@Dato
--0: Resumen de todos los IVA
--1: IVA del Interes Corriente	(INTE)
--2: IVA del Interes Moratorio	(INPE)
--3: IVA del Cargo Mora			(MORA)
Begin
	Declare @Resultado	Decimal(10,4)
	Declare @IVA0		Decimal(10,4)
	Declare @IVA1		Decimal(10,4)
	Declare @IVA2		Decimal(10,4)
	Declare @IVA3		Decimal(10,4) 
	Declare @Contador	Decimal(10,4) 
	
	Set @IVA0		= 0
	Set @IVA1		= 0
	Set @IVA2		= 0
	Set @IVA3		= 0
	Set @Contador	= 0
	
	If @Dato In(0, 1)
	Begin
		Select @IVA0 = Round((AVG(P) + Sum(P)/Count(*)) / 2, 3) from (
		SELECT     Interes.Devengado AS Base, Iva.Devengado AS Calculo, Iva.Devengado / CASE Interes.Devengado WHEN 0 THEN 1 ELSE Interes.Devengado END AS P, 
							  Interes.SecCuota
		FROM         (SELECT     SecCuota, Devengado
							   FROM          tCsEstadoCuentaCronograma
							   WHERE      (CodConcepto IN ('INTE')) And CodPrestamo = @CodPrestamo And Corte = @Corte) AS Interes INNER JOIN
								  (SELECT     SecCuota, Devengado
									FROM          tCsEstadoCuentaCronograma AS Resumen_1
									WHERE      (CodConcepto IN ('IVAIT')) And CodPrestamo = @CodPrestamo And Corte = @Corte) AS Iva ON Interes.SecCuota = Iva.SecCuota
		WHERE     (Interes.Devengado > 0) And Iva.Devengado > 0) Datos  
		Set @IVA1 = @IVA0
	End
	If @Dato In(0, 2)
	Begin
		Select @IVA0 = Round((AVG(P) + Sum(P)/Count(*)) / 2, 3) from (
		SELECT     Interes.Devengado AS Base, Iva.Devengado AS Calculo, Iva.Devengado / CASE Interes.Devengado WHEN 0 THEN 1 ELSE Interes.Devengado END AS P, 
							  Interes.SecCuota
		FROM         (SELECT     SecCuota, Devengado
							   FROM          tCsEstadoCuentaCronograma
							   WHERE      (CodConcepto IN ('INPE')) And CodPrestamo = @CodPrestamo And Corte = @Corte) AS Interes INNER JOIN
								  (SELECT     SecCuota, Devengado
									FROM          tCsEstadoCuentaCronograma AS Resumen_1
									WHERE      (CodConcepto IN ('IVAMO')) And CodPrestamo = @CodPrestamo And Corte = @Corte) AS Iva ON Interes.SecCuota = Iva.SecCuota
		WHERE     (Interes.Devengado > 0) And Iva.Devengado > 0) Datos  
		Set @IVA2 = @IVA0
	End
	If @Dato In(0, 3)
	Begin
		Select @IVA0 = Round((AVG(P) + Sum(P)/Count(*)) / 2, 3) from (
		SELECT     Interes.Devengado AS Base, Iva.Devengado AS Calculo, Iva.Devengado / CASE Interes.Devengado WHEN 0 THEN 1 ELSE Interes.Devengado END AS P, 
							  Interes.SecCuota
		FROM         (SELECT     SecCuota, Devengado
							   FROM          tCsEstadoCuentaCronograma
							   WHERE      (CodConcepto IN ('MORA')) And CodPrestamo = @CodPrestamo And Corte = @Corte) AS Interes INNER JOIN
								  (SELECT     SecCuota, Devengado
									FROM          tCsEstadoCuentaCronograma AS Resumen_1
									WHERE      (CodConcepto IN ('IVACM')) And CodPrestamo = @CodPrestamo And Corte = @Corte) AS Iva ON Interes.SecCuota = Iva.SecCuota
		WHERE     (Interes.Devengado > 0) And Iva.Devengado > 0) Datos 
		Set @IVA3 = @IVA0 
	End
	IF @Dato = 0
	Begin
		--Print @Contador 
		Set @IVA0 = 0
		If Isnull(@IVA1, 0) > 0 
		Begin
			Set @Contador = @Contador + 1
			Set @IVA0 = @IVA0 + @IVA1
		End
		If Isnull(@IVA2, 0) > 0 
		Begin
			Set @Contador = @Contador + 1
			Set @IVA0 = @IVA0 + @IVA2
		End
		If Isnull(@IVA3, 0) > 0 
		Begin
			Set @Contador = @Contador + 1
			Set @IVA0 = @IVA0 + @IVA3
		End
		If @Contador = 0 Begin Set @Contador = 1 End 
		--Print @Contador
		Set @IVA0 = @IVA0/@Contador 
	End
	Set @Resultado = @IVA0 	
Return(@Resultado)
End
GO