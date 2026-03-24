SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCASolRegPromotorDatos] @fecha smalldatetime, @codoficina varchar(3)
as
	select * from tCsASolRegPromotor
GO