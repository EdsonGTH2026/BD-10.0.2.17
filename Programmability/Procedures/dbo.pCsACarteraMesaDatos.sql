SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACarteraMesaDatos] @fecha smalldatetime, @codoficina varchar(200)
as
	select * from tCsRptCAMesa
GO