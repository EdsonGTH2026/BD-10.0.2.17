SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[fSgCorrReportesParam](@codreporte as int)
RETURNS INT  AS  
BEGIN 

RETURN (SELECT ISNULL(MAX(CodParametro) + 1, 1) AS Ultimo FROM  tSgReportesParametros where codreporte=@codreporte)

END

GO