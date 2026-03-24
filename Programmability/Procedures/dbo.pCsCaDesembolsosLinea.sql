SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE  [dbo].[pCsCaDesembolsosLinea] 
@Fecha SmalldateTime
AS
Exec  [BD-FINAMIGO-DC].finmas.dbo.pCsCaDesembolsosLinea @Fecha
GO