SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduPrestBanOtrosOrgMenor30] ( @Fecha	smalldatetime)  
RETURNS decimal(16,4) AS  
BEGIN 
declare @valor decimal (16,4)
--DECLARE @Fecha	smalldatetime
--set @Fecha = '20080831'
	SELECT  @valor = Sum(a.Capital)
	FROM         tCsCaOtrosOrganismosCuotas AS a INNER JOIN
						  tCsCaOtrosOrganismos AS b ON a.CodPrestamo = b.CodPrestamo AND a.Tipo = b.Tipo
	WHERE     (a.Fecha > @Fecha) AND (a.Fecha <= DATEADD(day, 30, @Fecha)) AND (b.PlanPagosFijo = 1)
return @valor 
END
GO