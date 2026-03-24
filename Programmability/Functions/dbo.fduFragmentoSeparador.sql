SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduFragmentoSeparador] 
(
@Texto 		Varchar(8000),
@Inicio 	Varchar(10),
@Fin		Varchar(10),
@Fragmento	Int
)  
RETURNS Varchar(8000)
AS  
BEGIN 
Declare @Resultado Varchar(8000)

Declare @Impar		Bit
Declare @Veces		Int
Declare @PI			Int
Declare @PF			Int
Declare @PT			Int
Declare @TT			Int
Declare @PA			Int


Set @Impar 	= @Fragmento % 2
Set @Veces 	= @Fragmento / 2
Set @PT		= 0
Set @TT		= 1
Set @PA		= 0

If @Impar = 0 Begin Set @Veces = @Veces -  1 End

While @PT	<= @Veces
Begin
	If @PA < @PF 
	Begin
		Set @PA	= @PF
	End
	Set @PI = CharIndex(@Inicio, @Texto, @TT) 
	Set @TT = Case When @PI = 0 Then 1 Else @PI + DataLength(@Inicio) End
	Set @PF = CharIndex(@Inicio, @Texto, @TT)
	Set @TT = Case When @PF = 0 Then 1 Else @PF + DataLength(@Fin) End
	If @PA > @PI Or @PA > @PF
	Begin
		Set @PI = Datalength(@Texto) + 1
		Break
	End
	Set @PT = @PT + 1	
	--Print @PA
	--Print @PI
	--Print @PF
	--Print '**********'
End

If @Impar = 1
Begin
	If @PI = 0 And @PF = 0 
	Begin
		If @Veces = 0
		Begin
			Set @Resultado = @Texto 
		End
		Else
		Begin
			Set @Resultado = ''
		End		
	End
	Else
	Begin
		If @Veces = 0
		Begin
			Set @PF = @PI
			Set @PI = 1			
		End
		Else
		Begin	
			--Print @PT
			--Print @Veces
			If @PT >= @Veces 
			Begin
				Set @PF = @PI
				Set @PI = @PA + DataLength(@Fin)		
			End
			Else
			Begin
				Set @PF = 1
				Set @PI = 1	
			End
		End
		--Print '----------'
		--Print @PI
		--Print @PF
		Set @Resultado = Substring(@Texto, @PI, @PF - @PI)
	End
End
If @Impar = 0
Begin
	If @PI = 0 And @PF = 0 
	Begin
		If @Veces = 0
		Begin
			Set @Resultado = ''
		End		
	End
	Else
	Begin		
		--Print @PT
		--Print @Veces
		Set @PI = @PI + DataLength(@Inicio)
		If @PT <= @Veces 
		Begin
			Set @PF = 1
			Set @PI = 1		
		End
		--Print @PI
		--Print @PF
		Set @Resultado = Substring(@Texto, @PI, @PF - @PI)
	End
End

RETURN (@Resultado)	
END






GO