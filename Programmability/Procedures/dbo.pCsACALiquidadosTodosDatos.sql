SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACALiquidadosTodosDatos] @fecha smalldatetime,@codoficina varchar(2)
as
	select * from tCsACALiqui
GO