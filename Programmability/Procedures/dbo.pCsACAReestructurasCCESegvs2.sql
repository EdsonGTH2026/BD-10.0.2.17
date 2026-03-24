SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACAReestructurasCCESegvs2]
as 
declare @fecini smalldatetime
declare @fecfin smalldatetime
--set @fecini='20200501'
--set @fecfin='20200520'

truncate table tCsACAReestructurasCCESegVs2

insert into [tCsACAReestructurasCCESegVs2]
exec [10.0.2.14].finmas.dbo.pCsACAReestructurasCCESegVs2
GO