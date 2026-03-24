SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduInteresDevengado] (@Corte SmallDateTime, @CodPrestamo Varchar(25), @CodUsuario Varchar(15), @Interes Decimal(19,4))  
RETURNS Decimal(19,4)
AS  
BEGIN 	
RETURN (SELECT     @Interes - SaldoINTE 
FROM         tCsCartera01BK20080124
WHERE     (Fecha = @Corte - 1) AND (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario))
END
GO