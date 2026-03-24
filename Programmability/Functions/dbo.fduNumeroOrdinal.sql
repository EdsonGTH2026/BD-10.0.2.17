SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduNumeroOrdinal] (@Numero Int)  
RETURNS Varchar(100)
AS  
BEGIN 
	Declare @VNumero	Varchar(2)
	Declare @TempI		Int
	Declare @Resultado 	Varchar(100)
	
	Set @VNumero 	= Rtrim(Ltrim(STR(@Numero, 10,0)))
	Set @Resultado 	= ''
	While Len(@VNumero) > 0
	Begin
		If Len(@VNumero) = 1
		Begin
			Set @Resultado = @Resultado + ' ' +
			Case @VNumero
				When '0' Then ''
				When '1' Then 'Primera'
				When '2' Then 'Segunda'
				When '3' Then 'Tercera'
				When '4' Then 'Cuarta'  
				When '5' Then 'Quinta' 
				When '6' Then 'Sexta'    
				When '7' Then 'Séptima'
				When '8' Then 'Octava'  
				When '9' Then 'Novena'							
			End 
			Set @VNumero = ''
		End
		If Len(@VNumero) = 2
		Begin
			Set @Resultado = 
			Case Substring(@VNumero, 1, 1)
				When '0' Then ''
				When '1' Then 'Décima'
				When '2' Then 'Vigésima'
				When '3' Then 'Trigésima'
				When '4' Then 'Cuadragésima'  
				When '5' Then 'Quincuagésima' 
				When '6' Then 'Sexagésima'    
				When '7' Then 'Septuagésima'
				When '8' Then 'Octogésima'  
				When '9' Then 'Nonagésima'
			End 
			Set @VNumero = Ltrim(Rtrim(SubString(@VNumero, 2, 1000)))
		End	 
	End	
	Set @Resultado = Ltrim(Rtrim(@Resultado))
RETURN (@Resultado)		
END






GO