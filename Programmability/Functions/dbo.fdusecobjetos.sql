SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fdusecobjetos] (@idarea int)
RETURNS int
AS
BEGIN

return (SELECT isnull(max(nroreporte),0) + 1 n
FROM tSgRegAtencion
where idarea=@idarea)

END
GO