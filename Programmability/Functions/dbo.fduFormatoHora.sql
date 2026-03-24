SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduFormatoHora] (@TiempoEstimado float)  
RETURNS Varchar(50)
AS  
BEGIN 
	--@TiempoEstimado Esta en segundo

	Declare @Tiempo		Varchar(50)
	Declare @Hora		Int
	Declare @Minuto 	Int	
	Declare @Segundo 	Int
	
	Set @Hora 	= 	CAST(@TiempoEstimado / 3600 AS int) 
	Set @Minuto 	= 	Cast(((@TiempoEstimado / 3600) - CAST(@TiempoEstimado / 3600 AS int)) * 60 as Int)--CAST(@TiempoEstimado / 60 AS int) 
	Set @Segundo 	= 	CAST((@TiempoEstimado / 60 - CAST(@TiempoEstimado / 60 AS int)) * 60 AS int)

	Set @Tiempo	= 	Replicate('0', 2 - Len(ltrim(rtrim(cast(@Hora 	as Varchar (5))))))	+ cast(@Hora as Varchar (5)) + ' ' +
				Replicate('0', 2 - Len(ltrim(rtrim(cast(@Minuto 	as Varchar (5)))))) 	+ cast(@Minuto as Varchar (5)) + '''' + ' ' +
				Replicate('0', 2 - Len(ltrim(rtrim(cast(@Segundo	as Varchar (5))))))   	+ cast(@Segundo as Varchar (5)) + ''''''
	
RETURN (@Tiempo)	
END



GO