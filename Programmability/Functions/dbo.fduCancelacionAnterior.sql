SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduCancelacionAnterior] (@CodUsuario Varchar(25), @Desembolso SmallDateTime)
RETURNS SmallDateTime
 AS  
BEGIN 
Return (SELECT    Max(Cancelacion)
FROM         tCsPadronCarteraDet
WHERE     (CodUsuario = @CodUsuario) AND Cancelacion <= @Desembolso) 
END

GO