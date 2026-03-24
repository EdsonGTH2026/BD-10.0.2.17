SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduCuentaATexto] (@Cuenta Varchar(50))  
RETURNS varchar(100)
AS  
BEGIN 	
	Declare @Resultado 	Varchar(100)
	Declare @Resultado2 	Varchar(100)
	Declare @Variable	Varchar(25)
	Declare @Comodin	Varchar(25)
	Declare @Vuelta		Int
	Declare @I		Int
	Declare @Vuelta2	Int
	Declare @I2		Int
	Declare @Punto 	Varchar(1)

	Set @Punto = ''	

	if Charindex('[', @Cuenta, 1) <> 0
		Begin
			Set @Variable	= Substring(@Cuenta, Charindex('[', @Cuenta, 1) + 1, Charindex(']', @Cuenta, 1) - Charindex('[', @Cuenta, 1)- 1) 
		End
	Set @Comodin 	=  '['+ @Variable +']'
	Set @Variable 	= Replace(@Variable, ',', '')
	Set @Cuenta 	= Replace(@Cuenta, '_', '0')
	Set @Vuelta	= Len(@Variable)
	
	If @Vuelta > 0 
		Begin
			Set @I = 1	
		End
	Else
		Begin
			Set @I = 0
		End
	Set @Resultado = ''
	Set @Resultado2 = ''
	IF @I <> 0	
	Begin
		WHILE @I <= @Vuelta
		BEGIN
			
			Set @Resultado2 = Replace(@Cuenta, @Comodin, Substring(@Variable, @I, 1))
			Set @Vuelta2 = (Len(Substring(@Resultado2, 3, 100))- 2)/2
			If @Vuelta2 > 0 
			Begin
				Set @I2 = 1	
			End
			Else
			Begin
				Set @I2 = 0
			End				
			If @I2 <> 0
			Begin
				While @I2 <= @Vuelta2
				Begin
					Set @Resultado2 = Substring(@Resultado2,1, @I2*3+1) + @Punto + Substring(@Resultado2,@I2*3+2, 25)
					Set @I2 = @I2 + 1	   							
				End		
			End
	
			Set @Resultado = @Resultado + '+' + @Resultado2
			Set @I = @I + 1	   
		END
		Set @Resultado = Substring(@Resultado, 2, 100)
	End	
	else
	Begin
		Set @Resultado = @Cuenta
		Set @Vuelta = (Len(Substring(@Resultado, 3, 100))- 2)/2
		If @Vuelta > 0 
		Begin
			Set @I = 1	
		End
		Else
		Begin
			Set @I = 0
		End				
		If @I <> 0
		Begin
			While @I <= @Vuelta
			Begin
				Set @Resultado = Substring(@Resultado,1, @I*3+1) + @Punto + Substring(@Resultado,@I*3+2, 25)
				Set @I = @I + 1	   			
			End		
		End
	End
RETURN (@Resultado)	
END



GO