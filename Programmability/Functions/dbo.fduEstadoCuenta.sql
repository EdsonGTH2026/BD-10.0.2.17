SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*

Update tCsPadronCarteraDet
Set EstadoCuenta = dbo.fduEstadoCuenta(1, CodPrestamo)
Where EstadoCuenta is null

*/

CREATE Function [dbo].[fduEstadoCuenta]
(
	@Dato			Int,			
	@CodPrestamo	Varchar(25)
)
Returns Decimal(10,4)
AS
Begin
	Declare @Resultado Decimal(10,4)
	SELECT     @Resultado = EstadoCuenta
	FROM         (SELECT     CodPrestamo, F, Dias, D, CASE WHEN D > 27 OR
												  D = 0 THEN 1 ELSE D END AS EstadoCuenta
						   FROM          (SELECT     CodPrestamo, AVG(DAY(FechaVencimiento)) AS F, AVG(DATEDIFF(day, FechaInicio, FechaVencimiento)) / 2 + 1 AS Dias, 
																		  CASE WHEN AVG(DAY(FechaVencimiento)) - AVG(DATEDIFF(day, FechaInicio, FechaVencimiento)) 
																		  / 2 + 1 < 0 THEN 31 + AVG(DAY(FechaVencimiento)) - AVG(DATEDIFF(day, FechaInicio, FechaVencimiento)) 
																		  / 2 + 1 ELSE AVG(DAY(FechaVencimiento)) - AVG(DATEDIFF(day, FechaInicio, FechaVencimiento)) / 2 + 1 END AS D
												   FROM          (SELECT DISTINCT 
																								  tCsPadronCarteraDet.CodPrestamo, tCsPadronPlanCuotas.SecCuota, tCsPadronPlanCuotas.FechaInicio, 
																								  tCsPadronPlanCuotas.FechaVencimiento
																		   FROM          tCsPadronCarteraDet INNER JOIN
																								  tCsPadronPlanCuotas ON tCsPadronCarteraDet.CodPrestamo = tCsPadronPlanCuotas.CodPrestamo
																		   WHERE      (tCsPadronCarteraDet.CodPrestamo = @CodPrestamo)) AS Datos
												   GROUP BY CodPrestamo) AS Datos) AS Datos

Return(@Resultado)
End              
GO