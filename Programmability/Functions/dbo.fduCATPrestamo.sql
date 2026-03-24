SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Function [dbo].[fduCATPrestamo]
(
	@Dato		Int,			
	@Desembolso	Decimal(18,6),
	@Plazo		Int,
	@Tasa		Decimal(10,6),
	@ComInicial	Decimal(18,6)
)
Returns Decimal(18,6)
AS
--@Dato
--1: @Cuota Igual sin IVA.
--2: TIR Tasa Interna de Retorno.
--3: CAT Costo Anual Total.
--4: GAT Gasto Total Anual.

--Set @Desembolso	= 20000
--Set @Tasa			= 3.67
--Set @Plazo		= 12
--Set @ComInicial	= 400
Begin
	Declare @Resultado		Decimal(18,6)
	Declare @PlazoI			Int
	Declare @Suma			Decimal(18,4)
	Declare @VANi			Decimal(18,4)
	Declare @VANf			Decimal(18,4)
	Declare @TIR			Decimal(18,4)
	Declare @TirI			Decimal(18,4)
	Declare @TirF			Decimal(18,4)
	Declare @TirC			Decimal(18,4)
	Declare @Factor1		Decimal(18,4)
	Declare @Factor2		Decimal(18,4)
	Declare @Cuota			Decimal(18,4)
	Declare @CAT			Decimal(18,4)
	Declare @V1				Decimal(18,4)
	Declare @V2				Decimal(18,4)

	Set @Tasa				= @Tasa/100.000000
	If @Dato In (1,2,3)
	Begin 
		Set @Factor1		= @Desembolso * @Tasa
		Set @Factor2		= @Factor1/(Power(1 + @Tasa, @Plazo) - 1)
		
		--Select @Factor1
		--Select @Factor2
		
		
		Set @Cuota			= @Factor2 + @Factor1

		Set @Desembolso		= @Desembolso - @ComInicial

		Set		@TirC		= 50

		Set		@PlazoI		= 1
		Set		@Suma		= 0
		Set		@TirI		= @TirC
		Set		@TirF		= @TirI - 100

		Set @V2 = 0
		While ABS(Round(@Suma - @Desembolso,2)) > 1 and @V2 < 10
		Begin
			--Print ABS(Round(@Suma - @Desembolso,2))
			
			IF @V1 = ABS(Round(@Suma - @Desembolso,2)) 
			Begin
				Set @V2 = @V2 + 1
			End
			Else
			Begin
				Set @V2 = 0
			End
			Set @V1	= ABS(Round(@Suma - @Desembolso,2))
			Set		@PlazoI = 1
			Set		@Suma	= 0
			While @PlazoI	<= @Plazo
			Begin
				
				Set @Suma	= @Suma		+ (@Cuota/CAse When Round(Power((1+@TirI/100),@PlazoI), 2) = 0 Then 0.1 Else Power((1+@TirI/100),@PlazoI)  End) 
				--Select @PlazoI as Plazo, @Suma as Suma, @TIR as TIR
				Set @PlazoI = @PlazoI	+ 1
			End
			Set @VANi = Round(@Suma - @Desembolso,2)
			Set		@PlazoI = 1
			Set		@Suma	= 0
			While @PlazoI	<= @Plazo
			Begin
				Set @Suma	= @Suma		+ (@Cuota/CAse When round(Power((1+@TirF/100),@PlazoI),2) = 0 Then 0.1 Else Power((1+@TirF/100),@PlazoI) End) 
				--Select @PlazoI as Plazo, @Suma as Suma, @TIR as TIR
				Set @PlazoI = @PlazoI	+ 1
			End
			Set @VANf = Round(@Suma - @Desembolso,2)
			/*Select	@TirI as TIRI,
					@VANi as VANI,
					@TirF as TIRF,
					@VANf as VANF
			*/		
			If ABS(@VANi) < ABS(@VANf)
			Begin
				Set @TIR	= @TirI 
				Set @TirF	= (@TirI + @TirF)/2.0000 
			End
			If ABS(@VANi) > ABS(@VANf)
			Begin
				Set @TIR	= @TirF
				Set @TirI = (@TirI + @TirF)/2.0000 
				If @VANi < 0 And @VANf < 0
				Begin
					Set @TirF = @TirF - 1 
				End
			End
		End
		Set @Cuota	= Round(@Cuota,2)
		Set @TIR	= Round(@TIR,2)
		Set @CAT	= Round((Power((1+@TIR/100.0000),12)-1) * 100.00,2)

		--Select @Cuota as Cuota, @TIR as TIR , @CAT as CAT

		/*
		Declare @Producto Varchar(3)

		Set @Producto = '123'

		SELECT     MAX(tCsCartera.NroCuotas/tCaClModalidadPlazo.FactorMensual) as CuotasMaximas,
		AVG(MontoDesembolso) As MontoPromedio, 
		(SUM(TasaIntCorriente*SaldoCapital)/SUM(SaldoCapital)/1200) as Tasa,
		(AVG(MontoDesembolso) *  (SUM(TasaIntCorriente*SaldoCapital)/SUM(SaldoCapital)/1200)) /(
		Power((1 + (SUM(TasaIntCorriente*SaldoCapital)/SUM(SaldoCapital)/1200)),MAX(tCsCartera.NroCuotas/tCaClModalidadPlazo.FactorMensual)) - 1) +
		(AVG(MontoDesembolso) *  (SUM(TasaIntCorriente*SaldoCapital)/SUM(SaldoCapital)/1200)) as Pago
		FROM         tCsCartera INNER JOIN
							  tCaClModalidadPlazo ON tCsCartera.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo
		WHERE     (tCsCartera.Fecha IN
								  (SELECT     FechaConsolidacion - 1 AS Expr1
									FROM          vCsFechaConsolidacion)) AND (tCsCartera.CodProducto = @Producto) AND (tCsCartera.Cartera = 'ACTIVA')
		       
		*/
		If @Dato = 1 Begin Set @Resultado = @Cuota	End
		If @Dato = 2 Begin Set @Resultado = @TIR	End
		If @Dato = 3 Begin Set @Resultado = @CAT	End
	End
	If @Dato = 4
	Begin
	
		If @Plazo <= 1 Begin Set @Plazo = 30 End
		
		Set @Plazo = Round(360/Cast(@Plazo as Decimal(10,6)),0)
		
		Select	@Desembolso	=	Cast(BaseCalculo as Decimal(18,6)) From tahclGatRangos
		Where	MontoMin	<=	@Desembolso And MontoMax >= @Desembolso
		
		Set	@Resultado		=	Power((1+@Tasa/Cast(@Plazo as Decimal(10,6))),Cast(@Plazo as Decimal(10,6))) * @Desembolso 
				
		--Set @Resultado	=	((@Resultado-@ComInicial)/@Desembolso)-1		
		--Set @Resultado	=	Round(@Resultado * 100.0000, 2)
		Set @Resultado		=	round(((@Resultado-@ComInicial - @Desembolso)*100.000000)/(@Desembolso),2)
		
	End
Return(@Resultado)
--return 99
--Return(@Factor1)
--Return(@Tasa)
--Return(@Resultado)
End
GO