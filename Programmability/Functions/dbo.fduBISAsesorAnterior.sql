SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduBISAsesorAnterior] (@CodPrestamo Varchar(25), @Ingreso SmallDateTime)  
RETURNS Varchar(20)
AS  
BEGIN 	
	
RETURN (SELECT  Top 1   AsesorActual
	FROM         tCsDetalleBIS
	WHERE     (CodPrestamo = @CodPrestamo) AND (Salida IN
	                          (SELECT     MAX(Salida) AS Salida
	                            FROM          tCsDetalleBIS
	                            WHERE      (CodPrestamo = @CodPrestamo) AND Salida < @Ingreso)))	
END









GO