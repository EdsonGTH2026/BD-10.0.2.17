SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduValorBS] (@Fecha smalldatetime, @IndicadorAplica int ,@NombreCampo varchar(50), @ValorColumna decimal(16,2))
RETURNS varchar(50) AS  
BEGIN 

DECLARE @Valor varchar(50)

SELECT     @valor = tCsBsRangos.Color
FROM         tCsBsMetaxUEN INNER JOIN
                      tCsBsRangos ON tCsBsMetaxUEN.iCodIndicador = tCsBsRangos.iCodIndicador AND tCsBsMetaxUEN.Item = tCsBsRangos.Item INNER JOIN
                      tCsBsIndicadores ON tCsBsRangos.iCodIndicador = tCsBsIndicadores.iCodIndicador
WHERE     (tCsBsMetaxUEN.iCodTipoBS = @IndicadorAplica) AND (tCsBsIndicadores.NombreCampo = @NombreCampo) AND (tCsBsMetaxUEN.ValorMin <= @ValorColumna) AND 
                      (tCsBsMetaxUEN.ValorMax >= @ValorColumna) AND (dbo.fduFechaAPeriodo(tCsBsMetaxUEN.Fecha) = dbo.fduFechaAPeriodo(@Fecha))

return @valor
END
GO