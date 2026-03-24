SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsARenovaAnticipaPreCal_t]
as 
	truncate table tCsARenovaAnticipaPreCal

	insert into tCsARenovaAnticipaPreCal
	select *
	from [10.0.2.14].finmas.dbo.tCsARenovaAnticipaPreCal
GO