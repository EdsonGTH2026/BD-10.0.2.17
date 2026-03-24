SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduIndiceKRiesgoCredito] (@Indice varchar(10),@FechaFin smalldatetime)  
RETURNS decimal(10,2) AS  
BEGIN 
return (SELECT     Saldo
FROM         tCsPrRegulatorios
WHERE     (Reporte = 'R21A2111') AND (Identificador = @Indice) AND (Fecha = @FechaFin)) 
END
GO