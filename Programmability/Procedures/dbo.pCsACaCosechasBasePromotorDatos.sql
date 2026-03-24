SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaCosechasBasePromotorDatos] @fecha smalldatetime, @codoficina varchar(4)
as select * from tCsACaCosechasBasePromotor with(nolock)
GO