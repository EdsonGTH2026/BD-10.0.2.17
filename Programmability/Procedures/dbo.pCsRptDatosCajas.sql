SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptDatosCajas] @fecha smalldatetime
as 
  execute finmas_20140820.dbo.pCsRptDatosCajas @fecha
GO