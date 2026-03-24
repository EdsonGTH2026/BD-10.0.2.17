SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduBSMetaRes] (@NivelIndica int,@Fecha smalldatetime,@Codigo varchar(5),@CodIndicador int,@valor decimal(16,4))
RETURNS decimal (16, 4) AS  
BEGIN 

declare @monto decimal (16, 4)

SELECT  @monto = tCsBsMetaxUEN.valorprog - @valor
FROM         tCsBsMetaxUEN 
WHERE     (tCsBsMetaxUEN.Fecha = @Fecha) AND (tCsBsMetaxUEN.iCodTipoBS = @NivelIndica) 
AND (tCsBsMetaxUEN.iCodIndicador = @CodIndicador) AND (tCsBsMetaxUEN.NCamValor = @Codigo) AND 
(tCsBsMetaxUEN.ValorMin <= @valor) AND (tCsBsMetaxUEN.ValorMax >= @valor)

return isnull(@monto,0)

END
GO