SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsABitacoraDatos] @fecha smalldatetime,@codoficina varchar(4)
as
	select * from tCsABitacoraCobranza
GO