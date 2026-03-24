SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsABaseIndicadoresMesaDatos] @fecha smalldatetime,@codoficina varchar(4)
as
	select * from tCsABaseIndicadoresMesa
GO