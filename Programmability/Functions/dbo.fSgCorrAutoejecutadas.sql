SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fSgCorrAutoejecutadas] ()  
RETURNS int AS  
BEGIN 
	return (SELECT ISNULL(MAX(IdAutoEjecutada), 0) + 1 FROM tSgAutoEjecutadas)
END
GO