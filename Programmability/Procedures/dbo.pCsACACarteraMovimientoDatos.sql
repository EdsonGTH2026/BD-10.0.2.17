SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACACarteraMovimientoDatos] @fecha smalldatetime, @codoficina varchar(10)
as
set nocount on
	select * from tCsACarteraMovimiento with(nolock)
GO