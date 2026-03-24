SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACAPagosDiaDatos] @fecha smalldatetime, @codoficina varchar(5)
as
	select * from tCsACAPagos with(nolock)
GO