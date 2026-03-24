SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduNombreMes] (@PARAMETRO INT)  
RETURNS Varchar(50)
AS  
BEGIN 
	DECLARE @Mes Varchar(50)

	Set @Mes  = (Case  @PARAMETRO
			When 1 Then 'Enero'
			When 2 Then 'Febrero'
			When 3 Then 'Marzo'
			When 4 Then 'Abril'
			When 5 Then 'Mayo' 
			When 6 Then 'Junio'
			When 7	 Then 'Julio'
			When 8 Then 'Agosto'
			When 9 Then 'Septiembre'
			When 10 Then 'Octubre'
			When 11 Then 'Noviembre'
			When 12 Then 'Diciembre'
			Else 'No se define'
			end)
	
RETURN (@Mes)	
END



GO