SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[psCaDataSOLAceptadas] @fecha smalldatetime,@fechafin smalldatetime

as  
SET NOCOUNT ON  
/*
declare @fecha smalldatetime 
set @fecha='20240901'

declare @fechafin smalldatetime 
set @fechafin='20240905'
*/

EXEC [10.0.2.14].[FINMAS].[DBO].psDataSOLAceptadas  @fecha,@fechafin
GO

GRANT EXECUTE ON [dbo].[psCaDataSOLAceptadas] TO [rie_jalvarezc]
GO