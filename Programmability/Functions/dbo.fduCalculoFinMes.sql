SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduCalculoFinMes] (@Fecha SmallDateTime)  
RETURNS Int
AS  
BEGIN 
	Declare @EsfinMes 	Int
	Declare @Dia		Int
	Declare @Mes		Int
	Declare @Año		Int
	Declare @strDia		Varchar(2)
	Declare @strMes	Varchar(2)
	Declare @strAño	Varchar(4)
	Declare @FechaNueva  SmallDateTime	

	Set @Mes = Month(@Fecha)
	Set @Año = Year(@Fecha)
	
	If @Mes = 12
		Begin
			Set @Mes = 1
			Set @Año = @Año + 1 
		End
	Else
		Begin
			Set @Mes = @Mes + 1
		End
	Set @Dia = 1
	
	Set @strDia	= 	Replicate('0', 2 - Len(Cast(@Dia  as varchar(2)))) + cast(@Dia   as Varchar(2))
	Set @strMes	= 	Replicate('0', 2 - Len(Cast(@Mes as varchar(2)))) + cast(@Mes as Varchar(2))
	Set @strAño	= 	Replicate('0', 4 - Len(Cast(@Año as varchar(4)))) + cast(@Año  as Varchar(4))
	
	Set @FechaNueva = convert(datetime, (@strAño + @strMes + @strDia))			

	Set @FechaNueva = DATEADD ( d , -1, @FechaNueva ) 
	Set @EsFinMes = 0
	if @FechaNueva = @Fecha
		Begin
			Set @EsFinMes = 1			
		End
	Else	
		Begin
			Set @EsFinMes = 0
		End
	
	Set @FechaNueva = DATEADD ( d , -1, @FechaNueva ) 
	
	if @FechaNueva = @Fecha 
		Begin
			Set @EsFinMes = 2
		End


RETURN (@EsFinMes)	
END



GO