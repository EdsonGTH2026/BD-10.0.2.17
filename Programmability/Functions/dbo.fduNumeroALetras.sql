SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduNumeroALetras] (@Numero Float, @CodMoneda int)  
RETURNS Varchar(500)
AS  
BEGIN 
	Declare @Resultado varchar(500)
	Declare @i  Integer
	Declare @intProceder  Integer
	Declare @intPosNumero  Integer
	Declare @intLongNumero  Integer
	Declare @strNumero  Varchar(50)
	Declare @strLetraNumero varchar(500)
	Declare @mvarNumero int
	Declare @strDecimal varchar(2)
	Declare @PasoTemporal Bit
   
	Declare @Fila  Integer
   	Declare @Columna Integer	

	Declare @intProcede Bit

	Set  @mvarNumero = Abs(@Numero)             
	Set  @strNumero = cast(cast(@mvarNumero as int) as varchar(50))      
	Set  @intLongNumero = Len(@strNumero)
	Set @intPosNumero = @intLongNumero
	Set @strLetraNumero = ''
	Set @i = 0

	While @i < @intLongNumero
		Begin
			Set @intProcede = 1
			Set @i = @i +1			
			If @intPosNumero % 3 = 1
				Begin
					If @intLongNumero > @intPosNumero
						Begin
							Set @PasoTemporal = 0
							If Substring(@strNumero, @i - 1, 2)  = '00'
								Begin
									If Upper(Right(@strLetraNumero, 7)) = 'CIENTO ' 
										Begin
											Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 6)
										             Set @strLetraNumero = @strLetraNumero + 'CIEN '
											Set @PasoTemporal = 1
										End
								End
							If Substring(@strNumero, @i - 1, 2)  = '11'
								Begin							
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 4)
								             Set @strLetraNumero = @strLetraNumero + 'ONCE '									
									Set @intProcede = 0
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '12'
								Begin							
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 4)
								             Set @strLetraNumero = @strLetraNumero + 'DOCE '									
									Set @intProcede = 0
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '13'
								Begin							
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 4)
								             Set @strLetraNumero = @strLetraNumero + 'TRECE '									
									Set @intProcede = 0
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '14'
								Begin							
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 4)
								             Set @strLetraNumero = @strLetraNumero + 'CATORCE '									
									Set @intProcede = 0
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '15'
								Begin							
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 4)
								             Set @strLetraNumero = @strLetraNumero + 'QUINCE '									
									Set @intProcede = 0
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '16'
								Begin							
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'CI'		
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '17'
								Begin							
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'CI'																		
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '18'
								Begin							
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'CI'																		
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '19'
								Begin							
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'CI'																		
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '21'
								Begin							
								             --Set @strLetraNumero = @strLetraNumero + 'Y '	
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'I'																			
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '22'
								Begin							
								             --Set @strLetraNumero = @strLetraNumero + 'Y '	
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'I'				
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '23'
								Begin							
								             --Set @strLetraNumero = @strLetraNumero + 'Y '	
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'I'				
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '24'
								Begin							
								             --Set @strLetraNumero = @strLetraNumero + 'Y '	
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'I'				
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '25'
								Begin							
								             --Set @strLetraNumero = @strLetraNumero + 'Y '	
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'I'				
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '26'
								Begin							
								             --Set @strLetraNumero = @strLetraNumero + 'Y '	
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'I'				
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '27'
								Begin							
								             --Set @strLetraNumero = @strLetraNumero + 'Y '	
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'I'				
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '28'
								Begin							
								             --Set @strLetraNumero = @strLetraNumero + 'Y '	
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'I'				
									Set @PasoTemporal = 1
								End
							If Substring(@strNumero, @i - 1, 2)  = '29'
								Begin							
								             --Set @strLetraNumero = @strLetraNumero + 'Y '	
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 1)
								             Set @strLetraNumero = @strLetraNumero + 'I'				
									Set @PasoTemporal = 1
								End
							If Cast(Substring(@strNumero, @i, 1) as Int) > 0 And Cast(Substring(@strNumero, @i - 1, 1) as Int) > 0  and  @PasoTemporal = 0
							               Begin							
								             --Set @strLetraNumero = @strLetraNumero + 'Y '	
									Set @strLetraNumero = Left(@strLetraNumero, Len(@strLetraNumero) - 0)
								             Set @strLetraNumero = @strLetraNumero + ' Y '				
									--Set @PasoTemporal = 1
								End
							
						End
				End 
			If Cast(Substring(@strNumero, @i, 1) as Int) > 0 and @intProcede = 1
				Begin
					Set @Fila = @IntPosNumero % 3	
					Set @Columna = Cast(Substring(@strNumero, @i, 1) as Int)
						
					IF @Fila = 0 AND @Columna = 1
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'CIENTO' + ' '
						End
					IF @Fila = 0 AND @Columna = 2
						Begin  
							Set @strLetraNumero = @strLetraNumero + 'DOSCIENTOS' + ' '
						End
					IF @Fila = 0 AND @Columna = 3     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'TRESCIENTOS' + ' '
						End
					IF @Fila = 0 AND @Columna = 4     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'CUATROCIENTOS' + ' '
						End
					IF @Fila = 0 AND @Columna = 5     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'QUINIENTOS' + ' '
						End
					IF @Fila = 0 AND @Columna = 6     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'SEISCIENTOS' + ' '
						End
					IF @Fila = 0 AND @Columna = 7     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'SETECIENTOS' + ' '
						End
					IF @Fila = 0 AND @Columna = 8     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'OCHOCIENTOS' + ' '
						End
					IF @Fila = 0 AND @Columna = 9     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'NOVECIENTOS' + ' '
						End
					IF @Fila = 1 AND @Columna = 1     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'UNO' + ' '
						End
					IF @Fila = 1 AND @Columna = 2     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'DOS' + ' '
						End
					IF @Fila = 1 AND @Columna = 3     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'TRES' + ' '
						End
					IF @Fila = 1 AND @Columna = 4     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'CUATRO' + ' '
						End
					IF @Fila = 1 AND @Columna = 5     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'CINCO' + ' '
						End
					IF @Fila = 1 AND @Columna = 6     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'SEIS' + ' '
						End
					IF @Fila = 1 AND @Columna = 7     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'SIETE' + ' '
						End
					IF @Fila = 1 AND @Columna = 8     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'OCHO' + ' '
						End
					IF @Fila = 1 AND @Columna = 9     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'NUEVE' + ' '
						End
					IF @Fila = 2 AND @Columna = 1     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'DIEZ' + ' '
						End
					IF @Fila = 2 AND @Columna = 2     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'VEINTE' + ' '
						End
					IF @Fila = 2 AND @Columna = 3     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'TREINTA' + ' '
						End
					IF @Fila = 2 AND @Columna = 4     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'CUARENTA' + ' '
						End
					IF @Fila = 2 AND @Columna = 5     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'CINCUENTA' + ' '
						End
					IF @Fila = 2 AND @Columna = 6     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'SESENTA' + ' '
						End
					IF @Fila = 2 AND @Columna = 7     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'SETENTA' + ' '
						End
					IF @Fila = 2 AND @Columna = 8     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'OCHENTA' + ' '
						End
					IF @Fila = 2 AND @Columna = 9     
						Begin 
							Set @strLetraNumero = @strLetraNumero + 'NOVENTA' + ' '
						End	

				End
			If @intPosNumero = 4
				Begin
					If Right(@strLetraNumero, 9) <> 'MILLONES ' And Right(@strLetraNumero, 13) <> 'MIL MILLONES ' And Right(@strLetraNumero, 9) <> 'BILLONES ' 
						Begin
						           Set @strLetraNumero = @strLetraNumero + 'MIL '
						End					
				End		
			If @intPosNumero = 7
				Begin
					If Right(@strLetraNumero, 13) <> 'MIL MILLONES ' And Right(@strLetraNumero, 9) <> 'BILLONES ' 
						Begin
						           Set @strLetraNumero = @strLetraNumero + 'MILLONES '
						End					
				End		
			If @intPosNumero = 10
				Begin
					If Right(@strLetraNumero, 9) <> 'BILLONES ' 
						Begin
						           Set @strLetraNumero = @strLetraNumero + 'MILLARDOS '
						End					
				End		
			If @intPosNumero = 13
				Begin
					Set @strLetraNumero = @strLetraNumero + 'BILLONES '					
				End		
			Set @intPosNumero = @intPosNumero - 1
		End	
		set @strDecimal =  RIGHT( STR ((@Numero) , 13, 2), 2)
		If @strLetraNumero = ''
			Begin
				Set @strLetraNumero = 'CERO '	
			End
		if @CodMoneda=1
		Begin
			Set @strLetraNumero = @strLetraNumero + 'Y ' + @strDecimal + '/100 NUEVOS SOLES'
		End
		if @CodMoneda=2 
		Begin
			Set @strLetraNumero = @strLetraNumero + 'Y ' + @strDecimal + '/100 DOLARES AMERICANOS'
		End
		if @CodMoneda=6 
		Begin
			Set @strLetraNumero = @strLetraNumero + 'PESOS ' + @strDecimal + '/100 M.N.'
		End
		Set @Resultado = @strLetraNumero
RETURN (@Resultado)	
END





















GO