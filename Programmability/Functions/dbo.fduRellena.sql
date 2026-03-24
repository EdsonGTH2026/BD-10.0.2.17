SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduRellena] 
(
@Caracter 	Varchar(1),
@Dato		Varchar(500),
@Tamaño		Int,
@Alinear	 Varchar(1)
)  
RETURNS Varchar(1000) AS  
BEGIN 
	Declare @Resultado Varchar(1000)
	
	If @Tamaño - Len(@Dato) < 0
	Begin
		Set @tamaño = Len(@Dato)
	End
	
	If @Alinear = 'I'
	Begin
		Select @Resultado =  @Dato + Replicate(@Caracter, @Tamaño - Len(@Dato)) 
	End		
	If @Alinear = 'D'
	Begin
		Select @Resultado =  Replicate(@Caracter, @Tamaño - Len(@Dato)) + @Dato
	End
	
Return(@Resultado)
END









GO