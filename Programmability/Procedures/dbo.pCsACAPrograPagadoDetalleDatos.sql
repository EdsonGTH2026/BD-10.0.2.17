SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACAPrograPagadoDetalleDatos]  @fecha smalldatetime, @codoficina varchar(1000)
as
	select * from tCsACaPrograPagadoDetalle	
GO