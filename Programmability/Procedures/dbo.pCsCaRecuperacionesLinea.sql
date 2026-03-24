SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsCaRecuperacionesLinea] 
@Fecha SmalldateTime
AS
Exec  [BD-FINAMIGO-DC].finmas.dbo.pCsCaRecuperacionesLinea @Fecha
GO