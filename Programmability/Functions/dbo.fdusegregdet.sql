SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fdusegregdet] (@idarea int, @nroreporte int)
RETURNS int
AS
BEGIN

return (SELECT isnull(max(Itera),0) + 1
FROM tSgRegAtencionDet
where nroreporte=@nroreporte and idarea=@idarea)

END

GO