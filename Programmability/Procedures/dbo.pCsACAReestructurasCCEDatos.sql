SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACAReestructurasCCEDatos] @fecha smalldatetime, @codoficina varchar(5)
as
	select * from tCsACAReestructurasCCE with(nolock)
GO