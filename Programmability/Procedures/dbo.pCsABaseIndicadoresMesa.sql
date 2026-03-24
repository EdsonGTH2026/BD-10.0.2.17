SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsABaseIndicadoresMesa
CREATE procedure [dbo].[pCsABaseIndicadoresMesa] @fecha smalldatetime
as

truncate table tCsABaseIndicadoresMesa

exec [10.0.2.14].finmas.dbo.pCsABaseIndicadoresMesa @fecha--'20160710'

insert into tCsABaseIndicadoresMesa
select * from [10.0.2.14].finmas.dbo.tCsABaseIndicadoresMesa
GO