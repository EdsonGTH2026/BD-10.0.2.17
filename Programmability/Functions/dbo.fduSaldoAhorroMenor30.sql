SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduSaldoAhorroMenor30] ( @Fecha	smalldatetime)  
RETURNS decimal(16,4) AS  
BEGIN 
declare @valor decimal (16,4)
--DECLARE @Fecha	smalldatetime
--set Fecha = '20080831'
SELECT     @valor =SUM(SaldoCuenta + IntAcumulado) 
FROM         tCsAhorros
WHERE     (Fecha = @Fecha) AND (CodProducto LIKE '2%') AND (FechaVencimiento <= DATEADD([day], 30, Fecha))
return @valor 
END
GO