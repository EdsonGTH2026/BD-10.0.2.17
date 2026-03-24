SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACASolicitudesRegDatos] @fecha smalldatetime, @codoficina varchar(3)
as
	select * from tCsASolicitudesRegistradas

GO