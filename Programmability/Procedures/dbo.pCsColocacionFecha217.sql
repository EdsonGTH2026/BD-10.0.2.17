SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsColocacionFecha217]  @fecini smalldatetime,@fecfin smalldatetime    
as  
set nocount on  

--declare @fecfin smalldatetime
--declare @fecini smalldatetime

--set @fecini='20240501'
--set @fecfin='20240526'


EXEC [10.0.2.14].[finmas].dbo.pCsColocacionFecha @fecini,@fecfin  
GO

GRANT EXECUTE ON [dbo].[pCsColocacionFecha217] TO [mchavezs2]
GO

GRANT EXECUTE ON [dbo].[pCsColocacionFecha217] TO [rie_jalvarezc]
GO