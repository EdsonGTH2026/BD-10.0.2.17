SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[fSgCorrLog](@Tabla varchar(20))
RETURNS NUMERIC(18) AS  
BEGIN 

declare @numlog numeric(18)

if (@tabla='1')
	begin
	SELECT  @numlog = ISNULL(MAX([Log]), 0) + 1  FROM tSgLogAccesos
	end
else
	begin
	SELECT  @numlog = ISNULL(MAX([Log]), 0) + 1  FROM tSgLogTrans
	end

RETURN (@numlog)

END



GO