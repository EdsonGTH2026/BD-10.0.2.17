SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		Christofer Urbizagastegui Montoya
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pCaResultadoDiaMail]
AS
BEGIN
    exec master..xp_cmdshell 'C:\SATfsc\EjeReports.bat', NO_OUTPUT
END
GO