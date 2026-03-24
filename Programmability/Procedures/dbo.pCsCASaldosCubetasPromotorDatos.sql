SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCASaldosCubetasPromotorDatos] @fecha smalldatetime,@codoficina varchar(4)
as
	select * from tCsACaSaldosCubPromotor
GO