SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduPrimerDia] (@Periodo Varchar(6))  
RETURNS SmallDateTime	
AS  
BEGIN 	
	Declare @FechaNueva  SmallDateTime	
	Declare @strDia	 varchar(2)
	Declare @strMes	varchar(2)
	Declare @strAño	varchar(4)
	Declare @Dia int
	Declare @Mes Int
	declare @Año int	

	Set @Mes = cast(  substring(@Periodo, 5, 2)   as int)
	Set @Año = cast(  substring(@Periodo, 1, 4)   as int)
	

	Set @Dia = 1
	
	Set @strDia	= 	Replicate('0', 2 - Len(Cast(@Dia  as varchar(2)))) + cast(@Dia   as Varchar(2))
	Set @strMes	= 	Replicate('0', 2 - Len(Cast(@Mes as varchar(2)))) + cast(@Mes as Varchar(2))
	Set @strAño	= 	Replicate('0', 4 - Len(Cast(@Año as varchar(4)))) + cast(@Año  as Varchar(4))
	
	Set @FechaNueva = convert(datetime, (@strAño + @strMes  + @strDia))			


RETURN (@FechaNueva)	
END



GO