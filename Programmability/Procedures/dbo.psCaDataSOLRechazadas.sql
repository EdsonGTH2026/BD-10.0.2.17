SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[psCaDataSOLRechazadas] @fecha smalldatetime,@fechafin smalldatetime

as  
SET NOCOUNT ON  
/*
declare @fecha smalldatetime 
set @fecha='20240901'

declare @fechafin smalldatetime 
set @fechafin='20240905'
*/

EXEC [10.0.2.14].[FINMAS].[DBO].psDataSOLRechazadas  @fecha,@fechafin
GO

GRANT EXECUTE ON [dbo].[psCaDataSOLRechazadas] TO [rie_jalvarezc]
GO