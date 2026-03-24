SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[fduAPIDA] (@Fecha SmallDateTime, @Cliente Varchar(15), @Atraso Float)  
RETURNS Float
AS  
BEGIN 
	Declare @Resultado Float

	SELECT     @Resultado = SUM(Porcentaje) 
	FROM         tCsDiasAtraso
	WHERE     (CodUsuario = @Cliente) AND (Fecha = @Fecha) AND (DiasAtraso >= @Atraso)
	
	
RETURN (@Resultado)	
END


GO