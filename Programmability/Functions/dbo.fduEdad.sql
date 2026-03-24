SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduEdad] (@Nacimiento SmallDateTime, @Corte SmallDateTime)  
RETURNS Int
AS  
BEGIN	
RETURN (CAST(DATEDIFF([Day], @Nacimiento, @Corte) / 365.25 AS Int))
END

GO