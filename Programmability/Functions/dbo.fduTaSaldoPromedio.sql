SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fduTaSaldoPromedio] (@Cuenta Varchar(20), @FI SmallDateTime, @FF SmallDateTime)  
RETURNS Decimal(18,4)
AS  
BEGIN 

Declare @Fecha		SmallDateTime
Declare @Resultado	Decimal(18,4)

Select @Resultado = AVG(Monto) From (
SELECT     SUM(CAST(tTaTipoMovimientos.operacion + '1' AS Int) 
							  * tTaMovimientos.Monto) AS Monto, Fecha.Fecha
FROM         tTaMovimientos INNER JOIN
                          (Select distinct Fecha From tCsAhorros
							Where Fecha >= @FI and fecha <= @FF
							UNION
							Select distinct Fecha From tCsCartera
							Where Fecha >= @FI and fecha <= @FF) AS Fecha ON tTaMovimientos.fecha <= Fecha.Fecha
							LEFT OUTER JOIN
							  tTaTipoMovimientos ON tTaMovimientos.codtipomov = tTaTipoMovimientos.CodTipoMov
WHERE     (tTaMovimientos.nrotarjeta = @Cuenta)
GROUP BY Fecha.Fecha) Datos

RETURN (@Resultado)	
END
GO