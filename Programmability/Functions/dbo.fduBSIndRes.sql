SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduBSIndRes] (@NivelIndica int,@Fecha smalldatetime,@Codigo varchar(5),@CodIndicador int,@valor decimal(16,4))
RETURNS varchar(20) AS  
BEGIN 

declare @color varchar(20)

SELECT  @color =   tCsBsRangos.Color
FROM         tCsBsMetaxUEN INNER JOIN
                      tCsBsRangos ON tCsBsMetaxUEN.iCodIndicador = tCsBsRangos.iCodIndicador AND tCsBsMetaxUEN.ItemColor = tCsBsRangos.ItemColor
WHERE     (tCsBsMetaxUEN.Fecha = @Fecha) AND (tCsBsMetaxUEN.iCodTipoBS = @NivelIndica) AND (tCsBsMetaxUEN.iCodIndicador = @CodIndicador) AND (tCsBsMetaxUEN.NCamValor = @Codigo) AND 
                      (tCsBsMetaxUEN.ValorMin <= @valor) AND (tCsBsMetaxUEN.ValorMax >= @valor)

return isnull(@color,'')

END

GO