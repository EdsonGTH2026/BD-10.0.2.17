SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Print dbo.fduTablaAmortizacion('V01KAADEARNG300911124823CA00474016')

CREATE Function [dbo].[fduTablaAmortizacion]
(
	@Firma Varchar(100)
)
Returns Varchar(8000)
AS
Begin 
	Declare @NroCuotas		Int
	Declare @Izq			Int
	Declare @Der			Int 
	Declare @CIzq			Int
	Declare @CDer			Int 
	Declare @DIzq			Varchar(500)
	Declare @DDer			Varchar(500)
	Declare @Contador		Int
	Declare @Cadena			Varchar(8000)
	Declare @Blanco			Int
	Declare @EspBordes		Int
	Declare @LinAncho		Int

	Select @NroCuotas  = COUNT(*) From (
	Select tCsFirmaReporteDetalle.Dec1
	FROM         tCsFirmaElectronica INNER JOIN
						  tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
	WHERE     (tCsFirmaReporteDetalle.Grupo = 'H') AND (tCsFirmaElectronica.Firma = @Firma)
	GROUP BY tCsFirmaReporteDetalle.Dec1) Datos

	Set @Der	= @NroCuotas / 2
	Set @Izq	= @NroCuotas - @Der 

	Set @CIzq	= 1
	Set @CDer	= Case When @Izq > 1 Then @Izq + 1 Else 0 End

	Set @Blanco		= 150
	Set @EspBordes	= 6
	Set @LinAncho	= 89
	Set @Cadena = ''
	/*
	If @Der = 0
	Begin
		Set @Cadena = @Cadena + Replicate('-', 31) + CHAR(10)
		Set @Cadena = @Cadena + '|        AMORTIZACIONES       |' + CHAR(10)
	End
	If @Der > 0
	Begin
		Set @Cadena = @Cadena + Replicate('-', 61)+ CHAR(10)
		Set @Cadena = @Cadena + '|                       AMORTIZACIONES                      |'+ CHAR(10)
	End 
	*/
	If @Der = 0
	Begin
		Set @Cadena = Replicate(' ', @Blanco)  + Replicate('-', @LinAncho/2)+ CHAR(10)
		Set @Cadena = Replicate(' ', @Blanco)  +  '| Cuota          Fecha                      Monto        |'+ CHAR(10)
	End
	If @Der > 0
	Begin
		Set @Cadena = @Cadena + Replicate(' ', @Blanco)  +  Replicate('-', @LinAncho)+ CHAR(10)
		Set @Cadena = @Cadena + Replicate(' ', @Blanco)  +  '| Cuota           Fecha                      Monto        | Cuota           Fecha                      Monto        |'+ CHAR(10)
	End 

	--/*
	If @Der = 0
	Begin
		Set @Cadena = @Cadena + Replicate(' ', @Blanco)  +  Replicate('-', @LinAncho/2)+ CHAR(10) + Replicate(' ', @Blanco)
	End
	If @Der > 0
	Begin
		Set @Cadena = @Cadena + Replicate(' ', @Blanco) +  Replicate('-', @LinAncho)+ CHAR(10) + Replicate(' ', @Blanco)
	End 
	--*/
	Set @Contador = 1

	While @Contador <= @Izq
	Begin	
		
		Set @DIzq = ''
		Set @DDer = ''
		
		Select  @DIzq = dbo.fduRellena('0', Ltrim(rtrim(str(tCsFirmaReporteDetalle.Dec1,2,0))), 2, 'D') + '         ' +					
						dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'DD') + '/' +
						dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'MM') + '/' +
						dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'AAAA') 	+ '         ' +		
						dbo.fduRellena(' ', dbo.fduNumeroTexto(SUM(tCsFirmaReporteDetalle.Saldo1), 2), 9, 'D')			
						+ Replicate(' ', @EspBordes)  + '|' + Replicate(' ', @EspBordes)
		FROM            tCsFirmaElectronica INNER JOIN
									 tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
		Where Grupo = 'H'	And tCsFirmaElectronica.Firma		= @Firma 
							--And tCsFirmaReporteDetalle.Sujeto	= @Codigo 
							And tCsFirmaReporteDetalle.Dec1		= @CIzq
		Group by tCsFirmaReporteDetalle.Fecha1, tCsFirmaReporteDetalle.Dec1						
		Set @CIzq		= @CIzq + 1
							
		If 	@CDer > 0 and @CDer <= @NroCuotas
		Begin 				
			Select  @DDer =  dbo.fduRellena('0', Ltrim(rtrim(str(tCsFirmaReporteDetalle.Dec1,2,0))), 2, 'D')		+ '         ' +					
						dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'DD') + '/' +
						dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'MM') + '/' +
						dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'AAAA') 	+ '         ' +				
						dbo.fduRellena(' ', dbo.fduNumeroTexto(Sum(tCsFirmaReporteDetalle.Saldo1), 2), 9, 'D')	
						+  Replicate(' ', @EspBordes) + '|'
			FROM            tCsFirmaElectronica INNER JOIN
										 tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
			Where Grupo = 'H'	And tCsFirmaElectronica.Firma		= @Firma 
								--And tCsFirmaReporteDetalle.Sujeto	= @Codigo 
								And tCsFirmaReporteDetalle.Dec1		= @CDer	
			Group by tCsFirmaReporteDetalle.Fecha1, tCsFirmaReporteDetalle.Dec1										
			Set @CDer		= @CDer + 1	
		End 
		Else
		Begin
			Set @DDer = ''		
			If @CDer > @NroCuotas 
			Begin 
				Set @DIzq = LTRIM(RTRIM(@DIzq))
				Set @DDer = '--------------------------------------'
			End
			Set @CDer = 0
		End
		Set @Cadena = @Cadena + '|' + Replicate(' ', @EspBordes) +  @DIzq + @DDer+ CHAR(10)  + Replicate(' ', @Blanco)
		Set @Contador	= @Contador + 1				
	End

	If @Der = 0 Or @Der <> @Izq 
	Begin
		Set @Cadena =  @Cadena + Replicate('-', @LinAncho/2)+ CHAR(10)
	End
	Else If @Der > 0
	Begin
		Set @Cadena =  @Cadena + Replicate('-', @LinAncho)+ CHAR(10)
	End 
Return(@Cadena)
End	
GO