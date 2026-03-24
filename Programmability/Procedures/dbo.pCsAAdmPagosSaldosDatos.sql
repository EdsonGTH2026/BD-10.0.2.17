SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAAdmPagosSaldosDatos] @fecha smalldatetime, @codoficina varchar(5)
as
	select * from tCsASaldosEstima where fecha=@fecha
GO